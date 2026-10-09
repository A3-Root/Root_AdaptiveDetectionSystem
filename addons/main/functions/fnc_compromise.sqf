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
 * 5: Bulletin always goes out (skips the chance roll, still needs a radioman) <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_unit", ["_reason", ""], ["_bulletin", true], ["_primary", true], ["_forceBulletin", false]];

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
[_grp, _entry, false, "identified: " + _reason] call FUNC(setIgnored);
[_grp, _entry, false] call FUNC(behaviourHooks);

_entry set [D_COMPVEH, _veh];
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

// The vehicle the unit was identified in is now known to this side around here
if (_veh != _unit && {MSET(burnOnIdentify)}) then {
    private _known = (_veh getVariable [QGVAR(burnedBy), []]) findIf {(_x select 0) == side _grp && {(_x select 1) > CBA_missionTime}} > -1;
    if (!_known) then {
        [_veh, side _grp, MSET(burnDuration), MSET(burnOnIdentifyRange), getPosATL _veh] call API(burnVehicle);
    };
};

[_grp, true] call FUNC(publishData);
if (RADS_DEBUG) then {
    [_grp, _entry, "IDENTIFIED", format ["%1 | primary=%2 bulletinRoll=%3 crewCascade=%4 shareMode=%5 instantRadius=%6", _reason, _primary, _bulletin && _primary, MSET(compromiseCrew), MSET(shareMode), MSET(shareInstantRadius)]] call FUNC(debugReport);
};
[QGVAR(compromised), [_grp, _unit, _reason, side _grp]] call CBA_fnc_globalEvent;

if (MSET(compromiseCrew) && _veh != _unit) then {
    {
        if (_x != _unit && {_x getVariable [QGVAR(cover), false]} && {[side _grp, _x] call FUNC(isHostile)}) then {
            [_grp, _x, _reason, false, false] call FUNC(compromise);
        };
    } forEach (crew _veh);
};

// Guilt by association: the rest of the convoy this vehicle travels in
private _convoyMode = MSET(convoyMode);
if (_primary && _convoyMode > 0 && _veh != _unit) then {
    private _spill = MSET(convoySpillSusp);
    {
        private _member = _x;
        if (_member != _veh) then {
            {
                if (_x getVariable [QGVAR(cover), false] && {[side _grp, _x] call FUNC(isHostile)}) then {
                    if (_convoyMode == 2) then {
                        [_grp, _x, "convoy of " + name _unit, false, false] call FUNC(compromise);
                    } else {
                        private _other = [_grp, _x, false] call FUNC(classify);
                        if ((_other select D_STATE) != ST_COMPROMISED) then {
                            _other set [D_SUSP, ((_other select D_SUSP) max _spill) min (MSET(identifyThreshold) - 1)];
                            [_grp, _other, ST_SEARCHING, format ["travels in the convoy of identified %1", name _unit]] call FUNC(setState);
                        };
                    };
                };
            } forEach (crew _member);
        };
    } forEach ([_veh] call FUNC(convoyOf));
    [_grp, true] call FUNC(publishData);
};

if (_primary) then {
    [_grp, _unit] call FUNC(shareKnowledge);
    if (_bulletin) then { [_grp, _unit, _reason, _forceBulletin] call FUNC(radioBulletin); };
};
