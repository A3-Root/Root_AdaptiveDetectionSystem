#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Per-group observer profile (vigilant checkpoint guards, sleepy sentries, special units that see
 * through disguises). Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Group or unit <GROUP|OBJECT>
 * 1: Suspicion build multiplier <NUMBER> (default: 1)
 * 2: Immune to disguises (vanilla detection) <BOOL> (default: false)
 * 3: Share radius override, -1 = setting <NUMBER> (default: -1)
 * 4: Bulletin chance override (0-1), -1 = setting <NUMBER> (default: -1)
 *
 * Return Value:
 * None
 *
 * Example:
 * [checkpointGroup, 3] call root_ads_fnc_setGroupProfile
 *
 * Public: Yes
 */

params [["_grp", grpNull, [grpNull, objNull]], ["_mult", 1, [0]], ["_immune", false, [false]], ["_shareRadius", -1, [0]], ["_bulletinChance", -1, [0]]];

if (!isServer) exitWith { [QGVAR(api), ["setGroupProfile", _this]] call CBA_fnc_serverEvent; };
if (_grp isEqualType objNull) then { _grp = group _grp; };
if (isNull _grp) exitWith {};

_grp setVariable [QGVAR(groupMult), _mult, true];
_grp setVariable [QGVAR(immune), _immune, true];
_grp setVariable [QGVAR(shareRadius), _shareRadius, true];
_grp setVariable [QGVAR(bulletinChance), _bulletinChance, true];
