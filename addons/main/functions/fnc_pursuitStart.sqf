#include "..\script_component.hpp"
/*
 * Author: Root
 * Starts a pursuit: the local AI group goes after a suspicious covered unit with a real MOVE
 * waypoint inserted in front of its own (restored afterwards). Foot groups run to it, mounted
 * groups follow the vehicle and signal it to stop for an inspection.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Target unit <OBJECT>
 * 2: Ordered by Zeus/API, skips the role, distance and group-count checks <BOOL> (default: false)
 *
 * Return Value:
 * Started <BOOL>
 *
 * Public: No
 */

params ["_grp", "_unit", ["_forced", false]];

if (isNull _grp || {!local _grp} || {!alive _unit} || {isPlayer (leader _grp)}) exitWith {false};
if (!isNil {_grp getVariable QGVAR(pursuit)}) exitWith {false};

private _leader = leader _grp;
private _aiVeh = vehicle _leader;
private _role = _grp getVariable [QGVAR(role), "patrol"];
private _why = "";

if (!_forced) then {
    _why = switch (true) do {
        case (_role != "patrol"): { format ["role is %1", _role] };
        case (_aiVeh isKindOf "StaticWeapon"): { "manning a static weapon" };
        case (_aiVeh isKindOf "Air" || {_aiVeh isKindOf "Ship"}): { "aircraft and boats do not pursue" };
        case ((([_grp, vehicle _unit] call FUNC(groupNearest)) select 1) > MSET(pursuitMaxStart)): { "too far away to start" };
        case (({(_x getVariable [QGVAR(pursuitTarget), objNull]) == _unit} count allGroups) >= MSET(pursuitMaxGroups)): { "enough groups already pursue" };
        default { "" };
    };
};
if (_why != "") exitWith {
    if (RADS_DEBUG) then { ["PURSUIT", format ["%1 does not pursue %2: %3", groupId _grp, name _unit, _why], _grp, _unit] call FUNC(debugLog); };
    false
};

private _mounted = _aiVeh != _leader
    && {alive _aiVeh}
    && {canMove _aiVeh}
    && {!isNull driver _aiVeh}
    && {group driver _aiVeh == _grp}
    && {_aiVeh isKindOf "LandVehicle"};

// Home: where the group was before it got involved. Kept for a while after a pursuit so chained
// pursuits cannot drag it ever farther away.
private _home = _grp getVariable [QGVAR(home), []];
if (_home isEqualTo [] || {time > (_grp getVariable [QGVAR(homeUntil), -1])}) then {
    _home = getPosATL _leader;
    _grp setVariable [QGVAR(home), _home];
};
_grp setVariable [QGVAR(homeUntil), 1e10];

private _pursuit = createHashMapFromArray [
    ["target", _unit],
    ["mounted", _mounted],
    ["aiVeh", [objNull, _aiVeh] select _mounted],
    ["phase", ["CHASE", "FOLLOW"] select _mounted],
    ["start", time],
    ["phaseStart", time],
    ["startPos", _home],
    ["outside", 0],
    ["savedBehaviour", behaviour _leader],
    ["savedSpeed", speedMode _grp],
    ["stopped", 0],
    ["signalStart", -1],
    ["refused", false],
    ["inspectors", []],
    ["inspectPos", []],
    ["nextMove", 0],
    ["lights", false],
    ["nextSignal", 0],
    ["signals", 0],
    ["minDist", 1e10],
    ["engaged", false],
    ["forced", _forced],
    ["clockStart", -1],
    ["freeze", -1],
    ["unfrozen", ""]
];

