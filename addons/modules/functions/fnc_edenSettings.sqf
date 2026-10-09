#include "..\script_component.hpp"
/*
 * Author: Root
 * 3DEN: mission-level setting overrides (Detection Settings / Pursuit, Sync & Truce Settings).
 * Every attribute is named ROOT_ADS_S_<setting>; "Keep setting" (-1, or -9999 for settings that
 * accept -1 themselves) leaves the CBA value alone.
 *
 * Arguments:
 * 0: Module logic <OBJECT>
 * 1: Synced units <ARRAY>
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic", ["_units", []], ["_activated", true]];

if (!isServer || {!_activated}) exitWith {};

private _meta = missionNamespace getVariable [QMVAR(settingMeta), createHashMap];
private _pairs = [];
{
    private _name = _x;
    private _info = _y;
    private _value = _logic getVariable ["ROOT_ADS_S_" + _name, "unset"];
    if (_value isEqualType 0) then {
        switch (_info select 0) do {
            case "CHECKBOX": { if (_value >= 0) then { _pairs pushBack [_name, _value == 1]; }; };
            case "SLIDER": {
                private _keep = [-1, -9999] select ((_info select 1) < 0);
                if (_value != _keep) then {
                    _value = (_value max (_info select 1)) min (_info select 2);
                    if ((_info select 3) == 0 && {!(_info select 4)}) then { _value = round _value; };
                    _pairs pushBack [_name, _value];
                };
            };
            case "LIST": { if (_value >= 0 && {_value in (_info select 1)}) then { _pairs pushBack [_name, _value]; }; };
        };
    };
} forEach _meta;

if (_pairs isNotEqualTo []) then {
    [_pairs] call API(setOverride);
    if (RADS_DEBUG) then { diag_log text format ["[RADS] 3DEN %1 applied %2 overrides: %3", typeOf _logic, count _pairs, _pairs]; };
};
