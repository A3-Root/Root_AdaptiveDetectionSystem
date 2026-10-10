# Changelog

## Public Release (v2.0.0.0)

### Added
- Per-group, per-player suspicion for players in civilian or observer-side vehicles, replacing instant vanilla detection.
- Entry snapshot: groups that saw you get in or were fighting you keep their knowledge; groups that knew you earlier start searching; the rest are fooled.
- Exposure from line of sight through the vehicle, field of view, distance, light, NVGs, fog and rain, observer behaviour and skill, seat, gear, driving, loitering, repeated passes and aiming.
- Close-range awareness: a vehicle parked right beside a soldier or crew is noticed outside their view cone.
- Vehicle faction tiers (same faction, same side, civilian, allied, enemy), per-class multipliers, whitelists and blacklists.
- Armored hulls: closed seats show only the vehicle; driven calmly they build nothing.
- Hidden-crew detection: reversing up to or parking rear-on near the AI is judged through the vehicle.
- Gear matching per slot against an enemy gear reference, collected from the mission's AI or set by hand.
- Visible vehicle damage, wanted units, burned vehicles and reported number plates.
- Hostile acts: shooting, hurting AI and aiming turrets blow cover; heat denies cover for a while.
- Ramming: a first ram raises suspicion, repeated ramming identifies and burns the vehicle.
- Honking: heard without line of sight and escalating with every honk in a series, capped below identification; the group searches after a few honks.
- Forgetting and vehicle swaps: break contact and they forget you; unseen swaps escalate with every repeat.
- Knowledge sharing between nearby groups and radio bulletins from radiomen (burned vehicles, wanted units, area alerts).
- Suspicion sync: checkpoint entry guards pass their suspicion to the exit guards, dropped when you change vehicle or kit.
- Convoys: more vehicles in view build faster; one identified makes the rest suspects.
- Pursuits: foot patrols chase; mounted patrols start up, follow, honk and flash for a stop while suspicion is held.
- Refusal alerts, called off again if the vehicle stops for the inspection after all.
- Inspections: priority dismount (passengers, spare crew, commander, driver; gunners stay), gestures, calm while nothing gives you away for every group.
- Clean inspections lower suspicion, pause it for that vehicle, send an all-clear to neighbours and block new pursuits for a cooldown; any give-away ends the grace.
- Fleeing an inspection identifies and reports you; dismounted crew remount before hunting.
- Roam limits and cooldowns for pursuing groups; one inspection per vehicle at a time.
- LAMBS Danger support: danger FSM paused during pursuits, hunt or rush on identification.
- AI starting suspicion per unit or group, kept out of the suspicion sync.
- Safe zone truces: AI hold fire on players inside until shooting, ramming, aiming or overstaying.
- Detection zones: multiplier, restricted and safe-haven areas with side filter, delay, duration and time window.
- Civilian informants, stolen-vehicle detection and optional AI reactions (AWARE, glance, look, watch).
- 291 live CBA settings with plain-language tooltips, server-wide and admin-only; the server decides who may use the debug tools.
- 16 Zeus modules and 11 Eden modules.
- 24 public API functions, runtime setting overrides and CBA events.
- Detailed RPT debug log with per-evaluation history, and a live debug overlay.
- ACE3 compatibility: handcuffed and surrendering units lose cover, unconscious AI do not observe.
- Works in singleplayer, multiplayer, on dedicated servers and with headless clients.

### Changed
- Version jumps from the 1.0.0.x development builds to 2.0.0.0 for the public Workshop release.
- Default settings tuned through the development test rounds.
- Investigating replaced by pursuits, stops and inspections.
- All text moved to stringtables and settings regrouped into 22 categories.

### Removed
- ACE self-interaction "Check cover status" (Zeus Inspect Detection Status keeps the readout).
- Investigate settings.
