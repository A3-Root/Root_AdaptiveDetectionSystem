#include "..\script_component.hpp"
/*
 * Author: Root
 * Hands a unit back to vanilla detection for this group (cover lost or vehicle does not fool them).
 * Remembered suspicion is kept; if it is high and the group can see the unit, the unit is revealed.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Entry <ARRAY>
 * 2: Reason (debug log) <STRING> (default: "cover lost")
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_entry", ["_reason", "cover lost"]];

if !(_entry select D_IGNORED) exitWith {};
[_grp, _entry, false, _reason] call FUNC(setIgnored);
[_grp, _entry, false] call FUNC(behaviourHooks);

private _unit = _entry select D_UNIT;
private _susp = _entry select D_SUSP;
if (alive _unit && {_susp >= MSET(exitRevealThreshold)} && {[_grp, _unit] call FUNC(groupSees)}) then {
    _grp reveal [_unit, (1 + 3 * _susp / 100) min 4];
    if (RADS_DEBUG) then { ["REVEAL", format ["released with suspicion %1 (>= %2) in view: revealed at knowsAbout %3", _susp toFixed 1, MSET(exitRevealThreshold), ((1 + 3 * _susp / 100) min 4) toFixed 2], _grp, _unit] call FUNC(debugLog); };
};
