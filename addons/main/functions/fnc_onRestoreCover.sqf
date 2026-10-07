#include "..\script_component.hpp"
/*
 * Author: Root
 * Event (every machine): every local hostile group forgets the unit; heat is cleared.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_unit", objNull]];

if (isNull _unit) exitWith {};

{
    private _grp = _x;
    if (local _grp && {(side _grp) in [west, east, independent]} && {[side _grp, _unit] call FUNC(isHostile)}) then {
        private _data = _grp getVariable QGVAR(data);
        private _entry = if (isNil "_data") then {[]} else {_data getOrDefault [hashValue _unit, []]};
        if (_entry isEqualTo []) then {
            _grp forgetTarget _unit;
            if (!isNull objectParent _unit) then { _grp forgetTarget (vehicle _unit); };
        } else {
            [_grp, _entry] call FUNC(forgetEntry);
        };
    };
} forEach allGroups;

if (local _unit) then { _unit setVariable [QGVAR(heatUntil), -1, true]; };
