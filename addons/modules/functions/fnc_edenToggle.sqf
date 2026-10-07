#include "..\script_component.hpp"
/*
 * Author: Root
 * 3DEN: enable/disable RADS at start, after a delay, or when a synced trigger fires.
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

private _action = _logic getVariable ["ROOT_ADS_T_action", 0];
private _value = [false, true, nil] select _action;
[_value, _logic getVariable ["ROOT_ADS_T_duration", 0], _logic getVariable ["ROOT_ADS_T_delay", 0]] call API(setEnabled);
