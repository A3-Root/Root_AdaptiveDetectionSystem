#include "..\script_component.hpp"
/*
 * Author: Root
 * Keeps a pursuing vehicle driving after its target with direct move orders for the driver (no
 * waypoint, so nothing competes with them). Orders are throttled: each new one restarts the driver's route
 * planning, so re-ordering every time a moving target got 15 m farther kept a parked vehicle
 * from ever pulling away. A standing vehicle gets 8 s to start before a new order, a moving one
 * is re-ordered at most every 3 s and only once the target moved a fair bit (30 m, or a quarter
 * of the distance). Logs the driving state and every order for the debug report.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Position to drive to (ATL) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_pos"];

private _pursuit = _grp getVariable QGVAR(pursuit);
if (isNil "_pursuit") exitWith {};
private _aiVeh = _pursuit get "aiVeh";
if (isNull _aiVeh) exitWith {};

private _commander = effectiveCommander _aiVeh;
private _driver = driver _aiVeh;
private _vehSpeed = abs speed _aiVeh;
private _ordered = _pursuit getOrDefault ["drivePos", []];
private _since = time - (_pursuit getOrDefault ["driveTime", -1e10]);
private _standing = _vehSpeed < 2;
private _shift = if (_ordered isEqualTo []) then {1e10} else {_pos distance2D _ordered};
private _why = switch (true) do {
    case (_ordered isEqualTo []): { "first order" };
    case (_standing && _since >= 8 && {(_aiVeh distance2D _pos) > 20}): { "still standing after 8 s" };
    case (!_standing && _since >= 3 && {_shift > (30 max (0.25 * (_aiVeh distance2D _pos)))}): { format ["target moved %1 m", round _shift] };
    default { "" };
};

if (!isEngineOn _aiVeh) then {
    if (local _aiVeh) then { _aiVeh engineOn true; } else { [QGVAR(engineOn), [_aiVeh], _aiVeh] call CBA_fnc_targetEvent; };
};

if (_why != "") then {
    _pursuit set ["drivePos", _pos];
    _pursuit set ["driveTime", time];
    _pursuit set ["orders", (_pursuit getOrDefault ["orders", 0]) + 1];
    // a unit told to stop ignores waypoints and move orders of its leader
    { if (stopped _x) then { _x doFollow (leader _grp); }; } forEach [_commander, _driver];
    if (local _driver) then { _driver doMove _pos; };
    if (_standing && {_ordered isNotEqualTo []}) then { _pursuit set ["stuckOrders", (_pursuit getOrDefault ["stuckOrders", 0]) + 1]; };
    if (RADS_DEBUG && {MSET(debugDetail) >= 1}) then {
        ["PURSUIT", format ["%1 orders driver %2 to drive to %3 (%4 m away): %5, %6 s after the last order, vehicle at %7 km/h", groupId _grp, name _driver, mapGridPosition _pos, round (_aiVeh distance2D _pos), _why, [round _since, "-"] select (_ordered isEqualTo []), round _vehSpeed], _grp, _pursuit get "target"] call FUNC(debugLog);
    };
};

if (RADS_DEBUG && {MSET(debugDetail) >= 1} && {time >= (_pursuit getOrDefault ["nextDriveLog", 0])}) then {
    _pursuit set ["nextDriveLog", time + 5];
    private _unit = _pursuit get "target";
    ["PURSUIT", format ["%1 driving %2: speed=%3 km/h to target=%4 m to order=%5 m engine=%6 fuel=%7 driver=%8 (PATH=%9 MOVE=%10 stopped=%11) commander=%12 (stopped=%13) wp=%14/%15 orders=%16 (while standing %17)",
        groupId _grp, typeOf _aiVeh, round _vehSpeed, round (_aiVeh distance2D vehicle _unit), round (_aiVeh distance2D _pos), isEngineOn _aiVeh, (fuel _aiVeh) toFixed 2,
        name _driver, _driver checkAIFeature "PATH", _driver checkAIFeature "MOVE", stopped _driver, name _commander, stopped _commander,
        currentWaypoint _grp, count waypoints _grp, _pursuit getOrDefault ["orders", 0], _pursuit getOrDefault ["stuckOrders", 0]], _grp, _unit] call FUNC(debugLog);
};
