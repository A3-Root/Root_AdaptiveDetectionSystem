#include "..\script_component.hpp"
/*
 * Author: Root
 * 3DEN: mission-level setting overrides (-1 / Keep leaves the CBA value).
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

private _numbers = ["buildRate", "decayRate", "suspiciousThreshold", "identifyThreshold", "maxRange", "identifyRange", "instantRange", "forgetAfter", "memoryTime", "heatDuration", "firedRadius", "shareMode", "shareRadius", "bulletinChance", "bulletinRange", "burnDuration", "wantedDuration"];
private _booleans = ["enabled", "bulletinEnabled", "informantsEnabled", "theftEnabled", "aiAware", "aiWatch", "aiInvestigate"];

private _pairs = [];
{
    private _value = _logic getVariable ["ROOT_RADS_S_" + _x, -1];
    if (_value >= 0) then { _pairs pushBack [_x, _value]; };
} forEach _numbers;
{
    private _value = _logic getVariable ["ROOT_RADS_S_" + _x, -1];
    if (_value >= 0) then { _pairs pushBack [_x, _value == 1]; };
} forEach _booleans;

if (_pairs isNotEqualTo []) then { [_pairs] call API(setOverride); };
