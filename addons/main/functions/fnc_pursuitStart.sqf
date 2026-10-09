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
    ["nextHorn", 0]
];

// LAMBS danger.fsm would take over the group the moment it gets nervous
if (MSET(lambsDisableDuringPursuit) && {isClass (configFile >> "CfgPatches" >> "lambs_danger")}) then {
    _pursuit set ["lambs", _grp getVariable ["lambs_danger_disableGroupAI", false]];
    _grp setVariable ["lambs_danger_disableGroupAI", true, true];
};

_grp setVariable [QGVAR(pursuit), _pursuit];
_grp setVariable [QGVAR(pursuitTarget), _unit, true];
_pursuit set ["wp", [_grp, "add", getPosATL (vehicle _unit)] call FUNC(pursuitWaypoint)];
if (behaviour _leader in ["SAFE", "CARELESS"]) then { _grp setBehaviour "AWARE"; };
_grp setSpeedMode "FULL";

_pursuit set ["pfh", [FUNC(pursuitTick), 1, _grp] call CBA_fnc_addPerFrameHandler];

if (RADS_DEBUG) then { ["PURSUIT", format ["%1 starts %2 %3 (%4) forced=%5 home=%6 (%7 m away) roam limit=%8 m", groupId _grp, ["chasing on foot", "following in"] select _mounted, [name _unit, typeOf _aiVeh] select _mounted, name _unit, _forced, mapGridPosition _home, round (_leader distance2D _home), [_grp, _mounted] call FUNC(pursuitLeash)], _grp, _unit] call FUNC(debugLog); };
[QGVAR(message), [format ["RADS: %1 (%2) starts pursuing %3", groupId _grp, side _grp, name _unit]]] call CBA_fnc_globalEvent;
true
