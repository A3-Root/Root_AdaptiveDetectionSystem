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
    // a different vehicle than the one they identified: maybe they lost the unit
    if ([_grp, _entry] call FUNC(trySwapForgive)) exitWith {};

    [_grp, _entry, false, "identified"] call FUNC(setIgnored);
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
    [_grp, _entry, ["vehicle does not fool this side (or group immune)", "restricted (no cover) zone"] select _noCover] call FUNC(releaseEntry);
};

[_grp, _entry, true, "disguise works on this side"] call FUNC(setIgnored);

([_grp, _unit, _veh] call FUNC(computeExposure)) params ["_exposure", "_sameVehicle", "_observer", ["_parts", []]];

// ------------------------------------------------------------------ debug bookkeeping (only when the debug log is on)
private _dbg = RADS_DEBUG;
private _factors = [];
private _fnc_record = {
    params ["_line", ["_print", false]];
    [_entry, _line] call FUNC(debugHistory);
    if (_print) then { diag_log text format ["[RADS] %1 | %2 vs %3", _line, groupId _grp, name _unit]; };
};
private _fnc_observerText = {
    if (isNull _observer) exitWith {"observer=<none>"};
    _parts params [["_vis", 0], ["_angle", 0], ["_fov", 0], ["_distF", 0], ["_beh", 0], ["_skill", 0], ["_light", 0], ["_close", 1], ["_aim", 1]];
    format ["observer=%1 (%2) d=%3m LOS=%4 angle=%5deg fov=%6 distF=%7 beh=%8 skill=%9 light=%10 faceToFace=%11 aimed=%12",
        name _observer, behaviour _observer, round (_observer distance _veh), _vis toFixed 2, round _angle,
        _fov toFixed 2, _distF toFixed 2, _beh toFixed 2, _skill toFixed 2, _light toFixed 2, _close toFixed 2, _aim toFixed 2]
};
private _fnc_vehicleText = {
    format ["veh grid=%1 speed=%2kmh onRoad=%3 visDmg=%4", mapGridPosition _veh, round speed _veh, isOnRoad _veh, ([_veh] call FUNC(visibleDamage)) toFixed 2]
};
#define FACTOR(name,val) if (_dbg) then { _factors pushBack format ["%1=%2", name, (val) toFixed 2] }

if (_sameVehicle && {MSET(sameVehicleInstant)}) exitWith {
    if (_dbg) then { [format ["t=%1 INSTANT same vehicle: %2 is riding with the unit | %3", CBA_missionTime toFixed 1, name _observer, call _fnc_vehicleText], true] call _fnc_record; };
    [_grp, _unit, "sameVehicle"] call FUNC(compromise);
};
if (_disguise == 2 && _exposure > 0.05) exitWith {
    if (_dbg) then { [format ["t=%1 INSTANT burned vehicle recognised (burnedFor=%2) exp=%3 | %4 | %5", CBA_missionTime toFixed 1, ((_veh getVariable [QGVAR(burnedBy), []]) select {(_x select 1) > CBA_missionTime}) apply {_x select 0}, _exposure toFixed 2, call _fnc_observerText, call _fnc_vehicleText], true] call _fnc_record; };
    [_grp, _unit, "burnedVehicle"] call FUNC(compromise);
};
if (_exposure > 0.05 && {[_veh, _side, _observer] call FUNC(plateReported)}) exitWith {
    if (_dbg) then { [format ["t=%1 INSTANT reported plate '%2' read exp=%3 | %4 | %5", CBA_missionTime toFixed 1, getPlateNumber _veh, _exposure toFixed 2, call _fnc_observerText, call _fnc_vehicleText], true] call _fnc_record; };
    [_grp, _unit, "plate"] call FUNC(compromise);
    if (MSET(plateCombat)) then { _grp setBehaviour "COMBAT"; };
};

private _susp = _entry select D_SUSP;
private _before = _susp;
private _visible = _exposure > 0.01 && {!_safe};
private _floorNote = "";

