#include "..\script_component.hpp"
/*
 * Author: Root
 * Local civilian groups that saw the unit (entering a vehicle, or a hostile act) may report it to
 * every hostile side after a delay, unless the informant is silenced first.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Position <ARRAY>
 * 2: What was seen <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_pos", ["_type", ""]];

if (!MSET(informantsEnabled) || {isNull _unit}) exitWith {};

private _range = MSET(informantRange);
private _chance = MSET(informantChance);
{
    private _grp = _x;
    if (local _grp
        && {side _grp == civilian}
        && {!isPlayer (leader _grp)}
        && {[_grp, _pos, _range] call FUNC(groupInRange)}
        && {[_grp, _unit, _range] call FUNC(groupSees)}
        && {random 1 < _chance}
    ) then {
        private _witness = ([_grp, _pos] call FUNC(groupNearest)) select 0;
        RLOG_2("civilian %1 will inform on %2",_witness,_unit);
        [{
            params ["_civ", "_unit", "_type"];
            if (!([_civ] call FUNC(isAwake)) || {isNull _unit}) exitWith {};
            private _veh = vehicle _unit;
            {
                if ([_x, _unit] call FUNC(isHostile)) then {
                    [QGVAR(bulletin), [_x, getPosATL _civ, MSET(bulletinRange), _unit, [objNull, _veh] select (_veh != _unit), "informant: " + _type, grpNull]] call CBA_fnc_globalEvent;
                };
            } forEach [west, east, independent];
        }, [_witness, _unit, _type], MSET(informantDelay)] call CBA_fnc_waitAndExecute;
    };
} forEach allGroups;
