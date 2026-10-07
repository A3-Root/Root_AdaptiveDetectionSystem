#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Summary of a unit's RADS status.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * [hasCover <BOOL>, heatRemaining <NUMBER>, wantedBySides <ARRAY>, maxPublishedSuspicion <NUMBER>, identifiedByGroups <NUMBER>]
 *
 * Example:
 * [player] call root_rads_fnc_getStatus
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]]];

private _now = CBA_missionTime;
private _max = 0;
private _identified = 0;
{
    private _pub = _x getVariable [QGVAR(pub), []];
    private _index = _pub findIf {(_x select 0) == _unit};
    if (_index > -1) then {
        _max = _max max ((_pub select _index) select 1);
        if (((_pub select _index) select 2) == ST_COMPROMISED) then { _identified = _identified + 1; };
    };
} forEach allGroups;

[
    _unit getVariable [QGVAR(cover), false],
    ((_unit getVariable [QGVAR(heatUntil), -1]) - _now) max 0,
    ((_unit getVariable [QGVAR(wantedBy), []]) select {(_x select 1) > _now}) apply {_x select 0},
    _max,
    _identified
]