if (_visible) then {
    ([_unit, _veh] call FUNC(seatFactor)) params ["_seatMult", "_exposedSeat"];
    private _gearMult = [_unit, _side, _exposedSeat] call FUNC(gearFactor);
    private _mult = _weather * _seatMult * _gearMult;
    FACTOR("weather",_weather);
    FACTOR("seat",_seatMult);
    FACTOR("gear",_gearMult);

    // vehicle look
    private _lookMult = [MSET(friendlyVehMult), MSET(civVehMult)] select (([_veh] call FUNC(vehicleSide)) == civilian);
    _mult = _mult * _lookMult;
    FACTOR("vehicleLook",_lookMult);
    if ([_veh] call FUNC(isOpenVehicle)) then { _mult = _mult * MSET(openVehicleMult); FACTOR("openVehicle",MSET(openVehicleMult)); };
    private _visibleDamage = [_veh] call FUNC(visibleDamage);
    _mult = _mult * (1 + _visibleDamage * MSET(damageInfluence));
    if (_visibleDamage > 0) then { FACTOR("damage",1 + _visibleDamage * MSET(damageInfluence)); };

    // how the vehicle is being driven
    private _speed = abs speed _veh;
    private _distance = _observer distance _veh;
    private _isAir = _veh isKindOf "Air";
    private _isLand = !_isAir && {!(_veh isKindOf "Ship")};
    if (_speed > MSET(fastSpeed)) then { _mult = _mult * MSET(fastMult); FACTOR("fastPass",MSET(fastMult)); };
    if (_distance < 100 && {_speed > MSET(speedingSpeed)}) then { _mult = _mult * MSET(speedingMult); FACTOR("speeding",MSET(speedingMult)); };
    if (_isLand && _distance < 150 && _speed > 10 && {!isOnRoad _veh}) then { _mult = _mult * MSET(offroadMult); FACTOR("offroad",MSET(offroadMult)); };
    if (_isLand && {sunOrMoon < 0.3} && _speed > 5 && {!isLightOn _veh}) then { _mult = _mult * MSET(lightsOffMult); FACTOR("lightsOff",MSET(lightsOffMult)); };
    if (CBA_missionTime - (_veh getVariable [QGVAR(hornTime), -100]) < 10) then { _mult = _mult * MSET(hornMult); FACTOR("horn",MSET(hornMult)); };
    if (_exposedSeat && {sunOrMoon < 0.5}) then {
        private _weapon = currentWeapon _unit;
        if (_weapon != "" && {(_unit isFlashlightOn _weapon) || {_unit isIRLaserOn _weapon}}) then { _mult = _mult * MSET(lightMult); FACTOR("weaponLight",MSET(lightMult)); };
    };
    if (_isAir) then {
        private _altitude = (getPosATL _veh) select 2;
        private _falloff = MSET(altitudeFalloff);
        if (_altitude > _falloff) then { _mult = _mult * (_falloff / _altitude); FACTOR("altitude",_falloff / _altitude); };
    };

    // occupants that are not covered give the vehicle away
    if (MSET(mixedCrewMode) == 1) then {
        private _odd = {alive _x && {!(_x getVariable [QGVAR(cover), false])} && {[_side, _x] call FUNC(isHostile)}} count (crew _veh);
        if (_odd > 0) then { _mult = _mult * (MSET(mixedCrewMult) ^ _odd); FACTOR("mixedCrew",MSET(mixedCrewMult) ^ _odd); };
    };

    // repeated passes and loitering
    if (!(_entry select D_VISIBLE) && {(time - (_entry select D_LASTEXP)) > MSET(passGap)}) then {
        _entry set [D_PASSES, (_entry select D_PASSES) + 1];
    };
    private _passMult = (1 + MSET(passBonus) * (((_entry select D_PASSES) - 1) max 0)) min MSET(passMax);
    _mult = _mult * _passMult;
    private _passName = format ["passes(%1)", _entry select D_PASSES];
    if (_passMult != 1) then { FACTOR(_passName,_passMult); };
    if (_speed < 3 && {_distance < (MSET(identifyRange) * 3)}) then {
        _entry set [D_STATIONARY, (_entry select D_STATIONARY) + _dt];
    };
    private _loiterMult = 1 + (MSET(stationaryMult) - 1) * (((_entry select D_STATIONARY) / (MSET(stationaryTime) max 1)) min 1);
    _mult = _mult * _loiterMult;
    private _loiterName = format ["loiter(%1s)", round (_entry select D_STATIONARY)];
    if (_loiterMult != 1) then { FACTOR(_loiterName,_loiterMult); };

    // a group busy fighting someone else pays less attention
    private _attackTarget = getAttackTarget (leader _grp);
    if (!isNull _attackTarget && _attackTarget != _unit && _attackTarget != _veh) then { _mult = _mult * MSET(engagedElsewhereMult); FACTOR("busyFighting",MSET(engagedElsewhereMult)); };

    // wanted by this side, searching for them, per-group / per-unit profiles
    private _now = CBA_missionTime;
    private _groupPos = getPosATL (leader _grp);
    private _wanted = (_unit getVariable [QGVAR(wantedBy), []]) findIf {
        _x params ["_wSide", "_until", "_wPos", "_range"];
        _wSide == _side && _until > _now && {_range <= 0 || {(_groupPos distance2D _wPos) <= _range}}
    } > -1;
    if (_wanted) then { _mult = _mult * MSET(wantedMult); FACTOR("wanted",MSET(wantedMult)); };
    if (_state == ST_SEARCHING) then { _mult = _mult * MSET(searchingBuildMult); FACTOR("searching",MSET(searchingBuildMult)); };
    private _profileMult = (_grp getVariable [QGVAR(groupMult), 1]) * (_unit getVariable [QGVAR(unitMult), 1]);
    _mult = _mult * _profileMult;
    if (_profileMult != 1) then { FACTOR("profiles",_profileMult); };
    if (_zoneBuild != 1) then { FACTOR("zone",_zoneBuild); };

    _susp = _susp + _exposure * _mult * _zoneBuild * MSET(buildRate) * _dt;
    _entry set [D_LASTEXP, time];

    // A visibly shot-up or burning vehicle is suspicious the moment it is seen
    private _damageAt = MSET(damageVisibleAt);
    if (_damageAt < 1 && _visibleDamage >= _damageAt && _exposure >= 0.1) then {
        private _suspicious = MSET(suspiciousThreshold);
        private _floor = _suspicious + (MSET(identifyThreshold) - 1 - _suspicious) * MSET(damageFloorScale) * _visibleDamage;
        if (_floor > _susp) then { _floorNote = format [" damageFloor=%1", _floor toFixed 1]; };
        _susp = _susp max _floor;
    };

    if (_dbg) then {
        private _gain = _susp - _before;
        private _line = format ["t=%1 SEEN susp %2->%3 (+%4 in %5s) exposure=%6 totalMult=%7 buildRate=%8%9 | %10 | %11 | factors: %12",
            CBA_missionTime toFixed 1, _before toFixed 1, (_susp min 100) toFixed 1, _gain toFixed 1, _dt toFixed 2,
            _exposure toFixed 2, (_mult * _zoneBuild) toFixed 2, MSET(buildRate), _floorNote,
            call _fnc_observerText, call _fnc_vehicleText, _factors joinString " "];
        private _detail = MSET(debugDetail);
        [_line, _detail >= 2 || {_detail == 1 && {_gain >= MSET(debugJump)}}] call _fnc_record;
    };
} else {
    _susp = _susp - MSET(decayRate) * _zoneDecay * _dt;
    _entry set [D_STATIONARY, ((_entry select D_STATIONARY) - 2 * _dt) max 0];
    if (_dbg) then {
        [format ["t=%1 unseen susp %2->%3%4 | %5", CBA_missionTime toFixed 1, _before toFixed 1, (_susp max 0) toFixed 1, [" (safe zone)", ""] select (!_safe), call _fnc_vehicleText], MSET(debugDetail) >= 2] call _fnc_record;
    };
};

