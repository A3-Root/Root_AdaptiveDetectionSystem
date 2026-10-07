#include "..\script_component.hpp"
/*
 * Author: Root
 * True when the vehicle carries a number plate reported to the observer's side (within the
 * report's range) and the observer is close enough to read it.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Observer side <SIDE>
 * 2: Observer <OBJECT>
 *
 * Return Value:
 * Plate recognised <BOOL>
 *
 * Public: No
 */

params ["_veh", "_side", "_observer"];

if (!MSET(plateRecognition) || {isNull _observer}) exitWith {false};
if ((_observer distance _veh) > MSET(plateReadRange)) exitWith {false};

private _plate = getPlateNumber _veh;
if (_plate == "") exitWith {false};

private _now = CBA_missionTime;
private _observerPos = getPosATL _observer;
(missionNamespace getVariable [QGVAR(burnedPlates), []]) findIf {
    _x params ["_reported", "_until", "_reportSide", "_pos", "_range"];
    _reported == _plate && _reportSide == _side && _until > _now && {_range <= 0 || {(_observerPos distance2D _pos) <= _range}}
} > -1
