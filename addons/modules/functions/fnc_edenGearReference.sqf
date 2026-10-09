#include "..\script_component.hpp"
/*
 * Author: Root
 * 3DEN: enemy gear reference of a side, from the module's lists and optionally from what that
 * side's AI wear 10 s after the start (both are merged).
 *
 * Arguments:
 * 0: Module logic <OBJECT>
 * 1: Synced units <ARRAY>
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic", ["_units", []], ["_activated", true]];

if (!isServer || {!_activated}) exitWith {};

private _side = ([_logic getVariable ["ROOT_ADS_R_side", "east"]] call FUNC(parseSides)) param [0, east];
private _lists = ["uniform", "vest", "headgear", "primary", "launcher", "backpack", "facewear"] apply {
    +([_logic getVariable ["ROOT_ADS_R_" + _x, ""]] call MFUNC(parseList))
};
private _collect = _logic getVariable ["ROOT_ADS_R_collect", true];

[{
    params ["_side", "_lists", "_collect"];
    if (_collect) then {
        private _found = [_side, true] call MFUNC(collectSideGear);
        { (_lists select _forEachIndex) append _x; } forEach _found;
        _lists = _lists apply {_x arrayIntersect _x};
    };
    [_side, _lists] call API(setGearReference);
}, [_side, _lists, _collect], [0, 10] select _collect] call CBA_fnc_waitAndExecute;
