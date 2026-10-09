# Matrix coverage

How each scenario in `matrix.txt` is handled. The matrix is a guideline, not a strict rule set. Every mechanism below is tunable in the CBA settings ([SETTINGS.md](SETTINGS.md)).

## Mechanisms

| Key | Mechanism |
|---|---|
| UNAWARE | Entry snapshot: no knowledge → UNAWARE. Unit and vehicle ignored (`ignoreTarget`), nothing revealed or erased. |
| PARTIAL | Weak prior knowledge seeds suspicion (`seedFactor`), which then builds only through real exposure. |
| WITNESS | Witness rule at entry: knowsAbout ≥ `witnessKA` and seen within `witnessWindow` → COMPROMISED, knowledge kept. |
| ENGAGED | Engaged rule: unit threatened the group within `combatWindow` → COMPROMISED, no `forgetTarget`. |
| STALE | Stale knowledge → SEARCHING with seeded suspicion and `searchingBuildMult`. Decays rather than being erased. |
| LOCAL | Evaluated per group. Beyond `maxRange` nothing builds. No global propagation. |
| BUILD | Suspicion build-up: `checkVisibility` through the vehicle's view geometry × distance × field of view × light × behaviour × skill × gear/seat. |
| LOITER | Loitering ramp (`stationaryTime`/`stationaryMult`) and face-to-face bonus (`instantRange`/`instantMult`). |
| NOLOS | No line of sight → no exposure. Suspicion decays (`decayRate`). |
| PASSES | Repeated-pass bonus (`passBonus`, `passGap`, `passMax`). |
| FAST | Fast drive-by reduction (`fastSpeed`, `fastMult`). |
| EXIT | Leaving the vehicle drops cover → vanilla detection. Remembered suspicion ≥ `exitRevealThreshold` plus line of sight reveals the unit. |
| MEMORY | Per-group memory kept for `memoryTime`; exiting and re-entering does not reset it. |
| FORGET | COMPROMISED → after `forgetAfter` with no contact: `forgetTarget`, disguise works again. Optional `setTargetAge`. |
| UPKEEP | COMPROMISED groups keep tracking: no ignore, contact time refreshed while seen. |
| VEHSIDE | Per-side disguise check: civilian and observer-side vehicles fool; the players' own side's vehicles fool only when allowed (`allowHostileVeh`: never / unarmed only / all) and then build suspicion much faster. Faction tiers: same faction < same side < civilian < allied < enemy (`sameFactionVehMult` ... `hostileVehMult`, `vehClassMults`). |
| ARMOR | Closed armored seats (class list or optics-only seats): only the vehicle body is judged, at `armoredHullMult`. |
| META | Vehicle body clearly visible within `metaRange` while the crew is hidden: `hiddenCrewMult`, more when reversing (`reverseMult`) or parked rear-on (`rearFacingMult`), ramping up with time. |
| GEARMATCH | Each visible item compared with the enemy's own kit (Gear Reference / group / side): match, other camo, mismatch, missing (`gearCompareMode`). |
| CONVOY | Covered vehicles travelling together: more of them in view builds faster; one identified → the rest suspects or identified (`convoyMode`). |
| SYNC | Rising suspicion passed to friendly groups around after `syncDelay`, ignored once the unit changed vehicle or kit. |
| PURSUIT | From `followThreshold` (or SEARCHING): real waypoint chase on foot, or follow + horn/lights + stop + dismounted inspection; refusing → area alert; fleeing → identified + bulletin. |
| TRUCE | Safe haven truce: AI hold fire on players inside (also on foot / identified) until shooting, hurting, ramming, aiming or overstaying. |
| HOSTILE | Hostile act: firing compromises groups within `firedRadius` / `firedRadiusSuppressed` or with line of sight, and adds heat. |
| DAMAGE | Hit/kill handler: the victim's group identifies a seen attacker. Otherwise it goes SEARCHING (`damageSuspicion`). |
| VATTACK | Optional `vehicleAttackedBlows`: AI shooting the covered vehicle anyway identify its occupants. |
| SHARE | Controlled sharing (`shareMode`, `shareRadius`, `shareDelay`). Cancelled if the witnesses die first. |
| BULLETIN | Radio bulletin (radioman, delay, cancellable) → burned vehicle / wanted unit / area alert. |
| SAMEVEH | Hostile AI in the same vehicle → instant identification (`sameVehicleInstant`). |
| PERUNIT | Knowledge is per group × per unit and never normalised to the highest level. |
| SEAT | Seat factors re-evaluated every tick: turned out, FFV, turret, driver, cargo. |
| ENGINE | Sound: RADS does not create knowledge from noise. Gunfire from cover goes through the firing rules. |
| BURNED | Burned vehicle: recognised on sight by that side. Changing vehicles out of sight escapes it. |
| WANTED | Wanted unit: faster suspicion in any vehicle (`wantedMult`). |
| COMBAT | Busy groups notice less (`behCombat`, `engagedElsewhereMult`). |
| BEHAV | Suspicious driving multipliers: speeding, off-road approach, lights off, horn, aiming. |
| HOOKS | Optional visible reactions while suspicious: AWARE / watch / investigate (`aiAware`, `aiWatch`, `aiInvestigate`). |
| ZONES | Detection zones: multiplier, restricted (no cover) or safe haven. Can be time-windowed. |
| PROFILE | Group profiles (vigilance multiplier, immunity) for checkpoints etc. |
| INSTANT | Groups within `shareInstantRadius` of an identifying group identify the unit at once. Groups already suspicious confirm on any share (`shareEscalate`). |
| SWAP | Identified unit gets into a different vehicle unseen (`swapMinUnseen`) → that group only suspects it (`swapBaseSuspicion`). Each repeat adds `swapPenalty` until swapping stops working. The old vehicle stays burned (`burnOnIdentify`). |
| VISDMG | Visible damage (body, glass, wheels, fire) multiplies build (`damageInfluence`). Above `damageVisibleAt` the group is SUSPICIOUS on sight (`damageFloorScale`). |
| RAM | Ramming / running over: the driver's client reports hostile AI it touches at once (`ramDetect`, `ramSpeed`) → SUSPICIOUS (`ramSuspicion`) or identified (`ramCompromise`). |
| GEARVOID | Optional: hostile-looking gear voids cover (`gearVoidsCover` + per-item toggles) → vanilla instant combat. |
| PLATE | Reported number plates (`plateRecognition`): every burn also reports the plate. A group that reads it (`plateReadRange`) identifies at once and goes COMBAT (`plateCombat`), whatever the suspicion or vehicle. |
| THRESH | `identifyThreshold` reached → `ignoreTarget` lifted + `reveal` (`revealKA`). |

