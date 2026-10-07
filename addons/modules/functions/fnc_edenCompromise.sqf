#include "..\script_component.hpp"
/*
 * Author: Root
 * 3DEN: compromise or restore synced units (or all players), usually when a synced trigger fires.
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

if (!isServer || {!_activated}) exitWith {};

private _targets = [synchronizedObjects _logic, _logic getVariable ["ROOT_ADS_C_allPlayers", true]] call FUNC(resolveUnits);
private _action = _logic getVariable ["ROOT_ADS_C_action", 0];
private _sides = [_logic getVariable ["ROOT_ADS_C_sides", ""]] call FUNC(parseSides);
private _radius = _logic getVariable ["ROOT_ADS_C_radius", -1];

{
    if (_action == 0) then {
        [_x, _sides, _radius] call API(forceCompromise);
    } else {
        [_x, _action == 2] call API(restoreCover);
    };
} forEach _targets;
