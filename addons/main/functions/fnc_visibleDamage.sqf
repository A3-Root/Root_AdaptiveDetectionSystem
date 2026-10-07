#include "..\script_component.hpp"
/*
 * Author: Root
 * How damaged a vehicle looks (0-1): overall damage, or its worst hit point (holed glass, body,
 * wheels, tracks...) slightly discounted, or burning. Cached for 2 s.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * Visible damage <NUMBER>
 *
 * Public: No
 */

params ["_veh"];

private _cache = _veh getVariable [QGVAR(visDamage), [-1, 0]];
if (time <= (_cache select 0)) exitWith { _cache select 1 };

private _hitPoints = (getAllHitPointsDamage _veh) param [2, []];
private _worst = if (_hitPoints isEqualTo []) then {0} else { selectMax _hitPoints };
private _value = ((damage _veh) max (0.8 * _worst)) min 1;
if (isBurning _veh) then { _value = 1; };

_veh setVariable [QGVAR(visDamage), [time + 2, _value]];
_value