_entry set [D_VISIBLE, _visible];
_susp = (_susp max 0) min 100;
_entry set [D_SUSP, _susp];

if (_susp >= MSET(identifyThreshold)) exitWith {
    [_grp, _unit, "identified (suspicion reached threshold)"] call FUNC(compromise);
};

private _newState = _state;
if (_susp >= MSET(suspiciousThreshold)) then {
    if (_state == ST_UNAWARE) then { _newState = ST_SUSPICIOUS; };
} else {
    if (_susp < MSET(recoverThreshold)) then { _newState = ST_UNAWARE; };
};

if (_newState != _state) then {
    private _why = if (_newState == ST_UNAWARE) then {
        format ["suspicion %1 fell below calm-down threshold %2", _susp toFixed 1, MSET(recoverThreshold)]
    } else {
        format ["suspicion %1 crossed suspicious threshold %2 (+%3 this evaluation)", _susp toFixed 1, MSET(suspiciousThreshold), (_susp - _before) toFixed 1]
    };
    [_grp, _entry, _newState, _why] call FUNC(setState);
    [_grp, true] call FUNC(publishData);
    if (_newState == ST_SUSPICIOUS && {isPlayer _unit}) then {
        [QGVAR(watched), [_grp], _unit] call CBA_fnc_targetEvent;
    };
};

[_grp, _entry, _newState in [ST_SUSPICIOUS, ST_SEARCHING]] call FUNC(behaviourHooks);
