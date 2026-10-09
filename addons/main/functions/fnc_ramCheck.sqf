#include "..\script_component.hpp"
/*
 * Author: Root
 * Client per-frame handler (5 Hz): while the local player drives a covered vehicle, hostile AI
 * touched by it are reported to their group owners at once (ramming / running over). Collisions
 * with AI vehicles are caught by a PhysX contact handler added to the driven vehicle.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (!MSET(ramDetect)) exitWith {};

private _unit = call CBA_fnc_currentUnit;
private _veh = vehicle _unit;
private _covered = _unit getVariable [QGVAR(cover), false];
private _truce = (_unit getVariable [QGVAR(truce), []]) isNotEqualTo [];
if (_veh == _unit || {driver _veh != _unit} || {!_covered && !_truce}) exitWith {};
// vehicle-on-vehicle: PhysX contact on the driven vehicle (local to its driver)
if (isNil {_veh getVariable QGVAR(epeEH)}) then {
    _veh setVariable [QGVAR(epeEH), _veh addEventHandler ["EpeContactStart", {
        params ["_veh", "_other"];
        [_veh, _other] call FUNC(ramContact);
    }]];
    if (RADS_DEBUG) then { ["RAM-DETECT", format ["vehicle contact handler added to %1", typeOf _veh], grpNull, _unit] call FUNC(debugLog); };
};
if (abs speed _veh < MSET(ramSpeed)) exitWith {};

// Geometry clipping (type 2): the actual hull, not mirrors/antennas/view geometry
(2 boundingBoxReal _veh) params ["_min", "_max", "_diameter"];
private _margin = 0.15;
private _reported = [];
{
    private _rel = _veh worldToModel (ASLToAGL (getPosASL _x));
    private _grp = group _x;
    if (!isPlayer _x
        && {!(_grp in _reported)}
        && {isNull objectParent _x}
        && {(_rel select 0) > ((_min select 0) - _margin) && {(_rel select 0) < ((_max select 0) + _margin)}}
        && {(_rel select 1) > ((_min select 1) - _margin) && {(_rel select 1) < ((_max select 1) + _margin)}}
        && {[side _grp, _unit] call FUNC(isHostile)}
        && {time > (_grp getVariable [QGVAR(nextRam), 0])}
    ) then {
        _reported pushBack _grp;
        _grp setVariable [QGVAR(nextRam), time + 2];
        if (RADS_DEBUG) then { ["RAM-DETECT", format ["%1 touched by %2 at %3 km/h (rel %4, box %5..%6)", name _x, typeOf _veh, round speed _veh, _rel apply {_x toFixed 1}, _min apply {_x toFixed 1}, _max apply {_x toFixed 1}], _grp, _unit] call FUNC(debugLog); };
        if (_truce) then { [_unit, format ["rammed %1", name _x]] call FUNC(breakTruce); };
        if (_covered) then { [QGVAR(rammed), [_grp, _unit]] call CBA_fnc_globalEvent; };
    };
} forEach (_veh nearEntities [["CAManBase"], _diameter / 2 + _margin]);
