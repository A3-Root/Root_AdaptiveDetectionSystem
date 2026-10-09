#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: manual radio bulletin about the unit/vehicle the module is placed on (burn it, mark wanted),
 * or clear its status.
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
private _pos = getPosATL _logic;
deleteVehicle _logic;

if (isNull _target) exitWith {
    [LLSTRING(msgPlaceUnit)] call zen_common_fnc_showMessage;
    playSound "FD_Start_F";
};

[
    LLSTRING(bulletinTitle),
    [
        ["COMBO", [LLSTRING(action), ""], [[0, 1], [LLSTRING(broadcast), LLSTRING(clearStatus)], 0]],
        ["SIDES", [LLSTRING(receivingSides), LLSTRING(receivingSides_desc)], [east]],
        ["CHECKBOX", [LLSTRING(burnVehicle), LLSTRING(burnVehicle_desc)], true],
        ["CHECKBOX", [LLSTRING(markWanted), LLSTRING(markWanted_desc)], true],
        ["CHECKBOX", [LLSTRING(alertArea), LLSTRING(alertArea_desc)], true],
        ["SLIDER", [LLSTRING(durationS), LLSTRING(bulletinDuration_desc)], [0, 7200, 0, 0]],
        ["SLIDER:RADIUS", [LLSTRING(range), LLSTRING(bulletinRange_desc)], [0, 30000, 0, 0, _pos, [1, 0.5, 0, 0.7]]]
    ],
    {
        params ["_results", "_args"];
        _args params ["_target", "_pos"];
        _results params ["_action", "_sides", "_burn", "_wanted", "_alert", "_duration", "_range"];
        if (_sides isEqualTo []) then { _sides = [west, east, independent]; };
        private _units = [[_target]] call FUNC(resolveUnits);
        private _veh = vehicle _target;

        if (_action == 1) exitWith {
            [_target, _sides, true] call API(clearBulletins);
            { [_x, _sides, false] call API(clearBulletins); } forEach _units;
            [LLSTRING(bulletinCleared)] call zen_common_fnc_showMessage;
        };

        private _time = [-1, _duration] select (_duration > 0);
        {
            private _side = _x;
            if (_burn && {!(_veh isKindOf "CAManBase")}) then { [_veh, _side, _time, _range, _pos] call API(burnVehicle); };
            if (_wanted) then { { [_x, _side, _time, _range, _pos] call API(markWanted); } forEach _units; };
            if (_alert) then {
                // reuse the bulletin event for the area alert only (burn/wanted already handled)
                { [QMVAR(bulletin), [_side, _pos, _range, _x, objNull, "areaOnly", grpNull]] call CBA_fnc_globalEvent; } forEach _units;
            };
        } forEach _sides;
        [LLSTRING(bulletinSent)] call zen_common_fnc_showMessage;
    },
    {},
    [_target, _pos]
] call zen_dialog_fnc_create;
