#include "..\script_component.hpp"
/*
 * Author: Root
 * Ends the stop request hold of a pursuit: suspicion of the target builds normally again
 * (refused to stop, pulled away, hostile act, inspection started).
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Reason <STRING>
 *
 * Return Value:
 * Was held <BOOL>
 *
 * Public: No
 */

params ["_grp", "_reason"];

private _pursuit = _grp getVariable QGVAR(pursuit);
if (isNil "_pursuit" || {(_pursuit getOrDefault ["freeze", -1]) < 0}) exitWith {false};

private _held = _pursuit get "freeze";
_pursuit set ["freeze", -1];
_pursuit set ["unfrozen", _reason];

private _unit = _pursuit get "target";
if (RADS_DEBUG) then { ["PURSUIT", format ["%1 stops holding suspicion of %2 at %3: %4 (builds normally again)", groupId _grp, name _unit, _held toFixed 1, _reason], _grp, _unit] call FUNC(debugLog); };
true
