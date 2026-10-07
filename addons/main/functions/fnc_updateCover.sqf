#include "..\script_component.hpp"
/*
 * Author: Root
 * Re-evaluates a unit's cover where the unit is local, publishes it and notifies every machine.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Has cover <BOOL>
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {false};

private _now = [_unit] call FUNC(isCoverEligible);
private _was = _unit getVariable [QGVAR(cover), false];
private _veh = vehicle _unit;
private _wasVeh = _unit getVariable [QGVAR(coverVeh), objNull];

if (_now isEqualTo _was && {!_now || _veh == _wasVeh}) exitWith {_now};

// Hopping straight from one covered vehicle to another: drop the old one first so witnesses re-classify
if (_now && _was && _veh != _wasVeh) then {
    [QGVAR(coverChanged), [_unit, _wasVeh, false]] call CBA_fnc_globalEvent;
};

_unit setVariable [QGVAR(cover), _now, true];
_unit setVariable [QGVAR(coverVeh), [objNull, _veh] select _now, true];
_unit setVariable [QGVAR(coverSince), CBA_missionTime, true];
_unit setVariable [QGVAR(lastCoverTime), CBA_missionTime, true];

if (_now && {!isNil QGVAR(managedUnits)}) then {
    GVAR(managedUnits) pushBackUnique _unit;
};

[QGVAR(coverChanged), [_unit, _veh, _now]] call CBA_fnc_globalEvent;
if (RADS_DEBUG) then { ["COVER", format ["cover %1 -> %2 (vehicle %3)", _was, _now, typeOf _veh], grpNull, _unit] call FUNC(debugLog); };

if (hasInterface && {_unit == player} && GVAR(notifyCover)) then {
    if (_now) then {
        hintSilent parseText format ["<t color='#66ff66'>Undercover</t><br/>%1", getText (configOf _veh >> "displayName")];
    } else {
        hintSilent parseText "<t color='#ff6666'>Cover lost</t>";
    };
};

_now
