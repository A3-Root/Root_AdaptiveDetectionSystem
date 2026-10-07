#include "..\script_component.hpp"
/*
 * Author: Root
 * Exposure multiplier from the unit's visible gear, relative to the observing side.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Observer side <SIDE>
 * 2: Seat exposes the unit's weapons <BOOL>
 *
 * Return Value:
 * Multiplier <NUMBER>
 *
 * Public: No
 */

params ["_unit", "_side", "_exposed"];

if (!MSET(gearEnabled)) exitWith {1};

private _cache = _unit getVariable [QGVAR(gearCache), []];
if (_cache isEqualTo [] || {time > (_cache select 0)}) then {
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
    _cache = [
        time + 5,
        _uSide,
        [headgear _unit] call _fnc_armored,
        [vest _unit] call _fnc_armored,
        _hmd != "" && {!(toLower _hmd in _neutral)},
        primaryWeapon _unit != "" || {secondaryWeapon _unit != ""}
    ];
    _unit setVariable [QGVAR(gearCache), _cache];
};

_cache params ["", "_uSide", "_helmet", "_vest", "_nvg", "_weapon"];

private _mult = switch (true) do {
    case (_uSide == sideUnknown): { 1 };
    case (_uSide == civilian): { MSET(uniformCivMult) };
    case ((_side getFriend _uSide) >= 0.6): { MSET(uniformObserverMult) };
    default { MSET(uniformHostileMult) };
};
if (_helmet) then { _mult = _mult * MSET(helmetMult); };
if (_vest) then { _mult = _mult * MSET(vestMult); };
if (_nvg && {sunOrMoon > 0.5}) then { _mult = _mult * MSET(nvgDayMult); };
if (_exposed && _weapon) then { _mult = _mult * MSET(weaponVisibleMult); };

_mult