if (_mounted) then {
    // crew parked at a checkpoint may have been told to stay put: free them for the pursuit
    private _freed = [];
    {
        private _crewman = _x;
        {
            if !(_crewman checkAIFeature _x) then {
                _crewman enableAI _x;
                _freed pushBack [_crewman, _x];
            };
        } forEach ["PATH", "MOVE"];
    } forEach ((crew _aiVeh) select {group _x == _grp});
    _pursuit set ["freedAI", _freed];
    (units _grp) doFollow _leader;
    if (RADS_DEBUG) then { ["PURSUIT", format ["%1 mounts up in %2: driver=%3 commander=%4 engine=%5 re-enabled=%6", groupId _grp, typeOf _aiVeh, name driver _aiVeh, name effectiveCommander _aiVeh, isEngineOn _aiVeh, _freed apply {format ["%1:%2", name (_x select 0), _x select 1]}], _grp, _unit] call FUNC(debugLog); };

    // the engine may be off at a checkpoint
    if (!isEngineOn _aiVeh) then {
        if (local _aiVeh) then { _aiVeh engineOn true; } else { [QGVAR(engineOn), [_aiVeh], _aiVeh] call CBA_fnc_targetEvent; };
    };

    // Stop request: suspicion is held while they follow and signal, until refused, fled or a hostile act
    if (MSET(stopFreeze)) then {
        private _entry = ([_grp] call FUNC(getData)) getOrDefault [hashValue _unit, []];
        if (_entry isNotEqualTo [] && {(_entry select D_STATE) != ST_COMPROMISED}) then {
            // Held where it is when they set off, but never below the suspicious threshold: a low
            // follow threshold (or a pursuit ordered by Zeus) must not let them calm down mid-stop.
            private _hold = ((_entry select D_SUSP) max MSET(suspiciousThreshold)) min (MSET(identifyThreshold) - 1);
            if ((_entry select D_SUSP) != _hold) then {
                if (RADS_DEBUG) then { [_entry, format ["t=%1 STOP REQUEST suspicion %2 -> %3 (held while they follow)", CBA_missionTime toFixed 1, (_entry select D_SUSP) toFixed 1, _hold toFixed 1]] call FUNC(debugHistory); };
                _entry set [D_SUSP, _hold];
                if ((_entry select D_STATE) == ST_UNAWARE) then { [_grp, _entry, ST_SUSPICIOUS, "stop request (pursuit started)"] call FUNC(setState); };
                [_grp, true] call FUNC(publishData);
            };
            _pursuit set ["freeze", _hold];
        };
    };
};

// LAMBS danger.fsm would take over the group the moment it gets nervous
if (MSET(lambsDisableDuringPursuit) && {isClass (configFile >> "CfgPatches" >> "lambs_danger")}) then {
    _pursuit set ["lambs", _grp getVariable ["lambs_danger_disableGroupAI", false]];
    _grp setVariable ["lambs_danger_disableGroupAI", true, true];
};

_grp setVariable [QGVAR(pursuit), _pursuit];
_grp setVariable [QGVAR(pursuitTarget), _unit, true];
// Foot groups get a waypoint. Vehicles only get direct move orders for the driver (pursuitDrive):
// a waypoint on top of those gives the crew two orders to fight over.
if (_mounted) then {
    _pursuit set ["wp", []];
    // AWARE / COMBAT crews drive slowly and cautiously; SAFE with full speed keeps up on the roads.
    // A hostile act ends the pursuit and puts them in COMBAT.
    _grp setBehaviour "SAFE";
} else {
    _pursuit set ["wp", [_grp, "add", getPosATL (vehicle _unit)] call FUNC(pursuitWaypoint)];
    if (behaviour _leader in ["SAFE", "CARELESS"]) then { _grp setBehaviour "AWARE"; };
};
_grp setSpeedMode "FULL";

_pursuit set ["pfh", [FUNC(pursuitTick), 1, _grp] call CBA_fnc_addPerFrameHandler];

if (RADS_DEBUG) then { ["PURSUIT", format ["%1 starts %2 %3 (%4) forced=%5 home=%6 (%7 m away) roam limit=%8 m", groupId _grp, ["chasing on foot", "following in"] select _mounted, [name _unit, typeOf _aiVeh] select _mounted, name _unit, _forced, mapGridPosition _home, round (_leader distance2D _home), [_grp, _mounted] call FUNC(pursuitLeash)], _grp, _unit] call FUNC(debugLog); };
[QGVAR(message), [format ["RADS: %1 (%2) starts pursuing %3", groupId _grp, side _grp, name _unit]]] call CBA_fnc_globalEvent;
true
