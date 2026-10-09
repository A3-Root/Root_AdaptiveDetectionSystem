#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Adds a detection zone. Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Area [centre, a, b, angle, isRectangle] <ARRAY>
 * 1: Mode: 0 multiplier, 1 no cover (restricted area), 2 safe haven (with truce) <NUMBER> (default: 0)
 * 2: Suspicion build multiplier <NUMBER> (default: 1)
 * 3: Suspicion decay multiplier <NUMBER> (default: 1)
 * 4: Observer sides affected, [] = all <ARRAY> (default: [])
 * 5: Delay before active (s) <NUMBER> (default: 0)
 * 6: Duration (s), 0 = permanent <NUMBER> (default: 0)
 * 7: Daytime window start hour, -1 = always <NUMBER> (default: -1)
 * 8: Daytime window end hour, -1 = always <NUMBER> (default: -1)
 * 9: Label <STRING> (default: "")
 * 10: Id, "" = generate <STRING> (default: "")
 * 11: Safe haven truce [enabled, maxStay, warnBefore, careless, breakScope, breakOnAim], [] = CBA defaults
 *     (see root_ads_fnc_setZoneTruce) <ARRAY> (default: [])
 *
 * Return Value:
 * Zone id ("" when forwarded from a client) <STRING>
 *
 * Example:
 * [[getMarkerPos "checkpoint", 150, 150, 0, false], 0, 2.5] call root_ads_fnc_addZone
 *
 * Public: Yes
 */

params [["_area", [], [[]]], ["_mode", 0], ["_build", 1], ["_decay", 1], ["_sides", []], ["_delay", 0], ["_duration", 0], ["_hourFrom", -1], ["_hourTo", -1], ["_label", ""], ["_id", ""], ["_truce", [], [[]]]];

if (!isServer) exitWith { [QGVAR(api), ["addZone", _this]] call CBA_fnc_serverEvent; "" };

_area params [["_center", [0, 0, 0]], ["_a", 100], ["_b", -1], ["_angle", 0], ["_rect", false]];
if (_b < 0) then { _b = _a; };
if (_center isEqualType objNull) then { _center = getPosATL _center; };

if (_id == "") then {
    GVAR(zoneCounter) = (missionNamespace getVariable [QGVAR(zoneCounter), 0]) + 1;
    _id = format ["ads_zone_%1", GVAR(zoneCounter)];
};
[_id] call API(removeZone);

private _start = CBA_missionTime + (_delay max 0);
private _end = [-1, _start + _duration] select (_duration > 0);

private _marker = "";
if (MSET(showZoneMarkers)) then {
    _marker = createMarker [_id, _center];
    _marker setMarkerShapeLocal (["ELLIPSE", "RECTANGLE"] select _rect);
    _marker setMarkerSizeLocal [_a, _b];
    _marker setMarkerDirLocal _angle;
    _marker setMarkerBrushLocal "FDiagonal";
    _marker setMarkerColor (["ColorOrange", "ColorRed", "ColorGreen"] param [_mode, "ColorOrange"]);
};

GVAR(zones) pushBack [_id, [_center, _a, _b, _angle, _rect, -1], _mode, _build, _decay, _sides, _start, _end, _hourFrom, _hourTo, _label, _marker, _truce];
publicVariable QGVAR(zones);

if (_end > 0) then {
    [{ [_this] call API(removeZone); }, _id, (_delay max 0) + _duration] call CBA_fnc_waitAndExecute;
};

_id
