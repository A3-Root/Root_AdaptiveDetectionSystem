#include "..\script_component.hpp"
/*
 * Author: Root
 * Best per-observer exposure of a covered unit to a group: line of sight through the vehicle's
 * view geometry (glass lets partial sight through), field of view, distance, light, observer
 * behaviour, skill, face-to-face proximity and whether the unit is aiming at the observer.
 * Armored seats only show the vehicle (slow build). A soft vehicle kept close and slow with its
 * crew hidden from the observer (reversing up, parking rear-on) is caught through the vehicle body.
 * Observers in vehicle gunner / commander seats see farther through their optics.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Unit <OBJECT>
 * 2: Unit's vehicle <OBJECT>
 *
 * Return Value:
 * [exposure <NUMBER>, hostile in same vehicle <BOOL>, best observer <OBJECT>, best observer factors <ARRAY>]
 * Factors: [visibility, angle, fov, distance, behaviour, skill, light, faceToFace, aimed, vehicleVisibility, hullMode, optics]
 * hullMode: "" crew seen directly, "armored", "hiddenCrew", "reversing", "rearFacing"
 *
 * Public: No
 */

params ["_grp", "_unit", "_veh"];

private _maxRange = MSET(maxRange);
private _observers = (units _grp) select {[_x] call FUNC(isObserver)};
if (_observers isEqualTo []) exitWith {[0, false, objNull]};

private _sameIdx = _observers findIf {vehicle _x == _veh};
if (_sameIdx > -1) exitWith {[100, true, _observers select _sameIdx]};

// Vehicle optics stretch the range (linear, not the field of view)
_observers = _observers select {(_x distance _unit) <= _maxRange * ([_x] call FUNC(observerOptics))};
if (_observers isEqualTo []) exitWith {[0, false, objNull]};
_observers = [_observers, [], {_x distance _unit}, "ASCEND"] call BIS_fnc_sortBy;
_observers resize ((count _observers) min (round MSET(maxObservers)));

// Direction the unit's weapon points, if it can aim from where it sits
private _aimDir = [_unit] call FUNC(aimDirection);

private _target = eyePos _unit;
private _identifyRange = MSET(identifyRange);
private _curve = MSET(distanceCurve);
private _instantRange = MSET(instantRange);
private _instantMult = MSET(instantMult);
private _minClose = MSET(minCloseExposure);
private _ignoreHull = !MSET(hullBlocks);
private _halfFov = MSET(fovAngle) / 2;
private _peripheral = MSET(peripheralMult);
private _nearAware = MSET(nearAwareRange);
private _skillInfluence = MSET(skillInfluence);
private _night = MSET(nightMult);
private _nvgNight = MSET(nvgNightMult);
private _aimAngle = MSET(aimAngle);
private _aimMult = MSET(aimMult);
private _light = sunOrMoon;

// Armored seat: nobody can see in, only the vehicle counts (and slowly)
private _inVehicle = _veh != _unit;
private _armored = _inVehicle && {[_unit, _veh] call FUNC(isArmoredSeat)};
private _armoredMult = MSET(armoredHullMult);
private _armoredClose = MSET(armoredCloseMult);
// Anti-meta: soft vehicle near the observer whose crew is hidden by the hull
private _meta = _inVehicle && {!_armored} && {MSET(metaDetect)};
private _metaRange = MSET(metaRange);
private _hiddenMult = MSET(hiddenCrewMult);
private _reverseMult = MSET(reverseMult);
private _rearMult = MSET(rearFacingMult);
private _rearAngle = 180 - MSET(rearFacingAngle);
private _reversing = _inVehicle && {((velocityModelSpace _veh) select 1) < -(MSET(reverseSpeed) / 3.6)};
private _slow = (abs speed _veh) < 10;
private _metaSlow = (abs speed _veh) <= MSET(metaMaxSpeed);
private _hiddenAny = MSET(hiddenCrewAny);
private _vehTarget = aimPos _veh;
private _vehDir = vectorDir _veh;
_vehDir set [2, 0];
_vehDir = vectorNormalized _vehDir;

private _best = 0;
private _bestObserver = objNull;
private _bestParts = [];

{
    private _observer = _x;
    private _observerVeh = vehicle _observer;
    private _eye = eyePos _observer;
    private _distance = _observer distance _unit;
    private _optics = [_observer] call FUNC(observerOptics);

    // With hull blocking we ignore the unit itself so the ray stops at the vehicle's glass/body
    private _visibility = [_observerVeh, "VIEW", [_unit, _veh] select _ignoreHull] checkVisibility [_eye, _target];
    private _vehVis = 0;
    private _hull = "";
    if (_armored) then {
        _vehVis = [_observerVeh, "VIEW", _veh] checkVisibility [_eye, _vehTarget];
        _visibility = _vehVis * _armoredMult;
        _hull = "armored";
    } else {
        // only a slow vehicle close by: a car driving past with the crew out of the ray is no trick
        if (_meta && _metaSlow && _distance <= _metaRange && _visibility < 0.15) then {
            _vehVis = [_observerVeh, "VIEW", _veh] checkVisibility [_eye, _vehTarget];
            if (_vehVis >= 0.5) then {
                // 0 deg = nose towards the observer, 180 deg = rear towards the observer
                private _toObserver = (getPosASL _veh) vectorFromTo _eye;
                _toObserver set [2, 0];
                private _relative = acos ((((vectorNormalized _toObserver) vectorDotProduct _vehDir) min 1) max -1);
                private _hiddenFactor = _hiddenMult;
                _hull = "hiddenCrew";
                if (_reversing) then {
                    _hiddenFactor = _hiddenFactor * _reverseMult;
                    _hull = "reversing";
                } else {
                    if (_slow && _relative >= _rearAngle) then {
                        _hiddenFactor = _hiddenFactor * _rearMult;
                        _hull = "rearFacing";
                    };
                };
                if (_hull != "hiddenCrew" || _hiddenAny) then {
                    _visibility = _visibility max (_vehVis * _hiddenFactor);
                } else {
                    _hull = "";
                };
            };
        };
    };
    if (_distance <= _instantRange) then { _visibility = _visibility max ([_minClose, _minClose * _armoredClose] select _armored); };

    if (_visibility > 0) then {
        private _toTarget = _eye vectorFromTo _target;
        private _facing = if (_observerVeh == _observer) then { eyeDirection _observer } else { vectorDir _observerVeh };
        private _angle = acos ((((vectorNormalized _facing) vectorDotProduct _toTarget) min 1) max -1);
        // right beside them nobody needs to look: a vehicle parked alongside is noticed anyway
        private _fov = [_peripheral, 1] select (_angle <= _halfFov || _distance <= _nearAware);

        // Telling who sits in a vehicle gets hard fast with distance: full inside close range,
        // then (closeRange / distance) ^ exponent, e.g. 40 m close range, exponent 1.5 -> 0.09 at 200 m
        // Optics: 1.5 = judged at 300 m as if it were 200 m away
        private _seenAt = _distance / (_optics max 0.01);
        private _distanceFactor = if (_seenAt <= _identifyRange) then {1} else {
            (_identifyRange / _seenAt) ^ _curve
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
            _bestParts = [_visibility, _angle, _fov, _distanceFactor, _behaviour, _skill, _lightFactor, _close, _aim, _vehVis, _hull, _optics];
        };
    };
} forEach _observers;

[_best, false, _bestObserver, _bestParts]
