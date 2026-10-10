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
    "armoredDrivingOnly",
    "vehOpticsEnabled",
    "vehOpticsMult",
    "vehDriverOpticsMult",
    "gearCompareMode",
    "gearRefSource",
    "metaDetect",
    "metaMaxSpeed",
    "hiddenCrewAny",
    "reverseMult",
    "rearFacingMult",
    "convoyMode",
    "convoySpillSusp",
    "bulletinEnabled",
    "bulletinChance",
    "bulletinRange",
    "informantsEnabled",
    "theftEnabled",
    "ramRepeatCount",
    "ramRepeatWindow",
    "ramCompromise",
    "ramBurn",
    "hornSuspicion",
    "hornEscalate",
    "hornWindow",
    "hornMaxSusp",
    "hornSearchCount",
    "nearAwareRange",
    "hornRange",
    "aiAware",
    "aiWatch",
    "aiGlance",
    "aiLook",
    "debugPublish",
    "debugClients"
]] call FUNC(settingsDialog);
