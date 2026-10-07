# RADS - CBA Settings

All settings live under **Addon Options > RADS - Adaptive Detection**. Every value is read live, so a change made mid-mission applies at the next evaluation. No rebuild or restart needed. Settings marked *client* are per-player. All others are mission/server settings, and the server can force them.

Runtime overrides from the Zeus/3DEN **Detection Settings** modules or `root_rads_fnc_setOverride` take precedence over these values until cleared.

Variable names are `root_rads_main_<name>`.

## General

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Enable RADS | `enabled` | true |  | Master switch. When off, all covered players are released to vanilla detection. |
| Cover BLUFOR units | `coverWest` | true |  | BLUFOR players (and their AI passengers) can go undercover in vehicles. |
| Cover OPFOR units | `coverEast` | false |  | OPFOR players can go undercover in vehicles. |
| Cover INDFOR units | `coverGuer` | false |  | Independent players can go undercover in vehicles. |
| Cover AI passengers | `coverAIPassengers` | true |  | AI of a covered side riding in a covered player's vehicle are covered too (otherwise the AI would engage the vehicle because of them). |
| Evaluation interval (s) | `tickInterval` | 1 | 0.25 - 5 | How often each AI group re-evaluates covered units. Lower = more responsive, more CPU. |
| Groups per frame | `groupsPerFrame` | 6 | 1 - 50 | Performance budget: max AI groups evaluated per frame (work is spread over frames). |
| Maximum observation range (m) | `maxRange` | 800 | 50 - 3000 | Beyond this distance an AI group cannot build suspicion at all. |
| Observers per group | `maxObservers` | 4 | 1 - 12 | Max units per group (closest first) checked for line of sight each evaluation. |

## Cover Eligibility

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Civilian vehicles give cover | `allowCivVeh` | true |  | Vehicles whose config side is civilian disguise the occupants. |
| Observer-side vehicles give cover | `allowFriendlyVeh` | true |  | Vehicles belonging to a side friendly to the observing AI (e.g. an OPFOR vehicle seen by OPFOR) disguise the occupants. |
| Aircraft give cover | `allowAir` | true |  | Allow disguise in qualifying helicopters and planes. |
| Boats give cover | `allowBoats` | true |  | Allow disguise in qualifying boats. |
| Open vehicles | `openVehicleMode` | Allowed with exposure penalty | Allowed with exposure penalty / No cover | Quads, bikes, karts, open boats... the occupant is in plain view. |
| Open vehicle classes | `openVehicleClasses` | `Quadbike_01_base_F,Kart_01_Base_F,Motorcycle,Bicycle,Rubber_duck_base_F,LSV_01_light_base_F,LSV_02_unarmed_base_F` |  | Comma-separated base classes treated as open vehicles (isKindOf). |
| Always-disguise vehicles | `vehWhitelist` | (empty) |  | Comma-separated classes (isKindOf) that always disguise, regardless of side. |
| Never-disguise vehicles | `vehBlacklist` | (empty) |  | Comma-separated classes (isKindOf) that never disguise. |
| Mixed crew | `mixedCrewMode` | Exposure penalty | Ignore / Exposure penalty / Void cover for everyone | Occupants that are not covered (exempt players, AI of other sides) in the same vehicle. |
| Stand down for captive units | `captiveStandDown` | true |  | If a mission or another undercover script sets a unit captive, RADS leaves it alone. |

## Entry Classification

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Witness knowledge | `witnessKA` | 1.5 | 0 - 4 | knowsAbout (0-4) at or above which a group that recently saw the player keeps full knowledge after vehicle entry. |
| Witness window (s) | `witnessWindow` | 6 | 0 - 60 | A group that saw the player within this many seconds of entry counts as a witness. |
| Combat window (s) | `combatWindow` | 20 | 0 - 180 | A group the player threatened within this many seconds keeps fighting through the vehicle entry. |
| Seed from old knowledge | `seedFactor` | 60% | 0 - 100% | Fraction of a group's existing (non-witness) knowledge converted into starting suspicion. |
| Searching build multiplier | `searchingBuildMult` | 1.5 | 1 - 5 | Groups that recently knew the player (searching) build suspicion this much faster. |
| Entry sync delay (s) | `coverGraceTime` | 2 | 0 - 5 | Remote machines wait this long after a cover change before lazily classifying, so the entry snapshot wins. |

