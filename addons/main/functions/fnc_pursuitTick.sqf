#include "..\script_component.hpp"
/*
 * Author: Root
 * Pursuit state machine, once a second on the machine that owns the group.
 *  CHASE   (on foot) run at the target; it stopping close by starts an inspection.
 *  FOLLOW  (mounted) engine on, drive after it, honk and flash every few seconds once close.
 *          Suspicion is held meanwhile (stop request). Stopping starts an inspection; not stopping
 *          in time, pulling away or a hostile act ends the hold ("refused to stop" alert).
 *  INSPECT dismounted look at the occupants; driving off = fled (identified + bulletin),
 *          surviving the inspection time = cleared.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: PFH handle <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_handle"];

private _pursuit = _grp getVariable QGVAR(pursuit);
if (isNil "_pursuit" || {!local _grp} || {(units _grp) findIf {[_x] call FUNC(isAwake)} == -1}) exitWith {
    [_handle] call CBA_fnc_removePerFrameHandler;
    if (!isNull _grp && {!isNil "_pursuit"}) then { [_grp, "group lost (dead, unconscious or moved to another machine)"] call FUNC(pursuitEnd); };
};

private _unit = _pursuit get "target";
if (!alive _unit) exitWith { [_grp, "target dead"] call FUNC(pursuitEnd); };

private _entry = ([_grp] call FUNC(getData)) getOrDefault [hashValue _unit, []];
private _state = _entry param [D_STATE, ST_UNAWARE];
private _phase = _pursuit get "phase";
private _veh = vehicle _unit;
private _speed = abs speed _veh;
([_grp, _veh] call FUNC(groupNearest)) params ["_nearest", "_distance"];
private _elapsed = time - (_pursuit get "start");

if (_state == ST_COMPROMISED) exitWith { [_grp, "target identified", true] call FUNC(pursuitEnd); };
if !(_unit getVariable [QGVAR(cover), false]) exitWith { [_grp, "target lost its cover (vanilla detection takes over)"] call FUNC(pursuitEnd); };

if (_phase != "INSPECT") then {
    if (_state == ST_UNAWARE) exitWith { [_grp, "suspicion faded"] call FUNC(pursuitEnd); };
    if (_elapsed > MSET(pursuitMaxTime) || {((leader _grp) distance (_pursuit get "startPos")) > MSET(pursuitMaxDist)}) exitWith {
        if (MSET(alertOnEscape)) then { [_grp, _unit, "got away from a pursuit"] call FUNC(pursuitAlert); };
        [_grp, format ["gave up after %1 s", round _elapsed]] call FUNC(pursuitEnd);
    };
};
if (isNil {_grp getVariable QGVAR(pursuit)}) exitWith {};

// Stop request: suspicion held (shares and syncs included) until a hostile act, refusal or flight
private _freeze = _pursuit get "freeze";
if (_freeze >= 0 && {_entry isNotEqualTo []}) then {
    if ((crew _veh) findIf {(_x getVariable [QGVAR(heatUntil), -1]) > CBA_missionTime} > -1) then {
        [_grp, "hostile act (shots fired from the vehicle)"] call FUNC(pursuitUnfreeze);
    } else {
        if ((_entry select D_SUSP) > _freeze) then {
            _entry set [D_SUSP, _freeze];
            [_grp, true] call FUNC(publishData);
        };
    };
};

// aim a little ahead of where the vehicle is going
private _lead = (getPosATL _veh) vectorAdd ((velocity _veh) vectorMultiply MSET(pursuitLead));
_lead set [2, 0];

// Roam limit: never farther than this from home. Waiting at the edge, they give up and radio
// once the target stays beyond it.
if (_phase != "INSPECT") then {
    private _leash = [_grp, _pursuit get "mounted"] call FUNC(pursuitLeash);
    if (_leash > 0) then {
        private _home = _pursuit get "startPos";
        if ((_lead distance2D _home) > _leash) then {
            _lead = _home getPos [_leash, _home getDir _lead];
            _lead set [2, 0];
            _pursuit set ["outside", (_pursuit get "outside") + 1];
            if (RADS_DEBUG && {(_pursuit get "outside") == 1}) then { ["PURSUIT", format ["%1: %2 is beyond the roam limit (%3 m from home), holding at the edge", groupId _grp, name _unit, _leash], _grp, _unit] call FUNC(debugLog); };
        } else {
            _pursuit set ["outside", 0];
        };
        if ((_pursuit get "outside") > MSET(leashGiveUp)) exitWith {
            if (MSET(alertOnEscape)) then { [_grp, _unit, "left the patrol area"] call FUNC(pursuitAlert); };
            [_grp, format ["target beyond the %1 m roam limit for %2 s", _leash, round MSET(leashGiveUp)]] call FUNC(pursuitEnd);
        };
    };
};
if (isNil {_grp getVariable QGVAR(pursuit)}) exitWith {};

switch (_phase) do {
    case "CHASE": {
        [_grp, "move", _lead] call FUNC(pursuitWaypoint);
        if (_distance <= MSET(inspectRange) && _speed < 3) then {
            _pursuit set ["stopped", (_pursuit get "stopped") + 1];
        } else {
            _pursuit set ["stopped", 0];
        };
        if ((_pursuit get "stopped") >= 2) exitWith { [_grp] call FUNC(inspectStart); };
        if (_distance > MSET(footGiveUpDist)) then {
            if (MSET(alertOnEscape)) then { [_grp, _unit, "outran a foot patrol"] call FUNC(pursuitAlert); };
            [_grp, format ["target %1 m away, out of reach on foot", round _distance]] call FUNC(pursuitEnd);
        };
    };
    case "FOLLOW": {
        private _aiVeh = _pursuit get "aiVeh";
        if (!alive _aiVeh || {!canMove _aiVeh} || {isNull driver _aiVeh}) exitWith {
            _pursuit set ["mounted", false];
            _pursuit set ["phase", "CHASE"];
            if (RADS_DEBUG) then { ["PURSUIT", format ["%1 lost its vehicle, continues on foot", groupId _grp], _grp, _unit] call FUNC(debugLog); };
        };
        [_grp, "move", _lead] call FUNC(pursuitWaypoint);
        if (!isEngineOn _aiVeh) then {
            if (local _aiVeh) then { _aiVeh engineOn true; } else { [QGVAR(engineOn), [_aiVeh], _aiVeh] call CBA_fnc_targetEvent; };
        };

        // pulling away from the closest they came = fleeing the stop
        _pursuit set ["minDist", (_pursuit get "minDist") min _distance];
        private _refuse = "";
        if (_distance - (_pursuit get "minDist") > MSET(stopFleeDistance)) then {
            _refuse = format ["pulled away (%1 m, closest was %2 m)", round _distance, round (_pursuit get "minDist")];
        };

        if (_distance <= MSET(stopSignalRange)) then {
            if ((_pursuit get "signalStart") < 0) then {
                _pursuit set ["signalStart", time];
                if (RADS_DEBUG) then { ["PURSUIT", format ["%1 is behind %2 (%3 m) and signals it to stop for %4 s (suspicion held at %5)", groupId _grp, name _unit, round _distance, round MSET(stopTimeout), [(_pursuit get "freeze") toFixed 1, "no"] select ((_pursuit get "freeze") < 0)], _grp, _unit] call FUNC(debugLog); };
                [QGVAR(message), [format ["RADS: %1 signals %2 to stop", groupId _grp, name _unit]]] call CBA_fnc_globalEvent;
            };
            if (!(_pursuit get "refused")) then { [_grp, true] call FUNC(pursuitSignal); };

            if (_distance <= MSET(followDistance) && _speed < 3) then { _pursuit set ["stopped", (_pursuit get "stopped") + 1]; } else { _pursuit set ["stopped", 0]; };
            if (_refuse == "" && {(time - (_pursuit get "signalStart")) > MSET(stopTimeout)}) then {
                _refuse = format ["did not stop within %1 s", round MSET(stopTimeout)];
            };
        } else {
            [_grp, false] call FUNC(pursuitSignal);
            _pursuit set ["stopped", 0];
        };
        if ((_pursuit get "stopped") >= 3) exitWith {
            [_grp, false] call FUNC(pursuitSignal);
            [_grp] call FUNC(inspectStart);
        };

        if (_refuse != "" && {!(_pursuit get "refused")}) then {
            _pursuit set ["refused", true];
            [_grp, false] call FUNC(pursuitSignal);
            [_grp, "refused to stop: " + _refuse] call FUNC(pursuitUnfreeze);
            if (_entry isNotEqualTo []) then {
                _entry set [D_SUSP, (((_entry select D_SUSP) + MSET(refuseSuspBonus)) min (MSET(identifyThreshold) - 1))];
                [_grp, true] call FUNC(publishData);
            };
            if (RADS_DEBUG) then { ["PURSUIT", format ["%1 REFUSED TO STOP for %2: %3 -> alert, suspicion %4 and building", name _unit, groupId _grp, _refuse, (_entry param [D_SUSP, 0]) toFixed 0], _grp, _unit] call FUNC(debugLog); };
            [_grp, _unit, "refused to stop"] call FUNC(pursuitAlert);
        };
    };
    case "INSPECT": {
        private _anchor = _pursuit get "inspectPos";
        if ((_veh distance2D _anchor) > MSET(fleeDistance) || {_speed > MSET(fleeSpeed)}) exitWith { [_grp] call FUNC(pursuitFled); };

        // keep the inspectors around the vehicle and looking in
        if (time >= (_pursuit get "nextMove")) then {
            _pursuit set ["nextMove", time + 5];
            private _inspectors = (_pursuit get "inspectors") select {[_x] call FUNC(isAwake) && {isNull objectParent _x}};
            private _count = count _inspectors;
            private _radius = 4 + (((sizeOf typeOf _veh) / 2) min 6);
            {
                private _angle = (getDir _veh) + 45 + (360 / (_count max 1)) * _forEachIndex;
                _x doMove (_veh getPos [_radius, _angle]);
                _x doWatch _veh;
            } forEach _inspectors;
            private _driver = driver _veh;
            if (!isNull _driver && {_inspectors isNotEqualTo []}) then { (_inspectors select 0) lookAt _driver; };
        };

        if ((time - (_pursuit get "phaseStart")) >= MSET(inspectTime)) then { [_grp, "cleared"] call FUNC(inspectEnd); };
    };
};
