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
    [LLSTRING(noZones)] call zen_common_fnc_showMessage;
    playSound "FD_Start_F";
};

private _values = ["__near", "__all"];
private _labels = [LLSTRING(removeNear), LLSTRING(removeAll)];
{
    _values pushBack (_x select Z_ID);
    _labels pushBack format [LLSTRING(zoneEntry), [_x select Z_ID, _x select Z_LABEL] select ((_x select Z_LABEL) != ""), [LLSTRING(zoneMult), LLSTRING(zoneNoCover), LLSTRING(zoneSafe)] select (_x select Z_MODE), round (_pos distance2D ((_x select Z_AREA) select 0))];
} forEach _zones;

[
    LLSTRING(removeTitle),
    [
        ["COMBO", [LLSTRING(remove), ""], [_values, _labels, 0]],
        ["SLIDER:RADIUS", [LLSTRING(removeRadius), LLSTRING(removeRadius_desc)], [10, 5000, 200, 0, _pos, [1, 0, 0, 0.7]]]
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
        [LLSTRING(zonesRemoved)] call zen_common_fnc_showMessage;
    },
    {},
    _pos
] call zen_dialog_fnc_create;
