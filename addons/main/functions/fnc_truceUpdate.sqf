#include "..\script_component.hpp"
/*
 * Author: Root
 * Safe zone truce for a local player, once a second: grants it inside a truce zone (on foot or
 * in a vehicle), counts down the allowed stay, watches for aiming at AI, and lifts it a few
 * seconds after the player leaves the zone.
 *
 * Arguments:
 * 0: Player unit (local) <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_unit"];

if (!alive _unit || {!local _unit}) exitWith {};

private _now = CBA_missionTime;
private _truce = _unit getVariable [QGVAR(truce), []];
private _zone = [];
if (MSET(enabled) && {MSET(truceEnabled)} && {_now >= (_unit getVariable [QGVAR(truceBlocked), -1])}) then {
    _zone = [getPosATL vehicle _unit] call FUNC(truceZoneAt);
};
private _notify = hasInterface && {_unit == call CBA_fnc_currentUnit} && GVAR(notifyTruce);

if (_zone isEqualTo []) exitWith {
    if (_truce isEqualTo []) exitWith {};
    private _outside = _unit getVariable [QGVAR(truceOutside), -1];
    if (_outside < 0) exitWith { _unit setVariable [QGVAR(truceOutside), _now]; };
    if ((_now - _outside) >= MSET(truceExitGrace) || {_now < (_unit getVariable [QGVAR(truceBlocked), -1])}) then {
        _unit setVariable [QGVAR(truce), [], true];
        _unit setVariable [QGVAR(truceOutside), nil];
        if (RADS_DEBUG) then { ["TRUCE", format ["left safe zone %1 - truce lifted", _truce select 0], grpNull, _unit] call FUNC(debugLog); };
        if (_notify) then { hintSilent parseText format ["<t color='#ffcc00'>%1</t>", localize LSTRING(truceLeft)]; };
    };
};

private _opts = [_zone] call FUNC(zoneTruce);
private _id = _zone select Z_ID;
_unit setVariable [QGVAR(truceOutside), nil];

if (_truce isEqualTo [] || {(_truce select 0) != _id}) then {
    _truce = [_id, _now, _zone select Z_SIDES, _opts select T_MAXSTAY];
    _unit setVariable [QGVAR(truce), _truce, true];
    _unit setVariable [QGVAR(truceWarned), false];
    _unit setVariable [QGVAR(truceAim), 0];
    if (RADS_DEBUG) then { ["TRUCE", format ["entered safe zone %1 (%2): truce granted, max stay %3 s, careless AI %4, break scope %5, aim breaks %6", _id, _zone select Z_LABEL, _opts select T_MAXSTAY, _opts select T_CARELESS, _opts select T_SCOPE, _opts select T_AIM], grpNull, _unit] call FUNC(debugLog); };
    if (_notify) then {
        private _stay = [localize LSTRING(truceNoLimit), format [localize LSTRING(truceStayFor), round (_opts select T_MAXSTAY)]] select ((_opts select T_MAXSTAY) > 0);
        hintSilent parseText format ["<t color='#66ccff'>%1</t><br/>%2", localize LSTRING(truceEntered), _stay];
    };
};

// overstaying the welcome
private _maxStay = _opts select T_MAXSTAY;
if (_maxStay > 0) then {
    private _left = (_truce select 1) + _maxStay - _now;
    if (_left <= (_opts select T_WARN) && {!(_unit getVariable [QGVAR(truceWarned), false])}) then {
        _unit setVariable [QGVAR(truceWarned), true];
        if (_notify) then { hint parseText format ["<t color='#ff8800'>%1</t>", format [localize LSTRING(truceWarning), round (_left max 0)]]; };
    };
    if (_left <= 0) then { [_unit, "overstayed the safe zone"] call FUNC(breakTruce); };
};

// pointing a weapon at the AI for too long
if (_opts select T_AIM) then {
    private _dir = [_unit] call FUNC(aimDirection);
    private _aiming = false;
    if (_dir isNotEqualTo []) then {
        private _eye = eyePos _unit;
        private _cone = MSET(aimAngle);
        _aiming = ((_unit nearEntities [["CAManBase"], 100]) findIf {
            alive _x && {!isPlayer _x} && {[side group _x, _unit] call FUNC(isHostile)}
            && {acos (((_dir vectorDotProduct (_eye vectorFromTo (eyePos _x))) min 1) max -1) <= _cone}
        }) > -1;
    };
    private _aimTime = [0, (_unit getVariable [QGVAR(truceAim), 0]) + 1] select _aiming;
    _unit setVariable [QGVAR(truceAim), _aimTime];
    if (_aimTime >= MSET(truceAimTime)) then { [_unit, "kept aiming at AI"] call FUNC(breakTruce); };
};
