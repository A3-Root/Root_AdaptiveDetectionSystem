#include "..\script_component.hpp"
/*
 * Author: Root
 * Hit on a vehicle (where it is local). Optionally, hostile AI shooting a covered vehicle anyway
 * identify its covered occupants (the vehicle was treated as a threat).
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Source <OBJECT>
 * 2: Damage <NUMBER>
 * 3: Instigator <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_veh", "_source", "", ["_instigator", objNull]];

if (!MSET(vehicleAttackedBlows) || {!local _veh}) exitWith {};

private _attacker = _instigator;
if (isNull _attacker && {!isNull _source}) then { _attacker = effectiveCommander _source; };
if (isNull _attacker || {isPlayer _attacker}) exitWith {};

private _grp = group _attacker;
if (time < (_grp getVariable [QGVAR(nextVehHitReaction), 0])) exitWith {};
_grp setVariable [QGVAR(nextVehHitReaction), time + 2];

{
    if (_x getVariable [QGVAR(cover), false] && {[side _grp, _x] call FUNC(isHostile)}) then {
        [QGVAR(forceCompromise), [_grp, _x, "vehicleAttacked"]] call CBA_fnc_globalEvent;
    };
} forEach (crew _veh);
