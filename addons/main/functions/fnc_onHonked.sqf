#include "..\script_component.hpp"
/*
 * Author: Root
 * Event (every machine): a covered unit honked. Local hostile groups within earshot get more
 * suspicious of everyone undercover in that vehicle (no line of sight needed: they hear it).
 *
 * Arguments:
 * 0: Honking unit <OBJECT>
 * 1: Its vehicle <OBJECT>
 * 2: Position (ATL) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_veh", "_pos"];

private _add = MSET(hornSuspicion);
private _range = MSET(hornRange);
if (isNull _veh || _add <= 0 || _range <= 0) exitWith {};

private _covered = (crew _veh) select {alive _x && {_x getVariable [QGVAR(cover), false]}};
if (_covered isEqualTo []) exitWith {};

private _heard = 0;
private _nearest = [grpNull, 1e10];
{
    private _grp = _x;
    if (RADS_DEBUG && {local _grp} && {!isPlayer (leader _grp)} && {[side _grp, _unit] call FUNC(isHostile)}) then {
        private _dist = ([_grp, _pos] call FUNC(groupNearest)) select 1;
        if (_dist < (_nearest select 1)) then { _nearest = [_grp, _dist]; };
    };
    if (local _grp
        && {!isPlayer (leader _grp)}
        && {[_grp, _pos, _range] call FUNC(groupInRange)}
    ) then {
        _heard = _heard + 1;
        private _side = side _grp;
        // a series of honks gets louder each time: x hornEscalate per honk within the window
        private _series = _grp getVariable [QGVAR(honks), createHashMap];
        (_series getOrDefault [hashValue _veh, [0, -1e10]]) params ["_count", "_last"];
        if (time - _last > MSET(hornWindow)) then { _count = 0; };
        _count = _count + 1;
        _series set [hashValue _veh, [_count, time]];
        _grp setVariable [QGVAR(honks), _series];
        private _gain = _add * (MSET(hornEscalate) ^ (_count - 1));
        private _cap = MSET(hornMaxSusp) min (MSET(identifyThreshold) - 1);
        private _search = MSET(hornSearchCount);
        {
            private _member = _x;
            if ([_side, _member] call FUNC(isHostile)) then {
                private _entry = [_grp, _member, false] call FUNC(classify);
                if ((_entry select D_STATE) != ST_COMPROMISED) then {
                    private _before = _entry select D_SUSP;
                    // never lowers what they already had, never identifies
                    _entry set [D_SUSP, _before max ((_before + _gain) min _cap)];
                    _entry set [D_LASTEXP, time];
                    private _state = _entry select D_STATE;
                    if (_search > 0 && _count >= _search && _state != ST_SEARCHING) then {
                        [_grp, _entry, ST_SEARCHING, format ["kept honking (%1 honks in %2 s)", _count, round MSET(hornWindow)]] call FUNC(setState);
                        if (isPlayer _member) then { [QGVAR(watched), [_grp], _member] call CBA_fnc_targetEvent; };
                    } else {
                        if (_state == ST_UNAWARE && {(_entry select D_SUSP) >= MSET(suspiciousThreshold)} && {!([_grp, _entry] call FUNC(clearedHold))}) then {
                            [_grp, _entry, ST_SUSPICIOUS, format ["honking nearby (+%1)", _gain toFixed 1]] call FUNC(setState);
                            if (isPlayer _member) then { [QGVAR(watched), [_grp], _member] call CBA_fnc_targetEvent; };
                        };
                    };
                    [_grp, true] call FUNC(publishData);
                    if (RADS_DEBUG) then {
                        [_entry, format ["t=%1 HORN #%5 heard (%2 m) suspicion %3 -> %4 (+%6, cap %7)", CBA_missionTime toFixed 1, round (([_grp, _pos] call FUNC(groupNearest)) select 1), _before toFixed 1, (_entry select D_SUSP) toFixed 1, _count, _gain toFixed 1, _cap]] call FUNC(debugHistory);
                        ["HORN", format ["%1 hears %2 honk #%6 %3 m away: suspicion %4 -> %5 (+%7, cap %8, state %9)", groupId _grp, name _member, round (([_grp, _pos] call FUNC(groupNearest)) select 1), _before toFixed 1, (_entry select D_SUSP) toFixed 1, _count, _gain toFixed 1, _cap, _entry select D_STATE], _grp, _member] call FUNC(debugLog);
                    };
                };
            };
        } forEach _covered;
    };
} forEach allGroups;

if (RADS_DEBUG && _heard == 0 && {!isNull (_nearest select 0)}) then {
    ["HORN", format ["nobody hears %1 honk: closest hostile group %2 is %3 m away (heard within %4 m)", name _unit, groupId (_nearest select 0), round (_nearest select 1), _range], _nearest select 0, _unit] call FUNC(debugLog);
};
