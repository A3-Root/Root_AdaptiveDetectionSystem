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

// Hurt by the covered vehicle itself with no recent gunfire: a collision / run over, not an attack
private _collision = !isNull _source && {!(_source isKindOf "CAManBase")} && {(CBA_missionTime - (_attacker getVariable [QGVAR(lastFired), -100])) > 3};
if (RADS_DEBUG) then { ["HIT", format ["%1 (%2) hurt: source=%3 instigator=%4 alive=%5 -> %6", name _unit, typeOf _unit, typeOf _source, [name _instigator, "-"] select (isNull _instigator), alive _unit, ["attack (gunfire)", "collision / run over (ram path)"] select _collision], _grp, _attacker] call FUNC(debugLog); };
if (_collision) exitWith {
    [QGVAR(rammed), [_grp, _attacker]] call CBA_fnc_globalEvent;
};

if (local _grp) then {
    [_grp, _attacker, "attacked"] call FUNC(onForceCompromise);
} else {
    [QGVAR(forceCompromise), [_grp, _attacker, "attacked"]] call CBA_fnc_globalEvent;
};
