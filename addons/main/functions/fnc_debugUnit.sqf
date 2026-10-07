#include "..\script_component.hpp"
/*
 * Author: Root
 * Debug description of a unit and its vehicle: name, side, cover, heat, wanted, vehicle class,
 * plate, grid, ASL position, speed, visible damage, seat, lights, burned status.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Description <STRING>
 *
 * Public: No
 */

params [["_unit", objNull]];

if (isNull _unit) exitWith {"unit=<null>"};

private _now = CBA_missionTime;
private _veh = vehicle _unit;
private _text = format ["unit=%1 (%2, %3, player=%4) cover=%5 heat=%6s wanted=%7",
    name _unit, typeOf _unit, side group _unit, isPlayer _unit,
    _unit getVariable [QGVAR(cover), false],
    round (((_unit getVariable [QGVAR(heatUntil), -1]) - _now) max 0),
    ((_unit getVariable [QGVAR(wantedBy), []]) select {(_x select 1) > _now}) apply {_x select 0}
];

if (_veh == _unit) exitWith {
    _text + format [" | on foot grid=%1 posASL=%2 speed=%3", mapGridPosition _unit, (getPosASL _unit) apply {round _x}, round speed _unit]
};

private _role = assignedVehicleRole _unit;
_text + format [" | veh=%1 (%2, side %3) plate='%4' grid=%5 posASL=%6 speed=%7kmh dir=%8 onRoad=%9 dmg=%10 visDmg=%11 seat=%12 turnedOut=%13 lights=%14 mode=%15 burnedFor=%16 crew=%17",
    typeOf _veh, getText (configOf _veh >> "displayName"), [_veh] call FUNC(vehicleSide),
    getPlateNumber _veh, mapGridPosition _veh, (getPosASL _veh) apply {round _x},
    round speed _veh, round getDir _veh, isOnRoad _veh,
    (damage _veh) toFixed 2, ([_veh] call FUNC(visibleDamage)) toFixed 2,
    _role, isTurnedOut _unit, isLightOn _veh,
    _veh getVariable [QGVAR(vehMode), "auto"],
    ((_veh getVariable [QGVAR(burnedBy), []]) select {(_x select 1) > _now}) apply {_x select 0},
    (crew _veh) apply {name _x}
]
