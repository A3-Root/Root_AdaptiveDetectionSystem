#include "..\script_component.hpp"
/*
 * Author: Root
 * Applies safe zone truces to one local AI group: it ignores every hostile player under a truce
 * that covers its side (on foot or in a vehicle, even ones it already identified), and relaxes
 * while any of its members stands in a truce zone with the careless option.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp"];

private _side = side _grp;
private _revoked = missionNamespace getVariable [QGVAR(truceRevoked), createHashMap];
private _want = [];
if (MSET(enabled) && {MSET(truceEnabled)}) then {
    {
        private _unit = _x;
        (_unit getVariable [QGVAR(truce), []]) params ["", "", ["_sides", []]];
        if ((_sides isEqualTo [] || {_side in _sides})
            && {time >= (_revoked getOrDefault [hashValue _unit, -1])}
            && {[_side, _unit] call FUNC(isHostile)}
        ) then {
            _want pushBackUnique _unit;
            private _veh = vehicle _unit;
            if (_veh != _unit) then { _want pushBackUnique _veh; };
        };
    } forEach (missionNamespace getVariable [QGVAR(truceUnits), []]);
};

private _old = _grp getVariable [QGVAR(ignoredTruce), []];
private _data = _grp getVariable [QGVAR(data), createHashMap];
private _fooledVehs = _grp getVariable [QGVAR(ignoredVehs), []];
{
    if (!isNull _x) then {
        // still fooled by a disguise: keep ignoring
        private _keep = if (_x isKindOf "CAManBase") then {
            (_data getOrDefault [hashValue _x, []]) param [D_IGNORED, false]
        } else {
            _x in _fooledVehs
        };
        if (!_keep) then { _grp ignoreTarget [_x, false]; };
        if (RADS_DEBUG && {_x isKindOf "CAManBase"}) then { ["TRUCE", format ["%1 no longer holds fire on %2 (truce over, still fooled=%3)", groupId _grp, name _x, _keep], _grp, _x] call FUNC(debugLog); };
    };
} forEach (_old - _want);

// re-asserted every evaluation: disguise logic may have cleared it meanwhile
{ _grp ignoreTarget [_x, true]; } forEach _want;
if (RADS_DEBUG) then {
    { ["TRUCE", format ["%1 holds fire on %2 (safe zone truce)", groupId _grp, name _x], _grp, _x] call FUNC(debugLog); } forEach ((_want - _old) select {_x isKindOf "CAManBase"});
};
_grp setVariable [QGVAR(ignoredTruce), _want];

// stop a fight already aimed at someone now protected
if (_want isNotEqualTo []) then {
    {
        if (alive _x && {(getAttackTarget _x) in _want}) then {
            _x doTarget objNull;
            _x doWatch objNull;
        };
    } forEach (units _grp);
};

// relaxed stance inside a careless truce zone
private _relax = false;
if (MSET(enabled) && {MSET(truceEnabled)} && {time >= (_grp getVariable [QGVAR(truceSuspended), -1])}) then {
    _relax = (units _grp) findIf {
        alive _x && {
            private _zone = [getPosATL _x, _side] call FUNC(truceZoneAt);
            _zone isNotEqualTo [] && {([_zone] call FUNC(zoneTruce)) select T_CARELESS}
        }
    } > -1;
};
[_grp, _relax] call FUNC(truceCareless);
