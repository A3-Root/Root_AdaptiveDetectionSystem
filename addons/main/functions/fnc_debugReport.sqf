#include "..\script_component.hpp"
/*
 * Author: Root
 * Full RPT report for an identification or state change: reason, group, target and vehicle context,
 * and the entry's recent evaluation history (oldest first), so the cause can be read back without
 * re-running the scenario.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Entry <ARRAY>
 * 2: Title (e.g. "IDENTIFIED") <STRING>
 * 3: Reason / extra detail <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_entry", "_title", ["_reason", ""]];

if (!RADS_DEBUG) exitWith {};

GVAR(reportId) = (missionNamespace getVariable [QGVAR(reportId), 0]) + 1;
private _unit = _entry select D_UNIT;
diag_log text format ["[RADS] ===== %1 #%2 t=%3 frame=%4 =====", _title, GVAR(reportId), CBA_missionTime toFixed 1, diag_frameNo];
diag_log text format ["[RADS] reason: %1", _reason];
diag_log text format ["[RADS] %1", [_grp] call FUNC(debugGroup)];
diag_log text format ["[RADS] %1", [_unit] call FUNC(debugUnit)];
diag_log text format ["[RADS] entry: suspicion=%1 state=%2 fooled=%3 passes=%4 loiter=%5s swaps=%6 lastExposure=%7s ago identifiedIn=%8 knowsAbout=%9",
    (_entry select D_SUSP) toFixed 1, STATE_NAMES select (_entry select D_STATE), _entry select D_IGNORED,
    _entry select D_PASSES, (_entry select D_STATIONARY) toFixed 1, _entry select D_SWAPS,
    (time - (_entry select D_LASTEXP)) toFixed 1, typeOf (_entry select D_COMPVEH), (_grp knowsAbout _unit) toFixed 2
];

private _history = _entry param [D_HISTORY, []];
if (_history isEqualTo []) then {
    diag_log text "[RADS] history: <none> (identified without a prior evaluation)";
} else {
    diag_log text format ["[RADS] history (last %1 evaluations, oldest first):", count _history];
    { diag_log text format ["[RADS]   %1", _x]; } forEach _history;
};
diag_log text format ["[RADS] ===== end #%1 =====", GVAR(reportId)];
