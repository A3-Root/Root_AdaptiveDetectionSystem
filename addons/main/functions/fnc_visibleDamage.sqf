#include "..\script_component.hpp"
/*
 * Author: Root
 * How damaged a vehicle looks (0-1): overall damage, or how much of the vehicle's hit points
 * (glass, body, wheels, tracks...) are damaged on average, or burning. A single broken light or
 * window barely registers; many holed panels do. Cached for 2 s.
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
private _spread = 0;
if (_hitPoints isNotEqualTo []) then {
    private _total = 0;
    { _total = _total + _x; } forEach _hitPoints;
    _spread = 2 * _total / count _hitPoints;
};
private _value = ((damage _veh) max _spread) min 1;
if (isBurning _veh) then { _value = 1; };

_veh setVariable [QGVAR(visDamage), [time + 2, _value]];
_value
