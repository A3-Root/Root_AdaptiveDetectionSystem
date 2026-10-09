#include "..\script_component.hpp"
/*
 * Author: Root
 * Exposure multiplier from the unit's visible gear. Two parts, picked by the gear compare mode:
 * the general look (civilian clothes, enemy uniform, helmet, vest, NVG, weapon) and how closely
 * each visible item matches what the observing side itself wears. In the default mode the item
 * matching only refines a disguise (their own or an allied uniform): enemy fatigues or civilian
 * clothes are already judged by the general look and are not penalised a second time.
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
([_unit] call FUNC(gearInfo)) params ["_uSide", "_helmet", "_vest", "_nvg", "_weapon"];

if (_compare != 1) then {
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

// 0 general look, 1 item matching, 2 general look + matching for disguise kit, 3 both always
private _text = "";
private _disguised = _uSide == sideUnknown || {_uSide != civilian && {(_side getFriend _uSide) >= 0.6}};
if (_compare == 2 && !_disguised) then { _text = "matching skipped (not wearing their kit)"; };
if (_compare == 1 || _compare == 3 || {_compare == 2 && _disguised}) then {
    ([_unit, _grp, _exposed] call FUNC(gearMatch)) params ["_matchMult", "_matchText"];
    _mult = _mult * _matchMult;
    _text = _matchText;
};

[_mult, _text]
