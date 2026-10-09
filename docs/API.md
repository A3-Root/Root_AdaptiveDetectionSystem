# RADS - Scripting API

Every function can be called from any machine. State-changing calls forward themselves to the server, and knowledge changes are sent to whichever machine owns each AI group.

## Functions

| Function | Arguments | Notes |
|---|---|---|
| `root_ads_fnc_setEnabled` | `[enabled, revertAfter = 0, delay = 0]` | `nil` returns to the CBA setting. |
| `root_ads_fnc_setOverride` | `[name, value]` or `[[[name, value], ...]]` | Runtime override of any setting (name without prefix, e.g. `"buildRate"`). `nil` clears it. |
| `root_ads_fnc_clearOverrides` | `[]` | |
| `root_ads_fnc_addZone` | `[[centre, a, b, angle, isRect], mode = 0, build = 1, decay = 1, sides = [], delay = 0, duration = 0, hourFrom = -1, hourTo = -1, label = "", id = "", truce = []]` | Mode 0 multiplier, 1 no cover, 2 safe haven. `truce` as in `setZoneTruce` ([] = CBA defaults). Returns the id on the server. |
| `root_ads_fnc_setZoneTruce` | `[id, [enabled, maxStay, warnBefore, careless, breakScope, breakOnAim]]` | Truce of a safe haven. Scope 0 offender, 1 offender's group, 2 everyone in the zone. `[]` = CBA defaults. |
| `root_ads_fnc_removeZone` | `[id]` | `""` or `"all"` removes every zone. |
| `root_ads_fnc_setVehicleMode` | `[vehicle, "auto"/"disguise"/"never"/"burned", revertAfter = 0, lookMultiplier = -1, armored = -1, optics = -1]` | Multiplier -1 = by faction/side. Armored -1 auto, 0 no, 1 yes. Optics = range multiplier for AI in its gunner/commander seats, -1 = setting. |
| `root_ads_fnc_burnVehicle` | `[vehicle, side, duration = -1, range = 0, reportPos = []]` | That side recognises the vehicle on sight. |
| `root_ads_fnc_markWanted` | `[unit, side, duration = -1, range = 0, reportPos = []]` | Faster suspicion for that side. |
| `root_ads_fnc_clearBulletins` | `[unitOrVehicle, sides = [], alsoVehicle = true]` | |
| `root_ads_fnc_setUnitMode` | `[unit, "normal"/"exempt"/"force", multiplier = 1, revertAfter = 0]` | |
| `root_ads_fnc_setGroupProfile` | `[groupOrUnit, multiplier = 1, immune = false, shareRadius = -1, bulletinChance = -1, role = "patrol", followThreshold = -1, roamLimit = -1]` | Role `"patrol"` (may pursue), `"outpost"` (stays, alerts and syncs), `"static"`. Roam limit in m, 0 = unlimited, -1 = settings. |
| `root_ads_fnc_setGearReference` | `[side, [uniforms, vests, headgear, rifles, launchers, backpacks, facewear]]` | Each list an array or a comma-separated string. `[]` clears. |
| `root_ads_fnc_getGearReference` | `[side]` → seven comma-separated strings | |
| `root_ads_fnc_collectSideGear` | `[side, apply = false]` → seven comma-separated strings | Everything that side's AI wear now; `apply` sets it as the reference. |
| `root_ads_fnc_startPursuit` | `[groupOrUnit, target]` | Chase (foot) or follow, stop and inspect (mounted). Sent to the group's owner. |
| `root_ads_fnc_stopPursuit` | `[groupOrUnit]` | The group returns to its own waypoints. |
| `root_ads_fnc_getPursuit` | `[groupOrUnit]` → `[target, phase]` | Phase `"CHASE"` / `"FOLLOW"` / `"INSPECT"`, known where the group is local. |
| `root_ads_fnc_getConvoy` | `[vehicle]` → vehicles | The convoy of covered vehicles it travels in (itself when alone). |
| `root_ads_fnc_forceCompromise` | `[unit, sides = [], radius = -1, centre = []]` | |
| `root_ads_fnc_restoreCover` | `[unit, clearBulletins = true]` | Every hostile group forgets the unit. |
| `root_ads_fnc_getSuspicion` | `[group, unit]` → `[0-100, stateName]` | Exact where the group is local, otherwise the last published value. |
| `root_ads_fnc_getStatus` | `[unit]` → `[hasCover, heatLeft, wantedSides, maxSuspicion, identifiedBy]` | |

