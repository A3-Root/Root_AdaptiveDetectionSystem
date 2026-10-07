#include "..\script_component.hpp"
/*
 * Author: Root
 * 3DEN: broadcasts synced units/vehicles as hostile to the receiving sides (or clears them).
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

if (!isServer || {!_activated}) exitWith {};

private _objects = (synchronizedObjects _logic) select {!(_x isKindOf "Logic") && {!(_x isKindOf "EmptyDetector")}};
private _sides = [_logic getVariable ["ROOT_RADS_B_sides", "east"]] call FUNC(parseSides);
private _burn = _logic getVariable ["ROOT_RADS_B_burn", true];
private _wanted = _logic getVariable ["ROOT_RADS_B_wanted", true];
private _duration = _logic getVariable ["ROOT_RADS_B_duration", -1];
private _range = _logic getVariable ["ROOT_RADS_B_range", 0];
private _pos = getPosATL _logic;

if (_logic getVariable ["ROOT_RADS_B_clear", false]) exitWith {
    { [_x, _sides, true] call API(clearBulletins); } forEach _objects;
};

private _vehicles = [];
{ if !(vehicle _x isKindOf "CAManBase") then { _vehicles pushBackUnique (vehicle _x); }; } forEach _objects;
private _people = [_objects] call FUNC(resolveUnits);

{
    private _side = _x;
    if (_burn) then { { [_x, _side, _duration, _range, _pos] call API(burnVehicle); } forEach _vehicles; };
    if (_wanted) then { { [_x, _side, _duration, _range, _pos] call API(markWanted); } forEach _people; };
} forEach _sides;
