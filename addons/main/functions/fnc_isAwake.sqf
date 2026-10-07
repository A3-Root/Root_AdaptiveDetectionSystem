#include "..\script_component.hpp"
/*
 * Author: Root
 * True when the unit is alive and conscious (vanilla incapacitation and ACE unconsciousness).
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Awake <BOOL>
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

alive _unit && {lifeState _unit != "INCAPACITATED"} && {!(_unit getVariable ["ACE_isUnconscious", false])}
