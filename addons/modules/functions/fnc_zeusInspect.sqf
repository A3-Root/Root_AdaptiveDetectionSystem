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

private _lines = [format ["<t size='1.2'>%1</t>", LLSTRING(inspectTitle)]];
{
    if (_x getVariable [QMVAR(cover), false]) then {
        ([_x] call API(getStatus)) params ["", "_heat", "_wanted", "_max", "_identified"];
        _lines pushBack format [LLSTRING(inspectLine), name _x, _max, _identified, ["", " " + LLSTRING(inspectWanted)] select (_wanted isNotEqualTo [])];
    };
} forEach (allPlayers - entities "HeadlessClient_F");
if (count _lines == 1) then { _lines pushBack LLSTRING(inspectNobody); };
if !(["debugPublish"] call FUNC(settingValue)) then { _lines pushBack format ["<t size='0.8'>%1</t>", LLSTRING(inspectNote)]; };
hint parseText (_lines joinString "<br/>");
