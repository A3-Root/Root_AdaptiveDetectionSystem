#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: disguise mode, burned sides, look multiplier and armor of the vehicle the module is placed on.
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
    [LLSTRING(msgPlaceVehicle)] call zen_common_fnc_showMessage;
    playSound "FD_Start_F";
};

private _current = _target getVariable [QMVAR(vehMode), "auto"];
private _modes = ["auto", "disguise", "never", "burned"];
private _armored = _target getVariable [QMVAR(armored), -1];

[
    format [LLSTRING(vehicleTitle), getText (configOf _target >> "displayName")],
    [
        ["COMBO", [LLSTRING(mode), LLSTRING(vehMode_desc)], [_modes, [LLSTRING(auto), LLSTRING(always), LLSTRING(never), LLSTRING(burned)], (_modes find _current) max 0]],
        ["SIDES", [LLSTRING(burnSides), LLSTRING(burnSides_desc)], []],
        ["SLIDER", [LLSTRING(suspMult), LLSTRING(vehMult_desc)], [-1, 10, _target getVariable [QMVAR(vehMult), -1], 2]],
        ["COMBO", [LLSTRING(armored), LLSTRING(armored_desc)], [[-1, 0, 1], [LLSTRING(auto), LLSTRING(notArmored), LLSTRING(armored)], ([-1, 0, 1] find _armored) max 0]],
        ["SLIDER", [LLSTRING(optics), LLSTRING(optics_desc)], [-1, 5, _target getVariable [QMVAR(opticsMult), -1], 2]],
        ["SLIDER", [LLSTRING(durationS), LLSTRING(vehDuration_desc)], [0, 7200, 0, 0]],
        ["CHECKBOX", [LLSTRING(clearBurned), LLSTRING(clearBurned_desc)], false]
    ],
    {
        params ["_results", "_veh"];
        _results params ["_mode", "_sides", "_mult", "_armored", "_optics", "_duration", "_clear"];
        if (_clear) then { [_veh, [], false] call API(clearBulletins); };
        [_veh, _mode, _duration, [-1, _mult] select (_mult >= 0), _armored, [-1, _optics] select (_optics >= 0)] call API(setVehicleMode);
        { [_veh, _x, [-1, _duration] select (_duration > 0)] call API(burnVehicle); } forEach _sides;
        [LLSTRING(vehicleUpdated)] call zen_common_fnc_showMessage;
    },
    {},
    _target
] call zen_dialog_fnc_create;