## Scenarios 1-150

| # | Scenario | Handled by |
|---|---|---|
| 1 | Enters civilian vehicle unnoticed | UNAWARE |
| 2 | Enters civilian vehicle while nearby AI is unaware | UNAWARE |
| 3 | Enters civilian vehicle while visible but not yet identified | PARTIAL, BUILD |
| 4 | Enters civilian vehicle while enemy AI has line of sight | WITNESS |
| 5 | Enters civilian vehicle after being completely unnoticed | UNAWARE |
| 6 | Enters civilian vehicle after being detected on foot | STALE |
| 7 | Enters civilian vehicle after active engagement | ENGAGED |
| 8 | Enters civilian vehicle during active combat, far AI | LOCAL |
| 9 | Enters civilian vehicle during active combat, nearby AI | PARTIAL, BUILD, INSTANT |
| 10 | Enters civilian vehicle while enemy AI is already firing at player | ENGAGED |
| 11 | Player breaks LOS immediately after entering | STALE |
| 12 | Player remains hidden in civilian vehicle | STALE, NOLOS |
| 13 | Player remains hidden for extended period | STALE, NOLOS |
| 14 | Enemy AI sees civilian vehicle but not player | UNAWARE, BUILD |
| 15 | Enemy AI sees player enter civilian vehicle | WITNESS |
| 16 | Enemy AI sees civilian vehicle stop near combat | COMBAT, UNAWARE |
| 17 | Civilian vehicle drives directly through enemy position | BUILD, FAST, HOOKS |
| 18 | Civilian vehicle remains extremely close to enemy AI | LOITER |
| 19 | Civilian vehicle remains close but behind solid cover | NOLOS |
| 20 | Civilian vehicle remains close with LOS blocked intermittently | BUILD, NOLOS |
| 21 | Player exits civilian vehicle near enemy | EXIT |
| 22 | Player exits civilian vehicle in front of enemy | EXIT |
| 23 | Player exits civilian vehicle after being previously known | EXIT, MEMORY |
| 24 | Player exits civilian vehicle after AI has forgotten him | EXIT |
| 25 | Player switches from civilian vehicle to military BLUFOR vehicle | VEHSIDE |
| 26 | Player switches from civilian vehicle to OPFOR vehicle | VEHSIDE |
| 27 | BLUFOR player enters OPFOR vehicle unnoticed | UNAWARE, VEHSIDE |
| 28 | BLUFOR player enters OPFOR vehicle while enemy AI watches | WITNESS |
| 29 | BLUFOR player enters OPFOR vehicle after being engaged | ENGAGED |
| 30 | BLUFOR player enters OPFOR vehicle after breaking LOS | STALE |
| 31 | BLUFOR player drives OPFOR vehicle past unaware enemy | VEHSIDE, BUILD |
| 32 | BLUFOR player drives OPFOR vehicle directly beside enemy | LOITER |
| 33 | BLUFOR player drives OPFOR vehicle directly through enemy formation | PASSES, BUILD |
| 34 | Enemy AI knows player is in vehicle but cannot see vehicle | UPKEEP |
| 35 | Enemy AI knows vehicle but not exact occupant | UNAWARE, HOOKS |
| 36 | Enemy AI previously saw player enter vehicle | WITNESS |
| 37 | Enemy AI never saw entry but knows player was nearby | STALE |
| 38 | Enemy AI sees player through vehicle window | BUILD |
| 39 | Enemy AI sees player partially through vehicle | BUILD |
| 40 | Enemy AI is too far away to detect player | LOCAL |
| 41 | Enemy AI is nearby but facing away | BUILD |
| 42 | Enemy AI is nearby and facing vehicle | BUILD |
| 43 | Enemy AI hears suspicious vehicle activity | ENGINE, HOSTILE |
| 44 | Enemy AI hears vehicle during active combat | COMBAT |
| 45 | Enemy AI sees suspicious vehicle but cannot identify occupant | BUILD, HOOKS |
| 46 | Enemy AI identifies vehicle as hostile | VEHSIDE |
| 47 | Enemy AI identifies vehicle as friendly but occupant is hostile | VEHSIDE, BUILD |
| 48 | Enemy AI receives information about player from another AI | SHARE, INSTANT |
| 49 | Enemy AI is not connected to witnessing AI | LOCAL, SHARE |
| 50 | One enemy AI sees player enter vehicle | WITNESS |
| 51 | Other enemy AI is nearby but did not see entry | PERUNIT |
| 52 | Witnessing AI communicates player location | SHARE, INSTANT |
| 53 | Player remains stationary inside vehicle near enemy | LOITER |
| 54 | Player rapidly passes enemy position in vehicle | FAST |
| 55 | Player repeatedly passes enemy position | PASSES |
| 56 | Player circles enemy position in civilian vehicle | PASSES, BEHAV |
| 57 | Player parks civilian vehicle beside enemy | LOITER |
| 58 | Player parks civilian vehicle far from enemy | LOCAL |
| 59 | Player hides vehicle behind terrain | NOLOS |
| 60 | Player drives behind terrain after being detected | UPKEEP |
| 61 | Player drives out of detection range after engagement | FORGET |
| 62 | Player remains undetected long enough after engagement | FORGET |
| 63 | Player returns after AI has forgotten him | FORGET |
| 64 | Player reappears shortly after being forgotten | FORGET, BUILD |
| 65 | Player changes vehicle while AI is tracking him | MEMORY, SWAP |
| 66 | Player changes from visible vehicle to concealed vehicle | UPKEEP, SWAP |
| 67 | Player changes from concealed vehicle to visible vehicle | BUILD |
| 68 | Player abandons vehicle and hides | EXIT |
| 69 | Player abandons vehicle after AI witnessed him | WITNESS, EXIT |
| 70 | Player enters vehicle while AI is actively engaging another BLUFOR | COMBAT, PERUNIT |
| 71 | Player enters vehicle while AI is actively engaging him | ENGAGED |
| 72 | Player enters vehicle while AI is actively engaging a different BLUFOR | PERUNIT, UNAWARE |
| 73 | Player enters vehicle during firefight but enemy AI is far outside firefight | LOCAL |
| 74 | Player enters vehicle during firefight and enemy AI hears gunfire | ENGINE |
| 75 | Player enters vehicle after killing an enemy nearby | DAMAGE |
| 76 | Enemy AI sees player attack from vehicle | HOSTILE |
| 77 | Enemy AI sees muzzle flash / weapon fire from vehicle | HOSTILE |
| 78 | Player fires from supposedly friendly enemy vehicle | HOSTILE |
| 79 | Player remains silent in supposedly friendly vehicle | UNAWARE, VEHSIDE |
| 80 | Enemy AI passes close to undercover player repeatedly | PASSES, LOITER |
| 81 | Enemy AI enters the same vehicle as undercover player | SAMEVEH |
| 82 | Undercover player sits in vehicle while enemy AI searches vehicle | LOITER, HOOKS |
| 83 | Enemy AI searches vehicle but has no reason to suspect it | BUILD |
| 84 | Enemy AI has stale knowledge of player but sees same vehicle later | BURNED, MEMORY, PLATE |
| 85 | Enemy AI has stale knowledge of player but sees different vehicle | MEMORY, WANTED |
| 86 | Enemy AI has completely forgotten player and sees civilian vehicle | FORGET |
| 87 | Player is undercover but another BLUFOR player is openly engaging enemy | PERUNIT |
| 88 | Undercover player is near openly engaged BLUFOR player | PERUNIT, BUILD |
| 89 | Undercover player becomes exposed while enemy is fighting another BLUFOR | HOSTILE, INSTANT |
| 90 | Undercover player leaves combat area | LOCAL |
| 91 | Undercover player enters an enemy-controlled area | VEHSIDE, ZONES |
| 92 | Undercover player stays in enemy-controlled area for extended period | BUILD, ZONES |
| 93 | Undercover player drives through an enemy checkpoint unnoticed | FAST, ZONES |
| 94 | Undercover player drives through checkpoint while being observed closely | LOITER |
| 95 | Undercover player stops at checkpoint | LOITER, PROFILE |
| 96 | Undercover player is questioned/approached by enemy AI | LOITER |
| 97 | Enemy AI identifies undercover player | THRESH |
| 98 | Enemy AI partially identifies player but loses contact | STALE |
| 99 | Enemy AI positively identifies player and then loses contact | UPKEEP |
| 100 | Enemy AI's knowledge gradually expires | FORGET |
| 101 | Enemy AI completely forgets player | FORGET |
| 102 | AI forgets player but another AI still knows player | PERUNIT |
| 103 | AI that forgot player receives fresh information | SHARE, BULLETIN, INSTANT |
| 104 | AI receives false/weak information | SHARE |
| 105 | Player enters vehicle outside AI detection range | LOCAL |
| 106 | Player approaches AI while concealed | BUILD |
| 107 | Player approaches AI while already known | ENGAGED |
| 108 | Player retreats while known | UPKEEP |
| 109 | Player retreats while unknown | LOCAL |
| 110 | Player drives into enemy AI's active combat zone but remains hidden | COMBAT |
| 111 | Player drives into enemy AI's active combat zone and becomes visible | BUILD, COMBAT |
| 112 | Player drives into combat zone and fires | HOSTILE |
| 113 | Player drives into combat zone and hits an enemy | DAMAGE, RAM |
| 114 | Player drives into combat zone but vehicle itself is attacked | VATTACK, VISDMG |
| 115 | Player drives into combat zone in enemy vehicle | VEHSIDE, COMBAT |
| 116 | Enemy AI observes friendly vehicle behaving suspiciously | BEHAV |
| 117 | Enemy AI observes friendly vehicle flee from combat | BEHAV |
| 118 | Enemy AI observes friendly vehicle assisting BLUFOR | HOSTILE |
| 119 | Undercover player changes seat inside vehicle | SEAT |
| 120 | Undercover player opens vehicle door | SEAT |
| 121 | Undercover player exits and immediately re-enters | MEMORY |
| 122 | Player changes vehicle while enemy AI has target knowledge | MEMORY, SWAP |
| 123 | Player changes vehicle out of sight | BURNED, SWAP |
| 124 | Player changes vehicle in enemy AI's LOS | WITNESS |
| 125 | Multiple enemy AI have different knowledge levels | PERUNIT |
| 126 | Enemy AI is in combat but has no knowledge of undercover player | UNAWARE |
| 127 | Enemy AI is searching for another player while undercover player is nearby | PERUNIT |
| 128 | Enemy AI searches last known position while undercover player is nearby | BUILD, HOOKS |
| 129 | Undercover player becomes the closest visible target | HOSTILE |
| 130 | Multiple undercover players occupy vehicles | PERUNIT |
| 131 | One undercover player is detected while another remains hidden | PERUNIT |
| 132 | Detected player moves near hidden player | BUILD |
| 133 | Hidden player is near a known target | PERUNIT |
| 134 | Hidden player assists known target without being seen | DAMAGE |
| 135 | Hidden player assists known target and is directly observed | HOSTILE |
| 136 | AI knows player is hostile but not player's exact location | STALE |
| 137 | AI knows vehicle is suspicious but not occupant identity | HOOKS |
| 138 | AI knows player is inside vehicle but cannot see player | UPKEEP |
| 139 | AI knows player exited vehicle but does not know direction | EXIT |
| 140 | AI loses player after vehicle destruction | EXIT |
| 141 | Player survives vehicle destruction unnoticed | EXIT |
| 142 | Player survives vehicle destruction and is observed | EXIT |
| 143 | Player uses vehicle as temporary concealment during firefight | ENGAGED |
| 144 | Player enters vehicle after enemy AI loses visual contact for only a short time | WITNESS, STALE |
| 145 | Player enters vehicle after enemy AI has been searching for a long time | STALE |
| 146 | Player enters vehicle after AI has fully forgotten him | FORGET |
| 147 | AI has direct visual contact but `knowsAbout` remains low | BUILD |
| 148 | AI has high `knowsAbout` but currently no LOS | STALE |
| 149 | AI has low `knowsAbout` and no LOS | PARTIAL |
| 150 | AI has zero/relevant target knowledge after `forgetTarget` | FORGET |

