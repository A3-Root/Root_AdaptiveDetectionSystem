#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Sets how a vehicle disguises its occupants. Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Mode: "auto" (by side/settings), "disguise" (always), "never", "burned" (recognised on sight by everyone) <STRING>
 * 2: Revert to "auto" after (s), 0 = never <NUMBER> (default: 0)
 *
 * Return Value:
 * None
 *
 * Example:
 * [myTruck, "disguise"] call root_rads_fnc_setVehicleMode
 *
 * Public: Yes
 */

params [["_veh", objNull, [objNull]], ["_mode", "auto", [""]], ["_duration", 0]];

if (!isServer) exitWith { [QGVAR(api), ["setVehicleMode", _this]] call CBA_fnc_serverEvent; };
if (isNull _veh) exitWith {};

_mode = toLower _mode;
if !(_mode in ["auto", "disguise", "never", "burned"]) then { _mode = "auto"; };
_veh setVariable [QGVAR(vehMode), _mode, true];

if (_duration > 0 && _mode != "auto") then {
    [{
        params ["_veh", "_mode"];
        if ((_veh getVariable [QGVAR(vehMode), "auto"]) == _mode) then { _veh setVariable [QGVAR(vehMode), "auto", true]; };
    }, [_veh, _mode], _duration] call CBA_fnc_waitAndExecute;
};
