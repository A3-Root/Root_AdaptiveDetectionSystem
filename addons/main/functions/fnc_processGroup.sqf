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
            [_grp, _entry] call FUNC(releaseEntry);
            if ((_entry select D_STATE) == ST_COMPROMISED) then {
                // engine dropped them on its own: no residual knowledge
                if ((_grp knowsAbout _unit) == 0 && {(time - (_entry select D_COMPTIME)) > 10}) then {
                    _entry set [D_STATE, ST_UNAWARE];
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

[_grp] call FUNC(publishData);
