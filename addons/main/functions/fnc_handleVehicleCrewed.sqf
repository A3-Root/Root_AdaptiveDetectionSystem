#include "..\script_component.hpp"
/*
 * Author: Root
 * GetIn/GetOut on any vehicle: remembers which AI group last crewed it, so taking it later counts
 * as a theft for that group.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Role <STRING>
 * 2: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_veh", "", "_unit"];

if (isNull _unit || {isPlayer _unit} || {!local _unit}) exitWith {};

private _side = side group _unit;
if !(_side in [west, east, independent]) exitWith {};
if (_side in (call FUNC(coveredSides))) exitWith {};

if ((_veh getVariable [QGVAR(ownerGroup), grpNull]) != group _unit) then {
    _veh setVariable [QGVAR(ownerGroup), group _unit, true];
};
