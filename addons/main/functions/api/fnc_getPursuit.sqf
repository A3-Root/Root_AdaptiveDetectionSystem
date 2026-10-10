#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Who an AI group is pursuing (works on every machine). The phase is only known where the
 * group is local.
 *
 * Arguments:
 * 0: AI group or one of its units <GROUP, OBJECT>
 *
 * Return Value:
 * [target <OBJECT>, phase <STRING> ("CHASE", "FOLLOW", "INSPECT", "" when unknown or none),
 *  suspicion held during the stop request <NUMBER> (-1 = not held or unknown)]
 *
 * Example:
 * [group checkpointGuard] call root_ads_fnc_getPursuit
 *
 * Public: Yes
 */

params [["_grp", grpNull, [grpNull, objNull]]];

if (_grp isEqualType objNull) then { _grp = group _grp; };
if (isNull _grp) exitWith {[objNull, ""]};

private _pursuit = _grp getVariable [QGVAR(pursuit), createHashMap];
[_grp getVariable [QGVAR(pursuitTarget), objNull], _pursuit getOrDefault ["phase", ""], _pursuit getOrDefault ["freeze", -1]]
