#include "..\script_component.hpp"
/*
 * Author: Root
 * One stop signal burst of a pursuing vehicle, where the vehicle is local: two honks and three
 * flashes of the headlights, then the lights go back to how they were.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Honk <BOOL>
 * 2: Flash the lights <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_veh", "_horn", "_lights"];

if (!local _veh || {!alive _veh} || {isNull driver _veh}) exitWith {};

if (_horn) then {
    private _weapons = _veh weaponsTurret [-1];
    private _hornWeapon = _weapons param [_weapons findIf {"horn" in toLower _x}, ""];
    if (_hornWeapon != "") then {
        [_veh, _hornWeapon, [-1]] call BIS_fnc_fire;
        [{
            params ["_veh", "_hornWeapon"];
            if (alive _veh && {!isNull driver _veh}) then { [_veh, _hornWeapon, [-1]] call BIS_fnc_fire; };
        }, [_veh, _hornWeapon], 0.7] call CBA_fnc_waitAndExecute;
    };
};

if (_lights && {isNil {_veh getVariable QGVAR(flashing)}}) then {
    // lights go back to how they were before the burst
    private _was = isLightOn _veh;
    _veh setVariable [QGVAR(flashing), true];
    // on/off three times, 0.35 s each
    for "_i" from 0 to 5 do {
        [{
            params ["_veh", "_on"];
            if (alive _veh && {local _veh}) then { _veh setPilotLight _on; };
        }, [_veh, (_i mod 2 == 0) != _was], 0.35 * _i] call CBA_fnc_waitAndExecute;
    };
    [{
        params ["_veh", "_was"];
        if (alive _veh && {local _veh}) then { _veh setPilotLight _was; };
        _veh setVariable [QGVAR(flashing), nil];
    }, [_veh, _was], 0.35 * 6] call CBA_fnc_waitAndExecute;
};
