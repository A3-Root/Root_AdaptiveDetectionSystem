#include "..\script_component.hpp"
/*
 * Author: Root
 * Writes one RADS debug event to the RPT, with group and unit context, when the debug log is on.
 *
 * Arguments:
 * 0: Event tag (e.g. "RAM", "HIT", "SWAP") <STRING>
 * 1: Message <STRING>
 * 2: Group or grpNull <GROUP> (default: grpNull)
 * 3: Unit or objNull <OBJECT> (default: objNull)
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_tag", "_message", ["_grp", grpNull], ["_unit", objNull]];

if (!RADS_DEBUG) exitWith {};

diag_log text format ["[RADS] t=%1 [%2] %3", CBA_missionTime toFixed 1, _tag, _message];
if (!isNull _grp) then { diag_log text format ["[RADS]     %1", [_grp] call FUNC(debugGroup)]; };
if (!isNull _unit) then { diag_log text format ["[RADS]     %1", [_unit] call FUNC(debugUnit)]; };
