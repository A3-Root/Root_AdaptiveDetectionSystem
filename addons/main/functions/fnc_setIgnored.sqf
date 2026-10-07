#include "..\script_component.hpp"
/*
 * Author: Root
 * Applies ignoreTarget for one entry's unit (the group is fooled / no longer fooled), only when it
 * actually changes. With the debug log on, the change and its reason are logged.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Entry <ARRAY>
 * 2: Ignore <BOOL>
 * 3: Reason <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_entry", "_ignore", ["_reason", ""]];

if ((_entry select D_IGNORED) isEqualTo _ignore) exitWith {};
_entry set [D_IGNORED, _ignore];
_grp ignoreTarget [_entry select D_UNIT, _ignore];

if (RADS_DEBUG) then {
    private _what = ["NOT FOOLED (vanilla detection)", "FOOLED (ignoreTarget)"] select _ignore;
    [_entry, format ["t=%1 %2 - %3 state=%4 suspicion=%5", CBA_missionTime toFixed 1, _what, _reason, STATE_NAMES select (_entry select D_STATE), (_entry select D_SUSP) toFixed 1]] call FUNC(debugHistory);
    ["FOOLED", format ["%1 - %2 (state %3, suspicion %4)", _what, _reason, STATE_NAMES select (_entry select D_STATE), (_entry select D_SUSP) toFixed 1], _grp, _entry select D_UNIT] call FUNC(debugLog);
};