## Suspicion Build-up

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Build rate (%/s) | `buildRate` | 12 | 1 - 100 | Suspicion gained per second at full exposure. 100 = identified. |
| Decay rate (%/s) | `decayRate` | 1.5 | 0 - 50 | Suspicion lost per second while not exposed. |
| Suspicious threshold (%) | `suspiciousThreshold` | 35 | 1 - 99 | Group becomes SUSPICIOUS (optional AI reactions, player warning). |
| Identify threshold (%) | `identifyThreshold` | 100 | 10 - 100 | Group identifies the player and engages. |
| Close identification range (m) | `identifyRange` | 40 | 5 - 500 | Inside this range distance does not reduce exposure. |
| Distance falloff exponent | `distanceCurve` | 1.5 | 0.25 - 4 | Shape of exposure falloff between close range and max range. Higher = drops faster. |
| Face-to-face range (m) | `instantRange` | 6 | 0 - 30 | Within this range an observer looking into the vehicle gets a large bonus. |
| Face-to-face multiplier | `instantMult` | 4 | 1 - 10 | Exposure multiplier inside face-to-face range. |
| Minimum close exposure | `minCloseExposure` | 40% | 0 - 100% | Minimum visibility assumed inside face-to-face range even through a closed hull. |
| Vehicle hull blocks sight | `hullBlocks` | true |  | Ray-cast respects the vehicle's own view geometry (glass lets partial sight through). Off = only terrain/objects block. |
| Loitering ramp time (s) | `stationaryTime` | 30 | 5 - 300 | Time stationary near a group to reach the maximum loitering bonus. |
| Loitering max multiplier | `stationaryMult` | 2.5 | 1 - 5 | Exposure multiplier when parked near the group for the full ramp time. |
| Repeated-pass bonus | `passBonus` | 0.25 | 0 - 2 | Extra exposure multiplier per separate pass in view (circling, repeated drive-bys). |
| Repeated-pass cap | `passMax` | 2.5 | 1 - 5 | Maximum multiplier from repeated passes. |
| Pass separation (s) | `passGap` | 10 | 2 - 120 | Out-of-view time needed before the next sighting counts as a new pass. |
| Hostile AI in same vehicle = identified | `sameVehicleInstant` | true |  | An enemy AI riding in the same vehicle identifies covered occupants instantly. |

## Observer Factors

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Observer field of view (deg) | `fovAngle` | 140 | 30 - 360 | Full cone angle in which an observer is looking at the vehicle. |
| Peripheral vision | `peripheralMult` | 15% | 0 - 100% | Exposure multiplier when outside the field of view. |
| Relaxed (SAFE/CARELESS) multiplier | `behSafe` | 0.7 | 0 - 3 | Exposure multiplier for relaxed observers. |
| AWARE multiplier | `behAware` | 1 | 0 - 3 | Exposure multiplier for alert observers. |
| COMBAT multiplier | `behCombat` | 0.5 | 0 - 3 | Exposure multiplier for observers in combat (distracted by the fight). |
| STEALTH multiplier | `behStealth` | 1.2 | 0 - 3 | Exposure multiplier for observers in stealth mode. |
| Skill influence | `skillInfluence` | 50% | 0 - 100% | How much AI spotDistance/spotTime skill scales exposure (±). |
| Busy fighting multiplier | `engagedElsewhereMult` | 0.6 | 0 - 2 | Exposure multiplier when the group is currently fighting another known enemy. |

## Environment

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Night visibility | `nightMult` | 45% | 0 - 100% | Exposure multiplier at full darkness (scaled by sun/moon light). |
| Night visibility with NVG | `nvgNightMult` | 85% | 0 - 100% | Night multiplier for observers using night vision. |
| Fog influence | `fogInfluence` | 60% | 0 - 100% | How strongly fog reduces exposure. |
| Rain influence | `rainInfluence` | 30% | 0 - 100% | How strongly rain reduces exposure. |

