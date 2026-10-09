#include "..\script_component.hpp"
/*
 * Author: Root
 * Short-range, controlled knowledge transfer after an identification. Arrives after a delay and
 * only if someone in the identifying group is still able to pass it on.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_unit"];

private _mode = MSET(shareMode);
if (_mode == 0) exitWith {};

// Groups right next to the identifying group see/hear the reaction and identify the unit at once
private _instant = MSET(shareInstantRadius);
if (_instant > 0) then {
    [QGVAR(share), [side _grp, getPosATL (([_grp, _unit] call FUNC(groupNearest)) select 0), _instant, _unit, 2, _grp]] call CBA_fnc_globalEvent;
};

private _radius = _grp getVariable [QGVAR(shareRadius), -1];
if (_radius < 0) then { _radius = MSET(shareRadius); };
if (_radius <= 0) exitWith {};

if (MSET(shareNeedsRadio) && {(units _grp) findIf {[_x] call FUNC(isAwake) && {[_x] call FUNC(hasRadio)}} == -1}) exitWith {};

[{
    params ["_grp", "_unit", "_mode", "_radius"];
    // witnesses wiped out before passing it on: the knowledge dies with them
    if (isNull _grp || {(units _grp) findIf {[_x] call FUNC(isAwake)} == -1}) exitWith {
        RLOG_1("%1 could not share (no survivors)",_grp);
    };
    [QGVAR(share), [side _grp, getPosATL (([_grp, _unit] call FUNC(groupNearest)) select 0), _radius, _unit, _mode, _grp]] call CBA_fnc_globalEvent;
}, [_grp, _unit, _mode, _radius], MSET(shareDelay)] call CBA_fnc_waitAndExecute;
