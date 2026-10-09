#include "..\script_component.hpp"
/*
 * Author: Root
 * How suspicious the vehicle itself looks to a group: their own faction's vehicles are expected,
 * enemy vehicles are not. A per-vehicle multiplier (module/API) or the class list wins.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Observing group <GROUP>
 *
 * Return Value:
 * [multiplier <NUMBER>, tier name <STRING>]
 *
 * Public: No
 */

params ["_veh", "_grp"];

private _override = _veh getVariable [QGVAR(vehMult), -1];
if (_override >= 0) exitWith {[_override, "vehicleModule"]};

// "Class:multiplier" pairs, first match wins (exact class, then isKindOf)
private _pairs = ([MSET(vehClassMults)] call FUNC(parseList)) apply {
    private _parts = _x splitString ":";
    [_parts param [0, ""], parseNumber (_parts param [1, "1"])]
};
private _type = toLower typeOf _veh;
private _index = _pairs findIf {(_x select 0) == _type};
if (_index < 0) then { _index = _pairs findIf {_veh isKindOf (_x select 0)}; };
if (_index > -1) exitWith {[(_pairs select _index) select 1, "classList"]};

private _side = side _grp;
private _vehSide = [_veh] call FUNC(vehicleSide);
switch (true) do {
    case (_vehSide == civilian): { [MSET(civVehMult), "civilian"] };
    case (_vehSide == sideUnknown): { [1, "unknown"] };
    case (_vehSide == _side && {(toLower getText (configOf _veh >> "faction")) == toLower (faction (leader _grp))}): { [MSET(sameFactionVehMult), "sameFaction"] };
    case (_vehSide == _side): { [MSET(friendlyVehMult), "sameSide"] };
    case ((_side getFriend _vehSide) >= 0.6): { [MSET(alliedVehMult), "allied"] };
    default { [MSET(hostileVehMult), "enemy"] };
}
