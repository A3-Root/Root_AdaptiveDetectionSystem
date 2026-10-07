#include "..\script_component.hpp"
/*
 * Author: Root
 * Event (every machine): a covered vehicle rammed a member of a group. The group owner makes the
 * group SUSPICIOUS at once (or identifies the driver, per setting).
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Driver <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_unit"];

if (isNull _grp || {!local _grp} || {isNull _unit} || {isPlayer (leader _grp)}) exitWith {};

if (MSET(ramCompromise)) exitWith {
    [_grp, _unit, "rammed", MSET(bulletinOnHostile)] call FUNC(compromise);
};

private _entry = [_grp, _unit, false] call FUNC(classify);
if ((_entry select D_STATE) == ST_COMPROMISED) exitWith {};

_entry set [D_SUSP, ((_entry select D_SUSP) max MSET(ramSuspicion)) min (MSET(identifyThreshold) - 1)];
_entry set [D_LASTEXP, time];
if ((_entry select D_STATE) == ST_UNAWARE) then {
    _entry set [D_STATE, ST_SUSPICIOUS];
    if (isPlayer _unit) then { [QGVAR(watched), [_grp], _unit] call CBA_fnc_targetEvent; };
};
[_grp, _entry, true] call FUNC(behaviourHooks);
[_grp, true] call FUNC(publishData);
RLOG_2("%1 rammed by %2",_grp,_unit);
