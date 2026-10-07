#include "..\script_component.hpp"
/*
 * Author: Root
 * Cached summary of a unit's visible gear (refreshed every 5 s).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * [uniform side <SIDE>, ballistic helmet <BOOL>, armored vest <BOOL>, NVG on head <BOOL>, rifle/launcher carried <BOOL>]
 *
 * Public: No
 */

params ["_unit"];

private _cache = _unit getVariable [QGVAR(gearCache), []];
if (_cache isNotEqualTo [] && {time <= (_cache select 0)}) exitWith { _cache select [1, 5] };

private _neutral = [MSET(gearNeutral)] call FUNC(parseList);

private _uniform = uniform _unit;
private _uSide = sideUnknown;
if (_uniform != "" && {!(toLower _uniform in _neutral)}) then {
    private _uClass = getText (configFile >> "CfgWeapons" >> _uniform >> "ItemInfo" >> "uniformClass");
    _uSide = [east, west, independent, civilian] param [getNumber (configFile >> "CfgVehicles" >> _uClass >> "side"), sideUnknown];
};

private _fnc_armored = {
    params ["_item"];
    if (_item == "" || {toLower _item in _neutral}) exitWith {false};
    private _protection = configFile >> "CfgWeapons" >> _item >> "ItemInfo" >> "HitpointsProtectionInfo";
    ("getNumber (_x >> 'armor') > 0" configClasses _protection) isNotEqualTo []
};

private _hmd = hmd _unit;
private _info = [
    _uSide,
    [headgear _unit] call _fnc_armored,
    [vest _unit] call _fnc_armored,
    _hmd != "" && {!(toLower _hmd in _neutral)},
    primaryWeapon _unit != "" || {secondaryWeapon _unit != ""}
];
_unit setVariable [QGVAR(gearCache), [time + 5] + _info];
_info
