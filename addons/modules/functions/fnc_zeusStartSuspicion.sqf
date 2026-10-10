#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: starting suspicion of the AI unit (or vehicle crew) the module is placed on, optionally
 * its whole group.
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

private _unit = effectiveCommander _target;
if (isNull _target || {isNull _unit} || {isPlayer _unit} || {isPlayer (leader group _unit)}) exitWith {
    [LLSTRING(msgPlaceAI)] call zen_common_fnc_showMessage;
    playSound "FD_Start_F";
};

private _units = [crew _target, [_target]] select (_target isKindOf "CAManBase");
private _current = 0;
{ _current = _current max (_x getVariable [QMVAR(startSusp), 0]); } forEach _units;

[
    format [LLSTRING(startTitle), [name _unit, getText (configOf _target >> "displayName")] select (_target != _unit)],
    [
        ["SLIDER", [LLSTRING(startPercent), LLSTRING(startPercent_desc)], [0, 99, _current, 0]],
        ["CHECKBOX", [LLSTRING(startGroup), LLSTRING(startGroup_desc)], false]
    ],
    {
        params ["_results", "_target"];
        _results params ["_percent", "_wholeGroup"];
        [_target, round _percent, _wholeGroup] call API(setStartSuspicion);
        [LLSTRING(startApplied)] call zen_common_fnc_showMessage;
    },
    {},
    _target
] call zen_dialog_fnc_create;
