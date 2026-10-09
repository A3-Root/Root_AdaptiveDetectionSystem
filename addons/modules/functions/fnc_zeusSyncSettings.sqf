#include "..\script_component.hpp"
/*
 * Author: Root
 * Zeus: overrides for sharing and syncing suspicion between AI groups.
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

[LLSTRING(syncTitle), [
    "syncEnabled",
    "syncRadius",
    "syncDelay",
    "syncInterval",
    "syncFactor",
    "syncMin",
    "syncNeedsRadio",
    "syncCanIdentify",
    "syncRespectSig",
    "appearanceChangeKeep",
    "shareMode",
    "shareRadius",
    "shareDelay",
    "shareInstantRadius",
    "followEnabled",
    "followThreshold"
]] call FUNC(settingsDialog);
