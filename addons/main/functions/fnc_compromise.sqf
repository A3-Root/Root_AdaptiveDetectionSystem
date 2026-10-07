#include "..\script_component.hpp"
/*
 * Author: Root
 * A local group identifies a unit: ignore lifted, knowledge revealed, crew optionally included,
 * nearby friendlies informed and a radio bulletin rolled.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Unit <OBJECT>
 * 2: Reason <STRING> (default: "")
 * 3: Allow radio bulletin roll <BOOL> (default: true)
 * 4: Primary (false for crew cascade / received shares: no further spreading) <BOOL> (default: true)
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_unit", ["_reason", ""], ["_bulletin", true], ["_primary", true]];

if (isNull _grp || {!local _grp} || {isNull _unit}) exitWith {};

private _data = [_grp] call FUNC(getData);
private _key = hashValue _unit;
private _entry = _data getOrDefault [_key, []];
if (_entry isEqualTo []) then {
    _entry = NEW_ENTRY(_unit);
    _data set [_key, _entry];
};

private _already = (_entry select D_STATE) == ST_COMPROMISED;
private _veh = vehicle _unit;
_entry set [D_SUSP, 100];
_entry set [D_STATE, ST_COMPROMISED];
_entry set [D_LASTEXP, time];
_entry set [D_LASTUPD, time];
_entry set [D_VEH, _veh];
_entry set [D_AGED, false];
[_grp, _entry, false] call FUNC(setIgnored);
[_grp, _entry, false] call FUNC(behaviourHooks);

if (_already) exitWith {};
_entry set [D_COMPTIME, time];

// The vehicle must be targetable again for this group
private _ignoredVehs = _grp getVariable [QGVAR(ignoredVehs), []];
if (_veh in _ignoredVehs) then {
    _grp ignoreTarget [_veh, false];
    _ignoredVehs deleteAt (_ignoredVehs find _veh);
};

private _knowledge = MSET(revealKA);
_grp reveal [_unit, _knowledge];
if (_veh != _unit) then { _grp reveal [_veh, _knowledge]; };
if (MSET(aiCombatOnIdentify)) then { _grp setBehaviour "COMBAT"; };

[_grp, true] call FUNC(publishData);
RLOG_3("%1 IDENTIFIED %2 (%3)",_grp,_unit,_reason);
[QGVAR(compromised), [_grp, _unit, _reason, side _grp]] call CBA_fnc_globalEvent;

if (MSET(compromiseCrew) && _veh != _unit) then {
    {
        if (_x != _unit && {_x getVariable [QGVAR(cover), false]} && {[side _grp, _x] call FUNC(isHostile)}) then {
            [_grp, _x, _reason, false, false] call FUNC(compromise);
        };
    } forEach (crew _veh);
};

if (_primary) then {
    [_grp, _unit] call FUNC(shareKnowledge);
    if (_bulletin) then { [_grp, _unit, _reason] call FUNC(radioBulletin); };
};
