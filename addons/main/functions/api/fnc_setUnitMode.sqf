#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Per-unit cover profile. Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Mode: "normal", "exempt" (never covered), "force" (covered in any vehicle, ignores side/heat/zones) <STRING> (default: "normal")
 * 2: Suspicion build multiplier against this unit <NUMBER> (default: 1)
 * 3: Revert to normal after (s), 0 = never <NUMBER> (default: 0)
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, "normal", 0.5] call root_rads_fnc_setUnitMode
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_mode", "normal", [""]], ["_mult", 1, [0]], ["_duration", 0]];

if (!isServer) exitWith { [QGVAR(api), ["setUnitMode", _this]] call CBA_fnc_serverEvent; };
if (isNull _unit) exitWith {};

_mode = toLower _mode;
_unit setVariable [QGVAR(exempt), _mode == "exempt", true];
_unit setVariable [QGVAR(forceCover), _mode == "force", true];
_unit setVariable [QGVAR(unitMult), _mult, true];

// Forced AI never runs the player cover loop: whichever machine owns them keeps their cover updated
if (_mode == "force" && {!isPlayer _unit}) then {
    private _extra = (missionNamespace getVariable [QGVAR(extraUnits), []]) select {alive _x};
    _extra pushBackUnique _unit;
    missionNamespace setVariable [QGVAR(extraUnits), _extra, true];
};

if (_duration > 0 && {_mode != "normal" || _mult != 1}) then {
    [{ [_this, "normal", 1] call API(setUnitMode); }, _unit, _duration] call CBA_fnc_waitAndExecute;
};
