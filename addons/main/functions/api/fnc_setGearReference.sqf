#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Sets the enemy gear reference of a side: the kit that side's AI expect to see. Players wearing
 * the same items build suspicion slower, mismatched items build it faster (gear compare mode).
 *
 * Arguments:
 * 0: Observing side <SIDE>
 * 1: Seven class lists in order uniform, vest, headgear, primary, launcher, backpack, facewear.
 *    Each entry is an array of classes or a comma-separated string. [] clears the reference. <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [east, ["U_O_CombatUniform_ocamo", "V_HarnessO_brn", "H_HelmetO_ocamo", "arifle_Katiba_F", "", "B_FieldPack_ocamo", ""]] call root_ads_fnc_setGearReference
 *
 * Public: Yes
 */

params [["_side", sideUnknown, [west]], ["_lists", [], [[]]]];

if (!isServer) exitWith { [QGVAR(api), ["setGearReference", _this]] call CBA_fnc_serverEvent; };

private _slots = [];
for "_i" from 0 to 6 do {
    private _entry = _lists param [_i, []];
    if (_entry isEqualType "") then { _entry = [_entry] call FUNC(parseList); };
    _entry = (_entry select {_x isEqualType ""}) apply {toLower _x};
    // weapons compare by base class (attachment presets count as the same rifle)
    if (_i in [3, 4]) then { _entry = _entry apply { [toLower ([_x] call BIS_fnc_baseWeapon), ""] select (_x == "") }; };
    _slots pushBack _entry;
};

private _all = (missionNamespace getVariable [QGVAR(gearRef), []]) select {(_x select 0) != _side};
if ((_slots findIf {_x isNotEqualTo []}) > -1) then { _all pushBack [_side, _slots]; };
missionNamespace setVariable [QGVAR(gearRef), _all, true];

// groups pick up the new reference on their next evaluation
{ _x setVariable [QGVAR(gearRefCache), nil]; } forEach allGroups;
[QGVAR(gearRefChanged), []] call CBA_fnc_globalEvent;
RLOG_2("gear reference for %1 set: %2",_side,_slots apply {count _x});
