#include "..\script_component.hpp"
/*
 * Author: Root
 * How far a group may roam from its home position while pursuing / searching. The group profile
 * (setGroupProfile / AI Group Profile module) can override it; -1 there = these settings.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Mounted <BOOL>
 *
 * Return Value:
 * Roam radius in m, 0 = unlimited <NUMBER>
 *
 * Public: No
 */

params ["_grp", "_mounted"];

if (!MSET(leashEnabled)) exitWith {0};
private _own = _grp getVariable [QGVAR(leash), -1];
if (_own >= 0) exitWith {_own};
[MSET(leashFoot), MSET(leashVehicle)] select _mounted
