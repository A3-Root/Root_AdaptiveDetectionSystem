#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: place on an AI unit to send its group after an undercover unit (chase on foot, or
 * follow, stop and inspect when mounted), or to call off its current pursuit.
 *
 * Arguments:
 * 0: Module logic <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic"];

if (!hasInterface) exitWith {};
private _target = attachedTo _logic;
deleteVehicle _logic;

private _grp = if (isNull _target) then {grpNull} else { group (effectiveCommander _target) };
if (isNull _grp || {isPlayer (leader _grp)}) exitWith {
    [LLSTRING(msgPlaceAI)] call zen_common_fnc_showMessage;
    playSound "FD_Start_F";
};

private _covered = (allUnits select {_x getVariable [QMVAR(cover), false]}) select {[side _grp, _x] call MFUNC(isHostile)};
private _values = [objNull] + _covered;
private _labels = [LLSTRING(pursuitCallOff)] + (_covered apply {format ["%1 (%2)", name _x, getText (configOf vehicle _x >> "displayName")]});
if (_covered isEqualTo []) then { [LLSTRING(pursuitNoTargets)] call zen_common_fnc_showMessage; };

[
    format [LLSTRING(pursuitOrderTitle), groupId _grp],
    [
        ["COMBO", [LLSTRING(pursuitTarget), LLSTRING(pursuitTarget_desc)], [_values, _labels, parseNumber (_covered isNotEqualTo [])]]
    ],
    {
        params ["_results", "_grp"];
        _results params ["_unit"];
        if (isNull _unit) exitWith {
            [_grp] call API(stopPursuit);
            [LLSTRING(pursuitStopped)] call zen_common_fnc_showMessage;
        };
        [_grp, _unit] call API(startPursuit);
        [LLSTRING(pursuitOrdered)] call zen_common_fnc_showMessage;
    },
    {},
    _grp
] call zen_dialog_fnc_create;
