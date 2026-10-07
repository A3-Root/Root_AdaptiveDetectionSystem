#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Marks a unit as wanted by a side: that side builds suspicion faster against it in any vehicle.
 * Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Side <SIDE>
 * 2: Duration (s), -1 = setting <NUMBER> (default: -1)
 * 3: Range from report position, 0 = side-wide <NUMBER> (default: 0)
 * 4: Report position, [] = unit position <ARRAY> (default: [])
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, east, 900] call root_ads_fnc_markWanted
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_side", east, [east]], ["_duration", -1], ["_range", 0], ["_pos", []]];

if (!isServer) exitWith { [QGVAR(api), ["markWanted", _this]] call CBA_fnc_serverEvent; };
if (isNull _unit) exitWith {};

if (_duration < 0) then { _duration = MSET(wantedDuration); };
if (_pos isEqualTo []) then { _pos = getPosATL _unit; };

private _now = CBA_missionTime;
private _list = (_unit getVariable [QGVAR(wantedBy), []]) select {(_x select 0) != _side && {(_x select 1) > _now}};
_list pushBack [_side, _now + _duration, _pos, _range];
_unit setVariable [QGVAR(wantedBy), _list, true];
RLOG_2("%1 wanted by %2",_unit,_side);