## Additional scenarios (151+)

| # | Scenario | Handling |
|---|---|---|
| 151 | Neighbouring group identifies the unit | `shareInstantRadius`: nearby groups identify at once. Already-suspicious groups confirm on share (`shareEscalate`). |
| 152 | Visibly damaged / burning vehicle | Visible damage multiplies build. Above `damageVisibleAt` the vehicle is suspicious on sight. |
| 153 | Ramming or running over AI | Driver-side contact check, immediate SUSPICIOUS (or identification). |
| 154 | Swap vehicles after being identified | Out of sight → only suspected. Repeats escalate (`swapPenalty`). Old vehicle burned. |
| 155 | Same plate on another vehicle (ZEN Plate Number) | Plate reported with the burn. Reading it identifies the occupants even in a different vehicle; changing the plate escapes it. |
| 156 | Hostile-looking gear | `gearVoidsCover`: own military uniform / helmet / vest / visible weapon voids cover. |
| 157 | Stolen vehicle seen or near its owners | Last AI crew is recorded; owners within `theftRadius` or with line of sight burn the vehicle and identify the thief (`theftEnabled`). |
| 158 | Witnesses killed before reporting | Sharing and bulletins check for survivors / a conscious radioman at send time. Silencing them keeps the knowledge local. |
| 159 | Radioman long-range alert | `bulletinChance` roll per identifying group with a radioman (`radiomanMode`). After `bulletinDelayMin/Max` it burns the vehicle and marks the unit wanted for that side within `bulletinRange`. |
| 160 | Civilian informants | Civilians who see an entry or a hostile act may report it after `informantDelay` (`informantsEnabled`, `informantChance`). |
| 161 | Several players in one vehicle | `compromiseCrew`: identifying one occupant identifies the covered crew for that group. |
| 162 | Player's AI squadmates riding along | `coverAIPassengers`: covered while a covered player is aboard, otherwise the AI would engage the vehicle. |
| 163 | Mixed crew (exempt player / other-side AI aboard) | `mixedCrewMode`: ignore / exposure penalty / void cover. |
| 164 | Open vehicles (quad, bike, RHIB) | `openVehicleMode` + `openVehicleClasses` + `openVehicleMult`. |
| 165 | Helicopters / planes / boats | `allowAir`, `allowBoats`, `altitudeFalloff`. |
| 166 | Night, NVG, fog, rain | `nightMult`, `nvgNightMult`, `fogInfluence`, `rainInfluence` (checkVisibility itself ignores light and fog). |
| 167 | Uniform / helmet / vest / NVG by day / visible weapon | Gear multipliers (`uniformCivMult`, `uniformObserverMult`, `uniformHostileMult`, `helmetMult`, `vestMult`, `nvgDayMult`, `weaponVisibleMult`). |
| 168 | Weapon light or laser on at night | `lightMult` when the seat exposes the weapon. |
| 169 | Aiming a turret / FFV weapon at AI | `aimMult` inside `aimAngle`. |
| 170 | Damaged or burning vehicle | `damageInfluence`. |
| 171 | Horn at a checkpoint | `hornMult` for 10 s. |
| 172 | Restricted base / checkpoint / safe town | Detection zones (Zeus/3DEN/API), with optional side filter, delay, duration and daytime window. |
| 173 | Heat after firing | `heatDuration`: no cover for a while after shooting. |
| 174 | Zeus remote-controlling an AI | Remote-controlled units never count as observers. |
| 175 | Player-led AI groups, PvP enemies | Only AI-led groups observe; player-controlled enemies are ignored by RADS. |
| 176 | Headless client / setGroupOwner mid-suspicion | State is mirrored on transitions and rehydrated by the new owner; ignore states re-applied. |
| 177 | Captive units / other undercover scripts | `captiveStandDown`: RADS leaves captive units alone. |
| 178 | ACE handcuffed / surrendering | compat_ace cover condition: no cover. |
| 179 | ACE unconscious observers / radiomen | Cannot observe, cannot send bulletins. |
| 180 | Respawn, disconnect, JIP | Cover cleared on death. Null units purged. Zones and object state are public vars. |
| 181 | Late-joining players and 'all players' profiles | 3DEN Unit Cover 'All players' is picked up by late joiners. |
| 182 | Groups spawned mid-mission, side relations changed | Picked up every cycle; hostility evaluated live (`getFriend`). |
| 183 | Vehicle hopping between two covered vehicles | Old cover dropped first, so witnesses of the swap re-classify. |
| 184 | Reversing up to / through a checkpoint so the AI never see the crew | META: the vehicle itself is judged, reversing multiplies it. |
| 185 | Parking rear-on next to a group | META: `rearFacingMult`, ramping with time. |
| 186 | BLUFOR vehicle at an OPFOR checkpoint / OPFOR vehicle at an OPFOR checkpoint | VEHSIDE: enemy tier x3 (unarmed only by default) / same faction x0.6. |
| 187 | APC / IFV / tank with hatches closed | ARMOR: only the hull is seen, slow build; turned out = normal. |
| 188 | Same uniform/vest/helmet/rifle as the guards vs another camo vs foreign kit | GEARMATCH per slot. |
| 189 | Convoy through a checkpoint, one vehicle identified | CONVOY (`convoyMode`), plus SHARE / instant radius for nearby groups. |
| 190 | Group leader far away from the members watching | Exposure, ranges, sharing, overlay and status all use the members, not only the leader. |
| 191 | Entry guards build suspicion, exit guards should know | SYNC. |
| 192 | Changing vehicle or kit between checkpoint guards | SYNC ignores it, `appearanceChangeKeep` halves remembered suspicion. |
| 193 | Highly suspicious vehicle drives on | PURSUIT: foot patrols chase, mounted patrols follow and signal to stop. |
| 194 | Player stops for the patrol | PURSUIT: dismount (gunners stay), inspect face to face; survive it and you are cleared (neighbours too). |
| 195 | Player ignores the stop signal / drives off during the inspection | PURSUIT: refused → area alert; fled → identified, vehicle known, bulletin. |
| 196 | Roleplay area: players on foot among enemy AI (Zeus controlling them) | TRUCE. |
| 197 | Player shoots / rams / overstays in a safe zone | TRUCE broken: zone AI go COMBAT and identify the offender. |
| 198 | LAMBS Danger loaded | LAMBS group AI paused during a pursuit; identified targets handed to LAMBS Rush / Hunt. |

## Engine limits

- Hearing: the engine decides what AI hear. RADS only adds the firing-radius rule for shots fired from cover.
- Opening a door is not detectable by script. Turning out and seat changes are.
- `setTargetAge` affects every side's knowledge, so it is opt-in (`targetAge`).
- `knowsAbout`, `forgetTarget` and `reveal` only work where the group is local. RADS runs on every machine and only touches local groups.
