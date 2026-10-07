#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Overrides one or more RADS settings at runtime for the whole mission, on top of CBA settings.
 * Names are the setting names without prefix (e.g. "buildRate", "maxRange"). nil value clears.
 * Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Setting name, or array of [name, value] pairs <STRING|ARRAY>
 * 1: Value <ANY>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["buildRate", 25] call root_rads_fnc_setOverride
 * [[["maxRange", 400], ["bulletinChance", 0.5]]] call root_rads_fnc_setOverride
 *
 * Public: Yes
 */

params [["_name", "", ["", []]], "_value"];

if (!isServer) exitWith { [QGVAR(api), ["setOverride", _this]] call CBA_fnc_serverEvent; };

private _pairs = if (_name isEqualType "") then { [[_name, _value]] } else { _name };
private _names = missionNamespace getVariable [QGVAR(overrideNames), []];

{
    _x params ["_setting", "_val"];
    if (isNil (QUOTE(ADDON) + "_" + _setting)) then {
        diag_log text format ["[RADS] Unknown setting override: %1", _setting];
    } else {
        private _var = QUOTE(ADDON) + "_ov_" + _setting;
        if (isNil "_val") then {
            missionNamespace setVariable [_var, nil, true];
            _names deleteAt (_names find _setting);
        } else {
            missionNamespace setVariable [_var, _val, true];
            _names pushBackUnique _setting;
        };
    };
} forEach _pairs;

missionNamespace setVariable [QGVAR(overrideNames), _names, true];
