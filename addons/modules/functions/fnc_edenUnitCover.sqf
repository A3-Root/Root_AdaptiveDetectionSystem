#include "..\script_component.hpp"
/*
 * Author: Root
 * 3DEN: cover profile for synced units or all players. A repeatable trigger reverts on deactivation.
 *
 * Arguments:
 * 0: Module logic <OBJECT>
 * 1: Synced units <ARRAY>
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic", ["_units", []], ["_activated", true]];

if (!isServer) exitWith {};

private _allPlayers = _logic getVariable ["ROOT_ADS_U_allPlayers", false];
private _targets = [synchronizedObjects _logic, _allPlayers] call FUNC(resolveUnits);

if (!_activated) exitWith {
    { [_x, "normal", 1] call API(setUnitMode); } forEach _targets;
    if (_allPlayers) then { missionNamespace setVariable [QMVAR(playerProfile), nil, true]; };
};

private _mode = _logic getVariable ["ROOT_ADS_U_mode", "normal"];
private _mult = _logic getVariable ["ROOT_ADS_U_mult", 1];
private _duration = _logic getVariable ["ROOT_ADS_U_duration", 0];
{ [_x, _mode, _mult, _duration] call API(setUnitMode); } forEach _targets;

// Players that join (or spawn) later pick the profile up themselves
if (_allPlayers) then {
    missionNamespace setVariable [QMVAR(playerProfile), [str CBA_missionTime, _mode, _mult, [-1, CBA_missionTime + _duration] select (_duration > 0)], true];
};
