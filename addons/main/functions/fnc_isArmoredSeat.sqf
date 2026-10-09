#include "..\script_component.hpp"
/*
 * Author: Root
 * True when the unit sits behind armour with no real window (closed hatch in a tank, APC, IFV...).
 * Observers can then only make out the vehicle, not who is in it.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Unit's vehicle <OBJECT>
 *
 * Return Value:
 * Armored seat <BOOL>
 *
 * Public: No
 */

params ["_unit", "_veh"];

if (!MSET(armoredDetect) || _veh == _unit || {isTurnedOut _unit} || {[_unit] call CBA_fnc_canUseWeapon}) exitWith {false};

// Vehicle module / API: -1 auto, 0 never armored, 1 always armored
private _flag = _veh getVariable [QGVAR(armored), -1];
if (_flag >= 0) exitWith {_flag == 1};

if (([MSET(armoredClasses)] call FUNC(parseList)) findIf {_veh isKindOf _x} > -1) exitWith {true};
if (!MSET(armoredAutoDetect)) exitWith {false};

// Seats that only see out through optics or periscopes
private _config = configOf _veh;
private _driverClosed = getNumber (_config >> "driverForceOptics") == 1 || {getNumber (_config >> "forceHideDriver") == 1};
if (_unit == driver _veh) exitWith {_driverClosed};

private _role = assignedVehicleRole _unit;
if (toLower (_role param [0, ""]) == "turret") exitWith {
    private _turret = [_veh, _role param [1, []]] call CBA_fnc_getTurret;
    getNumber (_turret >> "gunnerForceOptics") == 1 || {getNumber (_turret >> "forceHideGunner") == 1}
};

// Passengers of a vehicle whose own driver has no window sit in a closed troop bay
_driverClosed
