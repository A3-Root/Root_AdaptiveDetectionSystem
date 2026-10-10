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

// Identified earlier but now in a different vehicle: maybe they lost the unit
private _swapped = _atEntry && {[_grp, _entry] call FUNC(trySwapForgive)};

if ((_entry select D_STATE) == ST_COMPROMISED) exitWith {_entry};

private _covered = _unit getVariable [QGVAR(cover), false];
private _knowledge = _grp knowsAbout _unit;
// Every member's knowledge counts, not just the leader's
private _knownByGroup = false;
private _lastSeen = -1e10;
private _lastThreat = -1e10;
{
    if (alive _x) then {
        (_x targetKnowledge _unit) params [["_known", false], "", ["_seen", -1e10], ["_threat", -1e10]];
        _knownByGroup = _knownByGroup || _known;
        _lastSeen = _lastSeen max _seen;
        _lastThreat = _lastThreat max _threat;
    };
} forEach (units _grp);

private _engaged = _knownByGroup && _lastThreat > 0 && {(time - _lastThreat) < MSET(combatWindow)};
private _witnessed = _atEntry && _knownByGroup && {_knowledge >= MSET(witnessKA)} && {(time - _lastSeen) < MSET(witnessWindow)};

if (!_swapped && {_engaged || _witnessed}) exitWith {
    private _why = ["witnessed", "engaged"] select _engaged;
    if (RADS_DEBUG) then {
        [_entry, format ["t=%1 ENTRY %2: knowsAbout=%3 (witness >= %4) lastSeen=%5s ago (window %6s) lastThreat=%7s ago (combat window %8s)",
            CBA_missionTime toFixed 1, _why, _knowledge toFixed 2, MSET(witnessKA), (time - _lastSeen) toFixed 1, MSET(witnessWindow), (time - _lastThreat) toFixed 1, MSET(combatWindow)]] call FUNC(debugHistory);
    };
    [_grp, _unit, _why, false] call FUNC(compromise);
    _entry
};

// starting suspicion of these AI (setStartSuspicion / modules)
private _start = [_grp] call FUNC(startSuspicion);
if (_start > (_entry select D_SUSP)) then {
    _entry set [D_SUSP, _start];
    if (RADS_DEBUG) then { [_entry, format ["t=%1 ENTRY starting suspicion %2 (set on these AI)", CBA_missionTime toFixed 1, _start toFixed 1]] call FUNC(debugHistory); };
};

private _oldState = _entry select D_STATE;
if (!_swapped && _knownByGroup && _knowledge > 0) then {
    private _seed = MSET(seedFactor) * (_knowledge / 4) * 100;
    _entry set [D_SUSP, ((_entry select D_SUSP) max _seed) min (MSET(identifyThreshold) - 1)];
    if (_knowledge >= 1) then {
        [_grp, _entry, ST_SEARCHING, format ["entry: group already knew the unit (knowsAbout %1, last seen %2 s ago) - search, suspicion seeded", _knowledge toFixed 2, (time - _lastSeen) toFixed 1]] call FUNC(setState);
    } else {
        if ((_entry select D_SUSP) >= MSET(suspiciousThreshold)) then {
            [_grp, _entry, ST_SUSPICIOUS, format ["entry: weak earlier knowledge (knowsAbout %1) seeded suspicion", _knowledge toFixed 2]] call FUNC(setState);
        };
    };
};

// Fool the group straight away (unit and vehicle) if this vehicle can fool them at all
private _veh = vehicle _unit;
if (_covered
    && {!(_grp getVariable [QGVAR(immune), false])}
    && {([_veh, side _grp, getPosATL (([_grp, _veh] call FUNC(groupNearest)) select 0)] call FUNC(vehicleDisguise)) == 1}
) then {
    [_grp, _entry, true, ["classified on cover", "cover gained (entry snapshot)"] select _atEntry] call FUNC(setIgnored);
    private _ignoredVehs = _grp getVariable [QGVAR(ignoredVehs), []];
    if (_veh != _unit && {!(_veh in _ignoredVehs)}) then {
        _grp ignoreTarget [_veh, true];
        _ignoredVehs pushBack _veh;
        _grp setVariable [QGVAR(ignoredVehs), _ignoredVehs];
    };
};

if (RADS_DEBUG) then {
    private _line = format ["t=%1 CLASSIFY atEntry=%2 swapped=%3 knowsAbout=%4 knownByGroup=%5 lastSeen=%6s ago -> %7 suspicion=%8 fooled=%9",
        CBA_missionTime toFixed 1, _atEntry, _swapped, _knowledge toFixed 2, _knownByGroup, (time - _lastSeen) toFixed 1,
        STATE_NAMES select (_entry select D_STATE), (_entry select D_SUSP) toFixed 1, _entry select D_IGNORED];
    [_entry, _line] call FUNC(debugHistory);
    if (_atEntry || {(_entry select D_STATE) != _oldState}) then { ["CLASSIFY", _line, _grp, _unit] call FUNC(debugLog); };
};
[_grp, true] call FUNC(publishData);

_entry
