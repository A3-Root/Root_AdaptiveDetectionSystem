#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Clears burned/wanted status. Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Unit or vehicle <OBJECT>
 * 1: Sides to clear, [] = all <ARRAY> (default: [])
 * 2: For a unit, also clear its current vehicle <BOOL> (default: true)
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call root_rads_fnc_clearBulletins
 *
 * Public: Yes
 */

params [["_object", objNull, [objNull]], ["_sides", []], ["_withVehicle", true]];

if (!isServer) exitWith { [QGVAR(api), ["clearBulletins", _this]] call CBA_fnc_serverEvent; };
if (isNull _object) exitWith {};

private _fnc_clear = {
    params ["_obj", "_var"];
    private _list = _obj getVariable [_var, []];
    if (_list isEqualTo []) exitWith {};
    _obj setVariable [_var, [[], _list select {!((_x select 0) in _sides)}] select (_sides isNotEqualTo []), true];
};

[_object, QGVAR(wantedBy)] call _fnc_clear;
[_object, QGVAR(burnedBy)] call _fnc_clear;
if (_withVehicle && {!isNull objectParent _object}) then {
    [vehicle _object, QGVAR(burnedBy)] call _fnc_clear;
};
