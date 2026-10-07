#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: cover profile for the unit the module is placed on, or for selected sides/groups/players.
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
private _target = attachedTo _logic;
deleteVehicle _logic;

private _controls = [
    ["COMBO", ["Mode", "Normal, exempt (never covered) or always covered (any vehicle, ignores side/heat/zones)."], [["normal", "exempt", "force"], ["Normal", "Exempt", "Always covered"], 0]],
    ["SLIDER", ["Suspicion multiplier", "How fast AI grow suspicious of these units."], [0, 5, 1, 2]],
    ["SLIDER", ["Duration (s)", "Revert to normal after this long. 0 = permanent."], [0, 7200, 0, 0]]
];
if (isNull _target) then {
    _controls pushBack ["OWNERS", ["Units", "Sides, groups or players to apply to."], [[], [], [], 2]];
};

[
    format ["RADS - Unit Cover Profile%1", ["", " - " + name _target] select (!isNull _target && {_target isKindOf "CAManBase"})],
    _controls,
    {
        params ["_results", "_target"];
        _results params ["_mode", "_mult", "_duration", ["_owners", []]];
        private _units = if (isNull _target) then {
            _owners params [["_sides", []], ["_groups", []], ["_players", []]];
            private _list = +_players;
            { _list append (units _x); } forEach _groups;
            { private _side = _x; _list append ((allPlayers - entities "HeadlessClient_F") select {side group _x == _side}); } forEach _sides;
            _list arrayIntersect _list
        } else {
            [[_target]] call FUNC(resolveUnits)
        };
        if (_units isEqualTo []) exitWith { ["No units selected"] call zen_common_fnc_showMessage; playSound "FD_Start_F"; };
        { [_x, _mode, _mult, _duration] call API(setUnitMode); } forEach _units;
        [format ["RADS profile applied to %1 unit(s)", count _units]] call zen_common_fnc_showMessage;
    },
    {},
    _target
] call zen_dialog_fnc_create;
