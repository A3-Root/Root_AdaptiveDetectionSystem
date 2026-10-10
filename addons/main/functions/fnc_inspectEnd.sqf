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
    // a clean inspection lowers suspicion by a set amount, and never leaves it above the cleared level
    private _clear = MSET(inspectClearSusp);
    private _before = _entry select D_SUSP;
    _entry set [D_SUSP, (((_before - MSET(inspectClearReduce)) min _clear) max 0) max ([_grp] call FUNC(startSuspicion))];
    if (RADS_DEBUG) then { [_entry, format ["t=%1 INSPECTION %2: suspicion %3 -> %4 (lowered by %5, at most %6)", CBA_missionTime toFixed 1, _outcome, _before toFixed 1, (_entry select D_SUSP) toFixed 1, MSET(inspectClearReduce), _clear]] call FUNC(debugHistory); };
    _entry set [D_SYNCSENT, _entry select D_SUSP];
    _entry set [D_CLEARED, time + MSET(inspectCooldown)];
    [_grp, _entry, ST_UNAWARE, format ["inspection passed (%1)", _outcome]] call FUNC(setState);
    [_grp, _entry, false] call FUNC(behaviourHooks);
    [_grp, true] call FUNC(publishData);
    // the neighbours hear it too
    if (MSET(syncEnabled)) then {
        [_grp, [[_unit, _entry select D_SUSP, [_unit] call FUNC(appearanceSig)]], true] call FUNC(syncSuspicion);
    };
};

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
