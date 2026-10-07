#include "..\script_component.hpp"
/*
 * Author: Root
 * True for vehicles that leave the occupants in plain view (quads, bikes, open boats...).
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * Open <BOOL>
 *
 * Public: No
 */

params [["_veh", objNull, [objNull]]];

private _classes = [MSET(openVehicleClasses)] call FUNC(parseList);
_classes findIf {_veh isKindOf _x} > -1
