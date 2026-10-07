#include "..\script_component.hpp"
/*
 * Author: Root
 * Event (every machine): a unit gained or lost cover. Local hostile groups snapshot their current
 * knowledge at this exact moment (witness/engaged/stale/unaware) or hand the unit back.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 * 2: Has cover <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_veh", "_hasCover"];

if (isNull _unit) exitWith {};

private _theft = _hasCover && {MSET(theftEnabled)} && {!isNull _veh};
{
    private _grp = _x;
    if (local _grp && {!isPlayer (leader _grp)} && {(side _grp) in [west, east, independent]} && {[side _grp, _unit] call FUNC(isHostile)}) then {
        if (_hasCover) then {
            [_grp, _unit, true] call FUNC(classify);
            if (_theft) then { [_grp, _unit, _veh] call FUNC(checkTheft); };
        } else {
            private _data = _grp getVariable QGVAR(data);
            if (!isNil "_data") then {
                private _entry = _data getOrDefault [hashValue _unit, []];
                if (_entry isNotEqualTo []) then { [_grp, _entry] call FUNC(releaseEntry); };
            };
        };
    };
} forEach allGroups;

// A civilian who watched a soldier climb into a car may talk
if (_hasCover && {MSET(informantsEnabled)}) then {
    [_unit, getPosATL _unit, "entry"] call FUNC(informantCheck);
};
