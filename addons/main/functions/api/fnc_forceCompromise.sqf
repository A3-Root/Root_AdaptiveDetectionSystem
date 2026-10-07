#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Blows a unit's cover for hostile groups (on whichever machine owns them).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Observer sides, [] = all hostile <ARRAY> (default: [])
 * 2: Radius, -1 = unlimited <NUMBER> (default: -1)
 * 3: Centre, [] = unit position <ARRAY> (default: [])
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, [east], 500] call root_ads_fnc_forceCompromise
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_sides", [], [[]]], ["_radius", -1, [0]], ["_pos", [], [[]]]];

if (isNull _unit) exitWith {};
[QGVAR(forceCompromise), [grpNull, _unit, "forced", _sides, _radius, _pos]] call CBA_fnc_globalEvent;
