#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: overrides for the default safe zone truce (zones without their own truce options).
 *
 * Arguments:
 * 0: Module logic <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic"];

if (!hasInterface) exitWith {};
deleteVehicle _logic;

[LLSTRING(truceTitle), [
    "truceEnabled",
    "truceMaxStay",
    "truceWarn",
    "truceCareless",
    "truceBreakScope",
    "truceBreakOnAim",
    "truceAimTime",
    "truceCooldown",
    "truceExitGrace",
    "truceBreakRadius",
    "truceBulletin"
]] call FUNC(settingsDialog);
