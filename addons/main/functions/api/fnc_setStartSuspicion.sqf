#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Starting suspicion of specific AI units (a jumpy sentry, a guard who has been warned). Their
 * group's suspicion of any covered unit starts at this value and never falls below it, even
 * while unaware; it still builds from there and the normal thresholds apply. The group uses
 * the highest value of its awake members. Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: AI unit, vehicle (its crew) or group <OBJECT|GROUP>
 * 1: Starting suspicion (%), 0 or less = clear <NUMBER>
 * 2: Apply to the whole group instead of only this unit <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Example:
 * [gateGuard, 30] call root_ads_fnc_setStartSuspicion
 * [group checkpointLeader, 50, true] call root_ads_fnc_setStartSuspicion
 * [gateGuard, 0] call root_ads_fnc_setStartSuspicion
 *
 * Public: Yes
 */

params [["_target", objNull, [objNull, grpNull]], ["_percent", 0, [0]], ["_wholeGroup", false, [false]]];

if (!isServer) exitWith { [QGVAR(api), ["setStartSuspicion", _this]] call CBA_fnc_serverEvent; };

private _units = switch (true) do {
    case (_target isEqualType grpNull): { units _target };
    case (_wholeGroup): { units group effectiveCommander _target };
    case (_target isKindOf "CAManBase"): { [_target] };
    default { crew _target };
};
_units = _units select {!isPlayer _x};
if (_units isEqualTo []) exitWith {};

private _value = (_percent min (MSET(identifyThreshold) - 1)) max 0;
{ _x setVariable [QGVAR(startSusp), [_value, nil] select (_value <= 0), true]; } forEach _units;

RLOG_3("start suspicion %1 percent set for %2 (group %3)",_value,_units apply {name _x},groupId group (_units select 0));
