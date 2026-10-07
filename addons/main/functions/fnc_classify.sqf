#include "..\script_component.hpp"
/*
 * Author: Root
 * Sorts a group's existing knowledge of a unit that just gained cover (or that the group meets
 * for the first time while covered):
 * - engaged (threatened recently) or, at entry, witnessed (recent sighting with high knowledge):
 *   knowledge carries over -> COMPROMISED
 * - stale knowledge: SEARCHING, suspicion seeded from what they knew
 * - weak knowledge: suspicion seeded, may be SUSPICIOUS
 * - nothing: UNAWARE; nothing is revealed or erased
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Unit <OBJECT>
 * 2: Called for the entry moment itself <BOOL> (default: false)
 *
 * Return Value:
 * Entry <ARRAY>
 *
 * Public: No
 */

params ["_grp", "_unit", ["_atEntry", false]];

private _data = [_grp] call FUNC(getData);
private _key = hashValue _unit;
private _entry = _data getOrDefault [_key, []];
if (_entry isEqualTo []) then {
    _entry = NEW_ENTRY(_unit);
    _data set [_key, _entry];
};
_entry set [D_LASTUPD, time];
_entry set [D_VEH, vehicle _unit];

if ((_entry select D_STATE) == ST_COMPROMISED) exitWith {_entry};

private _covered = _unit getVariable [QGVAR(cover), false];
private _knowledge = _grp knowsAbout _unit;
((leader _grp) targetKnowledge _unit) params [["_knownByGroup", false], "", ["_lastSeen", -1e10], ["_lastThreat", -1e10]];

private _engaged = _knownByGroup && _lastThreat > 0 && {(time - _lastThreat) < MSET(combatWindow)};
private _witnessed = _atEntry && _knownByGroup && {_knowledge >= MSET(witnessKA)} && {(time - _lastSeen) < MSET(witnessWindow)};

if (_engaged || _witnessed) exitWith {
    private _why = ["witnessed", "engaged"] select _engaged;
    RLOG_3("%1 keeps knowledge of %2 (%3)",_grp,_unit,_why);
    [_grp, _unit, _why, false] call FUNC(compromise);
    _entry
};

private _oldState = _entry select D_STATE;
if (_knownByGroup && _knowledge > 0) then {
    private _seed = MSET(seedFactor) * (_knowledge / 4) * 100;
    _entry set [D_SUSP, ((_entry select D_SUSP) max _seed) min (MSET(identifyThreshold) - 1)];
    if (_knowledge >= 1) then {
        _entry set [D_STATE, ST_SEARCHING];
    } else {
        if ((_entry select D_SUSP) >= MSET(suspiciousThreshold)) then { _entry set [D_STATE, ST_SUSPICIOUS]; };
    };
};

// Fool the group straight away (unit and vehicle) if this vehicle can fool them at all
private _veh = vehicle _unit;
if (_covered
    && {!(_grp getVariable [QGVAR(immune), false])}
    && {([_veh, side _grp, getPosATL (leader _grp)] call FUNC(vehicleDisguise)) == 1}
) then {
    [_grp, _entry, true] call FUNC(setIgnored);
    private _ignoredVehs = _grp getVariable [QGVAR(ignoredVehs), []];
    if (_veh != _unit && {!(_veh in _ignoredVehs)}) then {
        _grp ignoreTarget [_veh, true];
        _ignoredVehs pushBack _veh;
        _grp setVariable [QGVAR(ignoredVehs), _ignoredVehs];
    };
};

if ((_entry select D_STATE) != _oldState) then {
    RLOG_3("%1 -> %2 for %3 (classified)",_grp,STATE_NAMES select (_entry select D_STATE),_unit);
};
[_grp, true] call FUNC(publishData);

_entry
