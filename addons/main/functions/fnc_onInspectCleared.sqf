#include "..\script_component.hpp"
/*
 * Author: Root
 * Event (every machine): a group cleared a vehicle in an inspection. Local groups still pursuing
 * or inspecting someone in it accept that: inspectors clear it too, followers stand down.
 *
 * Arguments:
 * 0: Inspected vehicle <OBJECT>
 * 1: Clearing group <GROUP>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_veh", "_source"];

if (isNull _veh) exitWith {};
{
    private _grp = _x;
    private _pursuit = _grp getVariable QGVAR(pursuit);
    if (_grp != _source && {local _grp} && {!isNil "_pursuit"} && {vehicle (_pursuit get "target") == _veh}) then {
        private _phase = _pursuit get "phase";
        if (RADS_DEBUG) then { ["PURSUIT", format ["%1 accepts the clearance of %2 by %3 (was in phase %4)", groupId _grp, typeOf _veh, groupId _source, _phase], _grp, _pursuit get "target"] call FUNC(debugLog); };
        if (_phase == "INSPECT") then {
            [_grp, "cleared"] call FUNC(inspectEnd);
        } else {
            if (_phase != "CLEARED") then { [_grp, format ["%1 cleared the vehicle", groupId _source]] call FUNC(pursuitEnd); };
        };
    };
} forEach allGroups;
