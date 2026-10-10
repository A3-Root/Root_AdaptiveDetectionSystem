#include "..\script_component.hpp"
/*
 * Author: Root
 * Stop signal of a pursuing vehicle: every few seconds (stopSignalInterval) a burst of two honks
 * and three flashes of the headlights (each optional), run where the vehicle is local.
 * Off just stops further bursts; a running burst restores the lights itself.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Signalling <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_on"];

private _pursuit = _grp getVariable [QGVAR(pursuit), createHashMap];
private _aiVeh = _pursuit getOrDefault ["aiVeh", objNull];
if (isNull _aiVeh || {!alive _aiVeh}) exitWith {};

if (!_on) exitWith { _pursuit set ["nextSignal", 0]; };
if (time < (_pursuit getOrDefault ["nextSignal", 0])) exitWith {};

_pursuit set ["nextSignal", time + MSET(stopSignalInterval)];
_pursuit set ["signals", (_pursuit getOrDefault ["signals", 0]) + 1];
private _args = [_aiVeh, MSET(stopSignalHorn), MSET(stopSignalLights)];
if (local _aiVeh) then { _args call FUNC(signalBurst); } else { [QGVAR(signalBurst), _args, _aiVeh] call CBA_fnc_targetEvent; };

if (RADS_DEBUG && {MSET(debugDetail) >= 1}) then {
    private _unit = _pursuit get "target";
    ["PURSUIT", format ["%1 stop signal #%2 to %3 (horn=%4 lights=%5, %6 s since the first)", groupId _grp, _pursuit get "signals", name _unit, MSET(stopSignalHorn), MSET(stopSignalLights), round (time - (_pursuit get "signalStart"))], _grp, _unit] call FUNC(debugLog);
};
