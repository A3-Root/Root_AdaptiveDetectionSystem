#include "..\script_component.hpp"
/*
 * Author: Root
 * Optional AI reactions while a group is suspicious or searching: go AWARE, watch the vehicle,
 * and once suspicion reaches the follow threshold (or the group is searching) chase or
 * interdict it (pursuit). Undone when the group calms down.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Entry <ARRAY>
 * 2: Suspicious or searching <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_entry", "_active"];

if (_active) then {
    private _unit = _entry select D_UNIT;
    private _veh = vehicle _unit;
    private _leader = leader _grp;

    if (MSET(aiAware) && {behaviour _leader in ["SAFE", "CARELESS"]} && {isNil {_grp getVariable QGVAR(truceSaved)}}) then {
        if (isNil {_grp getVariable QGVAR(savedBehaviour)}) then { _grp setVariable [QGVAR(savedBehaviour), behaviour _leader]; };
        _grp setBehaviour "AWARE";
    };

    if (MSET(aiWatch)) then {
        { if ([_x] call FUNC(isObserver)) then { _x doWatch _veh; }; } forEach (units _grp);
        _grp setVariable [QGVAR(watching), true];
    };

    // Follow / chase / stop the vehicle once suspicion is high enough or the group is searching
    private _threshold = _grp getVariable [QGVAR(followThreshold), -1];
    if (_threshold < 0) then { _threshold = MSET(followThreshold); };
    if (MSET(pursuitEnabled)
        && {MSET(followEnabled)}
        && {(_entry select D_STATE) == ST_SEARCHING || {(_entry select D_SUSP) >= _threshold}}
        && {isNil {_grp getVariable QGVAR(pursuit)}}
        && {time >= (_entry select D_CLEARED)}
        && {time >= (_grp getVariable [QGVAR(nextPursuit), 0])}
    ) then {
        _grp setVariable [QGVAR(nextPursuit), time + 10];
        [_grp, _unit] call FUNC(pursuitStart);
    };

    _entry set [D_HOOKS, true];
} else {
    if (_entry select D_HOOKS) then {
        _entry set [D_HOOKS, false];

        private _saved = _grp getVariable QGVAR(savedBehaviour);
        if (!isNil "_saved") then {
            _grp setBehaviour _saved;
            _grp setVariable [QGVAR(savedBehaviour), nil];
        };
        if (_grp getVariable [QGVAR(watching), false]) then {
            { _x doWatch objNull; } forEach (units _grp);
            _grp setVariable [QGVAR(watching), nil];
        };
        private _looker = _grp getVariable [QGVAR(looker), objNull];
        if (!isNull _looker) then {
            _looker lookAt objNull;
            _grp setVariable [QGVAR(looker), nil];
        };
    };
};
