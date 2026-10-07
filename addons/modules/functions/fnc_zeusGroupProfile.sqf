#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: observer profile of the AI group the module is placed on.
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

if (isNull _target) exitWith {
    ["Place the module on an AI unit"] call zen_common_fnc_showMessage;
    playSound "FD_Start_F";
};
private _grp = group (effectiveCommander _target);
if (isNull _grp || {isPlayer (leader _grp)}) exitWith {
    ["Place the module on an AI unit"] call zen_common_fnc_showMessage;
    playSound "FD_Start_F";
};

[
    format ["RADS - AI Group Profile - %1", groupId _grp],
    [
        ["SLIDER", ["Suspicion multiplier", "Vigilance: 2-3 checkpoint guards, 0.5 sleepy sentries."], [0, 10, _grp getVariable [QMVAR(groupMult), 1], 2]],
        ["CHECKBOX", ["Immune to disguises", "This group sees through every disguise (vanilla detection)."], _grp getVariable [QMVAR(immune), false]],
        ["SLIDER", ["Share radius (m)", "-1 = setting."], [-1, 3000, _grp getVariable [QMVAR(shareRadius), -1], 0]],
        ["SLIDER", ["Bulletin chance (%)", "-1 = setting."], [-1, 100, ((_grp getVariable [QMVAR(bulletinChance), -1]) * 100) max -1, 0]]
    ],
    {
        params ["_results", "_grp"];
        _results params ["_mult", "_immune", "_share", "_chance"];
        [_grp, _mult, _immune, round _share, [-1, _chance / 100] select (_chance >= 0)] call API(setGroupProfile);
        ["RADS group profile applied"] call zen_common_fnc_showMessage;
    },
    {},
    _grp
] call zen_dialog_fnc_create;
