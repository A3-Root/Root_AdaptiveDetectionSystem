#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Sets the truce options of a safe zone (players inside are not attacked while they behave).
 *
 * Arguments:
 * 0: Zone id <STRING>
 * 1: Options [enabled, maxStay s (0 = unlimited), warn s before the end, AI careless BOOL,
 *    break scope (0 offender, 1 offender's group, 2 everyone in the zone), aiming breaks BOOL].
 *    [] = use the CBA defaults. <ARRAY>
 *
 * Return Value:
 * Zone found <BOOL>
 *
 * Example:
 * ["ads_zone_1", [true, 600, 60, true, 1, false]] call root_ads_fnc_setZoneTruce
 *
 * Public: Yes
 */

params [["_id", "", [""]], ["_options", [], [[]]]];

if (!isServer) exitWith { [QGVAR(api), ["setZoneTruce", _this]] call CBA_fnc_serverEvent; true };

private _index = GVAR(zones) findIf {(_x select Z_ID) == _id};
if (_index < 0) exitWith { diag_log text format ["[RADS] setZoneTruce: no zone %1", _id]; false };

if (_options isNotEqualTo []) then {
    _options params [["_enabled", true], ["_maxStay", 0], ["_warn", 60], ["_careless", true], ["_scope", 1], ["_aim", false]];
    _options = [_enabled, _maxStay max 0, _warn max 0, _careless, (round _scope) max 0 min 2, _aim];
};
(GVAR(zones) select _index) set [Z_TRUCE, _options];
publicVariable QGVAR(zones);
RLOG_2("zone %1 truce set to %2",_id,_options);
true
