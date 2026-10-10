#include "..\script_component.hpp"
/*
 * Author: Root
 * The local player sounded the horn: marks the vehicle (hornMult) and lets nearby AI hear it
 * (one report every 2 s while held). Called from the fire key handler (the game does not always
 * report the horn as a shot) and from FiredMan.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Source, for the log <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_source"];

private _veh = vehicle _unit;
if (_veh == _unit || {driver _veh != _unit}) exitWith {};

_veh setVariable [QGVAR(hornTime), CBA_missionTime, true];
if (time < (_veh getVariable [QGVAR(nextHornEvent), 0])) exitWith {};
if ((crew _veh) findIf {_x getVariable [QGVAR(cover), false]} == -1) exitWith {};

_veh setVariable [QGVAR(nextHornEvent), time + 2];
if (RADS_DEBUG) then { RLOG_3("HORN %1 honks (%2, from %3)",name _unit,typeOf _veh,_source); };
[QGVAR(honked), [_unit, _veh, getPosATL _veh]] call CBA_fnc_globalEvent;
