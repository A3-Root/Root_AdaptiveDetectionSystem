#include "..\script_component.hpp"
/*
 * Author: Root
 * Reference kit an observing group compares players against: the mission's enemy gear list
 * (Gear Reference module/API), the group's own kit, or what every unit of its side wears.
 * Cached 30 s per group.
 *
 * Arguments:
 * 0: Observing group <GROUP>
 *
 * Return Value:
 * Per slot [classes <ARRAY>, model families <ARRAY>] in GEAR_SLOTS order, [] when nothing is known <ARRAY>
 *
 * Public: No
 */

params ["_grp"];

private _cache = _grp getVariable [QGVAR(gearRefCache), []];
if (_cache isNotEqualTo [] && {time < (_cache select 0)}) exitWith {_cache select 1};

private _side = side _grp;
private _mode = MSET(gearRefSource);
private _fnc_hasAny = { (_this findIf {_x isNotEqualTo []}) > -1 };

private _slots = [];
if (_mode != 0) then {
    private _index = (missionNamespace getVariable [QGVAR(gearRef), []]) findIf {(_x select 0) == _side};
    if (_index > -1) then { _slots = ((missionNamespace getVariable [QGVAR(gearRef), []]) select _index) select 1; };
};

if (_mode == 0 || {_mode == 2 && {!(_slots call _fnc_hasAny)}}) then {
    // what this group wears itself
    _slots = [[], [], [], [], [], [], []];
    {
        if (alive _x && {!isPlayer _x}) then {
            private _items = [_x] call FUNC(gearItems);
            { (_slots select _forEachIndex) pushBackUnique _x; } forEach _items;
        };
    } forEach (units _grp);

    // a lone sentry is a thin sample: fall back to the whole side
    if (_mode == 2 && {count (units _grp) < 2 || {!(_slots call _fnc_hasAny)}}) then {
        _slots = [_side] call FUNC(collectSideGear);
    };
};

private _result = [];
if (_slots call _fnc_hasAny) then {
    {
        private _slot = _x;
        private _known = _slots param [_forEachIndex, []];
        private _families = [];
        { if (_x != "") then { _families pushBackUnique ([_slot, _x] call FUNC(gearFamily)); }; } forEach _known;
        _result pushBack [_known, _families];
    } forEach GEAR_SLOTS;
};

_grp setVariable [QGVAR(gearRefCache), [time + 30, _result]];
_result
