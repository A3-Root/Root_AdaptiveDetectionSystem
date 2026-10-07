#include "..\script_component.hpp"
/*
 * Author: Root
 * Units a module applies to: all players, or the synced/attached objects (vehicles expand to crew
 * when units are wanted).
 *
 * Arguments:
 * 0: Objects <ARRAY>
 * 1: All players instead <BOOL> (default: false)
 * 2: Expand vehicles to their crew <BOOL> (default: true)
 *
 * Return Value:
 * Units <ARRAY>
 *
 * Public: No
 */

params [["_objects", []], ["_allPlayers", false], ["_expand", true]];

if (_allPlayers) exitWith { allPlayers - entities "HeadlessClient_F" };

private _units = [];
{
    if (_x isKindOf "CAManBase") then {
        _units pushBackUnique _x;
    } else {
        if (_expand) then { { _units pushBackUnique _x; } forEach (crew _x); };
    };
} forEach (_objects select {!isNull _x && {!(_x isKindOf "Logic")} && {!(_x isKindOf "EmptyDetector")}});
_units
