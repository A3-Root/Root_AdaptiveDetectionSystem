#include "..\script_component.hpp"
/*
 * Author: Root
 * Sides whose units can go undercover.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Sides <ARRAY>
 *
 * Public: No
 */

private _sides = [];
if (MSET(coverWest)) then { _sides pushBack west; };
if (MSET(coverEast)) then { _sides pushBack east; };
if (MSET(coverGuer)) then { _sides pushBack independent; };
_sides
