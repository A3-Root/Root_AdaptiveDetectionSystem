#include "..\script_component.hpp"
/*
 * Author: Root
 * Side the vehicle belongs to by config (not by current crew).
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * Side <SIDE>
 *
 * Public: No
 */

params [["_veh", objNull, [objNull]]];

[east, west, independent, civilian] param [getNumber (configOf _veh >> "side"), sideUnknown]
