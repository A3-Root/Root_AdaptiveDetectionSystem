#include "..\script_component.hpp"
/*
 * Author: Root
 * Client per-frame handler (5 Hz): while the local player drives a covered vehicle, hostile AI
 * touched by it are reported to their group owners at once (ramming / running over).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (!MSET(ramDetect)) exitWith {};

private _unit = call CBA_fnc_currentUnit;
private _veh = vehicle _unit;
if (_veh == _unit || {driver _veh != _unit} || {!(_unit getVariable [QGVAR(cover), false])}) exitWith {};
if (abs speed _veh < MSET(ramSpeed)) exitWith {};

private _radius = ((boundingBoxReal _veh) select 2) / 2 + 1.5;
private _reported = [];
{
    private _grp = group _x;
    if (!isPlayer _x
        && {!(_grp in _reported)}
        && {isNull objectParent _x}
        && {[side _grp, _unit] call FUNC(isHostile)}
        && {time > (_grp getVariable [QGVAR(nextRam), 0])}
    ) then {
        _reported pushBack _grp;
        _grp setVariable [QGVAR(nextRam), time + 2];
        [QGVAR(rammed), [_grp, _unit]] call CBA_fnc_globalEvent;
    };
} forEach (_veh nearEntities [["CAManBase"], _radius]);
