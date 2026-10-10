#include "..\script_component.hpp"
/*
 * Author: Root
 * Evaluates one local AI group against every covered unit, cleans up entries for units that lost
 * cover, and keeps the group's vehicle ignores in sync.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Covered units <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_covered"];

if (isNull _grp || {!local _grp}) exitWith {};
if (isPlayer (leader _grp)) exitWith {};
if ((units _grp) findIf {alive _x} == -1) exitWith {};

private _side = side _grp;
private _now = time;
private _dt = ((_now - (_grp getVariable [QGVAR(lastTick), _now])) max 0) min 5;
_grp setVariable [QGVAR(lastTick), _now];

private _data = [_grp] call FUNC(getData);
private _weather = (1 - fog * MSET(fogInfluence)) * (1 - rain * MSET(rainInfluence));
private _grace = MSET(coverGraceTime);
private _seen = [];

{
    private _unit = _x;
    if ([_side, _unit] call FUNC(isHostile)) then {
        private _key = hashValue _unit;
        private _entry = _data getOrDefault [_key, []];
        // let the entry-time snapshot from the coverChanged event win over lazy classification
        if (_entry isEqualTo [] && {(CBA_missionTime - (_unit getVariable [QGVAR(coverSince), -100])) >= _grace}) then {
            _entry = [_grp, _unit, false] call FUNC(classify);
        };
        if (_entry isNotEqualTo []) then {
            _seen pushBack _key;
            if (_dt > 0) then { [_grp, _entry, _dt, _weather] call FUNC(processEntry); };
        };
    };
} forEach _covered;

// Units no longer covered: back to vanilla detection, remembered for a while
private _decay = MSET(decayRate);
private _memory = MSET(memoryTime);
private _delete = [];
{
    private _entry = _y;
    if !(_x in _seen) then {
        private _unit = _entry select D_UNIT;
        if (isNull _unit) then {
            _delete pushBack _x;
        } else {
            [_grp, _entry, "unit no longer covered"] call FUNC(releaseEntry);
            if ((_entry select D_STATE) == ST_COMPROMISED) then {
                // engine dropped them on its own: no residual knowledge
                if ((_grp knowsAbout _unit) == 0 && {(time - (_entry select D_COMPTIME)) > 10}) then {
                    [_grp, _entry, ST_UNAWARE, "engine knowledge dropped to 0 while the unit had no cover"] call FUNC(setState);
                    _entry set [D_SUSP, 0];
                };
            } else {
                _entry set [D_SUSP, ((_entry select D_SUSP) - _decay * _dt) max 0];
            };
            if ((time - (_entry select D_LASTUPD)) > _memory) then { _delete pushBack _x; };
        };
    };
} forEach _data;
{ _data deleteAt _x; } forEach _delete;

// Ignore the vehicles of fooled-by units, but never one carrying someone this group identified
private _wantVehs = [];
private _keepVisible = [];
{
    private _unit = _y select D_UNIT;
    private _veh = vehicle _unit;
    if (_veh != _unit) then {
        if ((_y select D_STATE) == ST_COMPROMISED) then {
            _keepVisible pushBackUnique _veh;
        } else {
            if (_y select D_IGNORED) then { _wantVehs pushBackUnique _veh; };
        };
    };
} forEach _data;
_wantVehs = _wantVehs - _keepVisible;

private _oldVehs = _grp getVariable [QGVAR(ignoredVehs), []];
{ if (!isNull _x) then { _grp ignoreTarget [_x, false]; }; } forEach (_oldVehs - _wantVehs);
{ _grp ignoreTarget [_x, true]; } forEach (_wantVehs - _oldVehs);
_grp setVariable [QGVAR(ignoredVehs), _wantVehs];

// Safe zone truces: hold fire on protected players, relax inside truce zones
[_grp] call FUNC(truceGroup);

// Pass rising suspicion on to friendly groups around (checkpoint entry -> exit)
if (MSET(syncEnabled) && {time >= (_grp getVariable [QGVAR(nextSync), 0])}) then {
    _grp setVariable [QGVAR(nextSync), time + MSET(syncInterval)];
    private _min = MSET(syncMin);
    // a starting suspicion is this group's own jumpiness, not something it saw: only the excess goes out
    private _start = [0, [_grp] call FUNC(startSuspicion)] select !MSET(syncStartSusp);
    private _batch = [];
    {
        private _entry = _y;
        private _susp = (_entry select D_SUSP) - _start;
        private _sent = _entry select D_SYNCSENT;
        if (_susp < _sent - 10) then { _entry set [D_SYNCSENT, _susp]; _sent = _susp; };
        if ((_entry select D_STATE) != ST_COMPROMISED && _susp >= _min && {_susp >= _sent + 2} && {alive (_entry select D_UNIT)} && {!([_grp, _entry] call FUNC(clearedHold))}) then {
            _entry set [D_SYNCSENT, _susp];
            _batch pushBack [_entry select D_UNIT, _susp, [_entry select D_UNIT] call FUNC(appearanceSig)];
        };
    } forEach _data;
    if (_batch isNotEqualTo []) then { [_grp, _batch] call FUNC(syncSuspicion); };
};

[_grp] call FUNC(publishData);
