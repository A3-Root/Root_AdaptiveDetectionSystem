#include "..\script_component.hpp"
/*
 * Author: Root
 * Applies ignoreTarget for one entry's unit, only when the state actually changes.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Entry <ARRAY>
 * 2: Ignore <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_entry", "_ignore"];

if ((_entry select D_IGNORED) isEqualTo _ignore) exitWith {};
_entry set [D_IGNORED, _ignore];
_grp ignoreTarget [_entry select D_UNIT, _ignore];
