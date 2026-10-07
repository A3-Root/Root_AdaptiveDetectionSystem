#include "..\script_component.hpp"
/*
 * Author: Root
 * Event (every machine): local friendly groups near the sender receive shared knowledge, either
 * as full identification or as a lead to search on. Shares never chain further.
 *
 * Arguments:
 * 0: Side <SIDE>
 * 1: Sender position <ARRAY>
 * 2: Radius <NUMBER>
 * 3: Unit <OBJECT>
 * 4: Mode (1 suspicion, 2 full) <NUMBER>
 * 5: Sender group <GROUP>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_side", "_pos", "_radius", "_unit", "_mode", ["_source", grpNull]];

if (isNull _unit || {!alive _unit}) exitWith {};

{
    private _grp = _x;
    if (_grp != _source
        && {local _grp}
        && {side _grp == _side}
        && {!isPlayer (leader _grp)}
        && {((leader _grp) distance _pos) <= _radius}
        && {[_side, _unit] call FUNC(isHostile)}
    ) then {
        if (_mode == 2) then {
            [_grp, _unit, "shared", false, false] call FUNC(compromise);
        } else {
            private _entry = [_grp, _unit, false] call FUNC(classify);
            if ((_entry select D_STATE) != ST_COMPROMISED) then {
                _entry set [D_SUSP, ((_entry select D_SUSP) max MSET(shareSuspicion)) min (MSET(identifyThreshold) - 1)];
                _entry set [D_STATE, ST_SEARCHING];
                [_grp, true] call FUNC(publishData);
                // uncovered units get a weak, positional lead
                if !(_unit getVariable [QGVAR(cover), false]) then { _grp reveal [_unit, MSET(shareKA) * 0.5]; };
            };
        };
    };
} forEach allGroups;