## Seat & Vehicle

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Driver seat | `seatDriver` | 1 | 0 - 3 | Exposure multiplier for drivers. |
| Passenger seat | `seatCargo` | 0.7 | 0 - 3 | Exposure multiplier for passengers. |
| Turret seat | `seatTurret` | 1.1 | 0 - 3 | Exposure multiplier for gunners/commanders. |
| Turned out | `seatTurnedOut` | 2 | 0 - 5 | Exposure multiplier when turned out. |
| Firing from vehicle position | `seatFFV` | 2.5 | 0 - 5 | Exposure multiplier in FFV seats where the weapon is usable. |
| Open vehicle multiplier | `openVehicleMult` | 2.5 | 1 - 10 | Exposure multiplier for open vehicles (if allowed). |
| Civilian vehicle multiplier | `civVehMult` | 1 | 0 - 3 | Exposure multiplier in civilian vehicles. |
| Observer-side vehicle multiplier | `friendlyVehMult` | 0.8 | 0 - 3 | Exposure multiplier in vehicles friendly to the observer (they expect their own people). |
| Fast pass speed (km/h) | `fastSpeed` | 50 | 10 - 200 | Above this speed a drive-by gives limited exposure. |
| Fast pass multiplier | `fastMult` | 40% | 0 - 100% | Exposure multiplier above the fast pass speed. |
| Aircraft altitude falloff (m) | `altitudeFalloff` | 60 | 10 - 1000 | Aircraft above this altitude (ATL) get proportionally less exposure. |
| Damaged vehicle influence | `damageInfluence` | 1 | 0 - 3 | Damaged/burning vehicles look suspicious: multiplier = 1 + damage x this. |
| Mixed crew multiplier | `mixedCrewMult` | 1.5 | 1 - 5 | Exposure multiplier per uncovered occupant (Mixed crew = penalty). |

## Gear

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Gear affects suspicion | `gearEnabled` | true |  | Uniform, headgear, vest and visible weapons modify how fast suspicion builds. |
| Civilian clothes | `uniformCivMult` | 0.6 | 0 - 3 | Exposure multiplier wearing a civilian uniform. |
| Observer-side uniform | `uniformObserverMult` | 0.5 | 0 - 3 | Exposure multiplier wearing the observer's (friendly to observer) uniform. |
| Hostile military uniform | `uniformHostileMult` | 1.6 | 0 - 5 | Exposure multiplier wearing a military uniform hostile to the observer (e.g. own BLUFOR uniform). |
| Ballistic headgear | `helmetMult` | 1.25 | 0 - 3 | Exposure multiplier wearing armored headgear. |
| Armored vest | `vestMult` | 1.2 | 0 - 3 | Exposure multiplier wearing an armored vest. |
| NVG worn in daylight | `nvgDayMult` | 1.3 | 0 - 3 | Exposure multiplier for night vision on the head during the day. |
| Visible weapon | `weaponVisibleMult` | 1.5 | 0 - 5 | Exposure multiplier when a primary weapon/launcher is visible (exposed seat or open vehicle). |
| Neutral gear | `gearNeutral` | (empty) |  | Comma-separated item classes ignored by gear checks. |

## Behaviour of Player

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Speeding near AI (km/h) | `speedingSpeed` | 70 | 10 - 200 | Driving faster than this within 100 m of a group is suspicious. |
| Speeding multiplier | `speedingMult` | 1.3 | 1 - 5 | Exposure multiplier when speeding near the group. |
| Off-road approach multiplier | `offroadMult` | 1.2 | 1 - 5 | Exposure multiplier when driving off-road within 150 m of the group. |
| Lights off at night multiplier | `lightsOffMult` | 1.4 | 1 - 5 | Exposure multiplier for a moving vehicle with headlights off at night. |
| Horn multiplier | `hornMult` | 1.5 | 1 - 5 | Exposure multiplier for 10 s after honking nearby. |
| Aiming at AI multiplier | `aimMult` | 2.5 | 1 - 10 | Exposure multiplier when the player/turret is aiming at the observer. |
| Aiming cone (deg) | `aimAngle` | 8 | 1 - 45 | Half-angle within which a weapon counts as aimed at an observer. |
| Weapon light/laser at night | `lightMult` | 2 | 1 - 5 | Exposure multiplier when a weapon flashlight or laser is on at night. |

