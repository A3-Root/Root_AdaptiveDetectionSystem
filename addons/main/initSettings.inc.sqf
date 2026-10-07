// CBA settings. Every value is read live (MSET) each evaluation, so changes in
// Addon Options apply mid-mission. Modules/API may layer runtime overrides on top.
#define CAT "RADS - Adaptive Detection"
#define SUB_GEN [CAT, "01 General"]
#define SUB_ELIG [CAT, "02 Cover Eligibility"]
#define SUB_ENTRY [CAT, "03 Entry Classification"]
#define SUB_BUILD [CAT, "04 Suspicion Build-up"]
#define SUB_OBS [CAT, "05 Observer Factors"]
#define SUB_ENV [CAT, "06 Environment"]
#define SUB_SEAT [CAT, "07 Seat & Vehicle"]
#define SUB_GEAR [CAT, "08 Gear"]
#define SUB_DRIVE [CAT, "09 Behaviour of Player"]
#define SUB_HOSTILE [CAT, "10 Hostile Acts"]
#define SUB_MEM [CAT, "11 Memory & Forgetting"]
#define SUB_SHARE [CAT, "12 Knowledge Sharing"]
#define SUB_RADIO [CAT, "13 Radio Bulletins"]
#define SUB_INFORM [CAT, "14 Civilian Informants & Theft"]
#define SUB_AI [CAT, "15 AI Reactions"]
#define SUB_RAM [CAT, "14b Ramming & Vehicle Swaps"]
#define SUB_PLATE [CAT, "14c Number Plates"]
#define SUB_NOTIFY [CAT, "16 Notifications"]
#define SUB_DEBUG [CAT, "17 Debug"]

