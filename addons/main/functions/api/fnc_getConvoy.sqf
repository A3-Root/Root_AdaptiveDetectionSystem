#include "..\..\script_component.hpp"
/*
 * Author: Root
 * The convoy a vehicle of covered units is travelling in, as seen by this machine.
 *
 * Arguments:
 * 0: Vehicle (or a unit inside it) <OBJECT>
 *
 * Return Value:
 * Convoy vehicles, [vehicle] when it travels alone <ARRAY>
 *
 * Example:
 * [vehicle player] call root_ads_fnc_getConvoy
 *
 * Public: Yes
 */

params [["_veh", objNull, [objNull]]];

[vehicle _veh] call FUNC(convoyOf)
