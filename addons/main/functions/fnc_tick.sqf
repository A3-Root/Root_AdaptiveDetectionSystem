#include "..\script_component.hpp"
/*
 * Author: Root
 * Per-frame scheduler. Every evaluation interval it snapshots the covered units and the local AI
 * groups, then works through the groups a few per frame (performance budget).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

if (GVAR(queue) isEqualTo [] && {(time - GVAR(cycleStart)) >= MSET(tickInterval)}) then {
    GVAR(cycleStart) = time;

    // Groups that moved to another machine: drop our stale copy, the new owner rehydrates from the public mirror
    {
        _x setVariable [QGVAR(data), nil];
        _x setVariable [QGVAR(ignoredVehs), nil];
    } forEach (allGroups select {!local _x && {!isNil {_x getVariable QGVAR(data)}}});

    private _players = allPlayers - entities "HeadlessClient_F";
    if (_players isEqualTo [] && {hasInterface}) then { _players = [player]; };

    private _covered = [];
    {
        { if (_x getVariable [QGVAR(cover), false]) then { _covered pushBackUnique _x; }; } forEach (crew vehicle _x);
    } forEach _players;
    // non-player units forced into cover through the API/modules
    {
        if (alive _x && {_x getVariable [QGVAR(cover), false]}) then { _covered pushBackUnique _x; };
    } forEach (missionNamespace getVariable [QGVAR(extraUnits), []]);
    GVAR(covered) = _covered;

    private _queue = allGroups select {local _x && {(side _x) in [west, east, independent]}};
    // nothing covered: only groups holding state still need work (release / forget)
    if (_covered isEqualTo []) then { _queue = _queue select {!isNil {_x getVariable QGVAR(data)}}; };
    GVAR(queue) = _queue;
};

private _budget = round MSET(groupsPerFrame);
while {_budget > 0 && {GVAR(queue) isNotEqualTo []}} do {
    [GVAR(queue) deleteAt 0, GVAR(covered)] call FUNC(processGroup);
    _budget = _budget - 1;
};
