#include "..\script_component.hpp"
/*
 * Author: Root
 * One evaluation step of a local group against one covered unit: builds or decays suspicion,
 * handles state transitions, identification, and forgetting once contact is lost.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Entry <ARRAY>
 * 2: Delta time (s) <NUMBER>
 * 3: Weather factor <NUMBER>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_entry", "_dt", "_weather"];

private _unit = _entry select D_UNIT;
private _veh = vehicle _unit;
private _side = side _grp;
private _state = _entry select D_STATE;
_entry set [D_LASTUPD, time];
_entry set [D_VEH, _veh];

// ------------------------------------------------------------------ identified: track contact, forget later
if (_state == ST_COMPROMISED) exitWith {
    [_grp, _entry, false] call FUNC(setIgnored);
    if ([_grp, _unit] call FUNC(groupSees)) then { _entry set [D_LASTEXP, time]; };

    private _lastSeen = ((leader _grp) targetKnowledge _unit) param [2, -1e10];
    private _since = time - (_lastSeen max (_entry select D_LASTEXP));

    private _age = MSET(targetAge);
    if (_age != "" && {!(_entry select D_AGED)} && {_since > MSET(targetAgeDelay)}) then {
        _entry set [D_AGED, true];
        _unit setTargetAge _age;
    };

    if (_since > MSET(forgetAfter)) then { [_grp, _entry] call FUNC(forgetEntry); };
};

// ------------------------------------------------------------------ does the vehicle fool this side at all?
private _disguise = if (_grp getVariable [QGVAR(immune), false]) then {0} else {
    [_veh, _side, getPosATL (leader _grp)] call FUNC(vehicleDisguise)
};
(([getPosATL _veh, _side] call FUNC(zoneModifiers))) params ["_noCover", "_zoneBuild", "_zoneDecay", "_safe"];

if (_disguise == 0 || _noCover) exitWith {
    [_grp, _entry] call FUNC(releaseEntry);
};

[_grp, _entry, true] call FUNC(setIgnored);

([_grp, _unit, _veh] call FUNC(computeExposure)) params ["_exposure", "_sameVehicle", "_observer"];

if (_sameVehicle && {MSET(sameVehicleInstant)}) exitWith {
    [_grp, _unit, "sameVehicle"] call FUNC(compromise);
};
if (_disguise == 2 && _exposure > 0.05) exitWith {
    [_grp, _unit, "burnedVehicle"] call FUNC(compromise);
};

private _susp = _entry select D_SUSP;
private _visible = _exposure > 0.01 && {!_safe};

if (_visible) then {
    ([_unit, _veh] call FUNC(seatFactor)) params ["_seatMult", "_exposedSeat"];
    private _mult = _weather * _seatMult * ([_unit, _side, _exposedSeat] call FUNC(gearFactor));

    // vehicle look
    _mult = _mult * ([MSET(friendlyVehMult), MSET(civVehMult)] select (([_veh] call FUNC(vehicleSide)) == civilian));
    if ([_veh] call FUNC(isOpenVehicle)) then { _mult = _mult * MSET(openVehicleMult); };
    private _visibleDamage = [_veh] call FUNC(visibleDamage);
    _mult = _mult * (1 + _visibleDamage * MSET(damageInfluence));

    // how the vehicle is being driven
    private _speed = abs speed _veh;
    private _distance = _observer distance _veh;
    private _isAir = _veh isKindOf "Air";
    private _isLand = !_isAir && {!(_veh isKindOf "Ship")};
    if (_speed > MSET(fastSpeed)) then { _mult = _mult * MSET(fastMult); };
    if (_distance < 100 && {_speed > MSET(speedingSpeed)}) then { _mult = _mult * MSET(speedingMult); };
    if (_isLand && _distance < 150 && _speed > 10 && {!isOnRoad _veh}) then { _mult = _mult * MSET(offroadMult); };
    if (_isLand && {sunOrMoon < 0.3} && _speed > 5 && {!isLightOn _veh}) then { _mult = _mult * MSET(lightsOffMult); };
    if (CBA_missionTime - (_veh getVariable [QGVAR(hornTime), -100]) < 10) then { _mult = _mult * MSET(hornMult); };
    if (_exposedSeat && {sunOrMoon < 0.5}) then {
        private _weapon = currentWeapon _unit;
        if (_weapon != "" && {(_unit isFlashlightOn _weapon) || {_unit isIRLaserOn _weapon}}) then { _mult = _mult * MSET(lightMult); };
    };
    if (_isAir) then {
        private _altitude = (getPosATL _veh) select 2;
        private _falloff = MSET(altitudeFalloff);
        if (_altitude > _falloff) then { _mult = _mult * (_falloff / _altitude); };
    };

    // occupants that are not covered give the vehicle away
    if (MSET(mixedCrewMode) == 1) then {
        private _odd = {alive _x && {!(_x getVariable [QGVAR(cover), false])} && {[_side, _x] call FUNC(isHostile)}} count (crew _veh);
        if (_odd > 0) then { _mult = _mult * (MSET(mixedCrewMult) ^ _odd); };
    };

    // repeated passes and loitering
    if (!(_entry select D_VISIBLE) && {(time - (_entry select D_LASTEXP)) > MSET(passGap)}) then {
        _entry set [D_PASSES, (_entry select D_PASSES) + 1];
    };
    _mult = _mult * ((1 + MSET(passBonus) * (((_entry select D_PASSES) - 1) max 0)) min MSET(passMax));
    if (_speed < 3 && {_distance < (MSET(identifyRange) * 3)}) then {
        _entry set [D_STATIONARY, (_entry select D_STATIONARY) + _dt];
    };
    _mult = _mult * (1 + (MSET(stationaryMult) - 1) * (((_entry select D_STATIONARY) / (MSET(stationaryTime) max 1)) min 1));

    // a group busy fighting someone else pays less attention
    private _attackTarget = getAttackTarget (leader _grp);
    if (!isNull _attackTarget && _attackTarget != _unit && _attackTarget != _veh) then { _mult = _mult * MSET(engagedElsewhereMult); };

    // wanted by this side, searching for them, per-group / per-unit profiles
    private _now = CBA_missionTime;
    private _groupPos = getPosATL (leader _grp);
    private _wanted = (_unit getVariable [QGVAR(wantedBy), []]) findIf {
        _x params ["_wSide", "_until", "_wPos", "_range"];
        _wSide == _side && _until > _now && {_range <= 0 || {(_groupPos distance2D _wPos) <= _range}}
    } > -1;
    if (_wanted) then { _mult = _mult * MSET(wantedMult); };
    if (_state == ST_SEARCHING) then { _mult = _mult * MSET(searchingBuildMult); };
    _mult = _mult * (_grp getVariable [QGVAR(groupMult), 1]) * (_unit getVariable [QGVAR(unitMult), 1]);

    _susp = _susp + _exposure * _mult * _zoneBuild * MSET(buildRate) * _dt;
    _entry set [D_LASTEXP, time];

    // A visibly shot-up or burning vehicle is suspicious the moment it is seen
    private _damageAt = MSET(damageVisibleAt);
    if (_damageAt < 1 && _visibleDamage >= _damageAt && _exposure >= 0.1) then {
        private _suspicious = MSET(suspiciousThreshold);
        private _floor = _suspicious + (MSET(identifyThreshold) - 1 - _suspicious) * MSET(damageFloorScale) * _visibleDamage;
        _susp = _susp max _floor;
    };
} else {
    _susp = _susp - MSET(decayRate) * _zoneDecay * _dt;
    _entry set [D_STATIONARY, ((_entry select D_STATIONARY) - 2 * _dt) max 0];
};

_entry set [D_VISIBLE, _visible];
_susp = (_susp max 0) min 100;
_entry set [D_SUSP, _susp];

if (_susp >= MSET(identifyThreshold)) exitWith {
    [_grp, _unit, "identified"] call FUNC(compromise);
};

private _newState = _state;
if (_susp >= MSET(suspiciousThreshold)) then {
    if (_state == ST_UNAWARE) then { _newState = ST_SUSPICIOUS; };
} else {
    if (_susp < MSET(recoverThreshold)) then { _newState = ST_UNAWARE; };
};

if (_newState != _state) then {
    _entry set [D_STATE, _newState];
    [_grp, true] call FUNC(publishData);
    RLOG_4("%1 -> %2 for %3 (%4)",_grp,STATE_NAMES select _newState,_unit,round _susp);
    if (_newState == ST_SUSPICIOUS && {isPlayer _unit}) then {
        [QGVAR(watched), [_grp], _unit] call CBA_fnc_targetEvent;
    };
};

[_grp, _entry, _newState in [ST_SUSPICIOUS, ST_SEARCHING]] call FUNC(behaviourHooks);
