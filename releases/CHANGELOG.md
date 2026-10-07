# Changelog

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
