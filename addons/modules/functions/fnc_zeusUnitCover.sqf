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
    ["COMBO", [LLSTRING(mode), LLSTRING(coverMode_desc)], [["normal", "exempt", "force"], [LLSTRING(normal), LLSTRING(exempt), LLSTRING(force)], 0]],
    ["SLIDER", [LLSTRING(suspMult), LLSTRING(unitMult_desc)], [0, 5, 1, 2]],
    ["SLIDER", [LLSTRING(durationS), LLSTRING(unitDuration_desc)], [0, 7200, 0, 0]]
];
if (isNull _target) then {
    _controls pushBack ["OWNERS", [LLSTRING(units), LLSTRING(units_desc)], [[], [], [], 2]];
};

[
    LLSTRING(coverTitle) + (["", " - " + name _target] select (!isNull _target && {_target isKindOf "CAManBase"})),
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
        if (_units isEqualTo []) exitWith { [LLSTRING(msgNoUnits)] call zen_common_fnc_showMessage; playSound "FD_Start_F"; };
        { [_x, _mode, _mult, _duration] call API(setUnitMode); } forEach _units;
        [format [LLSTRING(profileApplied), count _units]] call zen_common_fnc_showMessage;
    },
    {},
    _target
] call zen_dialog_fnc_create;
