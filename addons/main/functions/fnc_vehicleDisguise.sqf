#include "..\script_component.hpp"
/*
 * Author: Root
 * How a vehicle looks to an observing side.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Observer side <SIDE>
 * 2: Observer position <ARRAY>
 *
 * Return Value:
 * 0 = no disguise, 1 = disguise, 2 = burned (recognised on sight) <NUMBER>
 *
 * Public: No
 */

params ["_veh", "_side", "_pos"];

private _now = CBA_missionTime;
private _burned = (_veh getVariable [QGVAR(burnedBy), []]) findIf {
    _x params ["_bSide", "_until", "_bPos", "_range"];
    _bSide == _side && _until > _now && {_range <= 0 || {(_pos distance2D _bPos) <= _range}}
} > -1;
if (_burned) exitWith {2};

private _mode = _veh getVariable [QGVAR(vehMode), "auto"];
if (_mode == "never") exitWith {0};
if (_mode == "burned") exitWith {2};
if (_mode == "disguise") exitWith {1};

if (([MSET(vehWhitelist)] call FUNC(parseList)) findIf {_veh isKindOf _x} > -1) exitWith {1};
if (([MSET(vehBlacklist)] call FUNC(parseList)) findIf {_veh isKindOf _x} > -1) exitWith {0};

private _vehSide = [_veh] call FUNC(vehicleSide);
if (_vehSide == civilian) exitWith { [0, 1] select MSET(allowCivVeh) };
if (_vehSide == sideUnknown) exitWith {0};
if ((_side getFriend _vehSide) >= 0.6) exitWith { [0, 1] select MSET(allowFriendlyVeh) };

// An enemy-side vehicle may still pass, but it looks far more suspicious (see vehicleLookMult).
// 0 never, 1 unarmed vehicles only, 2 any vehicle
switch (MSET(allowHostileVeh)) do {
    case 2: {1};
    case 1: { [1, 0] select ([_veh] call FUNC(isArmedVehicle)) };
    default {0};
}
