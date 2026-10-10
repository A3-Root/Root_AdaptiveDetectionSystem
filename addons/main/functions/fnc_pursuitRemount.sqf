#include "..\script_component.hpp"
/*
 * Author: Root
 * A stop turned into a fight (fled or identified) while crew were out inspecting: the dismounted
 * driver / commander / turret crew run back to their own seats first, then the vehicle goes after
 * the target (LAMBS hunt when enabled, otherwise reveal and drive at it). Passengers stay out and
 * fight on foot. Gives up waiting after 30 s.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: AI vehicle <OBJECT>
 * 2: Crew seats [unit, role, turret path] <ARRAY>
 * 3: Target <OBJECT>
 * 4: Roam limit (m), 0 = unlimited <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_aiVeh", "_seats", "_target", "_leash"];

_seats = _seats select {[_x select 0] call FUNC(isAwake)};
{
    _x params ["_crewman", "_role", "_turretPath"];
    unassignVehicle _crewman;
    switch (_role) do {
        case "driver": { _crewman assignAsDriver _aiVeh; };
        case "commander": { _crewman assignAsCommander _aiVeh; };
        default { _crewman assignAsTurret [_aiVeh, _turretPath]; };
    };
    [_crewman] allowGetIn true;
    [_crewman] orderGetIn true;
} forEach _seats;

if (RADS_DEBUG) then { ["PURSUIT", format ["%1 crew back to %2 before engaging: %3", groupId _grp, typeOf _aiVeh, _seats apply {format ["%1 (%2)", name (_x select 0), _x select 1]}], _grp, _target] call FUNC(debugLog); };

[{
    params ["_grp", "_aiVeh", "_seats", "", "", "_start"];
    !alive _aiVeh || {isNull _grp} || {time - _start > 30} || {_seats findIf {[_x select 0] call FUNC(isAwake) && {vehicle (_x select 0) != _aiVeh}} == -1}
}, {
    params ["_grp", "_aiVeh", "_seats", "_target", "_leash", "_start"];
    if (isNull _grp || {!alive _aiVeh}) exitWith {};
    private _out = (_seats select {[_x select 0] call FUNC(isAwake) && {vehicle (_x select 0) != _aiVeh}}) apply {name (_x select 0)};
    if (RADS_DEBUG) then { ["PURSUIT", format ["%1 remounted %2 after %3 s (still out: %4), engaging %5", groupId _grp, typeOf _aiVeh, round (time - _start), _out, name _target], _grp, _target] call FUNC(debugLog); };
    if (!alive _target) exitWith {};
    _grp reveal [vehicle _target, 4];
    if (MSET(lambsHuntOnCompromise) && {!isNil "lambs_wp_fnc_taskHunt"}) then {
        [_grp, [1000, _leash] select (_leash > 0)] spawn lambs_wp_fnc_taskHunt;
    } else {
        private _driver = driver _aiVeh;
        if (!isNull _driver && {local _driver}) then { _driver doMove (getPosATL vehicle _target); };
    };
}, [_grp, _aiVeh, _seats, _target, _leash, time]] call CBA_fnc_waitUntilAndExecute;
