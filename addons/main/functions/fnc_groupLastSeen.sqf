#include "..\script_component.hpp"
/*
 * Author: Root
 * Most recent time any awake member of the group saw the unit (engine target knowledge).
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Unit <OBJECT>
 *
 * Return Value:
 * Last seen time, -1e10 when never seen <NUMBER>
 *
 * Public: No
 */

params ["_grp", "_unit"];

private _lastSeen = -1e10;
{
    if ([_x] call FUNC(isAwake)) then {
        _lastSeen = _lastSeen max ((_x targetKnowledge _unit) param [2, -1e10]);
    };
} forEach (units _grp);
_lastSeen
