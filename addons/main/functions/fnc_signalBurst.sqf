#include "..\script_component.hpp"
/*
 * Author: Root
 * One stop signal burst of a pursuing vehicle, where the vehicle is local: two honks 1 s apart
 * and three flashes of the headlights (0.5 s on, 0.5 s off), then the lights go back to how
 * they were. The burst takes 3 s.
 * The crew's own light handling is paused for the burst (AI feature "LIGHTS" on every AI crew
 * member), otherwise the AI switches the lights straight back. The horn is fired by the driver directly
 * (forceWeaponFire) instead of BIS_fnc_fire, whose weapon action kept the AI vehicle parked in tests.
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

private _driver = driver _veh;
if (!local _veh || {!alive _veh} || {isNull _driver}) exitWith {};

if (_horn) then {
    private _weapons = _veh weaponsTurret [-1];
    private _hornWeapon = _weapons param [_weapons findIf {"horn" in toLower _x}, ""];
    if (_hornWeapon != "") then {
        _driver forceWeaponFire [_hornWeapon, _hornWeapon];
        [{
            params ["_veh", "_driver", "_hornWeapon"];
            if (alive _veh && {driver _veh == _driver} && {local _driver}) then { _driver forceWeaponFire [_hornWeapon, _hornWeapon]; };
        }, [_veh, _driver, _hornWeapon], 1] call CBA_fnc_waitAndExecute;
    } else {
        if (RADS_DEBUG) then { RLOG_1("stop signal: %1 has no horn",typeOf _veh); };
    };
};

if (_lights && {isNil {_veh getVariable QGVAR(flashing)}}) then {
    private _was = isLightOn _veh;
    // whoever handles the lights (driver or commander) must not switch them straight back
    private _paused = (crew _veh) select {alive _x && {!isPlayer _x} && {local _x} && {_x checkAIFeature "LIGHTS"}};
    { _x disableAI "LIGHTS"; } forEach _paused;
    _veh setVariable [QGVAR(flashing), true];
    // on/off three times, 0.5 s each; the log shows what each step found (was the AI overriding it?)
    for "_i" from 0 to 5 do {
        [{
            params ["_veh", "_on", "_step"];
            if !(alive _veh && {local _veh}) exitWith {};
            private _found = isLightOn _veh;
            _veh setPilotLight _on;
            if (RADS_DEBUG && {MSET(debugDetail) >= 2}) then { RLOG_4("stop signal lights %1 step %2: found %3, set %4",typeOf _veh,_step,_found,_on); };
        }, [_veh, (_i mod 2 == 0) != _was, _i], 0.5 * _i] call CBA_fnc_waitAndExecute;
    };
    [{
        params ["_veh", "_was", "_paused"];
        if (alive _veh && {local _veh}) then { _veh setPilotLight _was; };
        { if (alive _x && {local _x}) then { _x enableAI "LIGHTS"; }; } forEach _paused;
        _veh setVariable [QGVAR(flashing), nil];
    }, [_veh, _was, _paused], 3] call CBA_fnc_waitAndExecute;
};

if (RADS_DEBUG && {MSET(debugDetail) >= 2}) then {
    RLOG_4("stop signal burst on %1: horn=%2 lights=%3 (lights were %4, crew light AI paused for the burst)",typeOf _veh,_horn,_lights,isLightOn _veh);
};
