#include "..\script_component.hpp"
/*
 * Author: Root
 * The target drove off during the stop or inspection: identified on the spot, its vehicle
 * reported, and a radio bulletin goes out (always, by chance, or never - flee bulletin setting).
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
private _mode = MSET(fleeBulletin);

if (RADS_DEBUG) then { ["PURSUIT", format ["%1 FLED the stop of %2 (moved %3 m, %4 km/h) -> identified, bulletin mode %5, burn %6", name _unit, groupId _grp, round (_veh distance2D (_pursuit get "inspectPos")), round abs speed _veh, _mode, MSET(fleeBurn)], _grp, _unit] call FUNC(debugLog); };

if (MSET(fleeBurn) && _veh != _unit) then {
    [_veh, side _grp, MSET(burnDuration), MSET(bulletinRange), getPosATL _veh] call API(burnVehicle);
};
{ [QGVAR(inspected), [_grp, false], _x] call CBA_fnc_targetEvent; } forEach ((crew _veh) select {isPlayer _x});
[_grp, _unit, "fled a checkpoint stop", _mode > 0, true, _mode == 2] call FUNC(compromise);
[_grp, "target fled", true] call FUNC(pursuitEnd);
