#include "..\script_component.hpp"
/*
 * Author: Root
 * Breaks a unit's safe zone truce (shooting, hurting or ramming AI, aiming, overstaying).
 * Every machine reacts through the truceBroken event.
 *
 * Arguments:
 * 0: Offending unit <OBJECT>
 * 1: Reason <STRING>
 *
 * Return Value:
 * Broken <BOOL>
 *
 * Public: No
 */

params ["_unit", ["_reason", "hostile act"]];

private _truce = _unit getVariable [QGVAR(truce), []];
if (_truce isEqualTo []) exitWith {false};
if (CBA_missionTime < (_unit getVariable [QGVAR(truceBreakSent), -1])) exitWith {false};
_unit setVariable [QGVAR(truceBreakSent), CBA_missionTime + 2];

private _id = _truce select 0;
private _zoneIndex = GVAR(zones) findIf {(_x select Z_ID) == _id};
private _scope = if (_zoneIndex > -1) then { ([GVAR(zones) select _zoneIndex] call FUNC(zoneTruce)) select T_SCOPE } else {0};

if (RADS_DEBUG) then { ["TRUCE", format ["truce in %1 BROKEN: %2 (scope %3)", _id, _reason, ["offender", "offender's group", "everyone in the zone"] select _scope], grpNull, _unit] call FUNC(debugLog); };
[QGVAR(truceBroken), [_unit, _id, _reason, _scope]] call CBA_fnc_globalEvent;
true
