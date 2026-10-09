#include "..\script_component.hpp"
/*
 * Author: Root
 * Event: a pursuing group radioed an alert. Local groups of that side within the radius go
 * AWARE (if set) and start SEARCHING for the unit with at least the alert suspicion.
 *
 * Arguments:
 * 0: Side <SIDE>
 * 1: Position <ARRAY>
 * 2: Radius (m) <NUMBER>
 * 3: Unit <OBJECT>
 * 4: Reason <STRING>
 * 5: Source group <GROUP>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_side", "_pos", "_radius", "_unit", ["_reason", ""], ["_source", grpNull]];

if (isNull _unit) exitWith {};

if (isServer) then {
    [QGVAR(message), [format ["RADS: %1 alert - %2 %3", _side, name _unit, _reason]]] call CBA_fnc_globalEvent;
};

private _floor = MSET(alertSuspicion);
private _setAware = MSET(areaAlertAware);
private _covered = _unit getVariable [QGVAR(cover), false];
{
    private _grp = _x;
    if (_grp != _source
        && {local _grp}
        && {side _grp == _side}
        && {!isPlayer (leader _grp)}
        && {[_grp, _pos, _radius] call FUNC(groupInRange)}
        && {[_side, _unit] call FUNC(isHostile)}
    ) then {
        if (_setAware && {behaviour (leader _grp) in ["SAFE", "CARELESS"]} && {isNil {_grp getVariable QGVAR(truceSaved)}}) then { _grp setBehaviour "AWARE"; };
        if (_covered) then {
            private _entry = [_grp, _unit, false] call FUNC(classify);
            if ((_entry select D_STATE) != ST_COMPROMISED) then {
                _entry set [D_SUSP, ((_entry select D_SUSP) max _floor) min (MSET(identifyThreshold) - 1)];
                _entry set [D_SIG, [_unit] call FUNC(appearanceSig)];
                [_grp, _entry, ST_SEARCHING, format ["alert from %1: %2", [groupId _source, "?"] select (isNull _source), _reason]] call FUNC(setState);
                [_grp, true] call FUNC(publishData);
            };
        } else {
            _grp reveal [_unit, 1];
        };
    };
} forEach allGroups;
