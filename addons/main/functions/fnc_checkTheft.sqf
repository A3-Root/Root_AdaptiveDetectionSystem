#include "..\script_component.hpp"
/*
 * Author: Root
 * A covered unit took a vehicle last crewed by this (local) group. If the owners are close or see
 * it, the vehicle is burned for their side and they identify the thief.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Unit <OBJECT>
 * 2: Vehicle <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_unit", "_veh"];

if ((_veh getVariable [QGVAR(ownerGroup), grpNull]) != _grp) exitWith {};

private _radius = MSET(theftRadius);
private _noticed = ((units _grp) findIf {[_x] call FUNC(isObserver) && {(_x distance _veh) <= _radius}} > -1)
    || {[_grp, _unit] call FUNC(groupSees)};
if (!_noticed) exitWith {};

RLOG_2("%1 saw %2 steal their vehicle",_grp,_unit);
[_veh, side _grp, MSET(burnDuration), 0, getPosATL _veh] call API(burnVehicle);
[_grp, _unit, "theft"] call FUNC(compromise);
