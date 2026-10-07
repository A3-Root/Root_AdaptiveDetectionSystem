#include "..\script_component.hpp"
/*
 * Author: Root
 * Debug description of an AI group: id, side, owner, leader position, behaviour, live members,
 * current attack target and profile.
 *
 * Arguments:
 * 0: Group <GROUP>
 *
 * Return Value:
 * Description <STRING>
 *
 * Public: No
 */

params [["_grp", grpNull]];

if (isNull _grp) exitWith {"grp=<null>"};

private _leader = leader _grp;
format ["grp=%1 (%2, owner %3, local=%4) leader=%5 grid=%6 posASL=%7 behaviour=%8 alive=%9 attackTarget=%10 vigilance=%11 immune=%12",
    groupId _grp, side _grp, groupOwner _grp, local _grp,
    name _leader, mapGridPosition _leader, (getPosASL _leader) apply {round _x},
    behaviour _leader, {alive _x} count (units _grp),
    [name getAttackTarget _leader, "-"] select (isNull getAttackTarget _leader),
    _grp getVariable [QGVAR(groupMult), 1], _grp getVariable [QGVAR(immune), false]
]
