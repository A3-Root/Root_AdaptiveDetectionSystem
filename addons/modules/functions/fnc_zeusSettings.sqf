#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: mission-wide overrides of the main detection settings.
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

[LLSTRING(settingsTitle), [
    "enabled",
    "buildRate",
    "decayRate",
    "suspiciousThreshold",
    "identifyThreshold",
    "maxRange",
    "identifyRange",
    "instantRange",
    "forgetAfter",
    "heatDuration",
    "firedRadius",
    "allowHostileVeh",
    "sameFactionVehMult",
    "hostileVehMult",
    "armoredDetect",
    "armoredHullMult",
    "gearCompareMode",
    "gearRefSource",
    "metaDetect",
    "reverseMult",
    "rearFacingMult",
    "convoyMode",
    "convoySpillSusp",
    "bulletinEnabled",
    "bulletinChance",
    "bulletinRange",
    "informantsEnabled",
    "theftEnabled",
    "aiAware",
    "aiWatch",
    "aiGlance",
    "aiLook",
    "debugPublish"
]] call FUNC(settingsDialog);
