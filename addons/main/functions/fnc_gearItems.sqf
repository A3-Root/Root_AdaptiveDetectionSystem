#include "..\script_component.hpp"
/*
 * Author: Root
 * The unit's kit per gear slot, lower case. Weapons are reduced to their base class so a rifle
 * with different attachments still counts as the same rifle.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * [uniform, vest, headgear, primary, launcher, backpack, facewear] <ARRAY>
 *
 * Public: No
 */

params ["_unit"];

private _fnc_base = {
    params ["_weapon"];
    if (_weapon == "") exitWith {""};
    [_weapon] call BIS_fnc_baseWeapon
};

[
    uniform _unit,
    vest _unit,
    headgear _unit,
    [primaryWeapon _unit] call _fnc_base,
    [secondaryWeapon _unit] call _fnc_base,
    backpack _unit,
    goggles _unit
] apply {toLower _x}
