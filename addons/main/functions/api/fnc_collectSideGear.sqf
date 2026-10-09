#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Lists everything the AI of a side currently wear and carry, as seven comma-separated lists
 * ready to paste into the Gear Reference module. Optionally applies it as that side's reference.
 *
 * Arguments:
 * 0: Side <SIDE>
 * 1: Apply as the gear reference of that side <BOOL> (default: false)
 *
 * Return Value:
 * [uniform, vest, headgear, primary, launcher, backpack, facewear] <ARRAY of STRING>
 *
 * Example:
 * [east, true] call root_ads_fnc_collectSideGear
 *
 * Public: Yes
 */

params [["_side", sideUnknown, [west]], ["_apply", false, [false]]];

private _slots = [_side, true] call FUNC(collectSideGear);
if (_apply) then { [_side, _slots] call API(setGearReference); };
_slots apply {(_x select {_x != ""}) joinString ","}
