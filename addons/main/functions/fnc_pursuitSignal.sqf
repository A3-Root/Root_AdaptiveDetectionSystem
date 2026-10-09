#include "..\script_component.hpp"
/*
 * Author: Root
 * Stop signal of a pursuing vehicle: headlights flashing every tick and the horn every few
 * seconds (each optional). Off switches the lights back off.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Signalling <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_on"];

private _pursuit = _grp getVariable [QGVAR(pursuit), createHashMap];
private _aiVeh = _pursuit getOrDefault ["aiVeh", objNull];
if (isNull _aiVeh || {!alive _aiVeh}) exitWith {};

if (!_on) exitWith {
    if (_pursuit getOrDefault ["lights", false]) then {
        _pursuit set ["lights", false];
        if (local _aiVeh) then { _aiVeh setPilotLight false; };
    };
};

if (MSET(stopSignalLights) && {local _aiVeh}) then {
    private _lights = !(_pursuit getOrDefault ["lights", false]);
    _pursuit set ["lights", _lights];
    _aiVeh setPilotLight _lights;
};

if (MSET(stopSignalHorn) && {time >= (_pursuit getOrDefault ["nextHorn", 0])}) then {
    _pursuit set ["nextHorn", time + 3];
    private _horn = (_aiVeh weaponsTurret [-1]) param [(_aiVeh weaponsTurret [-1]) findIf {"horn" in toLower _x}, ""];
    if (_horn != "") then { [_aiVeh, _horn, [-1]] call BIS_fnc_fire; };
};
