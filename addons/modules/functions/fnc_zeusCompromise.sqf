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
    ["COMBO", ["Action", ""], [[0, 1, 2], ["Compromise (hostile AI identify them)", "Restore cover (hostile AI forget them)", "Restore cover + clear burned/wanted"], 0]],
    ["SIDES", ["Observer sides", "Compromise only: sides that identify. None = all hostile."], []],
    ["SLIDER:RADIUS", ["Radius (m)", "Compromise only: groups within this distance of each unit. 0 = unlimited."], [0, 10000, 0, 0, _pos, [1, 0, 0, 0.7]]]
];
if (isNull _target) then {
    _controls pushBack ["OWNERS", ["Units", "Sides, groups or players."], [[], [], [], 2]];
};

[
    "RADS - Compromise / Restore Cover",
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
        if (_units isEqualTo []) exitWith { ["No units selected"] call zen_common_fnc_showMessage; playSound "FD_Start_F"; };
        {
            if (_action == 0) then {
                [_x, _sides, [-1, _radius] select (_radius > 0)] call API(forceCompromise);
            } else {
                [_x, _action == 2] call API(restoreCover);
            };
        } forEach _units;
        [format ["RADS: %1 unit(s) %2", count _units, ["compromised", "restored", "restored"] select _action]] call zen_common_fnc_showMessage;
    },
    {},
    _target
] call zen_dialog_fnc_create;
