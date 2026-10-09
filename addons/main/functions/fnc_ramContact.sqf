#include "..\script_component.hpp"
/*
 * Author: Root
 * EpeContactStart on a vehicle driven by a local covered player: ramming an AI vehicle is reported
 * to the groups of its crew like ramming a soldier (breaks a truce too).
 *
 * Arguments:
 * 0: Driven vehicle <OBJECT>
 * 1: Object it collided with <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_veh", "_other"];

if (!MSET(ramDetect) || {isNull _other} || {_other isKindOf "CAManBase"} || {!(_other isKindOf "AllVehicles")}) exitWith {};

private _unit = driver _veh;
if (isNull _unit || {!local _unit} || {!isPlayer _unit}) exitWith {};
private _covered = _unit getVariable [QGVAR(cover), false];
private _truce = (_unit getVariable [QGVAR(truce), []]) isNotEqualTo [];
if (!_covered && !_truce) exitWith {};

// a nudge while parking is no ram: relative speed of the two vehicles
private _relative = (vectorMagnitude ((velocity _veh) vectorDiff (velocity _other))) * 3.6;
if (_relative < MSET(ramSpeed)) exitWith {};

private _reported = [];
{
    private _grp = group _x;
    if (alive _x && {!isPlayer _x} && {!(_grp in _reported)}
        && {[side _grp, _unit] call FUNC(isHostile)}
        && {time > (_grp getVariable [QGVAR(nextRam), 0])}
    ) then {
        _reported pushBack _grp;
        _grp setVariable [QGVAR(nextRam), time + 2];
        if (RADS_DEBUG) then { ["RAM-DETECT", format ["%1 rammed %2 (crew %3) at %4 km/h relative", typeOf _veh, typeOf _other, name _x, round _relative], _grp, _unit] call FUNC(debugLog); };
        if (_truce) then { [_unit, format ["rammed %1", typeOf _other]] call FUNC(breakTruce); };
        if (_covered) then { [QGVAR(rammed), [_grp, _unit]] call CBA_fnc_globalEvent; };
    };
} forEach (crew _other);
