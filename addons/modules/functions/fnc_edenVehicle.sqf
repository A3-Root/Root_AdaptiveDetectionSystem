#include "..\script_component.hpp"
/*
 * Author: Root
 * 3DEN: disguise mode / burned status for synced vehicles. A repeatable trigger reverts on deactivation.
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

private _vehicles = [];
{
    private _veh = vehicle _x;
    if (!(_veh isKindOf "CAManBase") && {!(_veh isKindOf "Logic")} && {!(_veh isKindOf "EmptyDetector")}) then { _vehicles pushBackUnique _veh; };
} forEach (synchronizedObjects _logic);

if (!_activated) exitWith {
    { [_x, "auto"] call API(setVehicleMode); [_x, [], false] call API(clearBulletins); } forEach _vehicles;
};

private _mode = _logic getVariable ["ROOT_ADS_V_mode", "disguise"];
private _sides = [_logic getVariable ["ROOT_ADS_V_burnSides", ""]] call FUNC(parseSides);
private _duration = _logic getVariable ["ROOT_ADS_V_duration", 0];
private _mult = _logic getVariable ["ROOT_ADS_V_mult", -1];
private _armored = _logic getVariable ["ROOT_ADS_V_armored", -1];
private _optics = _logic getVariable ["ROOT_ADS_V_optics", -1];
{
    private _veh = _x;
    [_veh, _mode, _duration, _mult, _armored, _optics] call API(setVehicleMode);
    { [_veh, _x, [-1, _duration] select (_duration > 0)] call API(burnVehicle); } forEach _sides;
} forEach _vehicles;
