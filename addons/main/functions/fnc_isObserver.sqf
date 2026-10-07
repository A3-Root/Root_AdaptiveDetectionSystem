#include "..\script_component.hpp"
/*
 * Author: Root
 * True when the unit can act as an AI observer: AI controlled, awake, not remote-controlled by Zeus.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Observer <BOOL>
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

!isPlayer _unit
    && {[_unit] call FUNC(isAwake)}
    && {isNull (_unit getVariable ["bis_fnc_moduleRemoteControl_owner", objNull])}
    && {!(_unit getVariable [QGVAR(blind), false])}
