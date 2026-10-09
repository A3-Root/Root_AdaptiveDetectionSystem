# RADS - Zeus and 3DEN modules

All modules are in the **Root's Adaptive Detection** category. Zeus modules need ZEN and open a dialog. 3DEN modules run on the server. Every label and tooltip comes from the stringtables, and the settings dialogs reuse the exact text of the CBA settings.

3DEN modules marked *trigger* can be synced to a trigger: they fire when the trigger activates, or at mission start if no trigger is synced. For Zone, Unit Cover and Vehicle, a repeatable trigger's deactivation reverts the module.

## Settings modules
Mission-wide runtime overrides of settings. They sit on top of the CBA values until cleared, so nothing needs a restart. Hover any field for what it does (same text as Addon Options).

| Zeus | 3DEN | Covers |
|---|---|---|
| Detection Settings | Detection Settings | Enable, build/decay rate, thresholds, ranges, forget/memory, heat, firing radius, own-side vehicles and faction multipliers, armored hulls, gear judging and reference source, hidden-crew tricks (reversing, rear-on), convoys, sharing, bulletins, informants, theft, AI reactions (alert, glance, look, watch), debug publishing |
| Suspicion Sync Settings | Pursuit, Sync & Truce Settings | Sync on/off, radius, delay, interval, share, minimum, radio, can identify, changing looks; sharing on identification; follow threshold |
| Pursuit & Checkpoint Settings | (same 3DEN module) | Pursuits, stop signal (horn, lights), time to stop, refusal alerts, inspection length/multiplier/clearing, fleeing, LAMBS integration |
| Safe Zone Truce Settings | (same 3DEN module) | Truce on/off, allowed stay, warning, AI relax, who loses it, aiming, cooldown, exit grace, reaction radius, bulletin |

- **Zeus**: each dialog is pre-filled with the current effective values. The last checkbox, *Clear these overrides*, returns those settings to their CBA values.
- **3DEN**: *Keep setting* (or `-1`; `-9999` for the sync radius, which accepts `-1` itself) leaves a value alone. Optional *trigger*.

## Detection Zone
| Field | Meaning |
|---|---|
| Mode | **Multiplier** scales suspicion build/decay (checkpoints, bases, busy towns). **No cover** means disguises do not work inside (restricted area). **Safe haven** means no suspicion builds inside and, with the truce, players inside are not attacked. |
| Build / Decay multiplier | Multiplier mode only. |
| Observer sides | Sides the zone affects. Empty = all. |
| Delay / Duration | Becomes active after the delay; removed after the duration (0 = permanent). |
| Active from / until hour | Daytime window (wraps past midnight), -1 = always. |
| Truce | Safe haven only: use the CBA truce settings, the zone's own options below, or no truce. |
| Truce: allowed stay / warning | Seconds a player may stay (0 = unlimited) and the warning before it runs out. |
| Truce: AI relax | AI inside are CARELESS and hold fire. |
| Truce: who loses it | Only the offender, the offender's group, or everyone in the zone. |
| Truce: aiming breaks it | Pointing a weapon at an AI soldier for a few seconds breaks it. |

**Truce (roleplay safe zones):** players under a truce (on foot or in a vehicle, even already identified) are ignored by the zone's AI sides. The AI standing in the zone relax. The truce breaks on shooting, hurting or ramming AI, overstaying, or aiming (optional). Then the zone's AI, and groups near or seeing the offender, go COMBAT and identify the offender. Players who lost the truce cannot regain it for the cooldown. Leaving the zone keeps the truce for the exit grace, so nobody opens fire at the border.

- **Zeus** *Add Detection Zone*: centred on the module, ellipse or rectangle, with radius preview. *Remove Detection Zones*: one zone, zones near the module, or all.
- **3DEN** *Detection Zone*: uses the module area (resizable, ellipse/rectangle). *trigger*.

Zone markers are drawn when the *Show zone markers* setting is on.

## Unit Cover Profile
| Field | Meaning |
|---|---|
| Mode | **Normal**. **Exempt**: never covered. **Always covered**: covered in any vehicle, ignoring side, heat and restricted zones. |
| Suspicion multiplier | How fast AI grow suspicious of these units (e.g. 0.5 for a trained operative, 2 for an obvious foreigner). |
| Duration | Revert to normal after this long (0 = permanent). |