## Hostile Acts

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Firing blows cover | `firedBlows` | true |  | Firing a weapon from cover compromises nearby groups and groups with line of sight. |
| Firing reveal radius (m) | `firedRadius` | 300 | 0 - 2000 | Groups within this radius of an unsuppressed shot are compromised. |
| Suppressed reveal radius (m) | `firedRadiusSuppressed` | 40 | 0 - 500 | Same, for suppressed weapons. |
| Seen firing = compromised | `firedLOS` | true |  | Any group with line of sight to the shooter (within max range) is compromised. |
| Heat after firing (s) | `heatDuration` | 120 | 0 - 1800 | After firing, the unit cannot regain cover for this long. 0 = disabled. |
| Hurting AI blows cover | `damageBlows` | true |  | When a covered unit (or its vehicle) damages an AI, that AI's group reacts. |
| Victim group must see attacker | `damageNeedsLOS` | true |  | Without line of sight the victim's group only becomes SEARCHING instead of identifying the attacker. |
| Unseen attack suspicion (%) | `damageSuspicion` | 70 | 0 - 99 | Suspicion given to the victim's group when the attacker was not seen. |
| Vehicle attacked by AI blows cover | `vehicleAttackedBlows` | false |  | If hostile AI shoot a covered vehicle anyway (e.g. it is a threat), the shooters' group identifies the occupants. |
| Compromise whole crew | `compromiseCrew` | true |  | Identifying one occupant identifies every covered occupant of that vehicle for that group. |
| Reveal knowledge on identification | `revealKA` | 4 | 0.5 - 4 | knowsAbout (0-4) given when a group identifies a unit. |

## Memory & Forgetting

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Forget after (s) | `forgetAfter` | 180 | 10 - 1800 | A compromised group that has not seen the unit for this long forgets it (forgetTarget) and the disguise works again. |
| Calm-down threshold (%) | `recoverThreshold` | 10 | 0 - 50 | SUSPICIOUS/SEARCHING groups return to UNAWARE below this suspicion. |
| Memory after exit (s) | `memoryTime` | 600 | 0 - 3600 | Suspicion is remembered this long after the unit leaves the vehicle (exit and re-enter does not reset it). |
| Exit reveal threshold (%) | `exitRevealThreshold` | 50 | 0 - 100 | Leaving the vehicle in view of a group at or above this suspicion reveals the unit to it. |
| Age knowledge on loss of contact | `targetAge` | Disabled | Disabled / Actual / 5 min / 10 min / 15 min / 30 min / 60 min / Unknown | Optionally calls setTargetAge on a compromised unit when it breaks contact. Affects every side's knowledge. |
| Age knowledge after (s) | `targetAgeDelay` | 60 | 5 - 600 | Time without contact before the target age is applied. |

## Knowledge Sharing

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Share on identification | `shareMode` | Suspicion (they start searching) | Nothing / Suspicion (they start searching) / Full identification | What nearby friendly groups learn when a group identifies a unit. |
| Share radius (m) | `shareRadius` | 300 | 0 - 3000 | Groups of the same side within this radius receive the information. |
| Share delay (s) | `shareDelay` | 5 | 0 - 120 | Delay before the information arrives. Killing the whole group first prevents it. |
| Shared knowledge | `shareKA` | 1.5 | 0.1 - 4 | knowsAbout (0-4) given on full share. |
| Shared suspicion (%) | `shareSuspicion` | 60 | 0 - 99 | Starting suspicion given on suspicion share. |
| Sharing needs a radio | `shareNeedsRadio` | false |  | The identifying group needs at least one unit with a radio to share. |

