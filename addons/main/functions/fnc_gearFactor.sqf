#include "..\script_component.hpp"
/*
 * Author: Root
 * Exposure multiplier from the unit's visible gear. Two parts, picked by the gear compare mode:
 * the general look (civilian clothes, enemy uniform, helmet, vest, NVG, weapon) and how closely
 * each visible item matches what the observing side itself wears.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Observing group <GROUP>
 * 2: Seat exposes the unit's weapons <BOOL>
 *
 * Return Value:
 * [multiplier <NUMBER>, per-slot debug text <STRING>]
 *
 * Public: No
 */

params ["_unit", "_grp", "_exposed"];

if (!MSET(gearEnabled)) exitWith {[1, ""]};

private _side = side _grp;
private _compare = MSET(gearCompareMode);
private _mult = 1;

if (_compare != 1) then {
    ([_unit] call FUNC(gearInfo)) params ["_uSide", "_helmet", "_vest", "_nvg", "_weapon"];
    _mult = switch (true) do {
        case (_uSide == sideUnknown): { 1 };
        case (_uSide == civilian): { MSET(uniformCivMult) };
        case ((_side getFriend _uSide) >= 0.6): { MSET(uniformObserverMult) };
        default { MSET(uniformHostileMult) };
    };
    if (_helmet) then { _mult = _mult * MSET(helmetMult); };
    if (_vest) then { _mult = _mult * MSET(vestMult); };
    if (_nvg && {sunOrMoon > 0.5}) then { _mult = _mult * MSET(nvgDayMult); };
    if (_exposed && _weapon) then { _mult = _mult * MSET(weaponVisibleMult); };
};

private _text = "";
if (_compare != 0) then {
    ([_unit, _grp, _exposed] call FUNC(gearMatch)) params ["_matchMult", "_matchText"];
    _mult = _mult * _matchMult;
    _text = _matchText;
};

[_mult, _text]
