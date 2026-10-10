#include "..\script_component.hpp"
/*
 * Author: Root
 * The inspection is over without an identification: the unit is cleared. Suspicion drops to the
 * all-clear level for this group and, through a sync, for its neighbours; no new pursuit of that
 * unit for the cooldown. An inspector waves the vehicle on (gesture, 2.5 s), then the group
 * remounts and returns to its route.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Outcome <STRING> (default: "cleared")
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", ["_outcome", "cleared"]];

private _pursuit = _grp getVariable QGVAR(pursuit);
if (isNil "_pursuit") exitWith {};

private _unit = _pursuit get "target";
private _entry = ([_grp] call FUNC(getData)) getOrDefault [hashValue _unit, []];
if (_entry isNotEqualTo [] && {(_entry select D_STATE) != ST_COMPROMISED}) then {
    // A clean inspection lowers suspicion by a set amount, never leaves it above the cleared level and
    // overrides a starting suspicion for the cooldown (clearedHold keeps them calm meanwhile)
    private _clear = MSET(inspectClearSusp);
    private _before = _entry select D_SUSP;
    private _after = ((_before - MSET(inspectClearReduce)) min _clear) max 0;
    _entry set [D_SUSP, _after];
    if (RADS_DEBUG) then { [_entry, format ["t=%1 INSPECTION %2: suspicion %3 -> %4 (lowered by %5, at most %6, paused %10 s, starting suspicion %7 ignored for %8 s, suspicious again at %9)", CBA_missionTime toFixed 1, _outcome, _before toFixed 1, _after toFixed 1, MSET(inspectClearReduce), _clear, [_grp] call FUNC(startSuspicion), MSET(inspectCooldown), (_after + MSET(inspectClearMargin)) toFixed 1, MSET(inspectClearGrace)]] call FUNC(debugHistory); };
    _entry set [D_SYNCSENT, _after];
    _entry set [D_CLEARED, time + MSET(inspectCooldown)];
    private _levels = _grp getVariable [QGVAR(clearedLevel), createHashMap];
    _levels set [hashValue _unit, _after];
    _grp setVariable [QGVAR(clearedLevel), _levels];
    // A short pause right after for the inspected vehicle only (anyone in it, every group): waiting
    // to drive off is not suspicious. Other vehicles, or the same people in another one, build as
    // usual; a give-away or a change of occupants breaks it (processEntry).
    private _inspected = vehicle _unit;
    if (MSET(inspectClearGrace) > 0) then {
        _inspected setVariable [QGVAR(calm), ["cleared", CBA_missionTime + MSET(inspectClearGrace), (crew _inspected) apply {hashValue _x}], true];
    } else {
        _inspected setVariable [QGVAR(calm), nil, true];
    };
    [_grp, _entry, ST_UNAWARE, format ["inspection passed (%1)", _outcome]] call FUNC(setState);
    [_grp, _entry, false] call FUNC(behaviourHooks);
    [_grp, true] call FUNC(publishData);
    // the neighbours hear it too
    if (MSET(syncEnabled)) then {
        [_grp, [[_unit, _entry select D_SUSP, [_unit] call FUNC(appearanceSig)]], true] call FUNC(syncSuspicion);
    };
};

// everyone else after that vehicle accepts the result (an inspection still running there would
// otherwise call the players driving off "fleeing")
[QGVAR(inspectCleared), [vehicle _unit, _grp]] call CBA_fnc_globalEvent;

{ [QGVAR(inspected), [_grp, false], _x] call CBA_fnc_targetEvent; } forEach ((crew vehicle _unit) select {isPlayer _x});

// Done: they stop, face the vehicle and wave it on, so the players can see the inspection is over
_pursuit set ["phase", "CLEARED"];
private _inspectors = (_pursuit get "inspectors") select {[_x] call FUNC(isAwake) && {isNull objectParent _x}};
{
    doStop _x;
    _x doWatch (vehicle _unit);
    _x playActionNow (["gestureNod", "gestureGo"] select (_forEachIndex == 0));
} forEach _inspectors;
if (RADS_DEBUG) then { ["PURSUIT", format ["%1 inspection of %2 %3: %4 inspector(s) wave the vehicle on", groupId _grp, name _unit, _outcome, count _inspectors], _grp, _unit] call FUNC(debugLog); };
[QGVAR(message), [format ["RADS: %1 waves %2 on (inspection %3)", groupId _grp, name _unit, _outcome]]] call CBA_fnc_globalEvent;

[{
    params ["_grp", "_outcome"];
    private _pursuit = _grp getVariable QGVAR(pursuit);
    if (isNil "_pursuit" || {(_pursuit get "phase") != "CLEARED"}) exitWith {};
    [_grp, "inspection " + _outcome] call FUNC(pursuitEnd);
}, [_grp, _outcome], [0, 2.5] select (_inspectors isNotEqualTo [])] call CBA_fnc_waitAndExecute;
