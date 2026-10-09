#include "..\script_component.hpp"
/*
 * Author: Root
 * The pursuit's own MOVE waypoint. It is inserted in front of the group's current waypoint, so
 * removing it hands the group back to exactly where it was in its own route.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: "add", "move" or "remove" <STRING>
 * 2: Position ATL (add/move) <ARRAY> (default: [])
 *
 * Return Value:
 * Waypoint (add/move), [] (remove) <ARRAY>
 *
 * Public: No
 */

params ["_grp", "_mode", ["_pos", []]];

private _pursuit = _grp getVariable [QGVAR(pursuit), createHashMap];
private _wp = _pursuit getOrDefault ["wp", []];

private _fnc_add = {
    private _index = currentWaypoint _grp;
    _pursuit set ["wpIndex", _index];
    private _new = _grp addWaypoint [ASLToAGL (ATLToASL _pos), 0, _index];
    _new setWaypointType "MOVE";
    _new setWaypointBehaviour "UNCHANGED";
    _new setWaypointSpeed "FULL";
    _new setWaypointCompletionRadius 10;
    _grp setCurrentWaypoint _new;
    _pursuit set ["wpPos", _pos];
    _new
};

switch (_mode) do {
    case "add": { call _fnc_add };
    case "move": {
        if (_wp isEqualTo [] || {(_wp select 1) >= count (waypoints _grp)}) exitWith {
            _wp = call _fnc_add;
            _pursuit set ["wp", _wp];
            _wp
        };
        // the group reached it and moved on: make it current again (no duplicates in the route)
        if (currentWaypoint _grp != (_wp select 1)) then {
            _wp setWaypointPosition [ASLToAGL (ATLToASL _pos), 0];
            _grp setCurrentWaypoint _wp;
            _pursuit set ["wpPos", _pos];
        };
        // only re-path when the target really moved, drivers stutter on every update
        if ((_pos distance2D (_pursuit getOrDefault ["wpPos", [0, 0, 0]])) > 12) then {
            _wp setWaypointPosition [ASLToAGL (ATLToASL _pos), 0];
            _pursuit set ["wpPos", _pos];
        };
        _wp
    };
    default {
        if (_wp isNotEqualTo [] && {(_wp select 1) < count (waypoints _grp)}) then {
            private _index = _pursuit getOrDefault ["wpIndex", _wp select 1];
            deleteWaypoint _wp;
            _grp setCurrentWaypoint [_grp, _index min ((count (waypoints _grp)) max 0)];
        };
        _pursuit set ["wp", []];
        []
    };
}
