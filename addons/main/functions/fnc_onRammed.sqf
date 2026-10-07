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

if (RADS_DEBUG) then { ["RAM", format ["group rammed by covered vehicle (identify=%1, suspicion=%2)", MSET(ramCompromise), MSET(ramSuspicion)], _grp, _unit] call FUNC(debugLog); };

if (MSET(ramCompromise)) exitWith {
    [_grp, _unit, "rammed", MSET(bulletinOnHostile)] call FUNC(compromise);
};

private _entry = [_grp, _unit, false] call FUNC(classify);
if ((_entry select D_STATE) == ST_COMPROMISED) exitWith {};

_entry set [D_SUSP, ((_entry select D_SUSP) max MSET(ramSuspicion)) min (MSET(identifyThreshold) - 1)];
_entry set [D_LASTEXP, time];
if ((_entry select D_STATE) == ST_UNAWARE) then {
    [_grp, _entry, ST_SUSPICIOUS, format ["rammed by covered vehicle %1 at %2 km/h", typeOf vehicle _unit, round speed vehicle _unit]] call FUNC(setState);
    if (isPlayer _unit) then { [QGVAR(watched), [_grp], _unit] call CBA_fnc_targetEvent; };
};
[_grp, _entry, true] call FUNC(behaviourHooks);
[_grp, true] call FUNC(publishData);
if (RADS_DEBUG) then { [_entry, format ["t=%1 RAMMED -> suspicion %2 state %3", CBA_missionTime toFixed 1, (_entry select D_SUSP) toFixed 1, STATE_NAMES select (_entry select D_STATE)]] call FUNC(debugHistory); };
