# Root_AdaptiveDetectionSystem

![version](https://img.shields.io/badge/version-1.0.0.0-blue)
[![build](https://github.com/A3-Root/Root_AdaptiveDetectionSystem/actions/workflows/auto-release.yml/badge.svg?branch=master)](https://github.com/A3-Root/Root_AdaptiveDetectionSystem/actions/workflows/auto-release.yml)

Root's Adaptive Detection System (RADS) is an Arma 3 mod that makes enemy AI detect and recognise players hidden in civilian or enemy vehicles gradually, instead of instantly. The result is a more dynamic and forgiving stealth experience.

In vanilla Arma, a BLUFOR player who gets into a civilian car or a captured OPFOR truck is engaged by every AI that can see the vehicle. RADS replaces that with **per-group, per-player suspicion**:

- If nobody saw you get in, you are a nobody in a car.
- If they watched you get in, or were already shooting at you, the car changes nothing.
- Loitering beside them, driving past again and again, parking at their checkpoint, wearing your own uniform, or turning out with a rifle all build suspicion until they identify you.
- Shooting from the car blows your cover on the spot.
- Break contact long enough and they forget you (`forgetTarget`), and the disguise works again.
- A radioman may broadcast your vehicle over long range. Every enemy who later sees that car engages it on sight. Kill the radioman before he finishes and the call never goes out.

It is driven by the engine's own knowledge commands: `targetKnowledge`, `knowsAbout`, `ignoreTarget`, `reveal`, `forgetTarget`, and optionally `setTargetAge`.

## Requirements
- Arma 3 **2.18+** (`ignoreTarget`)
- [CBA_A3](https://steamcommunity.com/workshop/filedetails/?id=450814997)
- [Zeus Enhanced (ZEN)](https://steamcommunity.com/workshop/filedetails/?id=1779063631)
- [ACE3](https://steamcommunity.com/workshop/filedetails/?id=463939057): optional. Adds a self-interaction status check, makes handcuffed/surrendering units lose cover, and stops unconscious AI from observing.

Works in SP, local-hosted MP, dedicated servers and dedicated servers with headless clients.

## How it works
```
           enters qualifying vehicle
                     │
          ┌──────────┴───────────────────────────────────────┐
  saw entry / fighting you          knew you earlier          knew nothing
          │                                │                        │
     COMPROMISED  ◄──── identify ────  SEARCHING  ◄── leads ── UNAWARE ⇄ SUSPICIOUS
  (vanilla engage)     (suspicion 100)   (seeded)    (share,      (fooled: ignoreTarget,
          │                                          bulletin)     suspicion builds/decays)
          └── no contact for "Forget after" ── forgetTarget ──► UNAWARE (fooled again)
```

Every evaluation (default 1 s, spread over frames), each AI group that is **local to this machine** (server, headless client or client) checks every covered unit:

1. **Can this vehicle fool this side?** Civilian vehicles, and vehicles of a side friendly to the observer, can. Per-vehicle modes, whitelists, blacklists, burned status and zones apply on top.
2. **Exposure**: the best observer's `checkVisibility` through the vehicle's view geometry (glass lets partial sight through), multiplied by field of view, distance falloff, light, NVG, fog and rain, observer behaviour and skill, seat (driver, cargo, turret, turned out, FFV), vehicle type, gear, driving behaviour, loitering, repeated passes, aiming, vehicle damage, wanted status, zone and group/unit profiles.
3. **Suspicion** builds with exposure and decays without it. At *Suspicious* the player can be warned and the AI can optionally react. At *Identify* the group lifts the ignore and `reveal`s the unit, then optionally shares the information and rolls for a radio bulletin.

Full scenario mapping: [docs/MATRIX_COVERAGE.md](docs/MATRIX_COVERAGE.md), covering the 150 matrix scenarios plus 32 more.

## Quick start
1. Load CBA, ZEN, RADS (and optionally ACE).
2. Put a BLUFOR player near some OPFOR. Get into a civilian car where nobody can see you, then drive past them.
3. Tune everything under **Addon Options > RADS - Adaptive Detection**. All 164 settings apply live.
4. Turn on *Debug overlay* (client) plus *Publish suspicion for debug* (server) to see each group's suspicion above its leader.

## Zeus and 3DEN
Category **Root's Adaptive Detection**, in both Zeus (ZEN) and the 3DEN modules list:

| Zeus | 3DEN | Purpose |
|---|---|---|
| Detection Settings | Detection Settings | Mission-wide live overrides of the key settings |
| Add / Remove Detection Zone | Detection Zone (area) | Multiplier, restricted (no cover) or safe-haven areas. Side filter, delay, duration, daytime window |
| Unit Cover Profile | Unit Cover Profile | Exempt / always covered / multiplier for units, groups, sides or all players |
| Vehicle Disguise | Vehicle Disguise | Always / never / auto / burned, per vehicle |
| AI Group Profile | AI Group Profile | Vigilance multiplier, immunity to disguises, share radius, bulletin chance |
| Compromise / Restore Cover | Compromise / Restore Cover | Blow or restore cover on demand (trigger-friendly) |
| Enable / Disable RADS | Enable / Disable RADS | On or off, after a delay, for a duration |
| Radio Bulletin | Radio Bulletin | Burn a vehicle / mark units wanted for chosen sides, or clear |
| Inspect Detection Status | - | Live per-group suspicion for a unit |

Details: [docs/MODULES.md](docs/MODULES.md).

## Documentation
- [docs/SETTINGS.md](docs/SETTINGS.md): every CBA setting, with default, range and effect
- [docs/MODULES.md](docs/MODULES.md): Zeus and 3DEN modules
- [docs/API.md](docs/API.md): public functions and CBA events for mission makers
- [docs/MATRIX_COVERAGE.md](docs/MATRIX_COVERAGE.md): how each scenario is handled
- [matrix.txt](matrix.txt): the original design matrix

## Building
```
hemtt check -p -Lc14 -e
hemtt build
hemtt release
```

## License
APL-SA. See [LICENSE](LICENSE).
