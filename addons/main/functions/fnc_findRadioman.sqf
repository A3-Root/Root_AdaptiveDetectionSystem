#include "..\script_component.hpp"
/*
 * Author: Root
 * Picks the unit of a group able to send a radio bulletin, according to the radioman setting.
 *
 * Arguments:
 * 0: Group <GROUP>
 *
 * Return Value:
 * Radioman or objNull <OBJECT>
 *
 * Public: No
 */

params ["_grp"];

private _units = (units _grp) select {!isPlayer _x && {[_x] call FUNC(isAwake)}};
if (_units isEqualTo []) exitWith {objNull};

private _mode = MSET(radiomanMode);
if (_mode == 3) exitWith { _units select 0 };
if (_mode == 2) exitWith { [objNull, leader _grp] select ((leader _grp) in _units) };

private _packs = [MSET(radioBackpacks)] call FUNC(parseList);
private _classes = [MSET(radiomanClasses)] call FUNC(parseList);
private _index = _units findIf {
    private _unit = _x;
    private _backpack = backpack _unit;
    (_backpack != "" && {_packs findIf {_backpack isKindOf [_x, configFile >> "CfgVehicles"]} > -1})
    || {"radio" in toLower (typeOf _unit)}
    || {_classes findIf {_unit isKindOf _x} > -1}
};

if (_index == -1 && _mode == 1) then {
    _index = _units findIf {[_x] call FUNC(hasRadio)};
};

if (_index == -1) exitWith {objNull};
_units select _index
