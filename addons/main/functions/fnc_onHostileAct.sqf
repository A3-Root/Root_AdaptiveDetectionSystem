#include "..\script_component.hpp"
/*
 * Author: Root
 * Event (every machine): a covered unit fired. Local hostile groups that heard it close by, or
 * saw it, identify the shooter. Civilians may report it.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Position <ARRAY>
 * 2: Reveal radius <NUMBER>
 * 3: Type <STRING> (default: "fired")
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_pos", "_radius", ["_type", "fired"]];

if (isNull _unit) exitWith {};

private _byLOS = MSET(firedLOS);
private _bulletin = MSET(bulletinOnHostile);
{
    private _grp = _x;
    if (local _grp && {!isPlayer (leader _grp)} && {(side _grp) in [west, east, independent]} && {[side _grp, _unit] call FUNC(isHostile)}) then {
        private _near = (units _grp) findIf {[_x] call FUNC(isAwake) && {(_x distance _pos) <= _radius}} > -1;
        private _sees = _byLOS && {[_grp, _unit] call FUNC(groupSees)};
        if (_near || _sees) then {
            if (RADS_DEBUG) then { ["FIRED", format ["%1 by covered unit: radius %2 m, groupWithinRadius=%3, groupSaw=%4 -> identify", _type, _radius, _near, _sees], _grp, _unit] call FUNC(debugLog); };
            [_grp, _unit, _type, _bulletin] call FUNC(compromise);
        };
    };
} forEach allGroups;

if (MSET(informantsEnabled)) then { [_unit, _pos, _type] call FUNC(informantCheck); };
