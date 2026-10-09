#include "..\script_component.hpp"
/*
 * Author: Root
 * Family key of an item: the 3D model it uses, so camo variants of the same uniform, vest,
 * helmet or rifle land in the same family. Cached per item.
 *
 * Arguments:
 * 0: Slot name <STRING>
 * 1: Item class (lower case) <STRING>
 *
 * Return Value:
 * Family key, "" for no item <STRING>
 *
 * Public: No
 */

params ["_slot", "_item"];

if (_item == "") exitWith {""};
if (isNil QGVAR(familyCache)) then { GVAR(familyCache) = createHashMap; };

private _cached = GVAR(familyCache) get _item;
if (!isNil "_cached") exitWith {_cached};

private _model = switch (_slot) do {
    case "uniform": {
        private _class = getText (configFile >> "CfgWeapons" >> _item >> "ItemInfo" >> "uniformClass");
        getText (configFile >> "CfgVehicles" >> _class >> "model")
    };
    case "backpack": { getText (configFile >> "CfgVehicles" >> _item >> "model") };
    case "facewear": { getText (configFile >> "CfgGlasses" >> _item >> "model") };
    default { getText (configFile >> "CfgWeapons" >> _item >> "model") };
};
_model = toLower _model;
if (_model == "") then { _model = _item; };

GVAR(familyCache) set [_item, _model];
_model
