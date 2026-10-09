#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Orders an AI group to pursue a covered unit right now (chase on foot, or follow and stop it
 * in a vehicle, then inspect). Runs on the machine that owns the group.
 *
 * Arguments:
 * 0: AI group or one of its units <GROUP, OBJECT>
 * 1: Target unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [group checkpointGuard, player] call root_ads_fnc_startPursuit
 *
 * Public: Yes
 */

params [["_grp", grpNull, [grpNull, objNull]], ["_unit", objNull, [objNull]]];

if (_grp isEqualType objNull) then { _grp = group _grp; };
if (isNull _grp || {isNull _unit}) exitWith {};

if (!local _grp) exitWith { [QGVAR(startPursuit), [_grp, _unit], _grp] call CBA_fnc_targetEvent; };
[_grp, _unit, true] call FUNC(pursuitStart);
