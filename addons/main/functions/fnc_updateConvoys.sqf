#include "..\script_component.hpp"
/*
 * Author: Root
 * Groups the vehicles of covered units into convoys: vehicles that stay within the convoy gap of
 * each other, heading the same way (or all halted), for the formation time. Chains count, so a
 * long column is one convoy. Run by every machine at the start of each evaluation cycle.
 *
 * Arguments:
 * 0: Covered units <ARRAY>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_covered"];

GVAR(convoys) = createHashMap;
if (!MSET(convoyEnabled)) exitWith { GVAR(convoyPairs) = createHashMap; };

private _vehicles = [];
{
    private _veh = vehicle _x;
    if (_veh != _x && {alive _veh}) then { _vehicles pushBackUnique _veh; };
} forEach _covered;
if (count _vehicles < 2) exitWith { GVAR(convoyPairs) = createHashMap; };

private _gap = MSET(convoyGap);
private _formTime = MSET(convoyFormTime);
private _oldPairs = missionNamespace getVariable [QGVAR(convoyPairs), createHashMap];
private _pairs = createHashMap;
private _links = _vehicles apply {[]};
private _count = count _vehicles;

for "_i" from 0 to (_count - 2) do {
    private _a = _vehicles select _i;
    for "_j" from (_i + 1) to (_count - 1) do {
        private _b = _vehicles select _j;
        if ((_a distance _b) <= _gap) then {
            private _halted = (abs speed _a) < 5 && {(abs speed _b) < 5};
            private _headingGap = abs ((((getDir _a) - (getDir _b)) + 540) mod 360 - 180);
            if (_halted || _headingGap <= 30) then {
                private _key = format ["%1|%2", hashValue _a, hashValue _b];
                private _since = _oldPairs getOrDefault [_key, time];
                _pairs set [_key, _since];
                if ((time - _since) >= _formTime) then {
                    (_links select _i) pushBack _j;
                    (_links select _j) pushBack _i;
                };
            };
        };
    };
};
GVAR(convoyPairs) = _pairs;

// connected vehicles form one convoy
private _done = [];
for "_i" from 0 to (_count - 1) do {
    if !(_i in _done) then {
        private _component = [];
        private _open = [_i];
        while {_open isNotEqualTo []} do {
            private _k = _open deleteAt 0;
            if !(_k in _done) then {
                _done pushBack _k;
                _component pushBack (_vehicles select _k);
                _open append (_links select _k);
            };
        };
        if (count _component > 1) then {
            { GVAR(convoys) set [hashValue _x, _component]; } forEach _component;
        };
    };
};
