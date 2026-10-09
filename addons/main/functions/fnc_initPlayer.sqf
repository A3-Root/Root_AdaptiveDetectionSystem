#include "..\script_component.hpp"
/*
 * Author: Root
 * Client setup: player event handlers and a periodic cover re-evaluation for the player and
 * any local AI riding with them (zones, heat, settings and seats change over time).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

GVAR(managedUnits) = [];

GVAR(attachUnit) = {
    params ["_unit"];
    if (isNull _unit || {_unit getVariable [QGVAR(ehAdded), false]}) exitWith {};
    _unit setVariable [QGVAR(ehAdded), true];

    _unit addEventHandler ["GetInMan", { [_this select 0] call FUNC(updateCover); }];
    _unit addEventHandler ["GetOutMan", { [_this select 0] call FUNC(updateCover); }];
    _unit addEventHandler ["SeatSwitchedMan", { [_this select 0] call FUNC(updateCover); }];
    _unit addEventHandler ["FiredMan", { _this call FUNC(handleFired); }];
    _unit addEventHandler ["Killed", {
        params ["_unit"];
        if (_unit getVariable [QGVAR(cover), false]) then {
            _unit setVariable [QGVAR(cover), false, true];
            _unit setVariable [QGVAR(coverVeh), objNull, true];
            [QGVAR(coverChanged), [_unit, objNull, false]] call CBA_fnc_globalEvent;
        };
    }];
};

[player] call GVAR(attachUnit);
["unit", {
    params ["_new"];
    [_new] call GVAR(attachUnit);
    [_new] call FUNC(updateCover);
}] call CBA_fnc_addPlayerEventHandler;

[{
    private _unit = call CBA_fnc_currentUnit;

    // Mission-wide player profile (3DEN Unit Cover module with "All players"), for late joiners/respawns
    private _profile = missionNamespace getVariable [QGVAR(playerProfile), []];
    if (_profile isNotEqualTo [] && {(_unit getVariable [QGVAR(profileId), ""]) != (_profile select 0)}) then {
        _profile params ["_id", "_mode", "_mult", "_until"];
        _unit setVariable [QGVAR(profileId), _id];
        if (_until < 0 || CBA_missionTime < _until) then {
            _unit setVariable [QGVAR(exempt), _mode == "exempt", true];
            _unit setVariable [QGVAR(forceCover), _mode == "force", true];
            _unit setVariable [QGVAR(unitMult), _mult, true];
            if (_until > 0) then {
                [{
                    _this setVariable [QGVAR(exempt), false, true];
                    _this setVariable [QGVAR(forceCover), false, true];
                    _this setVariable [QGVAR(unitMult), 1, true];
                }, _unit, _until - CBA_missionTime] call CBA_fnc_waitAndExecute;
            };
        };
    };

    [_unit] call FUNC(truceUpdate);

    private _units = (units group _unit) + (crew vehicle _unit) + GVAR(managedUnits);
    _units = (_units arrayIntersect _units) select {local _x};
    { [_x] call FUNC(updateCover); } forEach _units;
    GVAR(managedUnits) = GVAR(managedUnits) select {!isNull _x && {_x getVariable [QGVAR(cover), false]}};
}, 1] call CBA_fnc_addPerFrameHandler;
