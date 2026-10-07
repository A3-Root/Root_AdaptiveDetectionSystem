#include "..\script_component.hpp"
/*
 * Author: Root
 * True when the observing side is hostile to the unit's real (group) side.
 *
 * Arguments:
 * 0: Observer side <SIDE>
 * 1: Unit <OBJECT>
 *
 * Return Value:
 * Hostile <BOOL>
 *
 * Public: No
 */

params ["_side", "_unit"];

(_side getFriend (side group _unit)) < 0.6
