#include "..\script_component.hpp"
/*
 * Author: Root
 * Puts a local AI group into its relaxed safe zone stance (CARELESS, hold fire) or restores the
 * behaviour and combat mode it had before.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Relaxed <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_relaxed"];

private _saved = _grp getVariable QGVAR(truceSaved);
if (_relaxed) then {
    if (isNil "_saved") then {
        _grp setVariable [QGVAR(truceSaved), [behaviour (leader _grp), combatMode _grp]];
        if (RADS_DEBUG) then { ["TRUCE", format ["%1 relaxes in a safe zone (was %2 / %3) -> CARELESS, hold fire", groupId _grp, behaviour (leader _grp), combatMode _grp], _grp] call FUNC(debugLog); };
    };
    if (behaviour (leader _grp) != "CARELESS") then { _grp setBehaviour "CARELESS"; };
    if (combatMode _grp != "BLUE") then { _grp setCombatMode "BLUE"; };
} else {
    if (isNil "_saved") exitWith {};
    _saved params ["_behaviour", "_combatMode"];
    _grp setBehaviour _behaviour;
    _grp setCombatMode _combatMode;
    _grp setVariable [QGVAR(truceSaved), nil];
    if (RADS_DEBUG) then { ["TRUCE", format ["%1 leaves its safe zone stance -> %2 / %3", groupId _grp, _behaviour, _combatMode], _grp] call FUNC(debugLog); };
};
