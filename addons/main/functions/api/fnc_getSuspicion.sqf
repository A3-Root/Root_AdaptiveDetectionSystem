#include "..\..\script_component.hpp"
/*
 * Author: Root
 * A group's suspicion of a unit and its state. Exact where the group is local, otherwise the
 * last published value.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Unit <OBJECT>
 *
 * Return Value:
 * [suspicion 0-100 <NUMBER>, state "UNAWARE"/"SUSPICIOUS"/"SEARCHING"/"COMPROMISED"/"" <STRING>]
 *
 * Example:
 * [group cursorObject, player] call root_ads_fnc_getSuspicion
 *
 * Public: Yes
 */

params [["_grp", grpNull, [grpNull]], ["_unit", objNull, [objNull]]];

if (local _grp) then {
    private _data = _grp getVariable QGVAR(data);
    private _entry = if (isNil "_data") then {[]} else {_data getOrDefault [hashValue _unit, []]};
    if (_entry isEqualTo []) then { [0, ""] } else { [_entry select D_SUSP, STATE_NAMES select (_entry select D_STATE)] }
} else {
    private _pub = _grp getVariable [QGVAR(pub), []];
    private _index = _pub findIf {(_x select 0) == _unit};
    if (_index == -1) then { [0, ""] } else { [(_pub select _index) select 1, STATE_NAMES select ((_pub select _index) select 2)] }
}
