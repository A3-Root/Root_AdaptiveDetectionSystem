# Changelog

## Inspection Crews (v1.0.0.13)

### Added
- Clean inspection lowers suspicion by a set amount (default 25%), still capped at "Cleared suspicion".
- Inspectors setting: how many dismount, in order passengers > other unarmed crew > commander > driver; gunners never leave.
- Crew remount before engaging: on flight or identification, dismounted driver/commander/turret crew get back in first, then hunt the target. Passengers fight on foot.

### Removed
- N/A

### Changed
- "Cleared suspicion" is now the highest value left after a clean inspection.

### Fixed
- N/A

## Inspections (v1.0.0.12)

### Added
- Cooldown between pursuits per group (default 60 s).
- Inspection gestures: the first inspector out signals stop; when cleared, they wave the vehicle on before remounting.
- Inspections judge the vehicle, not the wait: standing next to them builds nothing; exposed/turned-out occupants, aiming, damage, uncovered occupants, weapon lights and honking still count (new setting, on).

### Removed
- N/A

### Changed
- Horn also detected from a driver's fire key (the game does not always report it as a shot).

### Fixed
- One impact counted as two rams (several reports of the same hit).

## Rams & Horns (v1.0.0.11)

### Added
- Honking is heard: enemy groups within 60 m get +5% per honk (no line of sight). Settings "Honking adds" / "Honking heard within".
- Repeated ramming: first ram only raises suspicion; from ram #2 (within 300 s) the ramming settings apply. Settings "Full reaction from ram #" / "Repeated ramming window".

### Removed
- N/A

### Changed
- Stop request holds suspicion where it was when the pursuit started (at least the suspicious threshold), with no decay.
- Pursuits ordered by Zeus/API no longer end because the group is unaware.

### Fixed
- Zeus "AI Starting Suspicion" module missing (not listed in units[]); units[] now generated.
- Follow threshold below 35% dropping the pursuers to UNAWARE the moment they started following.

## Pursuit Catch-Up (v1.0.0.10)

### Added
- N/A

### Removed
- N/A

### Changed
- Mounted pursuers drive in SAFE at full speed and aim ahead of a moving target (20 m behind only when close and slow).
- Time to stop and the pulling-away check start once the pursuers are under way, not while still parked.

### Fixed
- Target always counted as fleeing while the pursuit vehicle was still pulling out.
- Light flashes overridden by the crew: light AI paused for every AI crew member during a flash.

## Pursuit Driving (v1.0.0.9)

### Added
- N/A

### Removed
- N/A

### Changed
- Mounted pursuit drives with direct driver orders only (no waypoint), aiming 20 m behind the target along its heading; crew set AWARE while following.

### Fixed
- Pursuing vehicle staying parked while the target drove: move orders were re-issued every 1-2 s, restarting the route each time. Now throttled (8 s to start, then at most every 3 s).

## Starting Suspicion (v1.0.0.8)

### Added
- AI starting suspicion: Zeus / 3DEN module and `root_ads_fnc_setStartSuspicion` set a per-unit floor suspicion starts at and never decays below.

### Removed
- N/A

### Changed
- N/A

### Fixed
- Pursuing vehicle staying parked while signalling: horn now fired by the driver directly.
- Light flashes near-instant: AI no longer switches the lights straight back during a flash.

## Stop Requests (v1.0.0.6)

### Added
- Stop request: a vehicle patrol that starts following holds suspicion at the follow threshold, starts its engine, honks and flashes every few seconds for the time to stop. Refusing, pulling away, shooting or ramming ends the hold.
- Settings: hold suspicion during a stop request, signal range, signal interval, pulling-away distance. Zeus/3DEN pursuit settings include them; getPursuit returns the held value.

### Removed
- ACE self-interaction "Check cover status" and its setting. Zeus Inspect keeps the readout.

### Changed
- Defaults updated to the tested server preset.
- All settings are server-only (admins); only debug options stay per player, and only for players the server allows ("Who may use debug": admins / admins and Zeus / everyone).
- "Signal to stop within" is now the separate inspect distance; signalling starts at the new signal range (150 m).

### Fixed
- Mounted pursuers identifying the target within seconds of starting to follow.
- Stop signal flashing once per second and honking once: now 0.5 s flashes and honks 1 s apart.
- Mounted pursuers staying parked: the commander gets direct move orders, stopped crew is released and PATH/MOVE re-enabled for the pursuit (restored afterwards).

## Balance & Fixes (v1.0.0.5)

### Added
- Vehicle optics: AI in gunner/commander seats judge from farther (range multiplier, per vehicle via module/API).
- Roam limit: pursuing groups stay within 200 m (foot) / 600 m (mounted) of home, give up and alert beyond it. Per group via profile/API.
- Ramming an AI vehicle counts as ramming (PhysX contact).
- Ramming makes the vehicle known (new setting, on).

### Removed
- N/A

### Changed
- Gear: item matching only refines a disguise (their/allied uniform); enemy fatigues no longer penalised twice. Old stacking kept as "Both, always".
- Gear does not count through armor or a hidden crew.
- Armored seats driven calmly build nothing; only speeding, off-road, lights off, horn, aiming, damage or loitering give them away.
- Hidden-crew check only below 15 km/h; plain hidden crew off by default (reversing / rear-on still caught).
- Ramming identifies the whole vehicle by default.
- Queued suspicion syncs are dropped once the unit is identified.

