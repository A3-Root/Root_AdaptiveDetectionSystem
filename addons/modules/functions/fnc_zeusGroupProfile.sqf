#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: observer profile of the AI group the module is placed on (vigilance, immunity, sharing,
 * pursuit role and follow threshold).
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
    [LLSTRING(msgPlaceAI)] call zen_common_fnc_showMessage;
    playSound "FD_Start_F";
};
private _grp = group (effectiveCommander _target);
if (isNull _grp || {isPlayer (leader _grp)}) exitWith {
    [LLSTRING(msgPlaceAI)] call zen_common_fnc_showMessage;
    playSound "FD_Start_F";
};

private _roles = ["patrol", "outpost", "static"];

[
    format [LLSTRING(groupTitle), groupId _grp],
    [
        ["SLIDER", [LLSTRING(suspMult), LLSTRING(groupMult_desc)], [0, 10, _grp getVariable [QMVAR(groupMult), 1], 2]],
        ["CHECKBOX", [LLSTRING(immune), LLSTRING(immune_desc)], _grp getVariable [QMVAR(immune), false]],
        ["SLIDER", [LLSTRING(shareRadius), LLSTRING(settingDefault)], [-1, 3000, _grp getVariable [QMVAR(shareRadius), -1], 0]],
        ["SLIDER", [LLSTRING(bulletinChance), LLSTRING(settingDefault)], [-1, 100, ((_grp getVariable [QMVAR(bulletinChance), -1]) * 100) max -1, 0]],
        ["COMBO", [LLSTRING(role), LLSTRING(role_desc)], [_roles, [LLSTRING(rolePatrol), LLSTRING(roleOutpost), LLSTRING(roleStatic)], (_roles find (_grp getVariable [QMVAR(role), "patrol"])) max 0]],
        ["SLIDER", [LLSTRING(followThreshold), LLSTRING(followThreshold_desc)], [-1, 99, _grp getVariable [QMVAR(followThreshold), -1], 0]],
        ["SLIDER", [LLSTRING(leash), LLSTRING(leash_desc)], [-1, 5000, _grp getVariable [QMVAR(leash), -1], 0]]
    ],
    {
        params ["_results", "_grp"];
        _results params ["_mult", "_immune", "_share", "_chance", "_role", "_follow", "_leash"];
        [_grp, _mult, _immune, round _share, [-1, _chance / 100] select (_chance >= 0), _role, round _follow, round _leash] call API(setGroupProfile);
        [LLSTRING(groupApplied)] call zen_common_fnc_showMessage;
    },
    {},
    _grp
] call zen_dialog_fnc_create;
