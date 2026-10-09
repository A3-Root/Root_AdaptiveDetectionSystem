#include "..\script_component.hpp"
/*
 * Author: Root
 * 3DEN: detection zone from the module area. A repeatable trigger removes it on deactivation.
 *
 * Arguments:
 * 0: Module logic <OBJECT>
 * 1: Synced units <ARRAY>
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic", ["_units", []], ["_activated", true]];

if (!isServer) exitWith {};

private _id = format ["ads_eden_%1", _logic call BIS_fnc_netId];
if (!_activated) exitWith { [_id] call API(removeZone); };

(_logic getVariable ["objectArea", [200, 200, 0, false, -1]]) params ["_a", "_b", "_angle", "_rect"];

// Safe haven truce: -1 CBA defaults, 0 none, 1 the module's own options
private _truceMode = _logic getVariable ["ROOT_ADS_Z_truce", -1];
private _truce = switch (_truceMode) do {
    case 0: { [false, 0, 0, false, 0, false] };
    case 1: {
        [true,
            _logic getVariable ["ROOT_ADS_Z_truceStay", 0],
            _logic getVariable ["ROOT_ADS_Z_truceWarn", 60],
            _logic getVariable ["ROOT_ADS_Z_truceCareless", true],
            _logic getVariable ["ROOT_ADS_Z_truceScope", 1],
            _logic getVariable ["ROOT_ADS_Z_truceAim", false]]
    };
    default { [] };
};

[
    [getPosATL _logic, _a, _b, _angle, _rect],
    _logic getVariable ["ROOT_ADS_Z_mode", 0],
    _logic getVariable ["ROOT_ADS_Z_build", 2],
    _logic getVariable ["ROOT_ADS_Z_decay", 1],
    [_logic getVariable ["ROOT_ADS_Z_sides", ""]] call FUNC(parseSides),
    _logic getVariable ["ROOT_ADS_Z_delay", 0],
    _logic getVariable ["ROOT_ADS_Z_duration", 0],
    _logic getVariable ["ROOT_ADS_Z_hourFrom", -1],
    _logic getVariable ["ROOT_ADS_Z_hourTo", -1],
    _logic getVariable ["ROOT_ADS_Z_label", ""],
    _id,
    _truce
] call API(addZone);
