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

{
    private _grp = _x;
    if (local _grp
        && {!isPlayer (leader _grp)}
        && {[_grp, _pos, _range] call FUNC(groupInRange)}
    ) then {
        private _side = side _grp;
        {
            private _member = _x;
            if ([_side, _member] call FUNC(isHostile)) then {
                private _entry = [_grp, _member, false] call FUNC(classify);
                if ((_entry select D_STATE) != ST_COMPROMISED) then {
                    private _before = _entry select D_SUSP;
                    _entry set [D_SUSP, (_before + _add) min (MSET(identifyThreshold) - 1)];
                    _entry set [D_LASTEXP, time];
                    if ((_entry select D_STATE) == ST_UNAWARE && {(_entry select D_SUSP) >= MSET(suspiciousThreshold)}) then {
                        [_grp, _entry, ST_SUSPICIOUS, format ["honking nearby (+%1)", _add]] call FUNC(setState);
                        if (isPlayer _member) then { [QGVAR(watched), [_grp], _member] call CBA_fnc_targetEvent; };
                    };
                    [_grp, true] call FUNC(publishData);
                    if (RADS_DEBUG) then {
                        [_entry, format ["t=%1 HORN heard (%2 m) suspicion %3 -> %4", CBA_missionTime toFixed 1, round (([_grp, _pos] call FUNC(groupNearest)) select 1), _before toFixed 1, (_entry select D_SUSP) toFixed 1]] call FUNC(debugHistory);
                        ["HORN", format ["%1 hears %2 honk %3 m away: suspicion %4 -> %5", groupId _grp, name _member, round (([_grp, _pos] call FUNC(groupNearest)) select 1), _before toFixed 1, (_entry select D_SUSP) toFixed 1], _grp, _member] call FUNC(debugLog);
                    };
                };
            };
        } forEach _covered;
    };
} forEach allGroups;
