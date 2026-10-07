#include "..\script_component.hpp"
/*
 * Author: Root
 * Hands a unit back to vanilla detection for this group (cover lost or vehicle does not fool them).
 * Remembered suspicion is kept; if it is high and the group can see the unit, the unit is revealed.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Entry <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_entry"];

if !(_entry select D_IGNORED) exitWith {};
[_grp, _entry, false] call FUNC(setIgnored);
[_grp, _entry, false] call FUNC(behaviourHooks);

private _unit = _entry select D_UNIT;
private _susp = _entry select D_SUSP;
if (alive _unit && {_susp >= MSET(exitRevealThreshold)} && {[_grp, _unit] call FUNC(groupSees)}) then {
    _grp reveal [_unit, (1 + 3 * _susp / 100) min 4];
    RLOG_3("%1 reveal %2 on release (%3)",_grp,_unit,round _susp);
};
