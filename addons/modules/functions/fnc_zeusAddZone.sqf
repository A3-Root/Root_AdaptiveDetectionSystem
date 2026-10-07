#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: creates a detection zone at the module position.
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
    "RADS - Add Detection Zone",
    [
        ["EDIT", ["Label", "Name shown when removing zones."], [format ["Zone %1", mapGridPosition _pos]]],
        ["COMBO", ["Mode", "Multiplier: scale suspicion speed. No cover: restricted area, disguises do not work. Safe haven: no suspicion builds."], [[0, 1, 2], ["Multiplier (e.g. checkpoint / base)", "No cover (restricted area)", "Safe haven"], 0]],
        ["COMBO", ["Shape", ""], [[false, true], ["Ellipse", "Rectangle"], 0]],
        ["SLIDER:RADIUS", ["Size A (m)", "Radius / half-width."], [10, 5000, 200, 0, _pos, [1, 0.5, 0, 0.7]]],
        ["SLIDER", ["Size B (m)", "Second half-axis. 0 = same as A."], [0, 5000, 0, 0]],
        ["SLIDER", ["Angle", ""], [0, 359, 0, 0]],
        ["SLIDER", ["Build multiplier", "Suspicion build multiplier inside (Multiplier mode)."], [0, 10, 2, 2]],
        ["SLIDER", ["Decay multiplier", "Suspicion decay multiplier inside (Multiplier mode)."], [0, 10, 1, 2]],
        ["SIDES", ["Observer sides", "Sides affected. None selected = all."], []],
        ["SLIDER", ["Delay (s)", "Becomes active after this long."], [0, 3600, 0, 0]],
        ["SLIDER", ["Duration (s)", "0 = permanent."], [0, 7200, 0, 0]],
        ["SLIDER", ["Active from hour", "Daytime window start. -1 = always."], [-1, 24, -1, 1]],
        ["SLIDER", ["Active until hour", "Daytime window end. -1 = always."], [-1, 24, -1, 1]]
    ],
    {
        params ["_results", "_pos"];
        _results params ["_label", "_mode", "_rect", "_a", "_b", "_angle", "_build", "_decay", "_sides", "_delay", "_duration", "_from", "_to"];
        if (_b <= 0) then { _b = _a; };
        [[_pos, _a, _b, _angle, _rect], _mode, _build, _decay, _sides, _delay, _duration, _from, _to, _label] call API(addZone);
        ["RADS zone added"] call zen_common_fnc_showMessage;
    },
    {},
    _pos
] call zen_dialog_fnc_create;
