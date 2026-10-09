#include "..\script_component.hpp"
/*
 * Author: Root
 * True when any awake member of the group is within the radius of a position or object.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Position or object <ARRAY, OBJECT>
 * 2: Radius (m) <NUMBER>
 *
 * Return Value:
 * In range <BOOL>
 *
 * Public: No
 */

params ["_grp", "_pos", "_radius"];

(units _grp) findIf {[_x] call FUNC(isAwake) && {(_x distance _pos) <= _radius}} > -1
