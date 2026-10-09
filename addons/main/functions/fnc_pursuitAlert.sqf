#include "..\script_component.hpp"
/*
 * Author: Root
 * Radio alert from a pursuing group ("refused to stop", "got away"): friendly groups and
 * outposts within the alert radius start SEARCHING for the unit with the alert suspicion.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Unit <OBJECT>
 * 2: Reason <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_unit", ["_reason", ""]];

private _radius = MSET(alertRadius);
if (_radius <= 0 || {isNull _unit}) exitWith {};

private _pos = getPosATL (([_grp, _unit] call FUNC(groupNearest)) select 0);
if (RADS_DEBUG) then { ["ALERT", format ["%1 radios '%2' about %3 to groups within %4 m", groupId _grp, _reason, name _unit, _radius], _grp, _unit] call FUNC(debugLog); };
[QGVAR(pursuitAlert), [side _grp, _pos, _radius, _unit, _reason, _grp]] call CBA_fnc_globalEvent;
