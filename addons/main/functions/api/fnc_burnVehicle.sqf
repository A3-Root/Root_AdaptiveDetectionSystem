#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Marks a vehicle as known-hostile for a side: that side's groups (within range of the report)
 * identify covered occupants as soon as they see it. Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Side that knows <SIDE>
 * 2: Duration (s), -1 = setting <NUMBER> (default: -1)
 * 3: Range from report position, 0 = side-wide <NUMBER> (default: 0)
 * 4: Report position, [] = vehicle position <ARRAY> (default: [])
 *
 * Return Value:
 * None
 *
 * Example:
 * [vehicle player, east, 600] call root_ads_fnc_burnVehicle
 *
 * Public: Yes
 */

params [["_veh", objNull, [objNull]], ["_side", east, [east]], ["_duration", -1], ["_range", 0], ["_pos", []]];

if (!isServer) exitWith { [QGVAR(api), ["burnVehicle", _this]] call CBA_fnc_serverEvent; };
if (isNull _veh) exitWith {};

if (_duration < 0) then { _duration = MSET(burnDuration); };
if (_pos isEqualTo []) then { _pos = getPosATL _veh; };

private _now = CBA_missionTime;
private _list = (_veh getVariable [QGVAR(burnedBy), []]) select {(_x select 0) != _side && {(_x select 1) > _now}};
_list pushBack [_side, _now + _duration, _pos, _range];
_veh setVariable [QGVAR(burnedBy), _list, true];

// The plate is reported too, so any vehicle carrying it is recognised once the plate is read
private _plate = getPlateNumber _veh;
if (_plate != "") then {
    private _plates = (missionNamespace getVariable [QGVAR(burnedPlates), []]) select {
        (_x select 1) > _now && {!((_x select 0) == _plate && {(_x select 2) == _side})}
    };
    _plates pushBack [_plate, _now + _duration, _side, _pos, _range];
    missionNamespace setVariable [QGVAR(burnedPlates), _plates, true];
};
RLOG_2("%1 burned for %2",_veh,_side);
