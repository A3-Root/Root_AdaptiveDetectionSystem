#include "..\script_component.hpp"
/*
 * Author: Root
 * Compares each visible item of the unit with the enemy reference kit of the observing side:
 * the very same item is reassuring, another camo of the same item is neutral, something they
 * never wear is suspicious. Weapons, launchers and backpacks only count from an exposed seat.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Observing group <GROUP>
 * 2: Seat exposes the unit <BOOL>
 *
 * Return Value:
 * [multiplier <NUMBER>, per-slot debug text <STRING>]
 *
 * Public: No
 */

params ["_unit", "_grp", "_exposed"];

private _reference = [_grp] call FUNC(gearReference);
if (_reference isEqualTo []) exitWith {[1, "no reference kit"]};

private _items = [_unit] call FUNC(gearItems);
private _weights = createHashMap;
{
    private _pair = _x splitString ":";
    _weights set [_pair param [0, ""], parseNumber (_pair param [1, "1"])];
} forEach ([MSET(gearSlotWeights)] call FUNC(parseList));

private _matchMult = MSET(gearMatchMult);
private _similarMult = MSET(gearSimilarMult);
private _mismatchMult = MSET(gearMismatchMult);
private _missingMult = MSET(gearMissingMult);
private _dbg = RADS_DEBUG;
private _mult = 1;
private _notes = [];

{
    private _slot = _x;
    private _visible = _exposed || {!(_slot in ["primary", "launcher", "backpack"])};
    (_reference select _forEachIndex) params [["_known", []], ["_families", []]];
    if (_visible && {_known isNotEqualTo []}) then {
        private _item = _items select _forEachIndex;
        private _result = switch (true) do {
            case (_item in _known): { "match" };
            case (_item == ""): { "missing" };
            case (([_slot, _item] call FUNC(gearFamily)) in _families): { "similar" };
            default { "mismatch" };
        };
        private _factor = switch (_result) do {
            case "match": { _matchMult };
            case "similar": { _similarMult };
            case "missing": { _missingMult };
            default { _mismatchMult };
        };
        _mult = _mult * (_factor ^ (_weights getOrDefault [_slot, 1]));
        if (_dbg) then { _notes pushBack format ["%1=%2", _slot, _result]; };
    };
} forEach GEAR_SLOTS;

[(_mult max MSET(gearMatchMin)) min MSET(gearMatchMax), _notes joinString " "]
