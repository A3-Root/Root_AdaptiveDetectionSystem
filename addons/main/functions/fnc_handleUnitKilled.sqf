#include "..\script_component.hpp"
/*
 * Author: Root
 * Killed AI unit: same reaction as a hit, for the survivors of its group. If nobody survives,
 * nobody knows (witness elimination).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Killer <OBJECT>
 * 2: Instigator <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_killer", ["_instigator", objNull]];

[_unit, _killer, 1, _instigator] call FUNC(handleUnitHit);