## Radio Bulletins

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Enable radio bulletins | `bulletinEnabled` | true |  | On identification a radioman may broadcast the unit/vehicle over long range. |
| Bulletin chance | `bulletinChance` | 10% | 0 - 100% | Chance per identifying group that a bulletin is sent. |
| Also roll on hostile acts | `bulletinOnHostile` | true |  | Groups compromised by gunfire/attacks also roll for a bulletin. |
| Who can send | `radiomanMode` | Above or any unit with a radio | Radio backpack / radioman class / Above or any unit with a radio / Group leader only / Anyone (no radioman needed) | Which units count as a radioman. |
| Radio backpacks | `radioBackpacks` | `B_RadioBag_01_base_F,TFAR_Bag_Base,ACRE_PRC117F,ACRE_PRC77` |  | Comma-separated backpack classes (isKindOf) that make a radioman. |
| Radioman classes | `radiomanClasses` | (empty) |  | Comma-separated unit classes (isKindOf). Units whose class contains 'radio' always count. |
| Bulletin delay min (s) | `bulletinDelayMin` | 10 | 0 - 300 | Minimum time to send. Killing/knocking out the radioman first cancels it. |
| Bulletin delay max (s) | `bulletinDelayMax` | 30 | 0 - 600 | Maximum time to send. |
| Bulletin range (m) | `bulletinRange` | 5000 | 0 - 30000 | Groups beyond this distance from the sender do not get it. 0 = side-wide. |
| Bulletin burns the vehicle | `bulletinBurn` | true |  | Receiving groups recognize the vehicle on sight and engage its covered occupants immediately. |
| Burned vehicle duration (s) | `burnDuration` | 900 | 30 - 7200 | How long a vehicle stays burned. |
| Bulletin marks unit as wanted | `bulletinWanted` | true |  | Receiving side builds suspicion faster against that unit in any vehicle. |
| Wanted duration (s) | `wantedDuration` | 600 | 30 - 7200 | How long the wanted status lasts. |
| Wanted multiplier | `wantedMult` | 2 | 1 - 10 | Suspicion build multiplier against wanted units. |
| Bulletin alerts the area | `bulletinAreaAlert` | true |  | Groups near the reported position start SEARCHING. |
| Area alert radius (m) | `areaAlertRadius` | 600 | 0 - 5000 | Radius around the reported position. |
| Area alert sets AWARE | `areaAlertAware` | true |  | Alerted groups that are SAFE/CARELESS switch to AWARE. |

## Civilian Informants & Theft

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Civilian informants | `informantsEnabled` | false |  | Civilian AI who witness a hostile act may report it to the nearest hostile force. |
| Informant chance | `informantChance` | 15% | 0 - 100% | Chance per witnessing civilian group. |
| Informant delay (s) | `informantDelay` | 45 | 0 - 600 | Time to make the report. Cancelled if the informant dies. |
| Informant witness range (m) | `informantRange` | 200 | 10 - 1000 | Max distance a civilian can witness from. |
| Stolen vehicles | `theftEnabled` | true |  | Taking a vehicle last crewed by an AI group burns it for that side if its owners are nearby or see it. |
| Theft witness radius (m) | `theftRadius` | 50 | 0 - 500 | Owners within this distance always notice the theft. |

## AI Reactions

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Suspicious groups go AWARE | `aiAware` | false |  | SAFE/CARELESS groups switch to AWARE while suspicious (restored when calm). |
| Suspicious groups watch the vehicle | `aiWatch` | false |  | Observers turn to watch the suspicious vehicle. |
| Suspicious groups investigate | `aiInvestigate` | false |  | Group leader moves towards the vehicle when suspicion is high. Overrides waypoints temporarily. |
| Investigate threshold (%) | `aiInvestigateMin` | 60 | 1 - 99 | Suspicion needed before investigating. |
| Investigate max distance (m) | `aiInvestigateRange` | 200 | 10 - 1000 | Only investigate vehicles within this distance. |
| Identifying groups go COMBAT | `aiCombatOnIdentify` | false |  | Set COMBAT behaviour on identification. |

## Notifications

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Show cover status changes *(client)* | `notifyCover` | true |  | Hint when you gain or lose cover. |
| Warn when watched *(client)* | `notifyWatched` | true |  | Hint when an enemy group becomes suspicious of you. |
| Warn when identified *(client)* | `notifyCompromised` | true |  | Hint when an enemy group identifies you. |
| Zeus notifications *(client)* | `notifyZeus` | true |  | Curators get messages for identifications and radio bulletins. |
| Allow suspicion feedback (server) | `allowWatchedHints` | true |  | Server permission for watched/identified hints and the ACE status suspicion readout. |

## Debug

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| Debug log | `debugLog` | false |  | Write state transitions to the RPT. |
| Publish suspicion for debug | `debugPublish` | false |  | Group owners broadcast suspicion every evaluation so overlays/Zeus inspect stay live (network cost). |
| Debug overlay *(client)* | `debugOverlay` | false |  | Draw each nearby group's suspicion toward you (needs 'Publish suspicion' for live values). |
| Show zone markers | `showZoneMarkers` | false |  | Create map markers for detection zones (visible to everyone). |

## ACE compatibility (only with ACE loaded)

| Setting | Name | Default | Range / options | Description |
|---|---|---|---|---|
| ACE self-action: cover status *(client)* | `root_rads_compat_ace_statusAction` | true |  | Adds 'Check cover status' to the ACE self-interaction menu while in a vehicle. |
