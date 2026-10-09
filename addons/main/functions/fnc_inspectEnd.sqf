#include "..\script_component.hpp"
/*
 * Author: Root
 * The inspection is over without an identification: the unit is cleared. Suspicion drops to the
 * all-clear level for this group and, through a sync, for its neighbours; no new pursuit of that
 * unit for the cooldown. The group remounts and returns to its route.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Outcome <STRING> (default: "cleared")
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", ["_outcome", "cleared"]];

private _pursuit = _grp getVariable QGVAR(pursuit);
if (isNil "_pursuit") exitWith {};

private _unit = _pursuit get "target";
private _entry = ([_grp] call FUNC(getData)) getOrDefault [hashValue _unit, []];
if (_entry isNotEqualTo [] && {(_entry select D_STATE) != ST_COMPROMISED}) then {
    private _clear = MSET(inspectClearSusp);
    _entry set [D_SUSP, (_entry select D_SUSP) min _clear];
    _entry set [D_SYNCSENT, _entry select D_SUSP];
    _entry set [D_CLEARED, time + MSET(inspectCooldown)];
    [_grp, _entry, ST_UNAWARE, format ["inspection passed (%1)", _outcome]] call FUNC(setState);
    [_grp, _entry, false] call FUNC(behaviourHooks);
    [_grp, true] call FUNC(publishData);
    // the neighbours hear it too
    if (MSET(syncEnabled)) then {
        [_grp, [[_unit, _entry select D_SUSP, [_unit] call FUNC(appearanceSig)]], true] call FUNC(syncSuspicion);
    };
};

{ [QGVAR(inspected), [_grp, false], _x] call CBA_fnc_targetEvent; } forEach ((crew vehicle _unit) select {isPlayer _x});
[_grp, "inspection " + _outcome] call FUNC(pursuitEnd);
