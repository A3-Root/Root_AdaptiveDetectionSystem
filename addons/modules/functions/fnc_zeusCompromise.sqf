#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: blow or restore the cover of the unit/vehicle the module is placed on, or selected units.
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
private _pos = getPosATL _logic;
deleteVehicle _logic;

private _controls = [
    ["COMBO", [LLSTRING(action), ""], [[0, 1, 2], [LLSTRING(compromise), LLSTRING(restore), LLSTRING(restoreClear)], 0]],
    ["SIDES", [LLSTRING(observerSides), LLSTRING(compromiseSides_desc)], []],
    ["SLIDER:RADIUS", [LLSTRING(radius), LLSTRING(compromiseRadius_desc)], [0, 10000, 0, 0, _pos, [1, 0, 0, 0.7]]]
];
if (isNull _target) then {
    _controls pushBack ["OWNERS", [LLSTRING(units), LLSTRING(units_desc)], [[], [], [], 2]];
};

[
    LLSTRING(compromiseTitle),
    _controls,
    {
        params ["_results", "_target"];
        _results params ["_action", "_sides", "_radius", ["_owners", []]];
        private _units = if (isNull _target) then {
            _owners params [["_ownerSides", []], ["_groups", []], ["_players", []]];
            private _list = +_players;
            { _list append (units _x); } forEach _groups;
            { private _side = _x; _list append ((allPlayers - entities "HeadlessClient_F") select {side group _x == _side}); } forEach _ownerSides;
            _list arrayIntersect _list
        } else {
            [[_target]] call FUNC(resolveUnits)
        };
        if (_units isEqualTo []) exitWith { [LLSTRING(msgNoUnits)] call zen_common_fnc_showMessage; playSound "FD_Start_F"; };
        {
            if (_action == 0) then {
                [_x, _sides, [-1, _radius] select (_radius > 0)] call API(forceCompromise);
            } else {
                [_x, _action == 2] call API(restoreCover);
            };
        } forEach _units;
        [format [LLSTRING(compromiseDone), count _units, [LLSTRING(compromised), LLSTRING(restored), LLSTRING(restored)] select _action]] call zen_common_fnc_showMessage;
    },
    {},
    _target
] call zen_dialog_fnc_create;