// ---------------------------------------------------------------- General
[QGVAR(enabled), "CHECKBOX", ["Enable RADS", "Master switch. When off, all covered players are released to vanilla detection."], SUB_GEN, true, true] call CBA_fnc_addSetting;
[QGVAR(coverWest), "CHECKBOX", ["Cover BLUFOR units", "BLUFOR players (and their AI passengers) can go undercover in vehicles."], SUB_GEN, true, true] call CBA_fnc_addSetting;
[QGVAR(coverEast), "CHECKBOX", ["Cover OPFOR units", "OPFOR players can go undercover in vehicles."], SUB_GEN, false, true] call CBA_fnc_addSetting;
[QGVAR(coverGuer), "CHECKBOX", ["Cover INDFOR units", "Independent players can go undercover in vehicles."], SUB_GEN, false, true] call CBA_fnc_addSetting;
[QGVAR(coverAIPassengers), "CHECKBOX", ["Cover AI passengers", "AI of a covered side riding in a covered player's vehicle are covered too (otherwise the AI would engage the vehicle because of them)."], SUB_GEN, true, true] call CBA_fnc_addSetting;
[QGVAR(tickInterval), "SLIDER", ["Evaluation interval (s)", "How often each AI group re-evaluates covered units. Lower = more responsive, more CPU."], SUB_GEN, [0.25, 5, 1, 2], true] call CBA_fnc_addSetting;
[QGVAR(groupsPerFrame), "SLIDER", ["Groups per frame", "Performance budget: max AI groups evaluated per frame (work is spread over frames)."], SUB_GEN, [1, 50, 6, 0], true] call CBA_fnc_addSetting;
[QGVAR(maxRange), "SLIDER", ["Maximum observation range (m)", "Beyond this distance an AI group cannot build suspicion at all."], SUB_GEN, [50, 3000, 800, 0], true] call CBA_fnc_addSetting;
[QGVAR(maxObservers), "SLIDER", ["Observers per group", "Max units per group (closest first) checked for line of sight each evaluation."], SUB_GEN, [1, 12, 4, 0], true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Cover eligibility
[QGVAR(allowCivVeh), "CHECKBOX", ["Civilian vehicles give cover", "Vehicles whose config side is civilian disguise the occupants."], SUB_ELIG, true, true] call CBA_fnc_addSetting;
[QGVAR(allowFriendlyVeh), "CHECKBOX", ["Observer-side vehicles give cover", "Vehicles belonging to a side friendly to the observing AI (e.g. an OPFOR vehicle seen by OPFOR) disguise the occupants."], SUB_ELIG, true, true] call CBA_fnc_addSetting;
[QGVAR(allowAir), "CHECKBOX", ["Aircraft give cover", "Allow disguise in qualifying helicopters and planes."], SUB_ELIG, true, true] call CBA_fnc_addSetting;
[QGVAR(allowBoats), "CHECKBOX", ["Boats give cover", "Allow disguise in qualifying boats."], SUB_ELIG, true, true] call CBA_fnc_addSetting;
[QGVAR(openVehicleMode), "LIST", ["Open vehicles", "Quads, bikes, karts, open boats... the occupant is in plain view."], SUB_ELIG, [[0, 1], ["Allowed with exposure penalty", "No cover"], 0], true] call CBA_fnc_addSetting;
[QGVAR(openVehicleClasses), "EDITBOX", ["Open vehicle classes", "Comma-separated base classes treated as open vehicles (isKindOf)."], SUB_ELIG, "Quadbike_01_base_F,Kart_01_Base_F,Motorcycle,Bicycle,Rubber_duck_base_F,LSV_01_light_base_F,LSV_02_unarmed_base_F", true] call CBA_fnc_addSetting;
[QGVAR(vehWhitelist), "EDITBOX", ["Always-disguise vehicles", "Comma-separated classes (isKindOf) that always disguise, regardless of side."], SUB_ELIG, "", true] call CBA_fnc_addSetting;
[QGVAR(vehBlacklist), "EDITBOX", ["Never-disguise vehicles", "Comma-separated classes (isKindOf) that never disguise."], SUB_ELIG, "", true] call CBA_fnc_addSetting;
[QGVAR(mixedCrewMode), "LIST", ["Mixed crew", "Occupants that are not covered (exempt players, AI of other sides) in the same vehicle."], SUB_ELIG, [[0, 1, 2], ["Ignore", "Exposure penalty", "Void cover for everyone"], 1], true] call CBA_fnc_addSetting;
[QGVAR(captiveStandDown), "CHECKBOX", ["Stand down for captive units", "If a mission or another undercover script sets a unit captive, RADS leaves it alone."], SUB_ELIG, true, true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Entry classification
[QGVAR(witnessKA), "SLIDER", ["Witness knowledge", "knowsAbout (0-4) at or above which a group that recently saw the player keeps full knowledge after vehicle entry."], SUB_ENTRY, [0, 4, 1.5, 2], true] call CBA_fnc_addSetting;
[QGVAR(witnessWindow), "SLIDER", ["Witness window (s)", "A group that saw the player within this many seconds of entry counts as a witness."], SUB_ENTRY, [0, 60, 6, 0], true] call CBA_fnc_addSetting;
[QGVAR(combatWindow), "SLIDER", ["Combat window (s)", "A group the player threatened within this many seconds keeps fighting through the vehicle entry."], SUB_ENTRY, [0, 180, 20, 0], true] call CBA_fnc_addSetting;
[QGVAR(seedFactor), "SLIDER", ["Seed from old knowledge", "Fraction of a group's existing (non-witness) knowledge converted into starting suspicion."], SUB_ENTRY, [0, 1, 0.6, 0, true], true] call CBA_fnc_addSetting;
[QGVAR(searchingBuildMult), "SLIDER", ["Searching build multiplier", "Groups that recently knew the player (searching) build suspicion this much faster."], SUB_ENTRY, [1, 5, 1.5, 2], true] call CBA_fnc_addSetting;
[QGVAR(coverGraceTime), "SLIDER", ["Entry sync delay (s)", "Remote machines wait this long after a cover change before lazily classifying, so the entry snapshot wins."], SUB_ENTRY, [0, 5, 2, 1], true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Suspicion build
[QGVAR(buildRate), "SLIDER", ["Build rate (%/s)", "Suspicion gained per second at full exposure. 100 = identified."], SUB_BUILD, [1, 100, 12, 1], true] call CBA_fnc_addSetting;
[QGVAR(decayRate), "SLIDER", ["Decay rate (%/s)", "Suspicion lost per second while not exposed."], SUB_BUILD, [0, 50, 1.5, 1], true] call CBA_fnc_addSetting;
[QGVAR(suspiciousThreshold), "SLIDER", ["Suspicious threshold (%)", "Group becomes SUSPICIOUS (optional AI reactions, player warning)."], SUB_BUILD, [1, 99, 35, 0], true] call CBA_fnc_addSetting;
[QGVAR(identifyThreshold), "SLIDER", ["Identify threshold (%)", "Group identifies the player and engages."], SUB_BUILD, [10, 100, 100, 0], true] call CBA_fnc_addSetting;
[QGVAR(identifyRange), "SLIDER", ["Close identification range (m)", "Inside this range distance does not reduce exposure."], SUB_BUILD, [5, 500, 40, 0], true] call CBA_fnc_addSetting;
[QGVAR(distanceCurve), "SLIDER", ["Distance falloff exponent", "Beyond close identification range exposure is (close range / distance) ^ this. 1.5 with 40 m: 0.35 at 80 m, 0.09 at 200 m, 0.03 at 400 m. Higher = drops faster."], SUB_BUILD, [0.25, 4, 1.5, 2], true] call CBA_fnc_addSetting;
[QGVAR(instantRange), "SLIDER", ["Face-to-face range (m)", "Within this range an observer looking into the vehicle gets a large bonus."], SUB_BUILD, [0, 100, 6, 1], true] call CBA_fnc_addSetting;
[QGVAR(instantMult), "SLIDER", ["Face-to-face multiplier", "Exposure multiplier inside face-to-face range."], SUB_BUILD, [1, 10, 4, 1], true] call CBA_fnc_addSetting;
[QGVAR(minCloseExposure), "SLIDER", ["Minimum close exposure", "Minimum visibility assumed inside face-to-face range even through a closed hull."], SUB_BUILD, [0, 1, 0.4, 0, true], true] call CBA_fnc_addSetting;
[QGVAR(hullBlocks), "CHECKBOX", ["Vehicle hull blocks sight", "Ray-cast respects the vehicle's own view geometry (glass lets partial sight through). Off = only terrain/objects block."], SUB_BUILD, true, true] call CBA_fnc_addSetting;
[QGVAR(stationaryTime), "SLIDER", ["Loitering ramp time (s)", "Time stationary near a group to reach the maximum loitering bonus."], SUB_BUILD, [5, 300, 30, 0], true] call CBA_fnc_addSetting;
[QGVAR(stationaryMult), "SLIDER", ["Loitering max multiplier", "Exposure multiplier when parked near the group for the full ramp time."], SUB_BUILD, [1, 5, 2.5, 2], true] call CBA_fnc_addSetting;
[QGVAR(passBonus), "SLIDER", ["Repeated-pass bonus", "Extra exposure multiplier per separate pass in view (circling, repeated drive-bys)."], SUB_BUILD, [0, 2, 0.25, 2], true] call CBA_fnc_addSetting;
[QGVAR(passMax), "SLIDER", ["Repeated-pass cap", "Maximum multiplier from repeated passes."], SUB_BUILD, [1, 5, 2.5, 2], true] call CBA_fnc_addSetting;
[QGVAR(passGap), "SLIDER", ["Pass separation (s)", "Out-of-view time needed before the next sighting counts as a new pass."], SUB_BUILD, [2, 120, 10, 0], true] call CBA_fnc_addSetting;
[QGVAR(sameVehicleInstant), "CHECKBOX", ["Hostile AI in same vehicle = identified", "An enemy AI riding in the same vehicle identifies covered occupants instantly."], SUB_BUILD, true, true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Observer factors
[QGVAR(fovAngle), "SLIDER", ["Observer field of view (deg)", "Full cone angle in which an observer is looking at the vehicle."], SUB_OBS, [30, 360, 140, 0], true] call CBA_fnc_addSetting;
[QGVAR(peripheralMult), "SLIDER", ["Peripheral vision", "Exposure multiplier when outside the field of view."], SUB_OBS, [0, 1, 0.15, 0, true], true] call CBA_fnc_addSetting;
[QGVAR(behSafe), "SLIDER", ["Relaxed (SAFE/CARELESS) multiplier", "Exposure multiplier for relaxed observers."], SUB_OBS, [0, 3, 0.7, 2], true] call CBA_fnc_addSetting;
[QGVAR(behAware), "SLIDER", ["AWARE multiplier", "Exposure multiplier for alert observers."], SUB_OBS, [0, 3, 1, 2], true] call CBA_fnc_addSetting;
[QGVAR(behCombat), "SLIDER", ["COMBAT multiplier", "Exposure multiplier for observers in combat (distracted by the fight)."], SUB_OBS, [0, 3, 0.5, 2], true] call CBA_fnc_addSetting;
[QGVAR(behStealth), "SLIDER", ["STEALTH multiplier", "Exposure multiplier for observers in stealth mode."], SUB_OBS, [0, 3, 1.2, 2], true] call CBA_fnc_addSetting;
[QGVAR(skillInfluence), "SLIDER", ["Skill influence", "How much AI spotDistance/spotTime skill scales exposure (±)."], SUB_OBS, [0, 1, 0.5, 0, true], true] call CBA_fnc_addSetting;
[QGVAR(engagedElsewhereMult), "SLIDER", ["Busy fighting multiplier", "Exposure multiplier when the group is currently fighting another known enemy."], SUB_OBS, [0, 2, 0.6, 2], true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Environment
[QGVAR(nightMult), "SLIDER", ["Night visibility", "Exposure multiplier at full darkness (scaled by sun/moon light)."], SUB_ENV, [0, 1, 0.45, 0, true], true] call CBA_fnc_addSetting;
[QGVAR(nvgNightMult), "SLIDER", ["Night visibility with NVG", "Night multiplier for observers using night vision."], SUB_ENV, [0, 1, 0.85, 0, true], true] call CBA_fnc_addSetting;
[QGVAR(fogInfluence), "SLIDER", ["Fog influence", "How strongly fog reduces exposure."], SUB_ENV, [0, 1, 0.6, 0, true], true] call CBA_fnc_addSetting;
[QGVAR(rainInfluence), "SLIDER", ["Rain influence", "How strongly rain reduces exposure."], SUB_ENV, [0, 1, 0.3, 0, true], true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Seat & vehicle
[QGVAR(seatDriver), "SLIDER", ["Driver seat", "Exposure multiplier for drivers."], SUB_SEAT, [0, 3, 1, 2], true] call CBA_fnc_addSetting;
[QGVAR(seatCargo), "SLIDER", ["Passenger seat", "Exposure multiplier for passengers."], SUB_SEAT, [0, 3, 0.7, 2], true] call CBA_fnc_addSetting;
[QGVAR(seatTurret), "SLIDER", ["Turret seat", "Exposure multiplier for gunners/commanders."], SUB_SEAT, [0, 3, 1.1, 2], true] call CBA_fnc_addSetting;
[QGVAR(seatTurnedOut), "SLIDER", ["Turned out", "Exposure multiplier when turned out."], SUB_SEAT, [0, 5, 2, 2], true] call CBA_fnc_addSetting;
[QGVAR(seatFFV), "SLIDER", ["Firing from vehicle position", "Exposure multiplier in FFV seats where the weapon is usable."], SUB_SEAT, [0, 5, 2.5, 2], true] call CBA_fnc_addSetting;
[QGVAR(openVehicleMult), "SLIDER", ["Open vehicle multiplier", "Exposure multiplier for open vehicles (if allowed)."], SUB_SEAT, [1, 10, 2.5, 2], true] call CBA_fnc_addSetting;
[QGVAR(civVehMult), "SLIDER", ["Civilian vehicle multiplier", "Exposure multiplier in civilian vehicles."], SUB_SEAT, [0, 3, 1, 2], true] call CBA_fnc_addSetting;
[QGVAR(friendlyVehMult), "SLIDER", ["Observer-side vehicle multiplier", "Exposure multiplier in vehicles friendly to the observer (they expect their own people)."], SUB_SEAT, [0, 3, 0.8, 2], true] call CBA_fnc_addSetting;
[QGVAR(fastSpeed), "SLIDER", ["Fast pass speed (km/h)", "Above this speed a drive-by gives limited exposure."], SUB_SEAT, [10, 200, 50, 0], true] call CBA_fnc_addSetting;
[QGVAR(fastMult), "SLIDER", ["Fast pass multiplier", "Exposure multiplier above the fast pass speed."], SUB_SEAT, [0, 1, 0.4, 0, true], true] call CBA_fnc_addSetting;
[QGVAR(altitudeFalloff), "SLIDER", ["Aircraft altitude falloff (m)", "Aircraft above this altitude (ATL) get proportionally less exposure."], SUB_SEAT, [10, 1000, 60, 0], true] call CBA_fnc_addSetting;
[QGVAR(damageInfluence), "SLIDER", ["Damaged vehicle influence", "Visibly damaged vehicles (body, glass, wheels, burning) build suspicion faster: multiplier = 1 + visible damage x this."], SUB_SEAT, [0, 5, 2, 2], true] call CBA_fnc_addSetting;
[QGVAR(damageVisibleAt), "SLIDER", ["Instantly suspicious from damage", "A vehicle seen with at least this much visible damage makes the observing group SUSPICIOUS at once. 100% = off."], SUB_SEAT, [0, 1, 0.15, 0, true], true] call CBA_fnc_addSetting;
[QGVAR(damageFloorScale), "SLIDER", ["Damage suspicion floor", "How far above the suspicious threshold heavy damage pushes suspicion (share of the gap to identification, scaled by damage)."], SUB_SEAT, [0, 1, 0.6, 0, true], true] call CBA_fnc_addSetting;
[QGVAR(mixedCrewMult), "SLIDER", ["Mixed crew multiplier", "Exposure multiplier per uncovered occupant (Mixed crew = penalty)."], SUB_SEAT, [1, 5, 1.5, 2], true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Gear
[QGVAR(gearEnabled), "CHECKBOX", ["Gear affects suspicion", "Uniform, headgear, vest and visible weapons modify how fast suspicion builds."], SUB_GEAR, true, true] call CBA_fnc_addSetting;
[QGVAR(uniformCivMult), "SLIDER", ["Civilian clothes", "Exposure multiplier wearing a civilian uniform."], SUB_GEAR, [0, 3, 0.6, 2], true] call CBA_fnc_addSetting;
[QGVAR(uniformObserverMult), "SLIDER", ["Observer-side uniform", "Exposure multiplier wearing the observer's (friendly to observer) uniform."], SUB_GEAR, [0, 3, 0.5, 2], true] call CBA_fnc_addSetting;
[QGVAR(uniformHostileMult), "SLIDER", ["Hostile military uniform", "Exposure multiplier wearing a military uniform hostile to the observer (e.g. own BLUFOR uniform)."], SUB_GEAR, [0, 5, 1.6, 2], true] call CBA_fnc_addSetting;
[QGVAR(helmetMult), "SLIDER", ["Ballistic headgear", "Exposure multiplier wearing armored headgear."], SUB_GEAR, [0, 3, 1.25, 2], true] call CBA_fnc_addSetting;
[QGVAR(vestMult), "SLIDER", ["Armored vest", "Exposure multiplier wearing an armored vest."], SUB_GEAR, [0, 3, 1.2, 2], true] call CBA_fnc_addSetting;
[QGVAR(nvgDayMult), "SLIDER", ["NVG worn in daylight", "Exposure multiplier for night vision on the head during the day."], SUB_GEAR, [0, 3, 1.3, 2], true] call CBA_fnc_addSetting;
[QGVAR(weaponVisibleMult), "SLIDER", ["Visible weapon", "Exposure multiplier when a primary weapon/launcher is visible (exposed seat or open vehicle)."], SUB_GEAR, [0, 5, 1.5, 2], true] call CBA_fnc_addSetting;
[QGVAR(gearVisibleRange), "SLIDER", ["Gear readable range (m)", "Gear multipliers apply fully within this distance and fade out by twice this distance (nobody can read a driver's uniform at 200 m)."], SUB_GEAR, [5, 500, 50, 0], true] call CBA_fnc_addSetting;
[QGVAR(gearNeutral), "EDITBOX", ["Neutral gear", "Comma-separated item classes ignored by gear checks."], SUB_GEAR, "", true] call CBA_fnc_addSetting;
[QGVAR(gearVoidsCover), "CHECKBOX", ["Hostile gear voids cover", "Units wearing the gear ticked below get no cover in vehicles: vanilla detection and instant combat. On foot is always vanilla."], SUB_GEAR, false, true] call CBA_fnc_addSetting;
[QGVAR(gearVoidUniform), "CHECKBOX", ["Void: own military uniform", "Wearing a military uniform of a covered side (e.g. BLUFOR fatigues)."], SUB_GEAR, true, true] call CBA_fnc_addSetting;
[QGVAR(gearVoidHelmet), "CHECKBOX", ["Void: ballistic helmet", "Wearing armored headgear."], SUB_GEAR, true, true] call CBA_fnc_addSetting;
[QGVAR(gearVoidVest), "CHECKBOX", ["Void: armored vest", "Wearing an armored vest."], SUB_GEAR, true, true] call CBA_fnc_addSetting;
[QGVAR(gearVoidWeapon), "CHECKBOX", ["Void: visible weapon", "Carrying a rifle/launcher in a seat that shows it (turned out, firing position, open vehicle)."], SUB_GEAR, true, true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Player behaviour
[QGVAR(speedingSpeed), "SLIDER", ["Speeding near AI (km/h)", "Driving faster than this within 100 m of a group is suspicious."], SUB_DRIVE, [10, 200, 70, 0], true] call CBA_fnc_addSetting;
[QGVAR(speedingMult), "SLIDER", ["Speeding multiplier", "Exposure multiplier when speeding near the group."], SUB_DRIVE, [1, 5, 1.3, 2], true] call CBA_fnc_addSetting;
[QGVAR(offroadMult), "SLIDER", ["Off-road approach multiplier", "Exposure multiplier when driving off-road within 150 m of the group."], SUB_DRIVE, [1, 5, 1.2, 2], true] call CBA_fnc_addSetting;
[QGVAR(lightsOffMult), "SLIDER", ["Lights off at night multiplier", "Exposure multiplier for a moving vehicle with headlights off at night."], SUB_DRIVE, [1, 5, 1.4, 2], true] call CBA_fnc_addSetting;
[QGVAR(hornMult), "SLIDER", ["Horn multiplier", "Exposure multiplier for 10 s after honking nearby."], SUB_DRIVE, [1, 5, 1.5, 2], true] call CBA_fnc_addSetting;
[QGVAR(aimMult), "SLIDER", ["Aiming at AI multiplier", "Exposure multiplier when the player/turret is aiming at the observer."], SUB_DRIVE, [1, 10, 2.5, 2], true] call CBA_fnc_addSetting;
[QGVAR(aimAngle), "SLIDER", ["Aiming cone (deg)", "Half-angle within which a weapon counts as aimed at an observer."], SUB_DRIVE, [1, 45, 8, 0], true] call CBA_fnc_addSetting;
[QGVAR(lightMult), "SLIDER", ["Weapon light/laser at night", "Exposure multiplier when a weapon flashlight or laser is on at night."], SUB_DRIVE, [1, 5, 2, 2], true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Hostile acts
[QGVAR(firedBlows), "CHECKBOX", ["Firing blows cover", "Firing a weapon from cover compromises nearby groups and groups with line of sight."], SUB_HOSTILE, true, true] call CBA_fnc_addSetting;
[QGVAR(firedRadius), "SLIDER", ["Firing reveal radius (m)", "Groups within this radius of an unsuppressed shot are compromised."], SUB_HOSTILE, [0, 2000, 300, 0], true] call CBA_fnc_addSetting;
[QGVAR(firedRadiusSuppressed), "SLIDER", ["Suppressed reveal radius (m)", "Same, for suppressed weapons."], SUB_HOSTILE, [0, 500, 40, 0], true] call CBA_fnc_addSetting;
[QGVAR(firedLOS), "CHECKBOX", ["Seen firing = compromised", "Any group with line of sight to the shooter (within max range) is compromised."], SUB_HOSTILE, true, true] call CBA_fnc_addSetting;
[QGVAR(heatDuration), "SLIDER", ["Heat after firing (s)", "After firing, the unit cannot regain cover for this long. 0 = disabled."], SUB_HOSTILE, [0, 1800, 120, 0], true] call CBA_fnc_addSetting;
[QGVAR(damageBlows), "CHECKBOX", ["Hurting AI blows cover", "When a covered unit (or its vehicle) damages an AI, that AI's group reacts."], SUB_HOSTILE, true, true] call CBA_fnc_addSetting;
[QGVAR(damageNeedsLOS), "CHECKBOX", ["Victim group must see attacker", "Without line of sight the victim's group only becomes SEARCHING instead of identifying the attacker."], SUB_HOSTILE, true, true] call CBA_fnc_addSetting;
[QGVAR(damageSuspicion), "SLIDER", ["Unseen attack suspicion (%)", "Suspicion given to the victim's group when the attacker was not seen."], SUB_HOSTILE, [0, 99, 70, 0], true] call CBA_fnc_addSetting;
[QGVAR(vehicleAttackedBlows), "CHECKBOX", ["Vehicle attacked by AI blows cover", "If hostile AI shoot a covered vehicle anyway (e.g. it is a threat), the shooters' group identifies the occupants."], SUB_HOSTILE, false, true] call CBA_fnc_addSetting;
[QGVAR(compromiseCrew), "CHECKBOX", ["Compromise whole crew", "Identifying one occupant identifies every covered occupant of that vehicle for that group."], SUB_HOSTILE, true, true] call CBA_fnc_addSetting;
[QGVAR(revealKA), "SLIDER", ["Reveal knowledge on identification", "knowsAbout (0-4) given when a group identifies a unit."], SUB_HOSTILE, [0.5, 4, 4, 2], true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Memory
[QGVAR(forgetAfter), "SLIDER", ["Forget after (s)", "A compromised group that has not seen the unit for this long forgets it (forgetTarget) and the disguise works again."], SUB_MEM, [10, 1800, 180, 0], true] call CBA_fnc_addSetting;
[QGVAR(recoverThreshold), "SLIDER", ["Calm-down threshold (%)", "SUSPICIOUS/SEARCHING groups return to UNAWARE below this suspicion."], SUB_MEM, [0, 50, 10, 0], true] call CBA_fnc_addSetting;
[QGVAR(memoryTime), "SLIDER", ["Memory after exit (s)", "Suspicion is remembered this long after the unit leaves the vehicle (exit and re-enter does not reset it)."], SUB_MEM, [0, 3600, 600, 0], true] call CBA_fnc_addSetting;
[QGVAR(exitRevealThreshold), "SLIDER", ["Exit reveal threshold (%)", "Leaving the vehicle in view of a group at or above this suspicion reveals the unit to it."], SUB_MEM, [0, 100, 50, 0], true] call CBA_fnc_addSetting;
[QGVAR(targetAge), "LIST", ["Age knowledge on loss of contact", "Optionally calls setTargetAge on a compromised unit when it breaks contact. Affects every side's knowledge."], SUB_MEM, [["", "ACTUAL", "5 MIN", "10 MIN", "15 MIN", "30 MIN", "60 MIN", "UNKNOWN"], ["Disabled", "Actual", "5 min", "10 min", "15 min", "30 min", "60 min", "Unknown"], 0], true] call CBA_fnc_addSetting;
[QGVAR(targetAgeDelay), "SLIDER", ["Age knowledge after (s)", "Time without contact before the target age is applied."], SUB_MEM, [5, 600, 60, 0], true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Sharing
[QGVAR(shareMode), "LIST", ["Share on identification", "What nearby friendly groups learn when a group identifies a unit."], SUB_SHARE, [[0, 1, 2], ["Nothing", "Suspicion (they start searching)", "Full identification"], 1], true] call CBA_fnc_addSetting;
[QGVAR(shareRadius), "SLIDER", ["Share radius (m)", "Groups of the same side within this radius receive the information."], SUB_SHARE, [0, 3000, 300, 0], true] call CBA_fnc_addSetting;
[QGVAR(shareDelay), "SLIDER", ["Share delay (s)", "Delay before the information arrives. Killing the whole group first prevents it."], SUB_SHARE, [0, 120, 5, 0], true] call CBA_fnc_addSetting;
[QGVAR(shareKA), "SLIDER", ["Shared knowledge", "knowsAbout (0-4) given on full share."], SUB_SHARE, [0.1, 4, 1.5, 2], true] call CBA_fnc_addSetting;
[QGVAR(shareSuspicion), "SLIDER", ["Shared suspicion (%)", "Starting suspicion given on suspicion share."], SUB_SHARE, [0, 99, 60, 0], true] call CBA_fnc_addSetting;
[QGVAR(shareNeedsRadio), "CHECKBOX", ["Sharing needs a radio", "The identifying group needs at least one unit with a radio to share."], SUB_SHARE, false, true] call CBA_fnc_addSetting;
[QGVAR(shareInstantRadius), "SLIDER", ["Instant identification radius (m)", "Groups this close to an identifying group identify the unit at once (they see/hear the reaction). 0 = off."], SUB_SHARE, [0, 1000, 150, 0], true] call CBA_fnc_addSetting;
[QGVAR(shareEscalate), "CHECKBOX", ["Suspicious groups confirm on share", "A group that is already SUSPICIOUS or SEARCHING identifies the unit when it receives a share."], SUB_SHARE, true, true] call CBA_fnc_addSetting;
[QGVAR(burnOnIdentify), "CHECKBOX", ["Identified vehicle is burned locally", "The vehicle a unit was identified in is recognised on sight by that side nearby (see range)."], SUB_SHARE, true, true] call CBA_fnc_addSetting;
[QGVAR(burnOnIdentifyRange), "SLIDER", ["Local burn range (m)", "Distance from the identification within which that side recognises the vehicle. 0 = side-wide."], SUB_SHARE, [0, 10000, 1500, 0], true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Radio bulletins
[QGVAR(bulletinEnabled), "CHECKBOX", ["Enable radio bulletins", "On identification a radioman may broadcast the unit/vehicle over long range."], SUB_RADIO, true, true] call CBA_fnc_addSetting;
[QGVAR(bulletinChance), "SLIDER", ["Bulletin chance", "Chance per identifying group that a bulletin is sent."], SUB_RADIO, [0, 1, 0.1, 0, true], true] call CBA_fnc_addSetting;
[QGVAR(bulletinOnHostile), "CHECKBOX", ["Also roll on hostile acts", "Groups compromised by gunfire/attacks also roll for a bulletin."], SUB_RADIO, true, true] call CBA_fnc_addSetting;
[QGVAR(radiomanMode), "LIST", ["Who can send", "Which units count as a radioman."], SUB_RADIO, [[0, 1, 2, 3], ["Radio backpack / radioman class", "Above or any unit with a radio", "Group leader only", "Anyone (no radioman needed)"], 1], true] call CBA_fnc_addSetting;
[QGVAR(radioBackpacks), "EDITBOX", ["Radio backpacks", "Comma-separated backpack classes (isKindOf) that make a radioman."], SUB_RADIO, "B_RadioBag_01_base_F,TFAR_Bag_Base,ACRE_PRC117F,ACRE_PRC77", true] call CBA_fnc_addSetting;
[QGVAR(radiomanClasses), "EDITBOX", ["Radioman classes", "Comma-separated unit classes (isKindOf). Units whose class contains 'radio' always count."], SUB_RADIO, "", true] call CBA_fnc_addSetting;
[QGVAR(bulletinDelayMin), "SLIDER", ["Bulletin delay min (s)", "Minimum time to send. Killing/knocking out the radioman first cancels it."], SUB_RADIO, [0, 300, 10, 0], true] call CBA_fnc_addSetting;
[QGVAR(bulletinDelayMax), "SLIDER", ["Bulletin delay max (s)", "Maximum time to send."], SUB_RADIO, [0, 600, 30, 0], true] call CBA_fnc_addSetting;
[QGVAR(bulletinRange), "SLIDER", ["Bulletin range (m)", "Groups beyond this distance from the sender do not get it. 0 = side-wide."], SUB_RADIO, [0, 30000, 5000, 0], true] call CBA_fnc_addSetting;
[QGVAR(bulletinBurn), "CHECKBOX", ["Bulletin burns the vehicle", "Receiving groups recognize the vehicle on sight and engage its covered occupants immediately."], SUB_RADIO, true, true] call CBA_fnc_addSetting;
[QGVAR(burnDuration), "SLIDER", ["Burned vehicle duration (s)", "How long a vehicle stays burned."], SUB_RADIO, [30, 7200, 900, 0], true] call CBA_fnc_addSetting;
[QGVAR(bulletinWanted), "CHECKBOX", ["Bulletin marks unit as wanted", "Receiving side builds suspicion faster against that unit in any vehicle."], SUB_RADIO, true, true] call CBA_fnc_addSetting;
[QGVAR(wantedDuration), "SLIDER", ["Wanted duration (s)", "How long the wanted status lasts."], SUB_RADIO, [30, 7200, 600, 0], true] call CBA_fnc_addSetting;
[QGVAR(wantedMult), "SLIDER", ["Wanted multiplier", "Suspicion build multiplier against wanted units."], SUB_RADIO, [1, 10, 2, 2], true] call CBA_fnc_addSetting;
[QGVAR(bulletinAreaAlert), "CHECKBOX", ["Bulletin alerts the area", "Groups near the reported position start SEARCHING."], SUB_RADIO, true, true] call CBA_fnc_addSetting;
[QGVAR(areaAlertRadius), "SLIDER", ["Area alert radius (m)", "Radius around the reported position."], SUB_RADIO, [0, 5000, 600, 0], true] call CBA_fnc_addSetting;
[QGVAR(areaAlertAware), "CHECKBOX", ["Area alert sets AWARE", "Alerted groups that are SAFE/CARELESS switch to AWARE."], SUB_RADIO, true, true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Informants / theft
[QGVAR(informantsEnabled), "CHECKBOX", ["Civilian informants", "Civilian AI who witness a hostile act may report it to the nearest hostile force."], SUB_INFORM, false, true] call CBA_fnc_addSetting;
[QGVAR(informantChance), "SLIDER", ["Informant chance", "Chance per witnessing civilian group."], SUB_INFORM, [0, 1, 0.15, 0, true], true] call CBA_fnc_addSetting;
[QGVAR(informantDelay), "SLIDER", ["Informant delay (s)", "Time to make the report. Cancelled if the informant dies."], SUB_INFORM, [0, 600, 45, 0], true] call CBA_fnc_addSetting;
[QGVAR(informantRange), "SLIDER", ["Informant witness range (m)", "Max distance a civilian can witness from."], SUB_INFORM, [10, 1000, 200, 0], true] call CBA_fnc_addSetting;
[QGVAR(theftEnabled), "CHECKBOX", ["Stolen vehicles", "Taking a vehicle last crewed by an AI group burns it for that side if its owners are nearby or see it."], SUB_INFORM, true, true] call CBA_fnc_addSetting;
[QGVAR(theftRadius), "SLIDER", ["Theft witness radius (m)", "Owners within this distance always notice the theft."], SUB_INFORM, [0, 500, 50, 0], true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Ramming / vehicle swaps
[QGVAR(ramDetect), "CHECKBOX", ["Detect ramming", "A covered vehicle driving into or over hostile AI alerts their group at once."], SUB_RAM, true, true] call CBA_fnc_addSetting;
[QGVAR(ramSpeed), "SLIDER", ["Ramming speed (km/h)", "Minimum speed for contact to count as ramming."], SUB_RAM, [1, 60, 5, 0], true] call CBA_fnc_addSetting;
[QGVAR(ramSuspicion), "SLIDER", ["Ramming suspicion (%)", "Suspicion given to the rammed group (they become SUSPICIOUS at least)."], SUB_RAM, [0, 99, 50, 0], true] call CBA_fnc_addSetting;
[QGVAR(ramCompromise), "CHECKBOX", ["Ramming = identified", "The rammed group identifies the driver outright instead of becoming suspicious."], SUB_RAM, false, true] call CBA_fnc_addSetting;
[QGVAR(swapForgive), "CHECKBOX", ["Fresh vehicle after identification", "An identified unit that gets into a different vehicle unseen is only suspected, not identified. The old vehicle stays known."], SUB_RAM, true, true] call CBA_fnc_addSetting;
[QGVAR(swapMinUnseen), "SLIDER", ["Unseen time before swap (s)", "The group must not have seen the unit for this long (and must not see it now) when it gets into the new vehicle."], SUB_RAM, [0, 300, 2, 0], true] call CBA_fnc_addSetting;
[QGVAR(swapBaseSuspicion), "SLIDER", ["Swap suspicion (%)", "Starting suspicion after the first vehicle swap."], SUB_RAM, [0, 99, 30, 0], true] call CBA_fnc_addSetting;
[QGVAR(swapPenalty), "SLIDER", ["Repeat swap penalty (%)", "Extra starting suspicion per previous swap. Once it reaches the identify threshold, swapping no longer works."], SUB_RAM, [0, 100, 30, 0], true] call CBA_fnc_addSetting;
[QGVAR(swapMemory), "SLIDER", ["Swap memory (s)", "How long a group remembers previous swaps."], SUB_RAM, [60, 7200, 900, 0], true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Number plates
[QGVAR(plateRecognition), "CHECKBOX", ["Recognise reported number plates", "A burned/reported vehicle's plate (ZEN Plate Number attribute, setPlateNumber) is reported too. Any vehicle carrying that plate is identified as soon as the plate is read, at any suspicion and on any vehicle side."], SUB_PLATE, true, true] call CBA_fnc_addSetting;
[QGVAR(plateReadRange), "SLIDER", ["Plate reading range (m)", "Observers must be this close (with line of sight) to read a plate."], SUB_PLATE, [5, 300, 50, 0], true] call CBA_fnc_addSetting;
[QGVAR(plateCombat), "CHECKBOX", ["Reported plate = COMBAT", "A group that reads a reported plate goes COMBAT at once."], SUB_PLATE, true, true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- AI reactions
[QGVAR(aiAware), "CHECKBOX", ["Suspicious groups go AWARE", "SAFE/CARELESS groups switch to AWARE while suspicious (restored when calm)."], SUB_AI, false, true] call CBA_fnc_addSetting;
[QGVAR(aiWatch), "CHECKBOX", ["Suspicious groups watch the vehicle", "Observers turn to watch the suspicious vehicle."], SUB_AI, false, true] call CBA_fnc_addSetting;
[QGVAR(aiInvestigate), "CHECKBOX", ["Suspicious groups investigate", "Group leader moves towards the vehicle when suspicion is high. Overrides waypoints temporarily."], SUB_AI, false, true] call CBA_fnc_addSetting;
[QGVAR(aiInvestigateMin), "SLIDER", ["Investigate threshold (%)", "Suspicion needed before investigating."], SUB_AI, [1, 99, 60, 0], true] call CBA_fnc_addSetting;
[QGVAR(aiInvestigateRange), "SLIDER", ["Investigate max distance (m)", "Only investigate vehicles within this distance."], SUB_AI, [10, 1000, 200, 0], true] call CBA_fnc_addSetting;
[QGVAR(aiCombatOnIdentify), "CHECKBOX", ["Identifying groups go COMBAT", "Set COMBAT behaviour on identification."], SUB_AI, false, true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Notifications (client-side unless noted)
[QGVAR(notifyCover), "CHECKBOX", ["Show cover status changes", "Hint when you gain or lose cover."], SUB_NOTIFY, true, false] call CBA_fnc_addSetting;
[QGVAR(notifyWatched), "CHECKBOX", ["Warn when watched", "Hint when an enemy group becomes suspicious of you."], SUB_NOTIFY, true, false] call CBA_fnc_addSetting;
[QGVAR(notifyCompromised), "CHECKBOX", ["Warn when identified", "Hint when an enemy group identifies you."], SUB_NOTIFY, true, false] call CBA_fnc_addSetting;
[QGVAR(notifyZeus), "CHECKBOX", ["Zeus notifications", "Curators get messages for identifications and radio bulletins."], SUB_NOTIFY, true, false] call CBA_fnc_addSetting;
[QGVAR(allowWatchedHints), "CHECKBOX", ["Allow suspicion feedback (server)", "Server permission for watched/identified hints and the ACE status suspicion readout."], SUB_NOTIFY, true, true] call CBA_fnc_addSetting;

// ---------------------------------------------------------------- Debug
[QGVAR(debugLog), "CHECKBOX", ["Debug log", "Write detailed RADS events to the RPT of the machine that owns the AI (server/HC) and of the player: identifications with full history, state changes, ramming, hits, shots, shares, bulletins, swaps, cover changes."], SUB_DEBUG, false, true] call CBA_fnc_addSetting;
[QGVAR(debugDetail), "LIST", ["Debug log detail", "What else is written besides events and identification reports."], SUB_DEBUG, [[0, 1, 2], ["Events and reports only", "Also large single jumps", "Every evaluation (very verbose)"], 1], true] call CBA_fnc_addSetting;
[QGVAR(debugJump), "SLIDER", ["Large jump threshold (%)", "With 'Also large single jumps', an evaluation that adds at least this much suspicion is logged on its own."], SUB_DEBUG, [1, 100, 8, 0], true] call CBA_fnc_addSetting;
[QGVAR(debugHistory), "SLIDER", ["History length", "Evaluations kept per group and unit and printed with every report (what led up to it)."], SUB_DEBUG, [1, 60, 15, 0], true] call CBA_fnc_addSetting;
[QGVAR(debugPublish), "CHECKBOX", ["Publish suspicion for debug", "Group owners broadcast suspicion every evaluation so overlays/Zeus inspect stay live (network cost)."], SUB_DEBUG, false, true] call CBA_fnc_addSetting;
[QGVAR(debugOverlay), "CHECKBOX", ["Debug overlay", "Draw each nearby group's suspicion toward you (needs 'Publish suspicion' for live values)."], SUB_DEBUG, false, false] call CBA_fnc_addSetting;
[QGVAR(showZoneMarkers), "CHECKBOX", ["Show zone markers", "Create map markers for detection zones (visible to everyone)."], SUB_DEBUG, false, true] call CBA_fnc_addSetting;