- **Zeus**: place on a unit (or a vehicle for its crew), or pick sides/groups/players.
- **3DEN**: synced units, or *All players* (late joiners included). *trigger*.

## Vehicle Disguise
| Field | Meaning |
|---|---|
| Mode | **Auto**: by side and settings. **Always disguise**: any side is fooled. **Never disguise**. **Burned**: recognised on sight by everyone. |
| Burned for sides | Those sides recognise the vehicle on sight. |
| Suspicion multiplier | How suspicious this vehicle looks, replacing the faction multipliers. -1 = by faction/side. |
| Armored | Auto / not armored / armored. Armored means only the vehicle can be judged, not the crew (slow build). |
| Duration | Revert after this long. |

- **Zeus**: place on the vehicle. Includes *Clear burned status*.
- **3DEN**: synced vehicles. *trigger*.

## AI Group Profile
| Field | Meaning |
|---|---|
| Suspicion multiplier | 2-3 for checkpoint guards, 0.5 for sleepy sentries. |
| Immune to disguises | The group always uses vanilla detection (counter-intelligence, dogs, etc.). |
| Share radius | Override the share radius. -1 = setting. |
| Bulletin chance | Override the bulletin chance. -1 = setting. |
| Role | **Patrol**: may chase and stop suspects. **Outpost**: stays put, still alerts and syncs. **Static**: never leaves its position. |
| Follow threshold | Suspicion at which this group starts pursuing. -1 = setting. |

- **Zeus**: place on any unit of the group. **3DEN**: synced units' groups.

## Enemy Gear Reference
What a side's AI expect to see. With *How gear is judged* set to matching, each visible item a player wears is compared with it. The very same item makes them less suspicious, another camo of the same item is neutral, and an item they never wear makes them more suspicious. Weapons, launchers and backpacks only count from exposed seats.

- **Zeus**: pick the side, then start from the current list, **collect from that side's AI now**, or clear it. The next dialog shows seven comma-separated lists (uniforms, vests, headgear, rifles, launchers, backpacks, facewear) to edit and apply. *Copy to clipboard* copies a ready `root_ads_fnc_setGearReference` line (also written to the RPT; clipboard access may be blocked in multiplayer).
- **3DEN**: side, the seven lists, and *Collect from that side's AI* (10 s after start, merged with the lists).
- Without any list, the *Gear reference source* setting falls back to the watching group's own kit, then to the whole side.

## Order Pursuit / Call Off (Zeus)
Place on an AI unit. Pick an undercover target and the group pursues it now. On foot it runs at the target. Mounted, it follows, flashes and honks to make the target stop, then inspects. Pick *Call off* to end its current pursuit; the group returns to its own waypoints.

## Compromise / Restore Cover
| Field | Meaning |
|---|---|
| Action | **Compromise**: hostile groups identify the units. **Restore**: every hostile group forgets them and heat is cleared. **Restore + clear**: also clears burned/wanted status. |
| Observer sides / Radius | Compromise only: which groups identify. |

- **Zeus**: place on a unit/vehicle, or pick sides/groups/players.
- **3DEN**: synced units or all players. Designed for triggers (alarm raised, intel leaked, etc.).

## Enable / Disable RADS
Disable, enable, or return to the CBA setting, with a delay and an optional duration. Zeus and 3DEN (*trigger*).

## Radio Bulletin
Manual long-range bulletin about a unit or vehicle.

| Field | Meaning |
|---|---|
| Receiving sides | Who hears it. |
| Burn vehicle | Vehicle recognised on sight. |
| Mark wanted | Units build suspicion faster in any vehicle. |
| Alert the area (Zeus) | Groups near the module position start searching. |
| Duration / Range | 0/-1 = settings. Range is measured from the module, 0 = side-wide. |
| Clear | Remove burned/wanted instead. |

- **Zeus**: place on the unit/vehicle. **3DEN**: synced units/vehicles. *trigger*.

## Inspect Detection Status (Zeus)
Place on a unit to see cover, heat, wanted/burned status, truce time left, pursuing groups, and every nearby group's suspicion and state. Place on empty ground for a summary of all covered players. Values refresh on state changes. Turn on *Publish suspicion live* for live numbers.
