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
    // cancel the chase move order too, or the commander drives on
    private _commander = effectiveCommander _aiVeh;
    if (local _commander) then { _commander doMove (getPosATL _aiVeh); };
    doStop (driver _aiVeh);

    // Who gets out, in this order: passengers (cargo and firing-from-vehicle seats), other
    // unarmed turret crew, the commander, the driver. Gunners (armed turrets) never leave their
    // weapon. Only as many as 'Inspectors' says. Crew seats are remembered for remounting.
    private _ranked = [];
    {
        _x params ["_crewman", "_role", "_cargoIndex", "_turretPath", "_isPersonTurret"];
        if (group _crewman == _grp && {[_crewman] call FUNC(isAwake)}) then {
            private _rank = switch (toLower _role) do {
                case "cargo": { 0 };
                case "turret": { [[1, -1] select ((_aiVeh weaponsTurret _turretPath) isNotEqualTo []), 0] select _isPersonTurret };
                case "commander": { 2 };
                case "driver": { 3 };
                default { -1 };
            };
            if (_rank >= 0) then { _ranked pushBack [_rank, _crewman, toLower _role, _turretPath]; };
        };
    } forEach (fullCrew _aiVeh);
    _ranked sort true;
    private _picked = _ranked select [0, (round MSET(inspectDismount)) max 1];
    _inspectors = _picked apply {_x select 1};
    // crew (not passengers) remount first if it comes to a fight
    _pursuit set ["crewSeats", (_picked select {(_x select 0) >= 1}) apply {[_x select 1, _x select 2, _x select 3]}];
    _inspectors allowGetIn false;
    _inspectors orderGetIn false;
    { doGetOut _x; } forEach _inspectors;
    if (RADS_DEBUG) then { ["PURSUIT", format ["%1 dismounts %2 of %3 candidates: %4 (gunners stay)", groupId _grp, count _inspectors, count _ranked, _picked apply {format ["%1 (%2)", name (_x select 1), _x select 2]}], _grp, _unit] call FUNC(debugLog); };
} else {
    _inspectors = (units _grp) select {[_x] call FUNC(isAwake) && {isNull objectParent _x}};
};
_pursuit set ["inspectors", _inspectors];

if (RADS_DEBUG) then { ["PURSUIT", format ["%1 INSPECTS %2 (%3 inspectors, %4 s, flee distance %5 m)", groupId _grp, name _unit, count _inspectors, MSET(inspectTime), MSET(fleeDistance)], _grp, _unit] call FUNC(debugLog); };
[QGVAR(message), [format ["RADS: %1 inspects %2", groupId _grp, name _unit]]] call CBA_fnc_globalEvent;
{ [QGVAR(inspected), [_grp, true], _x] call CBA_fnc_targetEvent; } forEach ((crew _veh) select {isPlayer _x});
