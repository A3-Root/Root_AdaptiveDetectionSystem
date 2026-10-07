#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: live mission-wide overrides of the most-used RADS settings (no rebuild, no restart).
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

// [setting, control, label, tooltip, control params]
private _table = [
    ["enabled", "CHECKBOX", "Enable RADS", "Master switch.", []],
    ["buildRate", "SLIDER", "Build rate (%/s)", "Suspicion gained per second at full exposure.", [1, 100, 1]],
    ["decayRate", "SLIDER", "Decay rate (%/s)", "Suspicion lost per second unseen.", [0, 50, 1]],
    ["suspiciousThreshold", "SLIDER", "Suspicious threshold (%)", "", [1, 99, 0]],
    ["identifyThreshold", "SLIDER", "Identify threshold (%)", "", [10, 100, 0]],
    ["maxRange", "SLIDER", "Max observation range (m)", "", [50, 3000, 0]],
    ["identifyRange", "SLIDER", "Close identification range (m)", "", [5, 500, 0]],
    ["instantRange", "SLIDER", "Face-to-face range (m)", "", [0, 30, 1]],
    ["forgetAfter", "SLIDER", "Forget after (s)", "Compromised groups forget after this long without contact.", [10, 1800, 0]],
    ["heatDuration", "SLIDER", "Heat after firing (s)", "", [0, 1800, 0]],
    ["firedRadius", "SLIDER", "Firing reveal radius (m)", "", [0, 2000, 0]],
    ["shareMode", "COMBO", "Share on identification", "", [[0, 1, 2], ["Nothing", "Suspicion", "Full identification"]]],
    ["shareRadius", "SLIDER", "Share radius (m)", "", [0, 3000, 0]],
    ["bulletinEnabled", "CHECKBOX", "Radio bulletins", "", []],
    ["bulletinChance", "SLIDER:PERCENT", "Bulletin chance", "", [0, 1, 0]],
    ["bulletinRange", "SLIDER", "Bulletin range (m, 0 = side-wide)", "", [0, 30000, 0]],
    ["informantsEnabled", "CHECKBOX", "Civilian informants", "", []],
    ["theftEnabled", "CHECKBOX", "Stolen vehicles", "", []],
    ["aiAware", "CHECKBOX", "Suspicious groups go AWARE", "", []],
    ["aiWatch", "CHECKBOX", "Suspicious groups watch", "", []],
    ["aiInvestigate", "CHECKBOX", "Suspicious groups investigate", "", []],
    ["debugPublish", "CHECKBOX", "Publish suspicion (debug)", "Live values for Inspect / overlays. Network cost.", []]
];

private _controls = [];
{
    _x params ["_name", "_type", "_label", "_tip", "_params"];
    private _value = [_name] call FUNC(settingValue);
    private _args = switch (_type) do {
        case "CHECKBOX": { _value };
        case "COMBO": { [_params select 0, _params select 1, (_params select 0) find _value max 0] };
        case "SLIDER:PERCENT": { [_params select 0, _params select 1, _value, _params select 2] };
        default { [_params select 0, _params select 1, _value, _params select 2] };
    };
    _controls pushBack [_type, [_label, _tip], _args];
} forEach _table;
_controls pushBack ["CHECKBOX", ["Clear all overrides", "Ignore the values above and return every setting to its CBA value."], false];

[
    "RADS - Detection Settings (mission override)",
    _controls,
    {
        params ["_results", "_table"];
        if (_results deleteAt (count _results - 1)) exitWith {
            [] call API(clearOverrides);
            ["RADS overrides cleared"] call zen_common_fnc_showMessage;
        };
        private _pairs = [];
        {
            private _value = _results select _forEachIndex;
            if (_value isEqualType 0 && {(_x select 1) == "SLIDER"} && {((_x select 4) select 2) == 0}) then { _value = round _value; };
            _pairs pushBack [_x select 0, _value];
        } forEach _table;
        [_pairs] call API(setOverride);
        ["RADS settings applied"] call zen_common_fnc_showMessage;
    },
    {},
    _table
] call zen_dialog_fnc_create;
