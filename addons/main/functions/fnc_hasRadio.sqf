#include "..\script_component.hpp"
/*
 * Author: Root
 * True when the unit carries any radio (vanilla, TFAR, ACRE) or a radio backpack.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Has radio <BOOL>
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

private _items = ((assignedItems _unit) + (items _unit)) apply {toLower _x};
if (_items findIf {"radio" in _x || {"tfar_" in _x} || {"tf_" in _x} || {"acre_" in _x}} > -1) exitWith {true};

private _backpack = backpack _unit;
_backpack != "" && {([MSET(radioBackpacks)] call FUNC(parseList)) findIf {_backpack isKindOf [_x, configFile >> "CfgVehicles"]} > -1}
