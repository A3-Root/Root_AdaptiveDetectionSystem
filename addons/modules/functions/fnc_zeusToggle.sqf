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
    LLSTRING(toggleTitle),
    [
        ["COMBO", [LLSTRING(action), ""], [[0, 1, 2], [LLSTRING(disable), LLSTRING(enable), LLSTRING(backToCba)], [1, 0] select (["enabled"] call FUNC(settingValue))]],
        ["SLIDER", [LLSTRING(delayS), LLSTRING(toggleDelay_desc)], [0, 3600, 0, 0]],
        ["SLIDER", [LLSTRING(durationS), LLSTRING(toggleDuration_desc)], [0, 7200, 0, 0]]
    ],
    {
        params ["_results"];
        _results params ["_action", "_delay", "_duration"];
        private _value = [false, true, nil] select _action;
        [_value, _duration, _delay] call API(setEnabled);
        [LLSTRING(toggleDone)] call zen_common_fnc_showMessage;
    },
    {}
] call zen_dialog_fnc_create;
