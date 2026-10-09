#include "..\script_component.hpp"
/*
 * Author: Root
 * Every item worn or carried by the AI of a side, per gear slot (cached 60 s per side).
 *
 * Arguments:
 * 0: Side <SIDE>
 * 1: Ignore the cache <BOOL> (default: false)
 *
 * Return Value:
 * Per slot class lists in GEAR_SLOTS order <ARRAY>
 *
 * Public: No
 */

params ["_side", ["_fresh", false]];

if (isNil QGVAR(sideGearCache)) then { GVAR(sideGearCache) = createHashMap; };
private _key = str _side;
private _cached = GVAR(sideGearCache) getOrDefault [_key, []];
if (!_fresh && {_cached isNotEqualTo []} && {time < (_cached select 0)}) exitWith {_cached select 1};

private _slots = [[], [], [], [], [], [], []];
{
    if (alive _x && {!isPlayer _x} && {side group _x == _side}) then {
        private _items = [_x] call FUNC(gearItems);
        { (_slots select _forEachIndex) pushBackUnique _x; } forEach _items;
    };
} forEach allUnits;

GVAR(sideGearCache) set [_key, [time + 60, _slots]];
RLOG_2("collected the gear of %1 AI units of %2",{side group _x == _side} count allUnits,_side);
_slots
