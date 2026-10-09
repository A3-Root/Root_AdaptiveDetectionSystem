#include "..\script_component.hpp"
/*
 * Author: Root
 * Human-readable cover status for a unit (ACE self-interaction, Zeus inspect). Suspicion comes
 * from the groups' public mirrors, so it can lag unless debug publishing is on.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Show per-group detail <BOOL> (default: false)
 *
 * Return Value:
 * Structured text string <STRING>
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]], ["_detail", false]];

private _now = CBA_missionTime;
private _cover = _unit getVariable [QGVAR(cover), false];
private _lines = [
    format ["<t size='1.2'>%1</t>", format [localize LSTRING(statusTitle), name _unit]],
    format [localize LSTRING(statusCover), [format ["<t color='#ff6666'>%1</t>", localize LSTRING(statusNone)], format ["<t color='#66ff66'>%1</t>", localize LSTRING(statusActive)]] select _cover]
];

private _heat = (_unit getVariable [QGVAR(heatUntil), -1]) - _now;
if (_heat > 0) then { _lines pushBack format [localize LSTRING(statusHeat), round _heat]; };

private _wanted = ((_unit getVariable [QGVAR(wantedBy), []]) select {(_x select 1) > _now}) apply {str (_x select 0)};
if (_wanted isNotEqualTo []) then { _lines pushBack format [localize LSTRING(statusWanted), _wanted joinString ", "]; };

private _veh = vehicle _unit;
if (_veh != _unit) then {
    private _burned = ((_veh getVariable [QGVAR(burnedBy), []]) select {(_x select 1) > _now}) apply {str (_x select 0)};
    if (_burned isNotEqualTo []) then { _lines pushBack format [localize LSTRING(statusBurned), _burned joinString ", "]; };
};

// Safe zone truce
private _truce = _unit getVariable [QGVAR(truce), []];
if (_truce isNotEqualTo []) then {
    _truce params ["", "_since", "", ["_maxStay", 0]];
    private _left = [localize LSTRING(statusTruceUnlimited), format [localize LSTRING(statusTruceLeft), round ((_since + _maxStay - _now) max 0)]] select (_maxStay > 0);
    _lines pushBack format ["<t color='#66ccff'>%1</t>", format [localize LSTRING(statusTruce), _left]];
};

private _pursuers = {(_x getVariable [QGVAR(pursuitTarget), objNull]) == _unit} count allGroups;
if (_pursuers > 0) then { _lines pushBack format ["<t color='#ff8800'>%1</t>", format [localize LSTRING(statusPursued), _pursuers]]; };

if (_detail || {MSET(allowWatchedHints)}) then {
    private _max = 0;
    private _identified = 0;
    private _groupLines = [];
    private _range = MSET(maxRange);
    {
        private _grp = _x;
        if ([_grp, _unit, _range] call FUNC(groupInRange)) then {
            private _pub = _grp getVariable [QGVAR(pub), []];
            private _index = _pub findIf {(_x select 0) == _unit};
            if (_index > -1) then {
                (_pub select _index) params ["", "_susp", "_state"];
                _max = _max max _susp;
                if (_state == ST_COMPROMISED) then { _identified = _identified + 1; };
                if (_detail) then { _groupLines pushBack format ["  %1 (%2): %3 - %4", groupId _grp, side _grp, _susp, STATE_NAMES select _state]; };
            };
        };
    } forEach allGroups;

    private _level = switch (true) do {
        case (_max < 10): { format ["<t color='#66ff66'>%1</t>", localize LSTRING(statusCalm)] };
        case (_max < MSET(suspiciousThreshold)): { format ["<t color='#ccff66'>%1</t>", localize LSTRING(statusNoticed)] };
        case (_max < 70): { format ["<t color='#ffcc00'>%1</t>", localize LSTRING(statusSuspicious)] };
        default { format ["<t color='#ff8800'>%1</t>", localize LSTRING(statusClose)] };
    };
    _lines pushBack format [localize LSTRING(statusAttention), _level];
    if (_identified > 0) then { _lines pushBack format ["<t color='#ff4444'>%1</t>", format [localize LSTRING(statusIdentified), _identified]]; };
    _lines append _groupLines;
};

_lines joinString "<br/>"
