#include "..\script_component.hpp"
/*
 * Author: Root
 * True when any observer of the group has clear line of sight to the unit (vehicle ignored).
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Unit <OBJECT>
 * 2: Range, -1 = max observation range <NUMBER> (default: -1)
 *
 * Return Value:
 * Sees <BOOL>
 *
 * Public: No
 */

params ["_grp", "_unit", ["_range", -1]];

if (_range < 0) then { _range = MSET(maxRange); };
private _target = eyePos _unit;
private _veh = vehicle _unit;

(units _grp) findIf {
    [_x] call FUNC(isObserver)
    && {(_x distance _unit) <= _range}
    && {([vehicle _x, "VIEW", _veh] checkVisibility [eyePos _x, _target]) > 0.25}
} > -1
