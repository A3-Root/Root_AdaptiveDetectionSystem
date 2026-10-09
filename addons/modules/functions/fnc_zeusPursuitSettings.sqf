#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: overrides for pursuits, checkpoint stops, inspections and fleeing.
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

[LLSTRING(pursuitTitle), [
    "pursuitEnabled",
    "followEnabled",
    "followThreshold",
    "pursuitMaxGroups",
    "pursuitMaxStart",
    "pursuitMaxTime",
    "pursuitMaxDist",
    "pursuitLead",
    "leashEnabled",
    "leashFoot",
    "leashVehicle",
    "leashGiveUp",
    "footGiveUpDist",
    "followDistance",
    "stopSignalHorn",
    "stopSignalLights",
    "stopTimeout",
    "refuseSuspBonus",
    "alertOnEscape",
    "alertRadius",
    "alertSuspicion",
    "inspectRange",
    "inspectTime",
    "inspectMult",
    "inspectClearSusp",
    "inspectCooldown",
    "fleeDistance",
    "fleeSpeed",
    "fleeBulletin",
    "fleeBurn",
    "lambsDisableDuringPursuit",
    "lambsHuntOnCompromise"
]] call FUNC(settingsDialog);
