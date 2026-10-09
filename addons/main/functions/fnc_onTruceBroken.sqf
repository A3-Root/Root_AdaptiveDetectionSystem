#include "..\script_component.hpp"
/*
 * Author: Root
 * Event: a safe zone truce was broken. Players covered by the break lose the truce for the
 * cooldown, AI in the zone (or seeing / near the offender) drop their careless stance, go
 * COMBAT and identify the offender.
 *
 * Arguments:
 * 0: Offender <OBJECT>
 * 1: Zone id <STRING>
 * 2: Reason <STRING>
 * 3: Scope: 0 offender, 1 offender's group, 2 every player under this zone's truce <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_zoneId", ["_reason", ""], ["_scope", 0]];

if (isNull _unit) exitWith {};

private _cooldown = MSET(truceCooldown);
private _players = allPlayers - entities "HeadlessClient_F";
private _losers = switch (_scope) do {
    case 1: { (units group _unit) select {isPlayer _x} };
    case 2: { _players select {((_x getVariable [QGVAR(truce), []]) param [0, ""]) == _zoneId} };
    default { [_unit] };
};
_losers pushBackUnique _unit;

if (isNil QGVAR(truceRevoked)) then { GVAR(truceRevoked) = createHashMap; };
{
    GVAR(truceRevoked) set [hashValue _x, time + _cooldown];
    if (local _x) then {
        _x setVariable [QGVAR(truce), [], true];
        _x setVariable [QGVAR(truceBlocked), CBA_missionTime + _cooldown, true];
        if (hasInterface && {_x == call CBA_fnc_currentUnit} && GVAR(notifyTruce)) then {
            hint parseText format ["<t color='#ff4444' size='1.2'>%1</t><br/>%2", localize LSTRING(truceBroken), _reason];
        };
    };
} forEach _losers;

private _zoneIndex = GVAR(zones) findIf {(_x select Z_ID) == _zoneId};
private _area = if (_zoneIndex > -1) then { (GVAR(zones) select _zoneIndex) select Z_AREA } else {[]};
private _radius = MSET(truceBreakRadius);
private _bulletin = MSET(truceBulletin);
private _why = "truce broken: " + _reason;

{
    private _grp = _x;
    if (local _grp
        && {!isPlayer (leader _grp)}
        && {(side _grp) in [west, east, independent]}
        && {[side _grp, _unit] call FUNC(isHostile)}
    ) then {
        private _inZone = _area isNotEqualTo [] && {(units _grp) findIf {alive _x && {_x inArea _area}} > -1};
        if (_inZone || {[_grp, _unit, _radius] call FUNC(groupInRange)} || {[_grp, _unit] call FUNC(groupSees)}) then {
            // no more truce for the offenders from this group
            private _ignored = _grp getVariable [QGVAR(ignoredTruce), []];
            {
                _grp ignoreTarget [_x, false];
                _ignored deleteAt (_ignored find _x);
                private _veh = vehicle _x;
                if (_veh != _x) then {
                    _grp ignoreTarget [_veh, false];
                    _ignored deleteAt (_ignored find _veh);
                };
            } forEach _losers;
            _grp setVariable [QGVAR(ignoredTruce), _ignored];

            _grp setVariable [QGVAR(truceSuspended), time + _cooldown];
            [_grp, false] call FUNC(truceCareless);
            _grp setBehaviour "COMBAT";
            if (RADS_DEBUG) then { ["TRUCE", format ["%1 (inZone=%2) reacts to the broken truce in %3 -> COMBAT, identifies offender", groupId _grp, _inZone, _zoneId], _grp, _unit] call FUNC(debugLog); };
            [_grp, _unit, _why, _bulletin] call FUNC(compromise);
        };
    };
} forEach allGroups;

if (isServer) then {
    [QGVAR(message), [format ["RADS: truce broken in %1 by %2 - %3", _zoneId, name _unit, _reason]]] call CBA_fnc_globalEvent;
};
