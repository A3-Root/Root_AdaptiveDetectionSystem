#include "..\script_component.hpp"
/*
 * Author: Root
 * Converts "east, west, independent" (also opfor/blufor/indfor/guer/resistance/civilian) to sides.
 *
 * Arguments:
 * 0: Sides string or array of sides <STRING|ARRAY>
 *
 * Return Value:
 * Sides <ARRAY>
 *
 * Public: No
 */

params [["_input", "", ["", []]]];

if (_input isEqualType []) exitWith { _input select {_x isEqualType west} };

private _map = createHashMapFromArray [
    ["east", east], ["opfor", east], ["red", east],
    ["west", west], ["blufor", west], ["blue", west],
    ["independent", independent], ["indfor", independent], ["guer", independent], ["resistance", independent], ["green", independent],
    ["civilian", civilian], ["civ", civilian]
];

private _sides = [];
{
    private _side = _map getOrDefault [_x, sideUnknown];
    if (_side != sideUnknown) then { _sides pushBackUnique _side; };
} forEach ((toLower _input) splitString ", ;");
_sides
