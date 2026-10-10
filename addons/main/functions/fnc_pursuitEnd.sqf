#include "..\script_component.hpp"
/*
 * Author: Root
 * Ends a pursuit: removes the pursuit waypoint (the group resumes its own route), remounts
 * dismounted inspectors, restores behaviour, speed and LAMBS. With "combat" the group stays in
 * COMBAT and, with LAMBS loaded and enabled, hunts the target.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Reason <STRING>
 * 2: Combat (target identified or fled) <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", ["_reason", ""], ["_combat", false]];

private _pursuit = _grp getVariable QGVAR(pursuit);
if (isNil "_pursuit") exitWith {};

private _pfh = _pursuit getOrDefault ["pfh", -1];
if (_pfh >= 0) then { [_pfh] call CBA_fnc_removePerFrameHandler; };
[_grp, false] call FUNC(pursuitSignal);
[_grp, "remove"] call FUNC(pursuitWaypoint);

// inspection broken off (fled, identified, lost): the vehicle loses its calm for everyone
private _inspectVeh = _pursuit getOrDefault ["inspectVeh", objNull];
if (!isNull _inspectVeh && {(_pursuit get "phase") == "INSPECT"} && {(([_inspectVeh] call FUNC(vehicleCalm)) select 0) == "inspect"}) then {
    _inspectVeh setVariable [QGVAR(calm), nil, true];
};

// back in the vehicle (fighting dismounts stay out, except the crew: see below)
private _inspectors = (_pursuit get "inspectors") select {alive _x};
private _unit = _pursuit get "target";
private _leash = [_grp, _pursuit get "mounted"] call FUNC(pursuitLeash);
private _aiVeh = _pursuit getOrDefault ["aiVeh", objNull];
private _crewSeats = (_pursuit getOrDefault ["crewSeats", []]) select {alive (_x select 0) && {vehicle (_x select 0) != _aiVeh}};
private _remount = _combat && {MSET(inspectRemount)} && {_pursuit get "mounted"} && {alive _aiVeh} && {canMove _aiVeh} && {_crewSeats isNotEqualTo []};
if (_inspectors isNotEqualTo []) then {
    { _x doWatch objNull; _x lookAt objNull; } forEach _inspectors;
    if (!_combat && {_pursuit get "mounted"}) then {
        _inspectors allowGetIn true;
        _inspectors orderGetIn true;
    } else {
        _inspectors allowGetIn true;
    };
};
(units _grp) doFollow (leader _grp);
// whatever the mission designer had switched off goes back off
{ _x params ["_crewman", "_feature"]; if (alive _crewman) then { _crewman disableAI _feature; }; } forEach (_pursuit getOrDefault ["freedAI", []]);

if (_combat) then {
    _grp setBehaviour "COMBAT";
} else {
    _grp setBehaviour (_pursuit get "savedBehaviour");
};
_grp setSpeedMode (_pursuit get "savedSpeed");

if ("lambs" in _pursuit) then { _grp setVariable ["lambs_danger_disableGroupAI", _pursuit get "lambs", true]; };

_grp setVariable [QGVAR(pursuit), nil];
_grp setVariable [QGVAR(pursuitTarget), objNull, true];
_grp setVariable [QGVAR(nextPursuit), time + MSET(pursuitCooldown)];
_grp setVariable [QGVAR(homeUntil), time + 120];

// crew out inspecting get back to their seats first; the hunt starts once they are in
if (_remount) then { [_grp, _aiVeh, _crewSeats, _unit, _leash] call FUNC(pursuitRemount); };

if (_combat && {!_remount} && {MSET(lambsHuntOnCompromise)} && {!isNil "lambs_wp_fnc_taskRush"} && {alive _unit}) then {
    // LAMBS search radius stays inside the roam limit
    if (_pursuit get "mounted") then {
        [_grp, [1000, _leash] select (_leash > 0)] spawn lambs_wp_fnc_taskHunt;
    } else {
        [_grp, [500, _leash] select (_leash > 0)] spawn lambs_wp_fnc_taskRush;
    };
    if (RADS_DEBUG) then { ["PURSUIT", format ["%1 handed to LAMBS %2", groupId _grp, ["taskRush", "taskHunt"] select (_pursuit get "mounted")], _grp, _unit] call FUNC(debugLog); };
};

if (RADS_DEBUG) then { ["PURSUIT", format ["%1 ends its pursuit of %2 after %3 s in phase %4: %5 (combat=%6)", groupId _grp, name _unit, round (time - (_pursuit get "start")), _pursuit get "phase", _reason, _combat], _grp, _unit] call FUNC(debugLog); };
[QGVAR(message), [format ["RADS: %1 stops pursuing %2 - %3", groupId _grp, name _unit, _reason]]] call CBA_fnc_globalEvent;
