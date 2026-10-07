#include "..\script_component.hpp"
/*
 * Author: Root
 * 3DEN: detection zone from the module area. A repeatable trigger removes it on deactivation.
 *
 * Arguments:
 * 0: Module logic <OBJECT>
 * 1: Synced units <ARRAY>
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic", ["_units", []], ["_activated", true]];

if (!isServer) exitWith {};

private _id = format ["rads_eden_%1", _logic call BIS_fnc_netId];
if (!_activated) exitWith { [_id] call API(removeZone); };

(_logic getVariable ["objectArea", [200, 200, 0, false, -1]]) params ["_a", "_b", "_angle", "_rect"];

[
    [getPosATL _logic, _a, _b, _angle, _rect],
    _logic getVariable ["ROOT_RADS_Z_mode", 0],
    _logic getVariable ["ROOT_RADS_Z_build", 2],
    _logic getVariable ["ROOT_RADS_Z_decay", 1],
    [_logic getVariable ["ROOT_RADS_Z_sides", ""]] call FUNC(parseSides),
    _logic getVariable ["ROOT_RADS_Z_delay", 0],
    _logic getVariable ["ROOT_RADS_Z_duration", 0],
    _logic getVariable ["ROOT_RADS_Z_hourFrom", -1],
    _logic getVariable ["ROOT_RADS_Z_hourTo", -1],
    _logic getVariable ["ROOT_RADS_Z_label", ""],
    _id
] call API(addZone);
