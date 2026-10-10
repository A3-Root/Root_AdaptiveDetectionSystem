#include "..\script_component.hpp"
/*
 * Author: Root
 * The target stopped: the pursuing group inspects it. A mounted group halts and everyone except
 * the gunners gets out; the inspectors surround the vehicle and look at the occupants, which
 * builds suspicion face to face (inspection multiplier).
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp"];

private _pursuit = _grp getVariable QGVAR(pursuit);
if (isNil "_pursuit") exitWith {};

private _unit = _pursuit get "target";
private _veh = vehicle _unit;
_pursuit set ["phase", "INSPECT"];
[_grp, "stopped for the inspection (judged face to face now)"] call FUNC(pursuitUnfreeze);
_pursuit set ["phaseStart", time];
_pursuit set ["inspectPos", getPosATL _veh];
_pursuit set ["nextMove", 0];

private _inspectors = [];
private _aiVeh = _pursuit get "aiVeh";
if (_pursuit get "mounted" && {alive _aiVeh}) then {
    // the vehicle halts where it is
    [_grp, "move", getPosATL _aiVeh] call FUNC(pursuitWaypoint);
    doStop (driver _aiVeh);

    // gunners stay on their weapons, everybody else gets out
    private _gunners = (fullCrew [_aiVeh, "gunner"]) apply {_x select 0};
    {
        _x params ["_crewman", "", "", "_turretPath", "_isPersonTurret"];
        if (!_isPersonTurret && {(_aiVeh weaponsTurret _turretPath) isNotEqualTo []}) then { _gunners pushBackUnique _crewman; };
    } forEach (fullCrew [_aiVeh, "turret"]);
    _inspectors = (crew _aiVeh) select {group _x == _grp && {!(_x in _gunners)} && {[_x] call FUNC(isAwake)}};
    _inspectors allowGetIn false;
    _inspectors orderGetIn false;
    { doGetOut _x; } forEach _inspectors;
} else {
    _inspectors = (units _grp) select {[_x] call FUNC(isAwake) && {isNull objectParent _x}};
};
_pursuit set ["inspectors", _inspectors];

if (RADS_DEBUG) then { ["PURSUIT", format ["%1 INSPECTS %2 (%3 inspectors, %4 s, flee distance %5 m)", groupId _grp, name _unit, count _inspectors, MSET(inspectTime), MSET(fleeDistance)], _grp, _unit] call FUNC(debugLog); };
[QGVAR(message), [format ["RADS: %1 inspects %2", groupId _grp, name _unit]]] call CBA_fnc_globalEvent;
{ [QGVAR(inspected), [_grp, true], _x] call CBA_fnc_targetEvent; } forEach ((crew _veh) select {isPlayer _x});
