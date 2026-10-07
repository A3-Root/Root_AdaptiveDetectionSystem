#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: enable/disable RADS for the mission, now or after a delay, permanently or temporarily.
 *
 * Arguments:
 * 0: Module logic <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic"];

if (!hasInterface) exitWith {};
deleteVehicle _logic;

[
    "RADS - Enable / Disable",
    [
        ["COMBO", ["Action", ""], [[0, 1, 2], ["Disable", "Enable", "Back to CBA setting"], [1, 0] select (["enabled"] call FUNC(settingValue))]],
        ["SLIDER", ["Delay (s)", "Apply after this long."], [0, 3600, 0, 0]],
        ["SLIDER", ["Duration (s)", "Revert after this long. 0 = permanent."], [0, 7200, 0, 0]]
    ],
    {
        params ["_results"];
        _results params ["_action", "_delay", "_duration"];
        private _value = [false, true, nil] select _action;
        [_value, _duration, _delay] call API(setEnabled);
        ["RADS toggle scheduled"] call zen_common_fnc_showMessage;
    },
    {}
] call zen_dialog_fnc_create;
