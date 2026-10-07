# Changelog

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
- Face-to-face range default 6 m -> 18 m (max 100 m).
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
