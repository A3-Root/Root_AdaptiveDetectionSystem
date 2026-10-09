#include "..\script_component.hpp"
/*
 * Author: Root
 * FiredMan on a local player: honking marks the vehicle, any real shot from cover (or right after
 * leaving it) is a hostile act broadcast to every AI owner, and puts the shooter on heat.
 *
 * Arguments:
 * FiredMan event arguments
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit", "_weapon"];

if (!local _unit) exitWith {};
private _veh = vehicle _unit;

if ("horn" in toLower _weapon) exitWith {
    if (_veh != _unit) then { _veh setVariable [QGVAR(hornTime), CBA_missionTime, true]; };
};

// Any shot from inside a safe zone truce ends it
if ((_unit getVariable [QGVAR(truce), []]) isNotEqualTo []) then { [_unit, format ["fired %1", _weapon]] call FUNC(breakTruce); };

private _covered = _unit getVariable [QGVAR(cover), false];
if (!_covered && {(CBA_missionTime - (_unit getVariable [QGVAR(lastCoverTime), -100])) > 3}) exitWith {};
if (!MSET(firedBlows)) exitWith {};

// automatic fire: one broadcast per second is plenty
if (time < (_unit getVariable [QGVAR(nextFiredEvent), 0])) exitWith {};
_unit setVariable [QGVAR(nextFiredEvent), time + 1];
_unit setVariable [QGVAR(lastFired), CBA_missionTime, true];

private _suppressed = ((_unit weaponAccessories _weapon) param [0, ""]) != "";
private _radius = [MSET(firedRadius), MSET(firedRadiusSuppressed)] select _suppressed;

private _heat = MSET(heatDuration);
if (_heat > 0) then { _unit setVariable [QGVAR(heatUntil), CBA_missionTime + _heat, true]; };

[QGVAR(hostileAct), [_unit, getPosATL _unit, _radius, "fired"]] call CBA_fnc_globalEvent;
[_unit] call FUNC(updateCover);