### Fixed
- Safe zone truce check spamming the RPT with "0 elements provided, 1 expected".
- Same error in getGearReference for a side without a list.

## Checkpoints & Pursuit (v1.0.0.4)

### Added
- Hidden-crew detection: reversing up to or parking rear-on near the AI is judged through the vehicle.
- Vehicle faction tiers (same faction, same side, civilian, allied, enemy) and per-class multipliers; own-side vehicles can give cover (unarmed only by default).
- Armored hulls: closed seats in tanks/APCs only show the vehicle, slow build.
- Gear matching per slot against an enemy gear reference (Zeus/3DEN module + API, collect from the mission's AI).
- Convoys: more vehicles in view build faster; one identified makes the rest suspects (or identified).
- Suspicion sync to friendly groups in range after a delay, dropped when the unit changes vehicle or kit.
- Pursuit from a follow threshold: waypoint chase on foot; mounted follow with horn/lights, stop, dismounted inspection; refusal alert, flee = identified + bulletin. LAMBS aware.
- Safe haven truce: AI hold fire on players inside (on foot too) until shooting, hurting/ramming AI, aiming or overstaying.
- AI glance at / look at suspicious vehicles.
- Zeus modules: Sync, Pursuit & Checkpoint, Truce settings, Enemy Gear Reference, Order Pursuit. 3DEN: Pursuit, Sync & Truce Settings, Enemy Gear Reference. 8 API functions.

### Removed
- Investigate settings (replaced by pursuit).

### Changed
- Every setting, module and hint rewritten in plain words and moved to stringtables; settings regrouped into 22 categories.
- Group members count on their own: ranges, sharing, overlay and status no longer depend on the leader's position.

## Detection Range Fixes (v1.0.0.3)

### Added
- Gear readable range (default 50 m): gear multipliers fade out by twice that distance.

### Removed
- N/A

### Changed
- Distance falloff is now (close range / distance) ^ exponent: 0.09 at 200 m instead of 0.64 (drivers were being identified from 200+ m).
- Visible damage uses the average hit-point damage instead of the single worst hit point (one broken window no longer counts as a wreck).
- Ramming detection uses the geometry hull with a 0.15 m margin (bystanders next to the road were counted as rammed).
- Vehicle swap: only a group that sees the unit in the new vehicle learns it; a swap that is merely too soon is re-checked every evaluation instead of burning the new vehicle.

## Debug Logging (v1.0.0.2)

### Added
- Detailed RPT debug log: identification/state/forget reports with group, target, vehicle context and per-entry evaluation history.
- Per-evaluation breakdown: observer factors, every multiplier, vehicle grid/speed/damage; instant triggers marked.
- Event logs for classification, ram detection, hits (gunfire vs collision), shots, shares, attacks, vehicle swaps and cover changes.
- Settings: debug detail level, large-jump threshold, history length.
- Every state change (any path) and every fooled/not-fooled change is logged with its cause.
- Number plates: burning a vehicle also reports its plate (ZEN Plate Number); a group that reads it within 50 m identifies at once and goes COMBAT.

### Removed
- N/A

### Changed
- Collisions/run-overs no longer count as attacks: they go through the ramming path (suspicious, not identified).
- Ramming detection uses the vehicle footprint + 0.5 m instead of the bounding sphere + 1.5 m; default ramming suspicion 75% -> 50%.
- Vehicle swap: identified-in vehicle tracked separately (no tick race), swap also checked during evaluation, default unseen time 15 s -> 2 s; a watched swap makes the new vehicle the known one.

## Testing Fixes (v1.0.0.1)

### Added
- Instant identification for groups near an identifying group (`shareInstantRadius`); already-suspicious groups confirm on any share.
- Visible vehicle damage (glass, body, wheels, fire): suspicious on sight above a threshold, faster build-up below it.
- Ramming/running over detection: rammed group suspicious at once (optional instant identification).
- Vehicle swap after identification: unseen swap only suspected, repeats escalate, old vehicle burned locally.
- Optional "Hostile gear voids cover" with per-item toggles (uniform, helmet, vest, visible weapon).

### Removed
- N/A

### Changed
- Face-to-face range slider max 30 m -> 100 m (default stays 6 m; 18 m made checkpoints impossible to pass).
- Damaged vehicle influence default 1 -> 2.
- Identified vehicles are burned for that side within 1500 m by default.

## Initial Public Release (v1.0.0.0)

### Added
- Initial release: per-group, per-player suspicion for units in civilian/observer-side vehicles.
- Entry snapshot: witnessed/engaged keep knowledge, stale seeds a search, unaware are fooled.
- Exposure from checkVisibility, FOV, distance, light, weather, behaviour, skill, seat, gear, driving, loitering, passes, aiming.
- Hostile acts, hit/kill reactions, heat, crew compromise, forgetting via forgetTarget.
- Controlled knowledge sharing, radio bulletins (burned vehicles, wanted units, area alert), civilian informants, theft.
- Optional AI reactions: AWARE, watch, investigate.
- 144 live CBA settings, runtime overrides.
- 10 Zeus and 8 3DEN modules.
- Public API and CBA events.
- Locality-safe: server, headless clients, client-owned AI, ownership transfer.
- ACE compat: status self-action, handcuffed/surrendering lose cover.

### Removed
- N/A

### Changed
- N/A
