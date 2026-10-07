# RADS - Zeus and 3DEN modules

All modules are in the **Root's Adaptive Detection** category. Zeus modules need ZEN and open a dialog. 3DEN modules run on the server.

3DEN modules marked *trigger* can be synced to a trigger: they fire when the trigger activates, or at mission start if no trigger is synced. For Zone, Unit Cover and Vehicle, a repeatable trigger's deactivation reverts the module.

## Detection Settings
Mission-wide runtime overrides of the most-used settings. Overrides sit on top of the CBA values until cleared, so no rebuild or restart is needed.

- **Zeus**: dialog pre-filled with the current effective values. Enable, build/decay rate, suspicious/identify thresholds, max/close/face-to-face range, forget after, heat, firing radius, share mode/radius, bulletins on/off/chance/range, informants, theft, AI reactions, debug publishing. *Clear all overrides* returns everything to CBA values.
- **3DEN**: the same set as attributes. `-1` or *Keep setting* leaves a value alone. Optional *trigger*.

## Detection Zone
| Field | Meaning |
|---|---|
| Mode | **Multiplier** scales suspicion build/decay (checkpoints, bases, busy towns). **No cover** means disguises do not work inside (restricted area). **Safe haven** means no suspicion builds inside. |
| Build / Decay multiplier | Multiplier mode only. |
| Observer sides | Sides the zone affects. Empty = all. |
| Delay / Duration | Becomes active after the delay; removed after the duration (0 = permanent). |
| Active from / until hour | Daytime window (wraps past midnight), -1 = always. |

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

- **Zeus**: place on any unit of the group. **3DEN**: synced units' groups.

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
Place on a unit to see cover, heat, wanted/burned status and every nearby group's suspicion and state. Place on empty ground for a summary of all covered players. Values refresh on state changes. Turn on *Publish suspicion for debug* for live numbers.
