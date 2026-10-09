#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Calls off an AI group's pursuit; the group returns to its own waypoints.
 *
 * Arguments:
 * 0: AI group or one of its units <GROUP, OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [group checkpointGuard] call root_ads_fnc_stopPursuit
 *
 * Public: Yes
 */

params [["_grp", grpNull, [grpNull, objNull]]];

if (_grp isEqualType objNull) then { _grp = group _grp; };
if (isNull _grp) exitWith {};

if (!local _grp) exitWith { [QGVAR(stopPursuit), [_grp], _grp] call CBA_fnc_targetEvent; };
[_grp, "called off (Zeus/API)"] call FUNC(pursuitEnd);
