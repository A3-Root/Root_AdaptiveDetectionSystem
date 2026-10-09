#include "..\script_component.hpp"
/*
 * Author: Root
 * Passes a group's current suspicion of covered units on to friendly groups around it after the
 * sync delay, so the far end of a checkpoint is as wary as the end that watched the car arrive.
 * Killing every witness before the delay runs out stops it.
 *
 * Arguments:
 * 0: Sending group (local) <GROUP>
 * 1: Batch of [unit, suspicion, appearance signature] <ARRAY>
 * 2: Clearing (an inspection let the unit go) <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_batch", ["_clear", false]];

if (_batch isEqualTo []) exitWith {};
if (MSET(syncNeedsRadio) && {(units _grp) findIf {[_x] call FUNC(isAwake) && {[_x] call FUNC(hasRadio)}} == -1}) exitWith {
    RLOG_1("%1 has no radio to sync suspicion",groupId _grp);
};

private _radius = MSET(syncRadius);
if (_radius < 0) then {
    _radius = _grp getVariable [QGVAR(shareRadius), -1];
    if (_radius < 0) then { _radius = MSET(shareRadius); };
};
if (_radius <= 0) exitWith {};

[{
    params ["_grp", "_batch", "_radius", "_clear"];
    if (isNull _grp || {(units _grp) findIf {[_x] call FUNC(isAwake)} == -1}) exitWith {
        RLOG("suspicion sync lost (sending group wiped out)");
    };
    private _positions = ((units _grp) select {[_x] call FUNC(isAwake)}) apply {getPosATL _x};
    if (RADS_DEBUG) then {
        ["SYNC", format ["%1 sends %2 within %3 m: %4", groupId _grp, ["suspicion", "all-clear"] select _clear, _radius, _batch apply {format ["%1=%2", name (_x select 0), round (_x select 1)]}], _grp] call FUNC(debugLog);
    };
    [QGVAR(syncSusp), [side _grp, _positions, _radius, _batch, _grp, _clear]] call CBA_fnc_globalEvent;
}, [_grp, _batch, _radius, _clear], MSET(syncDelay)] call CBA_fnc_waitAndExecute;
