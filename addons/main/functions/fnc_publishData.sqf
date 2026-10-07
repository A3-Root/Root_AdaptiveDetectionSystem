#include "..\script_component.hpp"
/*
 * Author: Root
 * Mirrors the group's knowledge to a public variable. Used to hand state over when the group
 * changes owner, and by overlays / Zeus inspect / ACE status. Throttled unless forced.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Force <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", ["_force", false]];

if (!_force && {!MSET(debugPublish)} && {time < (_grp getVariable [QGVAR(nextPub), 0])}) exitWith {};
_grp setVariable [QGVAR(nextPub), time + 15];

private _pub = (values (_grp getVariable [QGVAR(data), createHashMap])) apply {
    [_x select D_UNIT, round (_x select D_SUSP), _x select D_STATE, _x select D_IGNORED, _x select D_VEH]
};

if (_pub isNotEqualTo (_grp getVariable [QGVAR(pub), []])) then {
    _grp setVariable [QGVAR(pub), _pub, true];
};
