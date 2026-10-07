#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: shows the RADS status of the unit the module is placed on (with per-group suspicion), or a
 * summary of every covered player.
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
deleteVehicle _logic;

private _unit = if (isNull _target) then {objNull} else {
    if (_target isKindOf "CAManBase") then {_target} else {effectiveCommander _target}
};

if (!isNull _unit) exitWith {
    hint parseText ([_unit, true] call MFUNC(coverStatusText));
};

private _lines = ["<t size='1.2'>RADS - covered players</t>"];
{
    if (_x getVariable [QMVAR(cover), false]) then {
        ([_x] call API(getStatus)) params ["", "_heat", "_wanted", "_max", "_identified"];
        _lines pushBack format ["%1: max %2, identified by %3%4", name _x, _max, _identified, ["", " (wanted)"] select (_wanted isNotEqualTo [])];
    };
} forEach (allPlayers - entities "HeadlessClient_F");
if (count _lines == 1) then { _lines pushBack "Nobody is undercover."; };
if !(["debugPublish"] call FUNC(settingValue)) then { _lines pushBack "<t size='0.8'>Values refresh on state changes (enable 'Publish suspicion' for live values).</t>"; };
hint parseText (_lines joinString "<br/>");
