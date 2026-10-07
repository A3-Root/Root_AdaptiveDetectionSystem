#include "..\script_component.hpp"
/*
 * Author: Root
 * Returns the group's local knowledge map (unit hash -> entry). When a group has just moved to
 * this machine (setGroupOwner / headless client balancing) the state published by the previous
 * owner is rehydrated, and ignore states are re-applied.
 *
 * Arguments:
 * 0: Group <GROUP>
 *
 * Return Value:
 * Data <HASHMAP>
 *
 * Public: No
 */

params ["_grp"];

private _data = _grp getVariable QGVAR(data);
if (!isNil "_data") exitWith {_data};

_data = createHashMap;
{
    _x params ["_unit", "_susp", "_state", "_ignored", ["_veh", objNull]];
    if (!isNull _unit) then {
        private _entry = NEW_ENTRY(_unit);
        _entry set [D_SUSP, _susp];
        _entry set [D_STATE, _state];
        _entry set [D_VEH, _veh];
        _data set [hashValue _unit, _entry];
        if (_ignored && _state != ST_COMPROMISED) then {
            _entry set [D_IGNORED, true];
            _grp ignoreTarget [_unit, true];
        };
    };
} forEach (_grp getVariable [QGVAR(pub), []]);

_grp setVariable [QGVAR(data), _data];
_grp setVariable [QGVAR(lastTick), time];
RLOG_2("%1 data initialised (%2 entries)",_grp,count _data);

_data
