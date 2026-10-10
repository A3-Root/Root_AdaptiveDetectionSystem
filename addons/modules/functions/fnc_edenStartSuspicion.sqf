#include "..\script_component.hpp"
/*
 * Author: Root
 * 3DEN: starting suspicion of the synced AI units (vehicles: their crew), optionally their
 * whole groups.
 *
 * Arguments:
 * 0: Module logic <OBJECT>
 * 1: Synced units <ARRAY>
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic", ["_units", []], ["_activated", true]];

if (!isServer || {!_activated}) exitWith {};

private _percent = _logic getVariable ["ROOT_ADS_SS_percent", 30];
private _wholeGroup = _logic getVariable ["ROOT_ADS_SS_group", false];
{
    if (!isPlayer (effectiveCommander _x) && {_x isKindOf "CAManBase" || {_x isKindOf "AllVehicles"}}) then {
        [_x, _percent, _wholeGroup] call API(setStartSuspicion);
    };
} forEach (synchronizedObjects _logic);
