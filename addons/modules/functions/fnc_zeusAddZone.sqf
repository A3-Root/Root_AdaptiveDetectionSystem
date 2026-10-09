#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: creates a detection zone at the module position (safe havens with their truce options).
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
private _pos = getPosATL _logic;
deleteVehicle _logic;

[
    LLSTRING(zoneTitle),
    [
        ["EDIT", [LLSTRING(zoneLabel), LLSTRING(zoneLabel_desc)], [format ["Zone %1", mapGridPosition _pos]]],
        ["COMBO", [LLSTRING(mode), LLSTRING(zoneMode_desc)], [[0, 1, 2], [LLSTRING(zoneMult), LLSTRING(zoneNoCover), LLSTRING(zoneSafe)], 0]],
        ["COMBO", [LLSTRING(zoneShape), ""], [[false, true], [LLSTRING(ellipse), LLSTRING(rectangle)], 0]],
        ["SLIDER:RADIUS", [LLSTRING(sizeA), LLSTRING(sizeA_desc)], [10, 5000, 200, 0, _pos, [1, 0.5, 0, 0.7]]],
        ["SLIDER", [LLSTRING(sizeB), LLSTRING(sizeB_desc)], [0, 5000, 0, 0]],
        ["SLIDER", [LLSTRING(angle), ""], [0, 359, 0, 0]],
        ["SLIDER", [LLSTRING(buildMult), LLSTRING(buildMult_desc)], [0, 10, 2, 2]],
        ["SLIDER", [LLSTRING(decayMult), LLSTRING(decayMult_desc)], [0, 10, 1, 2]],
        ["SIDES", [LLSTRING(observerSides), LLSTRING(zoneSides_desc)], []],
        ["SLIDER", [LLSTRING(delayS), LLSTRING(zoneDelay_desc)], [0, 3600, 0, 0]],
        ["SLIDER", [LLSTRING(durationS), LLSTRING(zoneDuration_desc)], [0, 7200, 0, 0]],
        ["SLIDER", [LLSTRING(hourFrom), LLSTRING(hour_desc)], [-1, 24, -1, 1]],
        ["SLIDER", [LLSTRING(hourTo), LLSTRING(hour_desc)], [-1, 24, -1, 1]],
        ["COMBO", [LLSTRING(truce), LLSTRING(truce_desc)], [[-1, 1, 0], [LLSTRING(truceCba), LLSTRING(truceOn), LLSTRING(truceOff)], 0]],
        ["SLIDER", [LLSTRING(truceStay), LLSTRING(truceStay_desc)], [0, 7200, ["truceMaxStay"] call FUNC(settingValue), 0]],
        ["SLIDER", [LLSTRING(truceWarn), ""], [0, 600, ["truceWarn"] call FUNC(settingValue), 0]],
        ["CHECKBOX", [LLSTRING(truceCareless), LLSTRING(truceCareless_desc)], ["truceCareless"] call FUNC(settingValue)],
        ["COMBO", [LLSTRING(truceScope), ""], [[0, 1, 2], [LLSTRING(truceScope0), LLSTRING(truceScope1), LLSTRING(truceScope2)], ["truceBreakScope"] call FUNC(settingValue)]],
        ["CHECKBOX", [LLSTRING(truceAim), ""], ["truceBreakOnAim"] call FUNC(settingValue)]
    ],
    {
        params ["_results", "_pos"];
        _results params ["_label", "_mode", "_rect", "_a", "_b", "_angle", "_build", "_decay", "_sides", "_delay", "_duration", "_from", "_to",
            "_truceMode", "_stay", "_warn", "_careless", "_scope", "_aim"];
        if (_b <= 0) then { _b = _a; };
        private _truce = switch (_truceMode) do {
            case 1: { [true, round _stay, round _warn, _careless, _scope, _aim] };
            case 0: { [false, 0, 0, false, 0, false] };
            default { [] };
        };
        [[_pos, _a, _b, _angle, _rect], _mode, _build, _decay, _sides, _delay, _duration, _from, _to, _label, "", _truce] call API(addZone);
        [LLSTRING(zoneAdded)] call zen_common_fnc_showMessage;
    },
    {},
    _pos
] call zen_dialog_fnc_create;
