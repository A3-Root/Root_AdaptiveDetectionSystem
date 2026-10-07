#include "..\script_component.hpp"
/*
 * Author: Root
 * Hit on an AI unit (where it is local). If a covered (or just-uncovered) unit did it, the
 * victim's group reacts: identification if they saw the attacker, otherwise a search.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Source <OBJECT>
 * 2: Damage <NUMBER>
 * 3: Instigator <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_source", "", ["_instigator", objNull]];

if (!local _unit || {isPlayer _unit} || {!MSET(damageBlows)}) exitWith {};

private _attacker = _instigator;
if (isNull _attacker && {!isNull _source}) then { _attacker = effectiveCommander _source; };
if (isNull _attacker || _attacker == _unit) exitWith {};

private _recent = (_attacker getVariable [QGVAR(cover), false])
    || {(CBA_missionTime - (_attacker getVariable [QGVAR(lastCoverTime), -100])) < 5};
if (!_recent) exitWith {};

private _grp = group _unit;
if (isNull _grp || {!([side _grp, _attacker] call FUNC(isHostile))}) exitWith {};

// one reaction per group per second is enough (bursts, shrapnel)
if (time < (_grp getVariable [QGVAR(nextHitReaction), 0])) exitWith {};
_grp setVariable [QGVAR(nextHitReaction), time + 1];

if (local _grp) then {
    [_grp, _attacker, "attacked"] call FUNC(onForceCompromise);
} else {
    [QGVAR(forceCompromise), [_grp, _attacker, "attacked"]] call CBA_fnc_globalEvent;
};
