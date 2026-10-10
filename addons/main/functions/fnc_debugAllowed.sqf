#include "..\script_component.hpp"
/*
 * Author: Root
 * Whether this machine may use the debug options (log, overlay, live publishing). The server
 * and headless clients always may; players only as far as the server setting "Who may use
 * debug" allows, so nobody can turn on an overlay or log of AI suspicion for themselves.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Allowed <BOOL>
 *
 * Public: No
 */

if (isServer || {!hasInterface}) exitWith {true};

switch (MSET(debugClients)) do {
    case 2: { true };
    case 1: { (call BIS_fnc_admin) == 2 || {!isNull getAssignedCuratorLogic player} };
    default { (call BIS_fnc_admin) == 2 };
}
