#include "..\script_component.hpp"
/*
 * Author: Root
 * Direction the unit's weapon points, if it can aim from where it is (on foot, turned out,
 * firing from vehicle, or manning a turret).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Direction vector, [] when it cannot aim <ARRAY>
 *
 * Public: No
 */

params ["_unit"];

private _veh = vehicle _unit;
if (_veh == _unit || {isTurnedOut _unit} || {[_unit] call CBA_fnc_canUseWeapon}) exitWith {
    private _weapon = currentWeapon _unit;
    [[], _unit weaponDirection _weapon] select (_weapon != "")
};

private _role = assignedVehicleRole _unit;
if (toLower (_role param [0, ""]) != "turret") exitWith {[]};
private _turretWeapon = _veh currentWeaponTurret (_role param [1, []]);
[[], _veh weaponDirection _turretWeapon] select (_turretWeapon != "")
