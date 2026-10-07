#include "..\script_component.hpp"
/*
 * Author: Root
 * Event (every machine): compromise a unit for one specific group, or for every local hostile
 * group matching a side filter and radius. "attacked" respects the line-of-sight setting: an
 * unseen attacker only puts the victim's group into SEARCHING.
 *
 * Arguments:
 * 0: Group, grpNull = area mode <GROUP>
 * 1: Unit <OBJECT>
 * 2: Reason <STRING> (default: "forced")
 * 3: Sides filter, [] = all hostile <ARRAY> (default: [])
 * 4: Radius, -1 = unlimited <NUMBER> (default: -1)
 * 5: Centre, [] = unit position <ARRAY> (default: [])
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params [["_grp", grpNull], ["_unit", objNull], ["_reason", "forced"], ["_sides", []], ["_radius", -1], ["_pos", []]];

if (isNull _unit) exitWith {};

if (!isNull _grp) exitWith {
    if (!local _grp) exitWith {};
    if (_reason == "attacked" && {MSET(damageNeedsLOS)} && {!([_grp, _unit] call FUNC(groupSees))}) exitWith {
        // they know they are under attack, not by whom
        private _entry = [_grp, _unit, false] call FUNC(classify);
        if ((_entry select D_STATE) != ST_COMPROMISED) then {
            _entry set [D_SUSP, (_entry select D_SUSP) max MSET(damageSuspicion)];
            [_grp, _entry, ST_SEARCHING, "attacked by a covered unit they did not see"] call FUNC(setState);
            [_grp, true] call FUNC(publishData);
            if (RADS_DEBUG) then { ["ATTACKED", format ["attacker not seen -> SEARCHING at %1 pct", (_entry select D_SUSP) toFixed 0], _grp, _unit] call FUNC(debugLog); };
        };
    };
    [_grp, _unit, _reason, MSET(bulletinOnHostile)] call FUNC(compromise);
};

if (_pos isEqualTo []) then { _pos = getPosATL _unit; };
{
    if (local _x
        && {!isPlayer (leader _x)}
        && {(side _x) in [west, east, independent]}
        && {[side _x, _unit] call FUNC(isHostile)}
        && {_sides isEqualTo [] || {(side _x) in _sides}}
        && {_radius < 0 || {((leader _x) distance _pos) <= _radius}}
    ) then {
        [_x, _unit, _reason, false] call FUNC(compromise);
    };
} forEach allGroups;
