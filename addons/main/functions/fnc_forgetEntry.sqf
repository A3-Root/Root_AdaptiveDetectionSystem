#include "..\script_component.hpp"
/*
 * Author: Root
 * Clean reset of a group's knowledge of a unit (forgetTarget). If the unit still has cover the
 * group is immediately fooled again.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Entry <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_entry"];

private _unit = _entry select D_UNIT;
_grp forgetTarget _unit;
private _veh = vehicle _unit;
if (_veh != _unit) then { _grp forgetTarget _veh; };

_entry set [D_SUSP, 0];
_entry set [D_STATE, ST_UNAWARE];
_entry set [D_PASSES, 0];
_entry set [D_STATIONARY, 0];
_entry set [D_VISIBLE, false];
_entry set [D_AGED, false];
_entry set [D_LASTEXP, -1000];
[_grp, _entry, false] call FUNC(behaviourHooks);

if (_unit getVariable [QGVAR(cover), false]) then { [_grp, _entry, true, "forgotten while still covered"] call FUNC(setIgnored); };

[_grp, true] call FUNC(publishData);
if (RADS_DEBUG) then { [_grp, _entry, "FORGOT", format ["no contact for %1 s (forgetTarget) -> UNAWARE, fooled again=%2", MSET(forgetAfter), _entry select D_IGNORED]] call FUNC(debugReport); };
