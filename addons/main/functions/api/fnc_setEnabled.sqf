#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Turns RADS on or off for the mission (runtime override of the Enable setting), optionally
 * reverting after a duration. Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Enabled, nil = clear override <BOOL>
 * 1: Revert after (s), 0 = never <NUMBER> (default: 0)
 * 2: Delay before applying (s) <NUMBER> (default: 0)
 *
 * Return Value:
 * None
 *
 * Example:
 * [false, 300] call root_rads_fnc_setEnabled
 *
 * Public: Yes
 */

params ["_enabled", ["_duration", 0], ["_delay", 0]];

if (!isServer) exitWith { [QGVAR(api), ["setEnabled", _this]] call CBA_fnc_serverEvent; };

if (_delay > 0) exitWith {
    [{ [_this select 0, _this select 1] call API(setEnabled); }, [_enabled, _duration], _delay] call CBA_fnc_waitAndExecute;
};

private _previous = missionNamespace getVariable QGVAR(ov_enabled);
["enabled", _enabled] call API(setOverride);

if (_duration > 0) then {
    [{ ["enabled", _this] call API(setOverride); }, _previous, _duration] call CBA_fnc_waitAndExecute;
};
