#include "..\..\script_component.hpp"
/*
 * Author: Root
 * The enemy gear reference of a side as seven comma-separated lists (empty strings when unset).
 *
 * Arguments:
 * 0: Observing side <SIDE>
 *
 * Return Value:
 * [uniform, vest, headgear, primary, launcher, backpack, facewear] <ARRAY of STRING>
 *
 * Example:
 * [east] call root_ads_fnc_getGearReference
 *
 * Public: Yes
 */

params [["_side", sideUnknown, [west]]];

private _all = missionNamespace getVariable [QGVAR(gearRef), []];
private _index = _all findIf {(_x select 0) == _side};
private _slots = if (_index > -1) then { (_all select _index) select 1 } else { [[], [], [], [], [], [], []] };
_slots apply {(_x select {_x != ""}) joinString ","}
