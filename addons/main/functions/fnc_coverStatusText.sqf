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
    format ["<t size='1.2'>RADS: %1</t>", name _unit],
    format ["Cover: %1", ["<t color='#ff6666'>none</t>", "<t color='#66ff66'>active</t>"] select _cover]
];

private _heat = (_unit getVariable [QGVAR(heatUntil), -1]) - _now;
if (_heat > 0) then { _lines pushBack format ["Heat: %1 s", round _heat]; };

private _wanted = ((_unit getVariable [QGVAR(wantedBy), []]) select {(_x select 1) > _now}) apply {str (_x select 0)};
if (_wanted isNotEqualTo []) then { _lines pushBack format ["Wanted by: %1", _wanted joinString ", "]; };

private _veh = vehicle _unit;
if (_veh != _unit) then {
    private _burned = ((_veh getVariable [QGVAR(burnedBy), []]) select {(_x select 1) > _now}) apply {str (_x select 0)};
    if (_burned isNotEqualTo []) then { _lines pushBack format ["Vehicle burned for: %1", _burned joinString ", "]; };
};

if (_detail || {MSET(allowWatchedHints)}) then {
    private _max = 0;
    private _identified = 0;
    private _groupLines = [];
    private _range = MSET(maxRange);
    {
        private _grp = _x;
        if (((leader _grp) distance _unit) < _range) then {
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
        case (_max < 10): { "<t color='#66ff66'>calm</t>" };
        case (_max < MSET(suspiciousThreshold)): { "<t color='#ccff66'>noticed</t>" };
        case (_max < 70): { "<t color='#ffcc00'>suspicious</t>" };
        default { "<t color='#ff8800'>close to identified</t>" };
    };
    _lines pushBack format ["Attention: %1", _level];
    if (_identified > 0) then { _lines pushBack format ["<t color='#ff4444'>Identified by %1 group(s)</t>", _identified]; };
    _lines append _groupLines;
};

_lines joinString "<br/>"
