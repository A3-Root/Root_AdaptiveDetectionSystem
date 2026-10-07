#include "..\script_component.hpp"
/*
 * Author: Root
 * Unit-level cover check (side-independent). Whether a specific observing side is fooled by the
 * vehicle is decided separately per group by vehicleDisguise.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Eligible <BOOL>
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

if (!MSET(enabled) || {!alive _unit}) exitWith {false};

private _veh = vehicle _unit;
if (_veh == _unit || {!alive _veh}) exitWith {false};
if (_unit getVariable [QGVAR(exempt), false]) exitWith {false};

private _forced = _unit getVariable [QGVAR(forceCover), false];
private _coveredSides = call FUNC(coveredSides);
if (!_forced && {!((side group _unit) in _coveredSides)}) exitWith {false};

// AI passengers only ride on a covered player's disguise
if (!_forced && {!isPlayer _unit}) exitWith {
    MSET(coverAIPassengers) && {(crew _veh) findIf {isPlayer _x && {[_x] call FUNC(isCoverEligible)}} > -1}
};

if (MSET(captiveStandDown) && {captive _unit}) exitWith {false};
if (!_forced && {(_unit getVariable [QGVAR(heatUntil), -1]) > CBA_missionTime}) exitWith {false};

private _mode = _veh getVariable [QGVAR(vehMode), "auto"];
if (_mode == "never") exitWith {false};
if (_veh isKindOf "Air" && {!MSET(allowAir)}) exitWith {false};
if (_veh isKindOf "Ship" && {!MSET(allowBoats)}) exitWith {false};

private _blocked = false;
if (_mode != "disguise") then {
    if (MSET(openVehicleMode) == 1 && {[_veh] call FUNC(isOpenVehicle)}) then { _blocked = true; };
    private _blacklist = [MSET(vehBlacklist)] call FUNC(parseList);
    if (_blacklist findIf {_veh isKindOf _x} > -1) then { _blocked = true; };
};
if (_blocked) exitWith {false};

if (!_forced && {([getPosATL _veh] call FUNC(zoneModifiers)) select 0}) exitWith {false};

// Mixed crew: exempt occupants, or occupants of a non-covered, non-civilian side other than the vehicle's own
if (MSET(mixedCrewMode) == 2) then {
    private _vehSide = [_veh] call FUNC(vehicleSide);
    _blocked = (crew _veh) findIf {
        private _crewSide = side group _x;
        alive _x && {
            (_x getVariable [QGVAR(exempt), false])
            || {!(_crewSide in _coveredSides) && _crewSide != civilian && _crewSide != _vehSide}
        }
    } > -1;
};
if (_blocked) exitWith {false};

GVAR(coverConditions) findIf {!([_unit] call _x)} == -1
