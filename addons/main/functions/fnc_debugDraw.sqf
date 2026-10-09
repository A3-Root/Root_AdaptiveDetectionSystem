#include "..\script_component.hpp"
/*
 * Author: Root
 * Draw3D debug overlay: each nearby group's published suspicion toward the current unit.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _unit = call CBA_fnc_currentUnit;
private _colors = [[0.4, 1, 0.4, 1], [1, 0.85, 0.2, 1], [1, 0.55, 0.1, 1], [1, 0.2, 0.2, 1]];

{
    private _grp = _x;
    // drawn over the member closest to you, the leader may be far away
    ([_grp, _unit] call FUNC(groupNearest)) params ["_member", "_distance"];
    if (alive _member && _distance < 1500) then {
        private _pub = _grp getVariable [QGVAR(pub), []];
        private _index = _pub findIf {(_x select 0) == _unit};
        if (_index > -1) then {
            (_pub select _index) params ["", "_susp", "_state", "_ignored"];
            drawIcon3D [
                "\a3\ui_f\data\IGUI\Cfg\Cursors\select_target_ca.paa",
                _colors select _state,
                (ASLToAGL (eyePos _member)) vectorAdd [0, 0, 1],
                0.8, 0.8, 0,
                format ["%1: %2 %3%4", groupId _grp, _susp, STATE_NAMES select _state, ["", " (fooled)"] select _ignored],
                1, 0.033, "RobotoCondensed"
            ];
        };
    };
} forEach allGroups;
