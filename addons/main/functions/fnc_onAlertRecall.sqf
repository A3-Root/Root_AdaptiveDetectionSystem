#include "..\script_component.hpp"
/*
 * Author: Root
 * Event (every machine): a vehicle that "refused to stop" stopped for an inspection after all.
 * Local groups that a pursuit alert put in SEARCHING for someone in it (within the last 2 min)
 * go back to the suspicion, state and behaviour they had before, unless they identified the unit
 * or became more suspicious than the alert made them (they saw something themselves).
 *
 * Arguments:
 * 0: Inspected vehicle <OBJECT>
 * 1: Inspecting group <GROUP>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_veh", "_source"];

if (isNull _veh) exitWith {};
private _crew = crew _veh;
private _floor = MSET(alertSuspicion);
{
    private _grp = _x;
    private _saved = _grp getVariable [QGVAR(alertSaved), createHashMap];
    if (local _grp && {count _saved > 0}) then {
        private _data = [_grp] call FUNC(getData);
        {
            private _key = hashValue _x;
            private _memo = _saved getOrDefault [_key, []];
            if (_memo isNotEqualTo []) then {
                _saved deleteAt _key;
                _memo params ["_susp", "_state", "_behaviour", "_at", "_reason"];
                private _entry = _data getOrDefault [_key, []];
                if (_entry isNotEqualTo [] && {time - _at < 120}) then {
                    private _now = _entry select D_SUSP;
                    private _keep = (_entry select D_STATE) == ST_COMPROMISED || {_now > ((_susp max _floor) + 10)};
                    if (_keep) then {
                        if (RADS_DEBUG) then { ["ALERT", format ["%1 keeps searching for %2: suspicion %3 is its own now (alert '%4' called off by %5)", groupId _grp, name _x, _now toFixed 1, _reason, groupId _source], _grp, _x] call FUNC(debugLog); };
                    } else {
                        _entry set [D_SUSP, _susp];
                        if (RADS_DEBUG) then {
                            [_entry, format ["t=%1 ALERT RECALLED by %2 (stopped for the inspection): suspicion %3 -> %4", CBA_missionTime toFixed 1, groupId _source, _now toFixed 1, _susp toFixed 1]] call FUNC(debugHistory);
                            ["ALERT", format ["%1 stands down on %2: '%3' called off, suspicion %4 -> %5, behaviour %6", groupId _grp, name _x, _reason, _now toFixed 1, _susp toFixed 1, _behaviour], _grp, _x] call FUNC(debugLog);
                        };
                        if ((_entry select D_STATE) != _state) then { [_grp, _entry, _state, format ["alert '%1' called off: stopped for %2", _reason, groupId _source]] call FUNC(setState); };
                        if (behaviour (leader _grp) != _behaviour && {isNil {_grp getVariable QGVAR(pursuit)}} && _state != ST_SEARCHING) then { _grp setBehaviour _behaviour; };
                        [_grp, _entry, _state in [ST_SUSPICIOUS, ST_SEARCHING]] call FUNC(behaviourHooks);
                        [_grp, true] call FUNC(publishData);
                    };
                };
            };
        } forEach _crew;
        _grp setVariable [QGVAR(alertSaved), _saved];
    };
} forEach allGroups;
