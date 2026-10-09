#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Sets how a vehicle disguises its occupants. Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Mode: "auto" (by side/settings), "disguise" (always), "never", "burned" (recognised on sight by everyone) <STRING>
 * 2: Revert to "auto" after (s), 0 = never <NUMBER> (default: 0)
 * 3: Suspicion multiplier of this vehicle's look, -1 = by faction/side (settings) <NUMBER> (default: -1)
 * 4: Armored (crew cannot be seen): -1 auto, 0 no, 1 yes <NUMBER> (default: -1)
 * 5: Optics range multiplier for AI watching from this vehicle's gunner / commander seats, -1 = setting <NUMBER> (default: -1)
 *
 * Return Value:
 * None
 *
 * Example:
 * [myTruck, "disguise"] call root_ads_fnc_setVehicleMode
 * [enemyBTR, "auto", 0, -1, -1, 2.5] call root_ads_fnc_setVehicleMode
 *
 * Public: Yes
 */

params [["_veh", objNull, [objNull]], ["_mode", "auto", [""]], ["_duration", 0], ["_mult", -1, [0]], ["_armored", -1, [0]], ["_optics", -1, [0]]];

if (!isServer) exitWith { [QGVAR(api), ["setVehicleMode", _this]] call CBA_fnc_serverEvent; };
if (isNull _veh) exitWith {};

_mode = toLower _mode;
if !(_mode in ["auto", "disguise", "never", "burned"]) then { _mode = "auto"; };
_veh setVariable [QGVAR(vehMode), _mode, true];
_veh setVariable [QGVAR(vehMult), _mult, true];
_veh setVariable [QGVAR(armored), round _armored, true];
_veh setVariable [QGVAR(opticsMult), _optics, true];

if (_duration > 0 && _mode != "auto") then {
    [{
        params ["_veh", "_mode"];
        if ((_veh getVariable [QGVAR(vehMode), "auto"]) == _mode) then { _veh setVariable [QGVAR(vehMode), "auto", true]; };
    }, [_veh, _mode], _duration] call CBA_fnc_waitAndExecute;
};
