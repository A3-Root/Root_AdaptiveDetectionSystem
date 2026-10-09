#include "..\script_component.hpp"
/*
 * Author: Root
 * Event (every machine): a radio bulletin went out. The server records the burned vehicle and the
 * wanted unit (shared state); each machine alerts its local groups near the reported position.
 *
 * Arguments:
 * 0: Side <SIDE>
 * 1: Sender position <ARRAY>
 * 2: Range, 0 = side-wide <NUMBER>
 * 3: Unit <OBJECT>
 * 4: Vehicle or objNull <OBJECT>
 * 5: Reason <STRING>
 * 6: Sender group <GROUP>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_side", "_pos", "_range", ["_unit", objNull], ["_veh", objNull], ["_reason", ""], ["_source", grpNull]];

if (isServer && _reason != "areaOnly") then {
    if (MSET(bulletinBurn) && {!isNull _veh}) then {
        [_veh, _side, MSET(burnDuration), _range, _pos] call API(burnVehicle);
    };
    if (MSET(bulletinWanted) && {!isNull _unit}) then {
        [_unit, _side, MSET(wantedDuration), _range, _pos] call API(markWanted);
    };
    private _what = if (isNull _veh) then {""} else { format [" in a %1", getText (configOf _veh >> "displayName")] };
    [QGVAR(message), [format ["RADS: %1 radio bulletin - %2%3 (%4)", _side, name _unit, _what, _reason]]] call CBA_fnc_globalEvent;
};

if (!MSET(bulletinAreaAlert) || {isNull _unit}) exitWith {};

private _alertRadius = MSET(areaAlertRadius);
private _setAware = MSET(areaAlertAware);
private _covered = _unit getVariable [QGVAR(cover), false];
{
    private _grp = _x;
    if (_grp != _source
        && {local _grp}
        && {side _grp == _side}
        && {!isPlayer (leader _grp)}
        && {[_grp, _pos, _alertRadius] call FUNC(groupInRange)}
    ) then {
        if (_setAware && {behaviour (leader _grp) in ["SAFE", "CARELESS"]}) then { _grp setBehaviour "AWARE"; };
        if (_covered && {[_side, _unit] call FUNC(isHostile)}) then {
            private _entry = [_grp, _unit, false] call FUNC(classify);
            if ((_entry select D_STATE) != ST_COMPROMISED) then {
                _entry set [D_SUSP, ((_entry select D_SUSP) max MSET(shareSuspicion)) min (MSET(identifyThreshold) - 1)];
                [_grp, _entry, ST_SEARCHING, format ["radio bulletin from %1 (%2): area alert", [groupId _source, "informant/zeus"] select (isNull _source), _reason]] call FUNC(setState);
                [_grp, true] call FUNC(publishData);
            };
        };
    };
} forEach allGroups;
