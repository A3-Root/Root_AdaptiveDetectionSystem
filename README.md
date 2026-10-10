# Root's Adaptive Detection System (RADS)

![version](https://img.shields.io/badge/version-2.0.0.0-blue)
[![build](https://github.com/A3-Root/Root_AdaptiveDetectionSystem/actions/workflows/auto-release.yml/badge.svg?branch=master)](https://github.com/A3-Root/Root_AdaptiveDetectionSystem/actions/workflows/auto-release.yml)

RADS is an Arma 3 mod for undercover vehicle gameplay. Players inside civilian or enemy vehicles are no longer engaged the instant an enemy AI can see the vehicle. Instead, every AI group tracks its own suspicion of every covered player and only identifies them once that suspicion is earned through what the group can actually observe.

The system runs on the engine's own knowledge commands (`targetKnowledge`, `knowsAbout`, `ignoreTarget`, `reveal`, `forgetTarget`, optionally `setTargetAge`), so identified players are handled by vanilla AI combat behaviour.

## Features

### Detection
- **Per-group, per-player suspicion** that builds while a group can see a covered player and decays when it cannot.
- **Entry snapshot**: groups that witnessed a player entering the vehicle, or were already engaging them, keep their knowledge. Groups that knew the player earlier start searching. All others are fooled.
- **Exposure model**: line of sight through the vehicle's view geometry, field of view (with close-range awareness), distance falloff, light, NVGs, fog and rain, observer behaviour and skill, and vehicle optics for AI crews.
- **Seat and vehicle**: driver, cargo, turret, FFV and turned-out seats; open vehicles; vehicle faction tiers (same faction, same side, civilian, allied, enemy) and per-class multipliers.
- **Armored vehicles**: closed hulls expose only the vehicle. Driven calmly they build no suspicion; speeding, off-road driving, missing lights at night, honking, aiming the main gun, visible damage and loitering still count.
- **Gear matching**: each visible slot is compared against a reference of the observing side's own equipment, collected from the mission's AI or set manually.
- **Driving behaviour**: fast passes, speeding, off-road approaches, reversing up to observers or parking rear-on to hide the crew, loitering and repeated passes.
- **Hostile acts**: firing, hurting AI and aiming at them remove cover. A first ram raises suspicion; repeated ramming identifies the vehicle.
- **Horn**: heard without line of sight and escalating with every honk in a series, capped below identification.
- **Visible damage, burned vehicles, wanted units and reported number plates.**

### Information flow
- **Knowledge sharing** between nearby groups when a player is identified.
- **Suspicion sync**: groups pass rising suspicion to friendly groups in range after a delay, as long as the player keeps the same vehicle and kit. A group's own starting suspicion is not shared.
- **Radio bulletins**: a radioman may broadcast the vehicle, its number plate and the occupants. Killing him before the delay ends stops the broadcast.
- **Convoys**: several covered vehicles travelling together build suspicion faster, and identifying one affects the rest.
- **Civilian informants** and **stolen-vehicle detection**.
- **Forgetting and vehicle swaps**: groups forget players after a period without contact; unseen swaps to another vehicle are tolerated with an escalating penalty.

### Pursuit, stops and inspections
- **Foot patrols** chase a suspicious vehicle; **mounted patrols** start their engine, follow, and signal the vehicle to stop with horn and lights while suspicion is held.
- **Refusing to stop** triggers an area alert, which is called off again if the vehicle stops for the inspection after all.
- **Inspections**: passengers dismount first, then spare crew, the commander and the driver; gunners stay in place. Waiting during an inspection builds no suspicion for any group; giving something away does.
- **Clearance**: a clean inspection ends with a wave-on gesture, lowers suspicion, pauses it briefly for that vehicle, sends an all-clear to neighbouring groups and blocks new pursuits for a cooldown.
- **Fleeing** an inspection identifies the occupants and triggers a bulletin. Dismounted crew return to their seats before the group engages.
- Roam limits, pursuit cooldowns and one inspection per vehicle at a time.
- **LAMBS Danger** support: its danger FSM is paused during pursuits, and identified targets are handed to its hunt and rush tasks.

### Mission tools
- **Detection zones**: multiplier areas (checkpoints, bases), restricted areas without cover and safe havens, with side filters, delay, duration and time-of-day windows.
- **Safe zone truces** for roleplay: AI hold fire on players inside, on foot included, until someone shoots, rams, aims or overstays.
- **Profiles**: per-unit cover modes and multipliers, per-vehicle disguise modes, per-group vigilance, roles and roam limits, and per-AI starting suspicion.
- **Optional AI reactions**: going AWARE, glancing and looking at suspects, watching them.

## Requirements
- Arma 3 **2.18** or newer
- [CBA_A3](https://steamcommunity.com/workshop/filedetails/?id=450814997)
- [Zeus Enhanced (ZEN)](https://steamcommunity.com/workshop/filedetails/?id=1779063631)
- [ACE3](https://steamcommunity.com/workshop/filedetails/?id=463939057) (optional): handcuffed and surrendering units lose cover, unconscious AI do not observe.
- [LAMBS Danger](https://steamcommunity.com/sharedfiles/filedetails/?id=1858075458) (optional): pursuit and hunt integration.

Load RADS on the server and on every client. It supports singleplayer, player-hosted multiplayer, dedicated servers and headless clients.

## How it works

### Detection states
```
           enters a qualifying vehicle
                     │
          ┌──────────┴───────────────────────────────────────┐
  saw entry / fighting it           knew it earlier           knew nothing
          │                                │                        │
     COMPROMISED  ◄──── identify ────  SEARCHING  ◄── leads ── UNAWARE ⇄ SUSPICIOUS
  (vanilla engage)     (threshold)       (seeded)    (share,      (ignoreTarget, suspicion
          │                                          bulletin)     builds and decays)
          └── no contact for "Forget after" ── forgetTarget ──► UNAWARE
```

### Evaluation
Every evaluation (default 1 s, spread over frames), each AI group local to the machine (server, headless client or client) checks every covered unit:

1. **Cover**: whether this vehicle can disguise its occupants from this side, taking vehicle side and faction, per-vehicle modes, whitelists, blacklists, burned status and zones into account.
2. **Exposure**: the best observer in the group, using `checkVisibility` through the vehicle geometry, multiplied by every applicable factor (field of view, distance, light, weather, behaviour, skill, seat, faction, gear, driving, loitering, passes, convoy, aiming, damage, wanted status, inspection state, zones and profiles).
3. **Suspicion**: builds with exposure and decays without it. At *Suspicious* the AI react and the player can be warned. At the *Follow threshold* the group pursues. At *Identify* the group stops ignoring the unit, reveals it, and optionally shares it, extends it to a convoy and rolls for a radio bulletin.

### Pursuit and inspection
```
 follow threshold ──► FOLLOW (mounted) ── engine on, follow, horn + lights, suspicion held
        │                 │  refuses / pulls away / hostile act ──► area alert, suspicion builds again
        │                 └─ stops in time ──────────────────────► INSPECT
        └─► CHASE (foot) ── target stops nearby ─────────────────► INSPECT
 INSPECT ── inspectors dismount by priority, gunners stay; idle waiting builds nothing
        ├─ drives off ───────────► identified + bulletin; crew remount, then engage
        └─ inspection time ends ─► CLEARED: suspicion lowered, short grace for that vehicle,
                                   all-clear to neighbours, pursuit cooldown
```

A scenario-by-scenario breakdown is in [docs/MATRIX_COVERAGE.md](docs/MATRIX_COVERAGE.md).

## Configuration

### CBA settings
**Addon Options > RADS - Adaptive Detection** contains 291 settings in 22 categories. All settings apply live during the mission and every tooltip describes the effect of higher and lower values. They are server-wide and can only be changed by admins.

The debug options are the only per-client settings. The server setting *Who may use debug* decides whether admins, admins and Zeus, or everyone may enable them.

Full list with defaults and ranges: [docs/SETTINGS.md](docs/SETTINGS.md).

### Zeus and Eden modules
Category **Root's Adaptive Detection** in Zeus (ZEN) and in the Eden module list (Systems > Modules).

| Zeus | Eden | Purpose |
|---|---|---|
| Detection Settings | Detection Settings | Mission-wide live overrides of the main settings |
| Suspicion Sync / Pursuit & Checkpoint / Safe Zone Truce Settings | Pursuit, Sync & Truce Settings | Overrides for sync, pursuits, inspections and truces |
| Add / Remove Detection Zone | Detection Zone (area) | Multiplier, restricted or safe-haven areas with side filter, delay, duration and time window |
| Unit Cover Profile | Unit Cover Profile | Exempt, always covered or a suspicion multiplier for units, groups, sides or all players |
| Vehicle Disguise | Vehicle Disguise | Auto, always, never or burned, plus look multiplier, armor and optics per vehicle |
| AI Group Profile | AI Group Profile | Vigilance, disguise immunity, share radius, bulletin chance, role, follow threshold and roam limit |
| AI Starting Suspicion | AI Starting Suspicion | Suspicion these AI start at and never fall below |
| Enemy Gear Reference | Enemy Gear Reference | Equipment a side's AI wear: collect, edit and copy |
| Order Pursuit / Call Off | - | Send a group after a covered unit, or call it off |
| Compromise / Restore Cover | Compromise / Restore Cover | Blow or restore cover on demand |
| Enable / Disable RADS | Enable / Disable RADS | Toggle the system, with optional delay and duration |
| Radio Bulletin | Radio Bulletin | Burn a vehicle or mark units wanted for chosen sides, or clear them |
| Inspect Detection Status | - | Live suspicion of every nearby group for a unit |

Field reference: [docs/MODULES.md](docs/MODULES.md).

### Scripting API
24 public functions (`root_ads_fnc_*`) and CBA events (`root_ads_main_*`). Calls that change state are forwarded to the server or to the machine that owns the group.

```sqf
// Jumpy checkpoint guards: start at 40% suspicion
[_guard, 40, true] call root_ads_fnc_setStartSuspicion;

// Never treat this vehicle as a disguise
[_truck, "never"] call root_ads_fnc_setVehicleMode;

// React to identifications
["root_ads_main_compromised", {
    params ["_group", "_unit", "_reason", "_side"];
}] call CBA_fnc_addEventHandler;
```

Reference: [docs/API.md](docs/API.md).

## Debugging
Enable **Debug log** under Addon Options > RADS > Debug. Lines are prefixed with `[RADS]` and written to the RPT of the machine that owns the AI (server or headless client). Ram detection, horn input and cover changes are written by the player's machine.

- **Reports** for every identification, state change and forget: reason, group (owner, position, behaviour, vigilance), target (vehicle, plate, position, speed, seat, damage, crew) and the last evaluations of that group against that unit.
- **Evaluation lines**: suspicion before and after, exposure, best observer with every observer factor, vehicle state, and every multiplier that applied. Instant triggers are marked `INSTANT`, `ENTRY` or `RAMMED`.
- **Event tags**: `CLASSIFY`, `FOOLED`, `REVEAL`, `COVER`, `HIT`, `FIRED`, `RAM-DETECT`, `RAM`, `HORN`, `SHARE`, `SYNC`, `ALERT`, `SWAP`, `ATTACKED`, `PURSUIT`, `INSPECT`, `TRUCE`.
- **Detail levels**: events only, events plus large jumps, or every evaluation.

The *Debug overlay* (client) together with *Publish suspicion live* (server) shows each group's suspicion in the world above its member closest to the player.

## Documentation
- [docs/SETTINGS.md](docs/SETTINGS.md): CBA settings
- [docs/MODULES.md](docs/MODULES.md): Zeus and Eden modules
- [docs/API.md](docs/API.md): functions, events and public variables
- [docs/MATRIX_COVERAGE.md](docs/MATRIX_COVERAGE.md): scenario coverage
- [releases/CHANGELOG.md](releases/CHANGELOG.md): release notes

## Building
Settings, stringtables and module configs are generated. Edit `tools/gen_settings.py` and `tools/gen_modules.py`, then regenerate:
```
python tools/gen_settings.py
python tools/gen_modules.py
hemtt check -p -Lc14 -e
hemtt build
hemtt release
```

## Credits
Author: Root (xMidnightSnowx)

## License
Arma Public License Share Alike (APL-SA). See [LICENSE](LICENSE).
