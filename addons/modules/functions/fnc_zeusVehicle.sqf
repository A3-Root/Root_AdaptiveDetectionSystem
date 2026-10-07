#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: disguise behaviour of the vehicle the module is placed on.
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
private _target = vehicle (attachedTo _logic);
deleteVehicle _logic;

if (isNull _target || {_target isKindOf "CAManBase"}) exitWith {
    ["Place the module on a vehicle"] call zen_common_fnc_showMessage;
    playSound "FD_Start_F";
};

private _current = _target getVariable [QMVAR(vehMode), "auto"];
private _modes = ["auto", "disguise", "never", "burned"];

[
    format ["RADS - Vehicle Disguise - %1", getText (configOf _target >> "displayName")],
    [
        ["COMBO", ["Mode", "Auto: by side and settings. Always disguise. Never disguise. Burned: recognised on sight by everyone."], [_modes, ["Auto", "Always disguise", "Never disguise", "Burned (all sides)"], (_modes find _current) max 0]],
        ["SIDES", ["Burned for sides", "Sides that recognise this vehicle on sight (in addition to the mode)."], []],
        ["SLIDER", ["Duration (s)", "Mode/burn reverts after this long. 0 = permanent (burn uses the setting)."], [0, 7200, 0, 0]],
        ["CHECKBOX", ["Clear burned status", "Forget every side's burn of this vehicle first."], false]
    ],
    {
        params ["_results", "_veh"];
        _results params ["_mode", "_sides", "_duration", "_clear"];
        if (_clear) then { [_veh, [], false] call API(clearBulletins); };
        [_veh, _mode, _duration] call API(setVehicleMode);
        { [_veh, _x, [-1, _duration] select (_duration > 0)] call API(burnVehicle); } forEach _sides;
        ["RADS vehicle updated"] call zen_common_fnc_showMessage;
    },
    {},
    _target
] call zen_dialog_fnc_create;
