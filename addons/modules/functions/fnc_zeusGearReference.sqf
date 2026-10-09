#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: view, collect, edit and apply the enemy gear reference of a side. Step one picks the side
 * and where to start (current list / collect from that side's AI now / clear), step two shows the
 * seven CSV lists ready to edit, copy and apply.
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
deleteVehicle _logic;

[
    LLSTRING(gearTitle),
    [
        ["COMBO", [LLSTRING(gearSide), LLSTRING(gearSide_desc)], [[east, west, independent], ["OPFOR", "BLUFOR", "INDFOR"], 0]],
        ["COMBO", [LLSTRING(gearStart), LLSTRING(gearStart_desc)], [[0, 1, 2], [LLSTRING(gearCurrent), LLSTRING(gearCollect), LLSTRING(gearClear)], 1]]
    ],
    {
        params ["_results"];
        _results params ["_side", "_start"];
        if (_start == 2) exitWith {
            [_side, []] call API(setGearReference);
            [format [LLSTRING(gearClearedMsg), _side]] call zen_common_fnc_showMessage;
        };
        private _lists = if (_start == 1) then { [_side] call API(collectSideGear) } else { [_side] call API(getGearReference) };
        private _labels = [LLSTRING(gearUniform), LLSTRING(gearVest), LLSTRING(gearHeadgear), LLSTRING(gearPrimary), LLSTRING(gearLauncher), LLSTRING(gearBackpack), LLSTRING(gearFacewear)];
        private _controls = [];
        { _controls pushBack ["EDIT", [_x, LLSTRING(gearList_desc)], [_lists select _forEachIndex]]; } forEach _labels;
        _controls pushBack ["CHECKBOX", [LLSTRING(gearCopy), LLSTRING(gearCopy_desc)], false];

        // the first dialog is still closing
        [{
            params ["_side", "_controls"];
            [
                format [LLSTRING(gearEditTitle), _side],
                _controls,
                {
                    params ["_results", "_side"];
                    private _copy = _results deleteAt 7;
                    private _text = format ["// RADS enemy gear reference for %1 (uniform, vest, headgear, primary, launcher, backpack, facewear)%2[%1, %3] call root_ads_fnc_setGearReference;", _side, endl, str _results];
                    diag_log text _text;
                    if (_copy) then { copyToClipboard _text; };
                    [_side, _results] call API(setGearReference);
                    [format [LLSTRING(gearApplied), _side]] call zen_common_fnc_showMessage;
                },
                {},
                _side
            ] call zen_dialog_fnc_create;
        }, [_side, _controls]] call CBA_fnc_execNextFrame;
    },
    {}
] call zen_dialog_fnc_create;
