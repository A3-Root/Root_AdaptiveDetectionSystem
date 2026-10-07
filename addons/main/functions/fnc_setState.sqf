#include "..\script_component.hpp"
/*
 * Author: Root
 * Changes an entry's state and, with the debug log on, writes a full report of the transition
 * (old -> new, why, group, target, vehicle and recent history).
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Entry <ARRAY>
 * 2: New state <NUMBER>
 * 3: Reason <STRING> (default: "")
 *
 * Return Value:
 * Changed <BOOL>
 *
 * Public: No
 */

params ["_grp", "_entry", "_state", ["_reason", ""]];

private _old = _entry select D_STATE;
if (_old == _state) exitWith {false};
_entry set [D_STATE, _state];

if (RADS_DEBUG) then {
    [_entry, format ["t=%1 STATE %2 -> %3 (%4) suspicion=%5", CBA_missionTime toFixed 1, STATE_NAMES select _old, STATE_NAMES select _state, _reason, (_entry select D_SUSP) toFixed 1]] call FUNC(debugHistory);
    [_grp, _entry, format ["STATE %1 -> %2", STATE_NAMES select _old, STATE_NAMES select _state], _reason] call FUNC(debugReport);
};
true
