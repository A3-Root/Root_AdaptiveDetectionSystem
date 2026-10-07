#include "..\script_component.hpp"
/*
 * Author: Root
 * Exposure multiplier for the unit's seat, and whether the seat exposes the unit's weapon.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 *
 * Return Value:
 * [multiplier <NUMBER>, exposed <BOOL>]
 *
 * Public: No
 */

params ["_unit", "_veh"];

if (isTurnedOut _unit) exitWith { [MSET(seatTurnedOut), true] };

private _role = toLower ((assignedVehicleRole _unit) param [0, ""]);
if (_role in ["cargo", "turret"] && {[_unit] call CBA_fnc_canUseWeapon}) exitWith { [MSET(seatFFV), true] };

private _mult = switch (true) do {
    case (_unit == driver _veh): { MSET(seatDriver) };
    case (_role == "turret"): { MSET(seatTurret) };
    default { MSET(seatCargo) };
};

[_mult, [_veh] call FUNC(isOpenVehicle)]
