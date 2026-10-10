#include "..\script_component.hpp"
/*
 * Author: Root
 * Starting suspicion of a group (setStartSuspicion / Starting Suspicion modules): the highest
 * value among its awake AI members, 0 when none is set. Suspicion of a covered unit starts at
 * this value and never decays below it.
 *
 * Arguments:
 * 0: Group <GROUP>
 *
 * Return Value:
 * Starting suspicion (%) <NUMBER>
 *
 * Public: No
 */

params ["_grp"];

private _floor = 0;
{
    if ([_x] call FUNC(isAwake)) then { _floor = _floor max (_x getVariable [QGVAR(startSusp), 0]); };
} forEach (units _grp);
_floor min (MSET(identifyThreshold) - 1)
