#include "..\script_component.hpp"
/*
 * Author: Root
 * Event: a friendly group shared how suspicious it is of covered units. Local groups of that side
 * in range take the higher value (or drop to the all-clear after an inspection), but only while
 * the unit still looks the way the sender saw it (same vehicle and kit).
 *
 * Arguments:
 * 0: Side <SIDE>
 * 1: Positions of the sending group's members <ARRAY>
 * 2: Radius (m) <NUMBER>
 * 3: Batch of [unit, suspicion, appearance signature] <ARRAY>
 * 4: Sending group <GROUP>
 * 5: All-clear <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_side", "_positions", "_radius", "_batch", ["_source", grpNull], ["_clear", false]];

if (!MSET(syncEnabled)) exitWith {};

private _factor = MSET(syncFactor);
private _canIdentify = MSET(syncCanIdentify);
private _identify = MSET(identifyThreshold);
private _cap = [_identify - 1, _identify] select _canIdentify;
private _respect = MSET(syncRespectSig);
private _from = [groupId _source, "?"] select (isNull _source);

{
    private _grp = _x;
    if (_grp != _source
        && {local _grp}
        && {side _grp == _side}
        && {!isPlayer (leader _grp)}
        && {_positions findIf {[_grp, _x, _radius] call FUNC(groupInRange)} > -1}
    ) then {
        {
            _x params ["_unit", "_susp", "_sig"];
            if (alive _unit && {_unit getVariable [QGVAR(cover), false]} && {[_side, _unit] call FUNC(isHostile)}) then {
                if (_respect && {([_unit] call FUNC(appearanceSig)) != _sig}) then {
                    if (RADS_DEBUG) then { ["SYNC", format ["from %1 ignored: %2 changed vehicle or kit since it was seen", _from, name _unit], _grp, _unit] call FUNC(debugLog); };
                } else {
                    private _entry = [_grp, _unit, false] call FUNC(classify);
                    private _state = _entry select D_STATE;
                    private _own = _entry select D_SUSP;
                    if (_state != ST_COMPROMISED) then {
                        if (_clear) then {
                            if (_own > _susp) then {
                                _entry set [D_SUSP, _susp];
                                _entry set [D_SYNCSENT, _susp];
                                _entry set [D_CLEARED, time + MSET(inspectCooldown)];
                                if (_state != ST_UNAWARE) then { [_grp, _entry, ST_UNAWARE, format ["all-clear from %1 (inspection passed)", _from]] call FUNC(setState); };
                                [_grp, _entry, false] call FUNC(behaviourHooks);
                                [_grp, true] call FUNC(publishData);
                            };
                        } else {
                            private _new = (_susp * _factor) min _cap;
                            if (_new > _own) then {
                                _entry set [D_SUSP, _new];
                                _entry set [D_SIG, _sig];
                                _entry set [D_SYNCSENT, _new];
                                if (RADS_DEBUG) then { [_entry, format ["t=%1 SYNC from %2: suspicion %3 -> %4", CBA_missionTime toFixed 1, _from, _own toFixed 1, _new toFixed 1]] call FUNC(debugHistory); };
                                if (_new >= _identify) then {
                                    [_grp, _unit, "synced suspicion from " + _from, false, false] call FUNC(compromise);
                                } else {
                                    if (_new >= MSET(suspiciousThreshold) && _state == ST_UNAWARE) then {
                                        [_grp, _entry, ST_SUSPICIOUS, format ["suspicion synced from %1 (%2)", _from, _new toFixed 0]] call FUNC(setState);
                                    };
                                    [_grp, true] call FUNC(publishData);
                                };
                            };
                        };
                    };
                };
            };
        } forEach _batch;
    };
} forEach allGroups;