## CBA events (`root_ads_main_*`)

| Event | Scope | Arguments |
|---|---|---|
| `root_ads_main_coverChanged` | global | `[unit, vehicle, hasCover]` |
| `root_ads_main_compromised` | global | `[group, unit, reason, side]` |
| `root_ads_main_bulletin` | global | `[side, position, range, unit, vehicle, reason, senderGroup]` |
| `root_ads_main_hostileAct` | global | `[unit, position, radius, type]` |
| `root_ads_main_watched` | target (player) | `[group]` |
| `root_ads_main_truceBroken` | global | `[offender, zoneId, reason, scope]` |
| `root_ads_main_syncSusp` | global | `[side, senderPositions, radius, [[unit, suspicion, appearanceSig], ...], senderGroup, allClear]` |
| `root_ads_main_pursuitAlert` | global | `[side, position, radius, unit, reason, senderGroup]` ("refused to stop", "got away from a pursuit", "outran a foot patrol") |
| `root_ads_main_inspected` | target (player) | `[group, active]` |

Identification reasons: `witnessed`, `engaged`, `identified`, `sameVehicle`, `burnedVehicle`, `fired`, `attacked`, `vehicleAttacked`, `theft`, `shared`, `forced`, `fled a checkpoint stop`, `truce broken: ...`, `convoy of ...`, `synced suspicion from ...`.

## Object variables (public)
| Variable | On | Meaning |
|---|---|---|
| `root_ads_main_cover` | unit | Currently covered. |
| `root_ads_main_heatUntil` | unit | `CBA_missionTime` until which cover is denied. |
| `root_ads_main_wantedBy` | unit | `[[side, until, pos, range], ...]` |
| `root_ads_main_burnedBy` | vehicle | `[[side, until, pos, range], ...]` |
| `root_ads_main_vehMode` | vehicle | `"auto"` / `"disguise"` / `"never"` / `"burned"` |
| `root_ads_main_vehMult` / `root_ads_main_armored` | vehicle | Look multiplier (-1 = faction) / armored (-1 auto, 0, 1) |
| `root_ads_main_truce` | unit | `[zoneId, since, sides, maxStay]` while a safe zone truce protects the player, `[]` otherwise |
| `root_ads_main_role` / `root_ads_main_followThreshold` | group | Pursuit role and follow threshold override |
| `root_ads_main_pursuitTarget` | group | Unit the group is pursuing (objNull when none) |
| `root_ads_main_gearRef` | mission | `[[side, [7 class lists]], ...]` enemy gear reference |
| `root_ads_main_pub` | group | Mirror of the group's knowledge `[[unit, suspicion, state, fooled, vehicle], ...]` |

## Extending cover rules
Push a condition into `root_ads_main_coverConditions` during preInit: `{params ["_unit"]; <bool>}`. Every condition must return true for the unit to have cover. The ACE compat addon uses this for handcuffed/surrendering units.

## Examples
```sqf
// Checkpoint guards are vigilant, and the base is restricted
[group guard1, 3] call root_ads_fnc_setGroupProfile;
[[getMarkerPos "base", 300, 300, 0, false], 1] call root_ads_fnc_addZone;

// The alarm goes off: everyone east of here knows the team
{ [_x, [east]] call root_ads_fnc_forceCompromise } forEach units alpha;

// Intel says the truck is known for 10 minutes
[truck1, east, 600] call root_ads_fnc_burnVehicle;

// React to identifications
["root_ads_main_compromised", {
    params ["_group", "_unit", "_reason"];
    if (_unit == player) then { systemChat format ["%1 made you (%2)", groupId _group, _reason] };
}] call CBA_fnc_addEventHandler;
```
