#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: removes one zone, zones near the module, or all zones.
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
private _pos = getPosATL _logic;
deleteVehicle _logic;

private _zones = missionNamespace getVariable [QMVAR(zones), []];
if (_zones isEqualTo []) exitWith {
    ["No RADS zones exist"] call zen_common_fnc_showMessage;
    playSound "FD_Start_F";
};

private _values = ["__near", "__all"];
private _labels = ["Zones near this position", "All zones"];
{
    _values pushBack (_x select Z_ID);
    _labels pushBack format ["%1 (%2, %3 m away)", [_x select Z_ID, _x select Z_LABEL] select ((_x select Z_LABEL) != ""), ["multiplier", "no cover", "safe haven"] select (_x select Z_MODE), round (_pos distance2D ((_x select Z_AREA) select 0))];
} forEach _zones;

[
    "RADS - Remove Detection Zones",
    [
        ["COMBO", ["Remove", ""], [_values, _labels, 0]],
        ["SLIDER:RADIUS", ["Near radius (m)", "Zones whose centre is within this radius (first option)."], [10, 5000, 200, 0, _pos, [1, 0, 0, 0.7]]]
    ],
    {
        params ["_results", "_pos"];
        _results params ["_choice", "_radius"];
        switch (_choice) do {
            case "__all": { ["all"] call API(removeZone); };
            case "__near": {
                {
                    if ((_pos distance2D ((_x select Z_AREA) select 0)) <= _radius) then { [_x select Z_ID] call API(removeZone); };
                } forEach (missionNamespace getVariable [QMVAR(zones), []]);
            };
            default { [_choice] call API(removeZone); };
        };
        ["RADS zones removed"] call zen_common_fnc_showMessage;
    },
    {},
    _pos
] call zen_dialog_fnc_create;
