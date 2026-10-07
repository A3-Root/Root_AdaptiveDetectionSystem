# RADS - Scripting API

Every function can be called from any machine. State-changing calls forward themselves to the server, and knowledge changes are sent to whichever machine owns each AI group.

## Functions

| Function | Arguments | Notes |
|---|---|---|
| `root_ads_fnc_setEnabled` | `[enabled, revertAfter = 0, delay = 0]` | `nil` returns to the CBA setting. |
| `root_ads_fnc_setOverride` | `[name, value]` or `[[[name, value], ...]]` | Runtime override of any setting (name without prefix, e.g. `"buildRate"`). `nil` clears it. |
| `root_ads_fnc_clearOverrides` | `[]` | |
| `root_ads_fnc_addZone` | `[[centre, a, b, angle, isRect], mode = 0, build = 1, decay = 1, sides = [], delay = 0, duration = 0, hourFrom = -1, hourTo = -1, label = "", id = ""]` | Mode 0 multiplier, 1 no cover, 2 safe haven. Returns the id on the server. |
| `root_ads_fnc_removeZone` | `[id]` | `""` or `"all"` removes every zone. |
| `root_ads_fnc_setVehicleMode` | `[vehicle, "auto"/"disguise"/"never"/"burned", revertAfter = 0]` | |
| `root_ads_fnc_burnVehicle` | `[vehicle, side, duration = -1, range = 0, reportPos = []]` | That side recognises the vehicle on sight. |
| `root_ads_fnc_markWanted` | `[unit, side, duration = -1, range = 0, reportPos = []]` | Faster suspicion for that side. |
| `root_ads_fnc_clearBulletins` | `[unitOrVehicle, sides = [], alsoVehicle = true]` | |
| `root_ads_fnc_setUnitMode` | `[unit, "normal"/"exempt"/"force", multiplier = 1, revertAfter = 0]` | |
| `root_ads_fnc_setGroupProfile` | `[groupOrUnit, multiplier = 1, immune = false, shareRadius = -1, bulletinChance = -1]` | |
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

Identification reasons: `witnessed`, `engaged`, `identified`, `sameVehicle`, `burnedVehicle`, `fired`, `attacked`, `vehicleAttacked`, `theft`, `shared`, `forced`.

## Object variables (public)
| Variable | On | Meaning |
|---|---|---|
| `root_ads_main_cover` | unit | Currently covered. |
| `root_ads_main_heatUntil` | unit | `CBA_missionTime` until which cover is denied. |
| `root_ads_main_wantedBy` | unit | `[[side, until, pos, range], ...]` |
| `root_ads_main_burnedBy` | vehicle | `[[side, until, pos, range], ...]` |
| `root_ads_main_vehMode` | vehicle | `"auto"` / `"disguise"` / `"never"` / `"burned"` |
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
