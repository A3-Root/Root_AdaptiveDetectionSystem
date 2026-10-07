#include "..\script_component.hpp"
/*
 * Author: Root
 * Best per-observer exposure of a covered unit to a group: line of sight through the vehicle's
 * view geometry (glass lets partial sight through), field of view, distance, light, observer
 * behaviour, skill, face-to-face proximity and whether the unit is aiming at the observer.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Unit <OBJECT>
 * 2: Unit's vehicle <OBJECT>
 *
 * Return Value:
 * [exposure <NUMBER>, hostile in same vehicle <BOOL>, best observer <OBJECT>, best observer factors <ARRAY>]
 *
 * Public: No
 */

params ["_grp", "_unit", "_veh"];

private _maxRange = MSET(maxRange);
private _observers = (units _grp) select {[_x] call FUNC(isObserver)};
if (_observers isEqualTo []) exitWith {[0, false, objNull]};

private _sameIdx = _observers findIf {vehicle _x == _veh};
if (_sameIdx > -1) exitWith {[100, true, _observers select _sameIdx]};

_observers = _observers select {(_x distance _unit) <= _maxRange};
if (_observers isEqualTo []) exitWith {[0, false, objNull]};
_observers = [_observers, [], {_x distance _unit}, "ASCEND"] call BIS_fnc_sortBy;
_observers resize ((count _observers) min (round MSET(maxObservers)));

// Direction the unit's weapon points, if it can aim from where it sits
private _aimDir = [];
if (isTurnedOut _unit || {[_unit] call CBA_fnc_canUseWeapon}) then {
    private _weapon = currentWeapon _unit;
    if (_weapon != "") then { _aimDir = _unit weaponDirection _weapon; };
} else {
    private _role = assignedVehicleRole _unit;
    if (toLower (_role param [0, ""]) == "turret") then {
        private _turretWeapon = _veh currentWeaponTurret (_role param [1, []]);
        if (_turretWeapon != "") then { _aimDir = _veh weaponDirection _turretWeapon; };
    };
};

private _target = eyePos _unit;
private _identifyRange = MSET(identifyRange);
private _curve = MSET(distanceCurve);
private _instantRange = MSET(instantRange);
private _instantMult = MSET(instantMult);
private _minClose = MSET(minCloseExposure);
private _ignoreHull = !MSET(hullBlocks);
private _halfFov = MSET(fovAngle) / 2;
private _peripheral = MSET(peripheralMult);
private _skillInfluence = MSET(skillInfluence);
private _night = MSET(nightMult);
private _nvgNight = MSET(nvgNightMult);
private _aimAngle = MSET(aimAngle);
private _aimMult = MSET(aimMult);
private _light = sunOrMoon;

private _best = 0;
private _bestObserver = objNull;
private _bestParts = [];

{
    private _observer = _x;
    private _observerVeh = vehicle _observer;
    private _eye = eyePos _observer;
    private _distance = _observer distance _unit;

    // With hull blocking we ignore the unit itself so the ray stops at the vehicle's glass/body
    private _visibility = [_observerVeh, "VIEW", [_unit, _veh] select _ignoreHull] checkVisibility [_eye, _target];
    if (_distance <= _instantRange) then { _visibility = _visibility max _minClose; };

    if (_visibility > 0) then {
        private _toTarget = _eye vectorFromTo _target;
        private _facing = if (_observerVeh == _observer) then { eyeDirection _observer } else { vectorDir _observerVeh };
        private _angle = acos ((((vectorNormalized _facing) vectorDotProduct _toTarget) min 1) max -1);
        private _fov = [_peripheral, 1] select (_angle <= _halfFov);

        // Telling who sits in a vehicle gets hard fast with distance: full inside close range,
        // then (closeRange / distance) ^ exponent, e.g. 40 m close range, exponent 1.5 -> 0.09 at 200 m
        private _distanceFactor = if (_distance <= _identifyRange) then {1} else {
            (_identifyRange / _distance) ^ _curve
        };

        private _behaviour = switch (behaviour _observer) do {
            case "COMBAT": { MSET(behCombat) };
            case "STEALTH": { MSET(behStealth) };
            case "AWARE": { MSET(behAware) };
            default { MSET(behSafe) };
        };

        private _skill = 1 + _skillInfluence * (((_observer skill "spotDistance") + (_observer skill "spotTime")) - 1);

        private _lightFactor = 1;
        if (_light < 1) then {
            private _dark = [_night, _nvgNight] select (hmd _observer != "");
            _lightFactor = _dark + (1 - _dark) * _light;
        };

        private _close = [1, _instantMult] select (_distance <= _instantRange);

        private _aim = 1;
        if (_aimDir isNotEqualTo []) then {
            private _toObserver = _target vectorFromTo _eye;
            if (acos (((_aimDir vectorDotProduct _toObserver) min 1) max -1) <= _aimAngle) then { _aim = _aimMult; };
        };

        private _exposure = _visibility * _fov * _distanceFactor * _behaviour * (_skill max 0) * _lightFactor * _close * _aim;
        if (_exposure > _best) then {
            _best = _exposure;
            _bestObserver = _observer;
            _bestParts = [_visibility, _angle, _fov, _distanceFactor, _behaviour, _skill, _lightFactor, _close, _aim];
        };
    };
} forEach _observers;

[_best, false, _bestObserver, _bestParts]
