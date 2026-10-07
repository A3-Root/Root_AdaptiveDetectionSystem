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

([_unit] call FUNC(gearInfo)) params ["_uSide", "_helmet", "_vest", "_nvg", "_weapon"];

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
