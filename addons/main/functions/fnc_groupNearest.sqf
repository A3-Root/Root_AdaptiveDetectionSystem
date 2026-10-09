#include "..\script_component.hpp"
/*
 * Author: Root
 * Closest awake member of a group to a position or object. Every member counts, not only the
 * leader, so a group whose leader is far away still reacts through its nearby members.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Position or object <ARRAY, OBJECT>
 *
 * Return Value:
 * [member <OBJECT>, distance <NUMBER>] (leader and its distance when nobody is awake)
 *
 * Public: No
 */

params ["_grp", "_pos"];

private _best = objNull;
private _bestDistance = 1e10;
{
    if ([_x] call FUNC(isAwake)) then {
        private _distance = _x distance _pos;
        if (_distance < _bestDistance) then {
            _best = _x;
            _bestDistance = _distance;
        };
    };
} forEach (units _grp);

if (isNull _best) then {
    _best = leader _grp;
    _bestDistance = _best distance _pos;
};

[_best, _bestDistance]
