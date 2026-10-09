#include "..\script_component.hpp"
/*
 * Author: Root
 * Vehicles travelling in the same convoy as this one (itself included).
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * Convoy vehicles, [vehicle] when it travels alone <ARRAY>
 *
 * Public: No
 */

params ["_veh"];

(missionNamespace getVariable [QGVAR(convoys), createHashMap]) getOrDefault [hashValue _veh, [_veh]]
