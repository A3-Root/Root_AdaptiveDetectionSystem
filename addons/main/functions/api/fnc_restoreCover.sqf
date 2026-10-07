#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Every hostile group forgets the unit (forgetTarget), heat is cleared, and optionally its
 * burned/wanted status too.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Also clear burned/wanted <BOOL> (default: true)
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call root_rads_fnc_restoreCover
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_clearBulletins", true, [false]]];

if (isNull _unit) exitWith {};
[QGVAR(restoreCover), [_unit]] call CBA_fnc_globalEvent;
if (_clearBulletins) then { [_unit] call API(clearBulletins); };
