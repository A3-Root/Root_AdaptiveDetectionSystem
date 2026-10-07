#include "..\script_component.hpp"
/*
 * Author: Root
 * Optional visible AI reactions while suspicious/searching (AWARE, watch, investigate), and
 * their restoration once the group calms down. All off by default.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Entry <ARRAY>
 * 2: Active <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_entry", "_active"];

if (_active) then {
    private _veh = vehicle (_entry select D_UNIT);
    private _leader = leader _grp;

    if (MSET(aiAware) && {behaviour _leader in ["SAFE", "CARELESS"]}) then {
        if (isNil {_grp getVariable QGVAR(savedBehaviour)}) then { _grp setVariable [QGVAR(savedBehaviour), behaviour _leader]; };
        _grp setBehaviour "AWARE";
    };

    if (MSET(aiWatch)) then {
        { if ([_x] call FUNC(isObserver)) then { _x doWatch _veh; }; } forEach (units _grp);
        _grp setVariable [QGVAR(watching), true];
    };

    if (MSET(aiInvestigate)
        && {(_entry select D_SUSP) >= MSET(aiInvestigateMin)}
        && {(_leader distance _veh) <= MSET(aiInvestigateRange)}
        && {time > (_grp getVariable [QGVAR(nextInvestigate), 0])}
    ) then {
        _grp setVariable [QGVAR(nextInvestigate), time + 20];
        _grp setVariable [QGVAR(investigating), true];
        _leader doMove (getPosATL _veh);
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
        if (_grp getVariable [QGVAR(investigating), false]) then {
            // hand the group back to its waypoints
            (units _grp) doFollow (leader _grp);
            _grp setCurrentWaypoint [_grp, currentWaypoint _grp];
            _grp setVariable [QGVAR(investigating), nil];
        };
    };
};
