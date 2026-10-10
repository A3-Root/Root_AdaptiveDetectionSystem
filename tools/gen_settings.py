"""
RADS settings generator.

One table below is the single source for:
  addons/main/initSettings.inc.sqf   (CBA settings, all text through stringtable keys)
  addons/main/stringtable.xml        (setting titles/tooltips + the UI strings in EXTRA)
  docs/SETTINGS.md                   (reference tables)

Run from the repository root:  python tools/gen_settings.py
Then: hemtt ln sort && hemtt check -p -Lc14 -e

Tooltip conventions (CBA shows the default value on the reset button and the variable name on
the last line by itself, so tooltips do not repeat either):
  line 1  what it does, in plain words
  line 2  Higher = ... / Lower = ...   (or what each state does)
  line 3  Example: a concrete situation with numbers
Multipliers: 1.0 = no change, 2.0 = suspicion builds twice as fast, 0.5 = half as fast.
"""
import os
import html

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NL = "\\n"  # literal \n: line break in Arma tooltips

CATS = []  # [(key, title, [settings])]


def cat(key, title):
    CATS.append((key, f"{len(CATS) + 1:02d} {title}", []))


def _add(entry):
    CATS[-1][2].append(entry)


def check(name, title, tip, default, glob=True):
    _add(dict(name=name, kind="CHECKBOX", title=title, tip=tip, default=default, glob=glob))


def slider(name, title, tip, lo, hi, default, dec=0, pct=False, glob=True):
    _add(dict(name=name, kind="SLIDER", title=title, tip=tip, lo=lo, hi=hi, default=default, dec=dec, pct=pct, glob=glob))


def edit(name, title, tip, default, glob=True):
    _add(dict(name=name, kind="EDITBOX", title=title, tip=tip, default=default, glob=glob))


def lst(name, title, tip, values, options, default_index, glob=True):
    _add(dict(name=name, kind="LIST", title=title, tip=tip, values=values, options=options, default=default_index, glob=glob))


def tip(*lines):
    return NL.join(lines)


MULT = "1.0 = no change, 2.0 = twice as fast, 0.5 = half as fast."

# ======================================================================= 01 Basics
cat("basics", "Basics")
check("enabled", "Enable RADS", tip(
    "Master switch for the whole undercover system.",
    "Off = every player is back to normal Arma detection right away (AI shoot on sight)."), True)
check("coverWest", "BLUFOR can go undercover", tip(
    "BLUFOR players (and their AI passengers) can hide their identity inside vehicles.",
    "Off = BLUFOR is always detected normally."), True)
check("coverEast", "OPFOR can go undercover", tip(
    "OPFOR players can hide their identity inside vehicles.",
    "Turn on when OPFOR is the player side."), True)
check("coverGuer", "INDFOR can go undercover", tip(
    "Independent players can hide their identity inside vehicles.",
    "Turn on when INDFOR is the player side."), True)
check("coverAIPassengers", "Cover AI passengers", tip(
    "AI soldiers of a covered side riding with an undercover player are undercover too.",
    "Off = enemy AI shoot at the vehicle because of the AI passenger."), True)
slider("tickInterval", "Check every (s)", tip(
    "How often each enemy group re-checks every undercover player.",
    "Lower = reacts faster but costs more CPU. Higher = cheaper but jumpier.",
    "Example: 1 = once per second (recommended)."), 0.25, 5, 1, 2)
slider("groupsPerFrame", "Groups checked per frame", tip(
    "Performance budget: how many enemy groups are checked in a single frame.",
    "Lower = smoother frame rate with many AI. Higher = every group is updated sooner.",
    "Leave at 6 unless you have hundreds of AI groups."), 1, 50, 6)
slider("maxRange", "Maximum spotting range (m)", tip(
    "Enemy AI farther away than this can never become suspicious of a vehicle.",
    "Lower = drive past distant positions freely. Higher = long-range observers matter.",
    "Example: 800 = a sniper team 1 km away ignores you."), 50, 3000, 800)
slider("maxObservers", "Observers checked per group", tip(
    "How many soldiers of each group (closest to the vehicle first) get a line-of-sight check.",
    "Higher = more accurate in big groups, costs more CPU."), 1, 12, 4)

# ======================================================================= 02 Who and what gets cover
cat("eligibility", "Who and What Gets Cover")
check("allowCivVeh", "Civilian vehicles give cover", tip(
    "Civilian cars, trucks, boats and aircraft disguise the people inside.",
    "Off = civilian vehicles do not hide anyone."), True)
check("allowFriendlyVeh", "Enemy-owned vehicles give cover", tip(
    "Vehicles of the watching AI's own or allied side disguise the people inside.",
    "Example: BLUFOR players in a captured OPFOR truck fool OPFOR."), True)
lst("allowHostileVeh", "Own-side vehicles give cover", tip(
    "Vehicles of a side the watching AI is at war with can still disguise the people inside,",
    "but suspicion builds much faster (see 'Vehicle Faction').",
    "Example: BLUFOR players in an unarmed BLUFOR Hunter at an OPFOR checkpoint."),
    [0, 1, 2], [("Never", "Your own side's vehicles are recognised and attacked on sight."),
                ("Unarmed vehicles only", "Trucks and unarmed cars can bluff their way through, gun trucks, APCs and tanks cannot."),
                ("All vehicles", "Even armed vehicles, tanks and APCs start undercover (not recommended for assaults).")], 2)
check("allowAir", "Aircraft give cover", tip(
    "Helicopters and planes can disguise the people inside.",
    "Off = aircraft never give cover."), True)
check("allowBoats", "Boats give cover", tip(
    "Boats can disguise the people inside.",
    "Off = boats never give cover."), True)
lst("openVehicleMode", "Open vehicles (quads, bikes...)", tip(
    "What happens in vehicles where everyone can see you (quad bikes, motorbikes, open boats)."),
    [0, 1], [("Cover, but easy to spot", "You get cover, but suspicion builds faster (see 'Open vehicle multiplier')."),
             ("No cover", "Riding an open vehicle never hides you.")], 1)
edit("openVehicleClasses", "Open vehicle classes", tip(
    "Comma-separated vehicle classes treated as open vehicles. Child classes are included.",
    "Example: Quadbike_01_base_F,Motorcycle"),
    "Quadbike_01_base_F,Kart_01_Base_F,Motorcycle,Bicycle,Rubber_duck_base_F,LSV_01_light_base_F,LSV_02_unarmed_base_F")
edit("vehWhitelist", "Always-disguise vehicles", tip(
    "Comma-separated vehicle classes that always disguise, whatever their side.",
    "Example: C_Van_01_transport_F"), "")
edit("vehBlacklist", "Never-disguise vehicles", tip(
    "Comma-separated vehicle classes that never disguise anyone.",
    "Example: B_MRAP_01_F (the Hunter is too obviously NATO)."), "")
lst("mixedCrewMode", "Uncovered people in the vehicle", tip(
    "What happens when someone in the vehicle has no cover (an exempt player, AI of another side)."),
    [0, 1, 2], [("Ignore", "They do not affect the others."),
                ("Faster suspicion", "Each of them makes suspicion build faster (see 'Mixed crew multiplier')."),
                ("Nobody has cover", "One uncovered occupant blows the cover of the whole vehicle.")], 1)
check("captiveStandDown", "Leave captive units alone", tip(
    "If a mission or another undercover script makes a unit captive, RADS ignores it.",
    "Keep on when combining RADS with other undercover scripts."), True)

# ======================================================================= Getting in
cat("entry", "Getting Into a Vehicle")
slider("witnessKA", "Witness knowledge", tip(
    "A group that knows you this well (0-4, the engine's knowsAbout) and saw you just before you got in",
    "keeps full knowledge: getting into a car in front of them does not fool them."), 0, 4, 1.5, 2)
slider("witnessWindow", "Witness window (s)", tip(
    "A group that saw you within this many seconds before you got in counts as a witness."), 0, 60, 6)
slider("combatWindow", "Combat window (s)", tip(
    "A group you fought within this many seconds keeps fighting you after you get in."), 0, 180, 20)
slider("seedFactor", "Earlier knowledge becomes suspicion", tip(
    "Share of a group's earlier (non-witness) knowledge of you that turns into starting suspicion when you get in.",
    "0 = a clean slate every time. 1 = what they knew carries over fully."), 0, 1, 0.497727, 0, True)
slider("searchingBuildMult", "Searching groups build faster", tip(
    "Suspicion speed for groups that are already SEARCHING for you. " + MULT), 1, 5, 1.5, 2)
slider("coverGraceTime", "Entry sync delay (s)", tip(
    "Technical: other machines wait this long after you get in before judging you, so the entry snapshot is used.",
    "Leave at 2 unless told otherwise."), 0, 5, 2, 1)

# ======================================================================= 03 Suspicion build-up
cat("build", "How Fast Suspicion Builds")
slider("buildRate", "Base build speed (%/s)", tip(
    "Suspicion gained per second when an alert soldier gets a clear look at you up close.",
    "Higher = identified faster. Lower = more time to pass through.",
    "Example: 12 = about 8 s of a clear close look from 0 to 100%."), 1, 100, 12, 1)
slider("decayRate", "Calm-down speed (%/s)", tip(
    "Suspicion lost per second while nobody in the group can see you.",
    "Higher = they forget you fast. Lower = they stay wary longer.",
    "Example: 1.5 = from 60% back to 0% in 40 s out of sight."), 0, 50, 1.5, 1)
slider("suspiciousThreshold", "Suspicious at (%)", tip(
    "At this suspicion the group becomes SUSPICIOUS: it may go alert, watch you, and you get a warning hint.",
    "Lower = they react to you earlier."), 1, 99, 35)
slider("identifyThreshold", "Identified at (%)", tip(
    "At this suspicion the group sees through your disguise and attacks.",
    "Lower = cover breaks sooner. 100 = only at full suspicion."), 10, 100, 100)
slider("identifyRange", "Close look range (m)", tip(
    "Within this distance the AI sees you just as well as up close. Farther away it gets harder fast.",
    "Higher = suspicion builds from farther away.",
    "Example: 40 = full effect inside 40 m."), 5, 500, 40)
slider("distanceCurve", "Distance falloff", tip(
    "How quickly seeing you gets harder beyond the close look range: (close range / distance) ^ this.",
    "Higher = distance protects you more.",
    "Example: 1.5 with 40 m: 35% as effective at 80 m, 9% at 200 m, 3% at 400 m."), 0.25, 4, 1.5, 2)
slider("instantRange", "Face-to-face range (m)", tip(
    "Within this distance a soldier is looking straight into the vehicle (checkpoint, walking past).",
    "Higher = the face-to-face bonus starts farther away."), 0, 100, 6, 1)
slider("instantMult", "Face-to-face multiplier", tip(
    "How much faster suspicion builds inside face-to-face range. " + MULT,
    "Example: 4 = a guard at your window is four times as effective."), 1, 10, 2, 1)
slider("minCloseExposure", "Face-to-face minimum visibility", tip(
    "How well a guard at face-to-face range sees you even through a closed body (they can lean in).",
    "0 = a closed hull fully protects. 1 = always seen perfectly up close."), 0, 1, 0.25, 0, True)
check("hullBlocks", "Vehicle body blocks sight", tip(
    "Line of sight respects the vehicle itself: glass lets some sight through, doors and roof block it.",
    "Off = only terrain and buildings block sight, the vehicle is see-through."), True)
slider("stationaryTime", "Loitering ramp time (s)", tip(
    "How long you must stay parked near a group before the loitering penalty is at its maximum.",
    "Lower = parking near the enemy becomes suspicious sooner."), 5, 300, 30)
slider("stationaryMult", "Loitering maximum multiplier", tip(
    "How much faster suspicion builds when parked near a group for the full ramp time. " + MULT), 1, 5, 2.5, 2)
slider("passBonus", "Repeated pass bonus", tip(
    "Extra suspicion speed for each separate time you drive past the same group (circling, drive-bys).",
    "Example: 0.25 = second pass x1.25, third x1.5 ..."), 0, 2, 0.25, 2)
slider("passMax", "Repeated pass cap", tip(
    "The repeated pass bonus never goes above this multiplier."), 1, 5, 2.5, 2)
slider("passGap", "Time between passes (s)", tip(
    "You must be out of sight this long before the next sighting counts as a new pass."), 2, 120, 10)
check("sameVehicleInstant", "Enemy riding with you = identified", tip(
    "An enemy AI sitting in the same vehicle identifies everyone in it at once.",
    "Off = they build suspicion like everyone else."), True)

# ======================================================================= 04 Observers
cat("observers", "What the AI Can See")
slider("fovAngle", "Field of view (deg)", tip(
    "Width of the cone a soldier is really looking at. Outside it only peripheral vision applies.",
    "Example: 140 = roughly what a person takes in without turning their head."), 30, 360, 140)
slider("peripheralMult", "Peripheral vision", tip(
    "How well a soldier notices you outside their field of view.",
    "0 = not at all. 1 = as well as looking straight at you."), 0, 1, 0.10247, 0, True)
slider("nearAwareRange", "Notices anything this close (m)", tip(
    "Within this distance the field of view does not matter: a vehicle parked right beside a soldier or",
    "a vehicle crew is noticed even outside their view cone. 0 = off (peripheral vision only)."), 0, 100, 20)
slider("behSafe", "Relaxed AI (SAFE / CARELESS)", tip(
    "Suspicion speed for relaxed soldiers. " + MULT,
    "Example: 0.7 = bored sentries are slower to notice."), 0, 3, 0.7, 2)
slider("behAware", "Alert AI (AWARE)", tip("Suspicion speed for alert soldiers. " + MULT), 0, 3, 1, 2)
slider("behCombat", "Fighting AI (COMBAT)", tip(
    "Suspicion speed for soldiers in combat. " + MULT,
    "Lower = they are busy with the fight and pay less attention to traffic."), 0, 3, 1.125, 2)
slider("behStealth", "Sneaking AI (STEALTH)", tip(
    "Suspicion speed for soldiers in stealth mode. " + MULT,
    "Higher = they are watching carefully."), 0, 3, 1.25, 2)
slider("skillInfluence", "AI skill influence", tip(
    "How much the AI's spotting skills change suspicion speed.",
    "0 = skill does not matter. 1 = a skilled spotter is up to twice as fast, a poor one much slower."), 0, 1, 0.5, 0, True)
slider("engagedElsewhereMult", "Busy fighting someone else", tip(
    "Suspicion speed while the group is fighting another enemy. " + MULT), 0, 2, 0.6, 2)
check("vehOpticsEnabled", "Vehicle optics see farther", tip(
    "AI in a vehicle's gunner or commander seat (hatch closed) look through sights: they judge you",
    "from farther away. Only the range changes, not how wide they look.",
    "Turned out or firing-from-vehicle seats use their own eyes and weapons."), True)
slider("vehOpticsMult", "Gunner / commander optics range", tip(
    "Range multiplier for AI behind vehicle optics. 1 = like the naked eye.",
    "Higher = they read you from farther (and suspicion builds faster at a distance). Lower = worse than the naked eye.",
    "Example: 1.5 = a BMP gunner 300 m away judges you as if you were 200 m away.",
    "Each vehicle can set its own value (Vehicle Disguise module / setVehicleMode)."), 0.25, 5, 1.5, 2)
slider("vehDriverOpticsMult", "Driver's view range", tip(
    "Range multiplier for AI driving a vehicle (hatch closed). 1 = like the naked eye.",
    "Lower = a driver behind a vision block sees less."), 0.25, 5, 0.580277, 2)

# ======================================================================= 05 Light and weather
cat("environment", "Light and Weather")
slider("nightMult", "Darkness", tip(
    "How well the AI sees into vehicles in full darkness (scaled smoothly by sun and moon light).",
    "0 = blind at night. 1 = night makes no difference."), 0, 1, 0.353623, 0, True)
slider("nvgNightMult", "Darkness with night vision", tip(
    "Same as Darkness, for AI wearing night vision goggles."), 0, 1, 0.85, 0, True)
slider("fogInfluence", "Fog", tip(
    "How much fog hides you. 0 = fog does nothing. 1 = thick fog hides you completely."), 0, 1, 0.6, 0, True)
slider("rainInfluence", "Rain", tip(
    "How much rain hides you. 0 = rain does nothing. 1 = heavy rain hides you completely."), 0, 1, 0.44832, 0, True)

# ======================================================================= 06 Seats and vehicle type
cat("seats", "Seats and Vehicle Type")
slider("seatDriver", "Driver seat", tip("Suspicion speed for the driver. " + MULT), 0, 3, 1, 2)
slider("seatCargo", "Passenger seat", tip(
    "Suspicion speed for passengers. " + MULT, "Lower = passengers in the back are harder to make out."), 0, 3, 0.7, 2)
slider("seatTurret", "Gunner / commander seat", tip("Suspicion speed for gunners and commanders inside. " + MULT), 0, 3, 1.1, 2)
slider("seatTurnedOut", "Turned out (head out of the hatch)", tip(
    "Suspicion speed when turned out. " + MULT, "Higher = sticking your head out is a giveaway."), 0, 5, 2.5, 2)
slider("seatFFV", "Firing from vehicle seat", tip(
    "Suspicion speed in seats where you hold your weapon out of the window. " + MULT), 0, 5, 2.5, 2)
slider("openVehicleMult", "Open vehicle multiplier", tip(
    "Suspicion speed on quads, bikes and other open vehicles (when they give cover). " + MULT), 1, 10, 2.99684, 2)
slider("fastSpeed", "Fast drive-by speed (km/h)", tip(
    "Above this speed the AI only get a short glimpse of you.",
    "Example: 50 = passing at 60 km/h is much safer than crawling past."), 10, 200, 70.1479)
slider("fastMult", "Fast drive-by multiplier", tip(
    "Suspicion speed above the fast drive-by speed. 1 = no protection. 0.4 = 40% speed."), 0, 1, 0.0983531, 0, True)
slider("altitudeFalloff", "Aircraft altitude falloff (m)", tip(
    "Aircraft above this height get proportionally less attention.",
    "Example: 60 = at 120 m suspicion builds half as fast."), 10, 1000, 200)
slider("damageInfluence", "Damaged vehicle influence", tip(
    "Visibly damaged vehicles (broken glass, bullet holes, burning) build suspicion faster:",
    "multiplier = 1 + visible damage x this. 0 = damage does not matter."), 0, 5, 2, 2)
slider("damageVisibleAt", "Suspicious on sight from damage", tip(
    "A vehicle with at least this much visible damage makes the group SUSPICIOUS the moment they see it.",
    "100% = off."), 0, 1, 0.254808, 0, True)
slider("damageFloorScale", "Damage suspicion floor", tip(
    "How far above 'Suspicious at' heavy damage pushes suspicion straight away.",
    "0 = only to the suspicious level. 100% = up to just below identification for a wreck."), 0, 1, 0.6, 0, True)
slider("mixedCrewMult", "Mixed crew multiplier", tip(
    "Suspicion speed for each uncovered person in the vehicle (when 'Uncovered people' = Faster suspicion). " + MULT), 1, 5, 1.5, 2)

# ======================================================================= 07 Vehicle faction
cat("faction", "Vehicle Faction")
slider("sameFactionVehMult", "Their own faction's vehicle", tip(
    "Suspicion speed in a vehicle of the exact faction watching you (CSAT truck at a CSAT checkpoint). " + MULT,
    "Lower = they expect their own vehicles and barely look twice."), 0, 3, 0.5, 2)
slider("friendlyVehMult", "Their side, other faction", tip(
    "Suspicion speed in a vehicle of the same side but another faction. " + MULT), 0, 3, 0.8, 2)
slider("civVehMult", "Civilian vehicle", tip("Suspicion speed in a civilian vehicle. " + MULT), 0, 3, 1, 2)
slider("alliedVehMult", "Allied side's vehicle", tip(
    "Suspicion speed in a vehicle of a side allied to the watching AI. " + MULT), 0, 5, 1.2, 2)
slider("hostileVehMult", "Enemy side's vehicle", tip(
    "Suspicion speed in a vehicle of a side they are at war with (only when 'Own-side vehicles give cover'). " + MULT,
    "Example: 3 = a BLUFOR Hunter at an OPFOR checkpoint is identified three times as fast."), 0, 10, 3, 2)
edit("vehClassMults", "Per-class multipliers", tip(
    "Comma-separated class:multiplier pairs that replace the faction multipliers. First match wins, child classes included.",
    "Example: O_MRAP_02_F:0.4,B_MRAP_01_F:5"), "")

# ======================================================================= 08 Armored vehicles
cat("armored", "Armored Vehicles")
check("armoredDetect", "Armored hulls hide the crew", tip(
    "In tanks, APCs and IFVs with closed hatches the AI cannot see who is inside. They can only judge",
    "the vehicle, so suspicion builds much slower. Turned out or firing from a port = normal rules."), True)
edit("armoredClasses", "Armored vehicle classes", tip(
    "Comma-separated vehicle classes treated as armored (child classes included).",
    "Example: Tank,Wheeled_APC_F"), "Tank,Wheeled_APC_F")
check("armoredAutoDetect", "Detect armored seats automatically", tip(
    "Seats that only see out through optics or periscopes (e.g. a BTR driver) count as armored",
    "even when the vehicle is not in the class list."), True)
slider("armoredHullMult", "Armored hull visibility", tip(
    "How much of the vehicle's visibility counts while the crew sits behind armor.",
    "Lower = armored vehicles are harder to see through. 1 = no protection.",
    "Example: 0.25 = a BMP that gives itself away builds suspicion about a quarter as fast as a car."), 0, 1, 0.0489455, 0, True)
slider("armoredCloseMult", "Armored face-to-face", tip(
    "Scales 'Face-to-face minimum visibility' for armored seats (a guard at the hull still cannot see in well)."), 0, 1, 0.14776, 0, True)
check("armoredDrivingOnly", "Armored: only behaviour gives it away", tip(
    "On = a closed armored vehicle driven calmly builds no suspicion at all (nobody can see in) and old suspicion fades.",
    "It only builds while it gives itself away: speeding or off-road near them, lights off at night, honking,",
    "pointing a gun at them, visible damage or parking next to them for long. Ramming always identifies.",
    "Off = it builds slowly from the vehicle alone (Armored hull visibility)."), True)

# ======================================================================= 09 Gear
cat("gear", "Gear")
check("gearEnabled", "Gear affects suspicion", tip(
    "Uniform, vest, helmet, goggles, backpack and visible weapons change how fast suspicion builds.",
    "Off = gear is ignored."), True)
lst("gearCompareMode", "How gear is judged", tip(
    "General look = civilian clothes, military uniform, helmets... Matching = item by item against",
    "what the watching side itself wears (see 'Gear Reference')."),
    [0, 1, 2, 3], [("General look only", "Old behaviour: side of the uniform, armored helmet/vest, NVG, visible weapon."),
                ("Item matching only", "Each visible item is compared with the enemy's own kit."),
                ("General look, matching for disguises", "General look always. Item matching only when you wear their (or an allied) uniform: it tells a good disguise from a sloppy one. Enemy fatigues are not punished twice (recommended)."),
                ("Both, always", "Strict: both multipliers always apply, enemy fatigues count twice.")], 2)
slider("uniformCivMult", "Civilian clothes", tip("Suspicion speed wearing civilian clothes. " + MULT), 0, 3, 0.6, 2)
slider("uniformObserverMult", "Their side's uniform", tip(
    "Suspicion speed wearing a uniform of the watching side or its allies. " + MULT), 0, 3, 0.295059, 2)
slider("uniformHostileMult", "Enemy military uniform", tip(
    "Suspicion speed wearing a military uniform of a side they are at war with (your own fatigues). " + MULT), 0, 5, 1.6, 2)
slider("helmetMult", "Ballistic helmet", tip("Suspicion speed wearing an armored helmet. " + MULT), 0, 3, 0.99911, 2)
slider("vestMult", "Armored vest", tip("Suspicion speed wearing an armored vest. " + MULT), 0, 3, 0.99911, 2)
slider("nvgDayMult", "Night vision in daylight", tip("Suspicion speed with NVGs on the head during the day. " + MULT), 0, 3, 1.3, 2)
slider("weaponVisibleMult", "Visible weapon", tip(
    "Suspicion speed when a rifle or launcher can be seen (turned out, firing seat, open vehicle). " + MULT), 0, 5, 1.5, 2)
slider("gearVisibleRange", "Gear readable range (m)", tip(
    "Gear counts fully within this distance and fades out by twice this distance.",
    "Example: 50 = nobody can read your uniform at 100 m."), 5, 500, 50)
edit("gearNeutral", "Neutral items", tip(
    "Comma-separated item classes that never count, good or bad (mission-specific kit).",
    "Example: H_Cap_red,G_Aviator"), "")
lst("gearRefSource", "Gear reference source", tip(
    "What the AI compare your kit against when 'How gear is judged' uses matching."),
    [0, 1, 2], [("Their own group's kit", "What the soldiers of the watching group wear right now."),
                ("Gear Reference list only", "Only the lists set by the Gear Reference module or API."),
                ("List, else group, else side", "The list when one exists, otherwise the group, otherwise every unit of that side (recommended).")], 2)
check("gearRefAutoCollect", "Collect enemy gear at mission start", tip(
    "10 s after the mission starts, every side without a Gear Reference list gets one built from what its AI wear.",
    "Off = use the group's own kit until a list is set."), True)
slider("gearMatchMult", "Same item as theirs", tip(
    "Suspicion speed for each visible item that is exactly what they wear. " + MULT), 0.1, 2, 0.498087, 2)
slider("gearSimilarMult", "Same item, other camo", tip(
    "Suspicion speed for each item of the same model but another variant (other camo). " + MULT), 0.1, 3, 0.75, 2)
slider("gearMismatchMult", "Item they never wear", tip(
    "Suspicion speed for each visible item that none of them wears. " + MULT,
    "Example: 1.15 with three wrong items = about 1.5x."), 0.5, 5, 1.15, 2)
slider("gearMissingMult", "Missing item they all wear", tip(
    "Suspicion speed for each empty slot they always fill (no helmet when every guard wears one). " + MULT), 0.5, 5, 1.05, 2)
edit("gearSlotWeights", "Slot weights", tip(
    "How much each slot counts (slot:weight, comma-separated). 2 = counts double, 0 = ignored.",
    "Slots: uniform, vest, headgear, primary, launcher, backpack, facewear."),
    "uniform:1.5,vest:1,headgear:1,primary:1.2,launcher:1,backpack:0.5,facewear:0.5")
slider("gearMatchMin", "Matching lowest multiplier", tip("Item matching never lowers suspicion speed below this."), 0.1, 1, 0.4, 2)
slider("gearMatchMax", "Matching highest multiplier", tip("Item matching never raises suspicion speed above this."), 1, 10, 3, 2)
check("gearVoidsCover", "Military gear blows cover", tip(
    "Units wearing the gear ticked below get no cover in vehicles at all (normal detection).",
    "On foot always uses normal detection anyway."), False)
check("gearVoidUniform", "...own military uniform", tip("Wearing a military uniform of a covered side (e.g. BLUFOR fatigues)."), False)
check("gearVoidHelmet", "...ballistic helmet", tip("Wearing armored headgear."), False)
check("gearVoidVest", "...armored vest", tip("Wearing an armored vest."), False)
check("gearVoidWeapon", "...visible weapon", tip("Carrying a rifle or launcher in a seat that shows it (turned out, firing seat, open vehicle)."), False)

# ======================================================================= 10 Driving behaviour
cat("driving", "Driving Behaviour")
slider("speedingSpeed", "Speeding near AI (km/h)", tip(
    "Driving faster than this within 100 m of a group is suspicious."), 10, 200, 99.8745)
slider("speedingMult", "Speeding multiplier", tip("Suspicion speed while speeding near a group. " + MULT), 1, 5, 1.3, 2)
slider("offroadMult", "Off-road approach", tip("Suspicion speed driving off-road within 150 m of a group. " + MULT), 1, 5, 1.2, 2)
slider("lightsOffMult", "Lights off at night", tip("Suspicion speed driving at night with headlights off. " + MULT), 1, 5, 1.4, 2)
slider("hornMult", "Honking", tip("Suspicion speed for 10 s after honking near them. " + MULT), 1, 5, 1.5, 2)
slider("hornSuspicion", "Honking adds (%)", tip(
    "Every honk (at most one every 2 s) adds this much suspicion of everyone undercover in your vehicle",
    "to enemy groups within earshot. They hear it: no line of sight needed. 0 = off."), 0, 50, 5)
slider("hornEscalate", "Repeated honking multiplier", tip(
    "Each further honk heard within the window adds this many times more than the one before.",
    "Example: 5% and 1.8 -> 5, 9, 16, 29 ... 1 = every honk adds the same."), 1, 5, 1.8, 2)
slider("hornWindow", "Repeated honking window (s)", tip(
    "Honks this close together count as one series. Quiet for longer and the series starts over."), 5, 300, 30)
slider("hornMaxSusp", "Honking suspicion cap (%)", tip(
    "Honking alone never takes suspicion above this, and never identifies anyone."), 0, 99, 95)
slider("hornSearchCount", "Honks before they search", tip(
    "After this many honks in one series the group starts SEARCHING for the vehicle. 0 = never."), 0, 20, 3)
slider("hornRange", "Honking heard within (m)", tip("How far away enemy groups hear your horn (no line of sight needed, mounted crews too)."), 0, 500, 150)
slider("aimMult", "Aiming at the AI", tip("Suspicion speed while your weapon or turret points at a soldier. " + MULT), 1, 10, 2.5, 2)
slider("aimAngle", "Aiming cone (deg)", tip(
    "How close to a soldier your weapon must point to count as aiming at them (half-angle)."), 1, 45, 8)
slider("lightMult", "Weapon light / laser at night", tip("Suspicion speed with a weapon light or laser on at night. " + MULT), 1, 5, 2, 2)
check("metaDetect", "Catch hidden-crew tricks", tip(
    "Close to a group, a vehicle in plain view whose crew is hidden (reversing up to a checkpoint,",
    "parking rear-on) still builds suspicion through the vehicle itself. Armored vehicles are exempt."), True)
slider("metaRange", "Hidden-crew range (m)", tip(
    "Hidden-crew tricks are only judged within this distance of a soldier."), 10, 500, 40.0359)
slider("metaMaxSpeed", "Hidden-crew top speed (km/h)", tip(
    "Only vehicles slower than this are checked for hidden-crew tricks. A car driving past",
    "whose crew happens to be out of sight is not a trick."), 3, 60, 15)
check("hiddenCrewAny", "Any hidden crew counts", tip(
    "Off = only reversing up and parking rear-on are caught.",
    "On = also a slow vehicle close by whose crew is hidden any other way (tinted or blocked windows)."), True)
slider("hiddenCrewMult", "Hidden crew", tip(
    "How much of the vehicle's visibility counts when the crew cannot be seen at all.",
    "0 = a hidden crew is perfectly safe. 1 = as if they could see you."), 0, 2, 0.6, 2)
slider("reverseSpeed", "Reversing from (km/h)", tip(
    "Moving backwards faster than this counts as reversing."), 1, 30, 3)
slider("reverseMult", "Reversing past the AI", tip(
    "Suspicion speed when reversing near them with the crew hidden. " + MULT,
    "Higher = reversing through a checkpoint is a dead giveaway."), 1, 10, 2.5, 2)
slider("rearFacingAngle", "Rear-facing cone (deg)", tip(
    "The vehicle counts as rear-on when the soldier is within this angle of straight behind it."), 10, 90, 60)
slider("rearFacingMult", "Parked rear-on", tip(
    "Suspicion speed when stopped or crawling with the back towards them and the crew hidden. " + MULT), 1, 10, 1.5, 2)
slider("metaRampTime", "Hidden-crew ramp time (s)", tip(
    "Keep reversing or parking rear-on this long and the extra penalty below is at its maximum."), 1, 120, 20)
slider("metaRampMax", "Hidden-crew ramp maximum", tip(
    "Extra suspicion speed after the full ramp time of hidden-crew tricks. " + MULT), 1, 5, 2, 2)

# ======================================================================= 11 Hostile acts
cat("hostile", "Hostile Acts")
check("firedBlows", "Shooting blows cover", tip(
    "Firing a weapon from cover gets you identified by nearby groups and by groups that see you."), True)
slider("firedRadius", "Shot heard within (m)", tip(
    "Groups within this distance of an unsuppressed shot identify the shooter."), 0, 2000, 300)
slider("firedRadiusSuppressed", "Suppressed shot heard within (m)", tip(
    "Same, for suppressed weapons."), 0, 500, 40)
check("firedLOS", "Seen shooting = identified", tip(
    "Any group with line of sight to the shooter (within spotting range) identifies them."), True)
slider("heatDuration", "Heat after shooting (s)", tip(
    "After firing you cannot regain cover for this long. 0 = off.",
    "Example: 120 = jumping into another car right after a firefight does not work for 2 minutes."), 0, 1800, 30)
check("damageBlows", "Hurting AI blows cover", tip(
    "When a covered unit (or its vehicle) hurts an AI soldier, that soldier's group reacts."), True)
check("damageNeedsLOS", "Victims must see the attacker", tip(
    "On = a group hurt by someone it did not see only starts SEARCHING.",
    "Off = it identifies the attacker anyway."), True)
slider("damageSuspicion", "Unseen attack suspicion (%)", tip(
    "Suspicion given to a group hurt by an attacker it did not see."), 0, 99, 70)
check("vehicleAttackedBlows", "AI shooting your vehicle = identified", tip(
    "If enemy AI shoot a covered vehicle anyway (it looked dangerous), they identify its occupants."), True)
check("compromiseCrew", "Identify the whole crew", tip(
    "Identifying one person in a vehicle identifies everyone undercover in it."), False)
slider("revealKA", "Knowledge on identification", tip(
    "How much the AI know about you once identified (0-4, the engine's knowsAbout).",
    "4 = they know exactly where you are."), 0.5, 4, 3, 2)

# ======================================================================= 12 Safe zones and truce
cat("truce", "Safe Zones and Truce")
check("truceEnabled", "Safe zones hold a truce", tip(
    "Inside a Safe haven zone the AI do not attack players of the zone's sides, not even on foot or",
    "once identified, as long as the players behave. Made for roleplay areas (Zeus playing the locals).",
    "Off = safe zones only stop suspicion from building."), True)
slider("truceMaxStay", "Allowed stay (s)", tip(
    "How long players may stay in a safe zone before the truce ends. 0 = no limit.",
    "Each zone can set its own value in the Zone module."), 0, 7200, 0)
slider("truceWarn", "Warning before the end (s)", tip(
    "Players get a warning this long before their allowed stay runs out."), 0, 600, 0)
check("truceCareless", "AI relax inside safe zones", tip(
    "AI groups standing in a safe zone are CARELESS and hold fire until the truce is broken."), True)
lst("truceBreakScope", "Who loses the truce", tip(
    "When one player breaks the truce (shooting, hurting or ramming AI, overstaying)..."),
    [0, 1, 2], [("Only the offender", "Everyone else keeps the truce."),
                ("The offender's group", "The offender's whole player group loses it."),
                ("Everyone in the zone", "All players in that zone lose it.")], 1)
check("truceBreakOnAim", "Aiming at AI breaks the truce", tip(
    "Pointing a weapon at an AI soldier for the time below breaks the truce."), True)
slider("truceAimTime", "Aiming time (s)", tip("How long aiming at an AI soldier is tolerated."), 1, 30, 9.82227)
slider("truceCooldown", "Truce cooldown (s)", tip(
    "After a break, the players who lost the truce cannot get it back for this long, even by leaving and re-entering."), 0, 3600, 300)
slider("truceExitGrace", "Exit grace (s)", tip(
    "The truce lasts this long after leaving the zone, so the AI do not open fire at the border."), 0, 120, 10)
slider("truceBreakRadius", "Break reaction radius (m)", tip(
    "Besides the groups inside the zone, groups within this distance of the offender (or seeing them) react."), 0, 2000, 200)
check("truceBulletin", "Breaking the truce triggers a bulletin", tip(
    "Groups reacting to a broken truce roll for a radio bulletin (see 'Radio Bulletins')."), True)

# ======================================================================= 13 Memory
cat("memory", "Memory and Forgetting")
slider("forgetAfter", "Forget after (s)", tip(
    "A group that identified you forgets you after not seeing you this long, and your disguise works again."), 10, 1800, 180)
slider("recoverThreshold", "Calm at (%)", tip(
    "SUSPICIOUS or SEARCHING groups calm down (UNAWARE) once suspicion falls below this."), 0, 50, 10)
slider("memoryTime", "Memory after leaving the vehicle (s)", tip(
    "Suspicion is remembered this long after you get out, so getting out and back in does not reset it."), 0, 3600, 600)
slider("exitRevealThreshold", "Getting out in view reveals at (%)", tip(
    "Getting out of the vehicle in view of a group at or above this suspicion reveals you to it."), 0, 100, 74.8879)
lst("targetAge", "Age knowledge after losing contact", tip(
    "Optionally ages what EVERY side knows about an identified unit after it breaks contact (setTargetAge)."),
    ["\"\"", "\"ACTUAL\"", "\"5 MIN\"", "\"10 MIN\"", "\"15 MIN\"", "\"30 MIN\"", "\"60 MIN\"", "\"UNKNOWN\""],
    [("Disabled", ""), ("Actual", ""), ("5 min", ""), ("10 min", ""), ("15 min", ""), ("30 min", ""), ("60 min", ""), ("Unknown", "")], 0)
slider("targetAgeDelay", "Age knowledge after (s)", tip("Time without contact before the knowledge is aged."), 5, 600, 60)

# ======================================================================= 14 Sharing and sync
cat("share", "Sharing and Suspicion Sync")
lst("shareMode", "On identification, nearby groups...", tip(
    "What friendly groups around learn when a group identifies someone."),
    [0, 1, 2], [("Learn nothing", "Every group finds out on its own."),
                ("Start searching", "They become SEARCHING with the shared suspicion."),
                ("Identify too", "They identify the unit at once.")], 1)
slider("shareRadius", "Share radius (m)", tip(
    "Friendly groups within this distance of any member of the identifying group get the information."), 0, 3000, 300)
slider("shareDelay", "Share delay (s)", tip(
    "Time before the information arrives. Killing the whole group first stops it."), 0, 120, 10.3202)
slider("shareKA", "Shared knowledge", tip("How much receiving groups learn about the position (0-4) on a full share."), 0.1, 4, 2, 2)
slider("shareSuspicion", "Shared suspicion (%)", tip("Starting suspicion for groups that start searching."), 0, 99, 49.6826)
check("shareNeedsRadio", "Sharing needs a radio", tip("The identifying group needs a soldier with a radio to share."), True)
slider("shareInstantRadius", "Right next to it (m)", tip(
    "Groups this close to an identifying group see the reaction and identify at once. 0 = off."), 0, 1000, 150)
check("shareEscalate", "Suspicious groups confirm", tip(
    "A group already SUSPICIOUS or SEARCHING identifies the unit when it hears about it."), True)
check("burnOnIdentify", "Identified vehicle is known", tip(
    "The vehicle someone was identified in is recognised on sight by that side nearby (see range)."), True)
slider("burnOnIdentifyRange", "Known vehicle range (m)", tip(
    "Distance from the identification within which that side recognises the vehicle. 0 = everywhere."), 0, 10000, 1500)
check("syncEnabled", "Sync suspicion between groups", tip(
    "While suspicion builds, nearby friendly groups get the same level after the sync delay.",
    "Example: the guards at a checkpoint's exit are as wary as the ones who watched you arrive.",
    "Changing vehicle, uniform, vest, helmet or weapon in between shakes it off."), True)
slider("syncRadius", "Sync radius (m)", tip(
    "Groups within this distance of any member of the sending group receive it. -1 = use 'Share radius'."), -1, 3000, -1)
slider("syncDelay", "Sync delay (s)", tip(
    "Time for the information to pass (radio, shouting). Killing the senders first stops it."), 0, 120, 5)
slider("syncInterval", "Sync every (s)", tip(
    "How often a group passes on rising suspicion. Lower = closer to real time, more network traffic."), 1, 60, 3)
slider("syncFactor", "Synced share", tip(
    "Share of the sender's suspicion the receivers take. 1 = the same level. 0.5 = half."), 0, 1, 1, 0, True)
slider("syncMin", "Sync from (%)", tip("Suspicion below this is not passed on."), 0, 99, 10)
check("syncNeedsRadio", "Sync needs a radio", tip("The sending group needs a soldier with a radio."), True)
check("syncStartSusp", "Share starting suspicion", tip(
    "Off = a group's starting suspicion (Starting Suspicion module / API) stays its own: only what it",
    "built on top by watching is passed on. On = the full value is passed on, so neighbours inherit it."), False)
check("syncCanIdentify", "Synced suspicion can identify", tip(
    "Off = synced suspicion stops just below 'Identified at', the receivers still need their own look."), False)
check("syncRespectSig", "Changing looks shakes it off", tip(
    "Synced suspicion only sticks while you still have the same vehicle and kit the sender saw."), True)
slider("appearanceChangeKeep", "Suspicion kept after changing looks", tip(
    "When a group sees you again in another vehicle or kit, it keeps this share of its suspicion.",
    "1 = changing makes no difference. 0 = a complete fresh start."), 0, 1, 0.353623, 0, True)

# ======================================================================= 15 Radio bulletins
cat("radio", "Radio Bulletins")
check("bulletinEnabled", "Radio bulletins", tip(
    "On identification a radioman may broadcast you and your vehicle over a long range."), True)
slider("bulletinChance", "Bulletin chance", tip("Chance per identifying group that a bulletin is sent."), 0, 1, 0.1, 0, True)
check("bulletinOnHostile", "Also after shooting / attacks", tip("Groups that identified you because of gunfire or attacks also roll."), True)
lst("radiomanMode", "Who can send", tip("Which soldiers can send a bulletin."),
    [0, 1, 2, 3], [("Radioman only", "Radio backpack or radioman class."),
                   ("Radioman or any radio", "Also anyone carrying a radio item."),
                   ("Group leader only", ""),
                   ("Anyone", "No radioman needed.")], 1)
edit("radioBackpacks", "Radio backpacks", tip(
    "Comma-separated backpack classes that make a radioman (child classes included)."),
    "B_RadioBag_01_base_F,TFAR_Bag_Base,ACRE_PRC117F,ACRE_PRC77")
edit("radiomanClasses", "Radioman classes", tip(
    "Comma-separated unit classes that count as radiomen. Classes with 'radio' in the name always count."), "")
slider("bulletinDelayMin", "Bulletin delay min (s)", tip(
    "Shortest time to send. Killing or knocking out the radioman first cancels it."), 0, 300, 10)
slider("bulletinDelayMax", "Bulletin delay max (s)", tip("Longest time to send."), 0, 600, 30)
slider("bulletinRange", "Bulletin range (m)", tip("Groups farther from the sender do not hear it. 0 = the whole side."), 0, 30000, 5000)
check("bulletinBurn", "Bulletin makes the vehicle known", tip(
    "Receiving groups recognise the vehicle on sight and attack its covered occupants."), True)
slider("burnDuration", "Known vehicle duration (s)", tip("How long a reported vehicle stays known."), 30, 7200, 900)
check("bulletinWanted", "Bulletin makes you wanted", tip(
    "The receiving side builds suspicion faster against you in any vehicle."), True)
slider("wantedDuration", "Wanted duration (s)", tip("How long the wanted status lasts."), 30, 7200, 600)
slider("wantedMult", "Wanted multiplier", tip("Suspicion speed against wanted units. " + MULT), 1, 10, 2, 2)
check("bulletinAreaAlert", "Bulletin alerts the area", tip("Groups near the reported position start SEARCHING."), True)
slider("areaAlertRadius", "Area alert radius (m)", tip("Radius around the reported position."), 0, 5000, 600)
check("areaAlertAware", "Alerts make AI alert", tip("Alerted SAFE / CARELESS groups switch to AWARE."), True)

# ======================================================================= 16 Convoys
cat("convoy", "Convoys")
check("convoyEnabled", "Recognise convoys", tip(
    "Undercover vehicles driving close together in the same direction count as one convoy."), True)
slider("convoyGap", "Convoy gap (m)", tip(
    "Vehicles within this distance of each other (chains count) form a convoy."), 10, 300, 100)
slider("convoyFormTime", "Convoy forms after (s)", tip(
    "Vehicles must stay together this long before they count as a convoy (two cars meeting at a junction do not)."), 0, 120, 10)
slider("convoyBuildPerVeh", "Extra suspicion per vehicle in view", tip(
    "Each additional convoy vehicle the group can see adds this to the suspicion speed.",
    "Example: 0.15 = three vehicles in view build 1.3x as fast."), 0, 1, 0.15, 2)
slider("convoyBuildMax", "Convoy multiplier cap", tip("The convoy multiplier never goes above this."), 1, 5, 1.75, 2)
lst("convoyMode", "One vehicle identified, the rest...", tip(
    "What happens to the other vehicles of a convoy when one of them is identified (by that group)."),
    [0, 1, 2], [("Nothing", "Every vehicle is judged on its own."),
                ("Become suspects", "They get the spill-over suspicion and are SEARCHED for."),
                ("Are identified too", "The whole convoy is identified at once.")], 1)
slider("convoySpillSusp", "Spill-over suspicion (%)", tip(
    "Suspicion the other convoy vehicles get when 'Become suspects' is chosen."), 0, 99, 60)

# ======================================================================= 17 Pursuit
cat("pursuit", "Pursuit and Checkpoint Stops")
check("pursuitEnabled", "AI pursue suspects", tip(
    "Suspicious and searching groups go after the vehicle with real waypoints: foot patrols run at it,",
    "mounted patrols follow it, signal it to stop and inspect it. Their own route resumes afterwards."), True)
check("followEnabled", "Pursue from the follow threshold", tip(
    "Groups start a pursuit once their suspicion reaches the follow threshold (searching groups always may)."), True)
slider("followThreshold", "Follow threshold (%)", tip(
    "Suspicion at which a group starts following or chasing you instead of just watching."), 1, 99, 75)
slider("pursuitMaxGroups", "Pursuers per target", tip(
    "Most groups that pursue the same unit at once. Keeps the whole map from converging on you."), 1, 10, 2)
slider("pursuitMaxStart", "Start distance (m)", tip("Only groups within this distance start a pursuit."), 50, 3000, 600)
slider("pursuitCooldown", "Cooldown between pursuits (s)", tip(
    "After a pursuit ends (given up, cleared or called off) that group starts no new one for this long.",
    "A passed inspection additionally clears you for 'Cleared for'."), 0, 1800, 60)
slider("pursuitMaxTime", "Give up after (s)", tip("A pursuit that has not led to a stop is abandoned after this long."), 30, 1800, 180)
slider("pursuitMaxDist", "Give up beyond (m)", tip(
    "A pursuit is abandoned once the group is this far from where it started."), 100, 10000, 1000)
slider("pursuitLead", "Aim ahead (s)", tip(
    "Pursuers head for where the vehicle will be in this many seconds."), 0, 10, 2, 1)
check("leashEnabled", "Roam limit", tip(
    "Pursuing groups never go farther than the limits below from where they were (their post or patrol spot).",
    "At the edge they stop, and give up and radio if you stay beyond it.",
    "Each group can have its own limit (AI Group Profile module / setGroupProfile)."), True)
slider("leashFoot", "Roam limit on foot (m)", tip(
    "How far a foot group may go from home while chasing, searching or inspecting."), 25, 3000, 200)
slider("leashVehicle", "Roam limit mounted (m)", tip(
    "How far a mounted group may go from home while following you."), 50, 10000, 600)
slider("leashGiveUp", "Give up beyond the limit after (s)", tip(
    "You stay beyond their roam limit this long and they give up (and alert, see 'Alert when you get away')."), 1, 300, 15)
slider("footGiveUpDist", "Foot patrols give up at (m)", tip(
    "A foot patrol gives up once the vehicle is this far away (they cannot catch a car)."), 50, 2000, 300)
check("stopFreeze", "Hold suspicion during a stop request", tip(
    "A vehicle patrol that starts following you stops judging you: suspicion is held at the follow threshold",
    "while they follow and signal you to pull over. It builds normally again once you refuse (the time to stop runs out),",
    "pull away from them or open fire / ram anyone. Stopping lets them inspect you instead.",
    "Off = suspicion keeps building while they follow (they usually identify you before you can react)."), True)
slider("stopSignalRange", "Signal to stop within (m)", tip(
    "A pursuing vehicle starts honking and flashing its lights once it is this close. The time to stop starts then.",
    "Example: 150 = the signal starts while they are still a few car lengths behind."), 20, 500, 150)
slider("followDistance", "Inspect when stopped within (m)", tip(
    "Stopping while the pursuers are this close starts the inspection. Stopped farther away, they drive up first."), 10, 200, 40)
slider("stopSignalInterval", "Signal every (s)", tip(
    "How often the pursuers repeat the signal: two honks 1 s apart and three flashes of the headlights",
    "(0.5 s on, 0.5 s off) each time; one signal takes 3 s.",
    "Lower = more insistent. Example: 4 with a 30 s time to stop = about 7 signals."), 4, 20, 4)
check("stopSignalHorn", "Stop signal: horn", tip("Pursuing vehicles honk to make you stop."), True)
check("stopSignalLights", "Stop signal: flashing lights", tip("Pursuing vehicles flash their headlights to make you stop."), True)
slider("stopTimeout", "Time to stop (s)", tip(
    "How long the pursuers keep signalling, counted once they are under way and within signal range.",
    "Not stopping by then counts as refusing: they radio an alert and suspicion builds normally again."), 5, 300, 30)
slider("stopFleeDistance", "Pulling away counts as fleeing (m)", tip(
    "Getting this much farther from the pursuers than the closest they came (once they are under way)",
    "counts as fleeing the stop: they radio an alert and suspicion builds normally again.",
    "Example: 150 = they closed to 40 m, you are now 190 m ahead."), 50, 2000, 150)
slider("refuseSuspBonus", "Refusing to stop adds (%)", tip("Suspicion added to the pursuers when you refuse to stop."), 0, 99, 20)
check("alertOnEscape", "Alert when you get away", tip(
    "When a pursuit is given up (you were too fast or too far), the pursuers alert the area too."), True)
slider("alertRadius", "Alert radius (m)", tip(
    "Groups and outposts within this distance of the pursuers hear their alerts."), 0, 10000, 1500)
slider("alertSuspicion", "Alert suspicion (%)", tip("Groups hearing an alert start SEARCHING with at least this suspicion."), 0, 99, 60)
slider("inspectRange", "Inspect within (m)", tip(
    "A foot patrol starts its inspection when your vehicle stops within this distance."), 5, 100, 30)
slider("inspectTime", "Inspection length (s)", tip(
    "How long the inspection lasts. Survive it without being identified and you are cleared."), 5, 300, 30)
check("inspectCalm", "Inspection judges the vehicle, not the wait", tip(
    "During an inspection, standing there builds no suspicion with any group: that is the point of a stop.",
    "Only what they find counts: a turned-out or exposed occupant, a weapon or turret pointed at them,",
    "visible damage, an uncovered occupant, a weapon light or honking. Off = suspicion builds face to face as usual."), True)
slider("inspectMult", "Inspection multiplier", tip(
    "Suspicion speed while being inspected, once something gives you away (on top of face-to-face). " + MULT), 0.1, 5, 1.5, 2)
slider("inspectClearReduce", "Clean inspection lowers suspicion by (%)", tip(
    "Passing an inspection cleanly lowers that group's suspicion by this much (and never leaves it above",
    "'Cleared suspicion', also below a starting suspicion). Nearby friendly groups calm down too.",
    "Example: 25 with 60% suspicion -> 35%, then capped at 'Cleared suspicion'."), 0, 100, 25)
slider("inspectClearSusp", "Cleared suspicion (%)", tip(
    "Highest suspicion left after passing an inspection. 99 = only the reduction above applies."), 0, 99, 15)
slider("inspectDismount", "Inspectors", tip(
    "How many of a vehicle patrol get out to inspect, in this order: passengers, other crew without",
    "a weapon, the commander, the driver. Gunners never leave their weapon."), 1, 10, 2)
check("inspectRemount", "Crew remount before engaging", tip(
    "If you flee or get identified during an inspection, dismounted driver / commander / turret crew",
    "run back to their own seats first, then the vehicle goes after you. Passengers fight on foot.",
    "Off = everyone stays where they are and fights."), True)
check("alertRecall", "Stopping calls off the alert", tip(
    "When a vehicle that 'refused to stop' does stop for the inspection after all, groups the refusal",
    "alert put in SEARCHING go back to how they were (if nothing else happened meanwhile)."), True)
slider("inspectCooldown", "Cleared for (s)", tip(
    "After passing an inspection, for this long: that group and the groups it told will not pursue you,",
    "stay calm (no searching), share no new suspicion and ignore the starting suspicion set on them."), 0, 3600, 300)
slider("inspectClearGrace", "Cleared: suspicion paused for (s)", tip(
    "Right after a clean inspection, every group's suspicion of the inspected vehicle (anyone in it)",
    "neither builds nor drops for this long, so waiting to drive off is not suspicious. Other vehicles,",
    "or you in another vehicle, build as usual. Ends at once (suspicion builds, 'cleared' calm lifted) on",
    "a give-away: turning out, wrong gear on show, shooting, aiming, honking, a weapon light, an",
    "uncovered occupant, an identified occupant or someone new getting in. 0 = off."), 0, 120, 15)
slider("inspectClearMargin", "Cleared: suspicious again after (+%)", tip(
    "While cleared, they only turn suspicious again once suspicion climbs this far above the level",
    "they cleared you at (something new gave you away). Example: cleared at 20, 15 -> suspicious at 35."), 0, 100, 15)
slider("fleeDistance", "Fleeing distance (m)", tip(
    "Driving more than this far from where you stopped, during the inspection, counts as fleeing."), 5, 200, 25)
slider("fleeSpeed", "Fleeing speed (km/h)", tip(
    "Driving faster than this during the inspection counts as fleeing."), 3, 100, 15)
lst("fleeBulletin", "Fleeing sends a bulletin", tip(
    "Fleeing a stop gets you identified on the spot. Should they also radio a bulletin?"),
    [0, 1, 2], [("Never", ""),
                ("By chance", "The normal bulletin chance."),
                ("Always", "Always (a radioman is still needed).")], 2)
check("fleeBurn", "Fleeing makes the vehicle known", tip(
    "The vehicle you fled in is recognised on sight within the bulletin range."), True)
check("lambsDisableDuringPursuit", "LAMBS: hold off during pursuit", tip(
    "With LAMBS Danger loaded, its group AI is paused while a group pursues, so it does not break the chase."), True)
check("lambsHuntOnCompromise", "LAMBS: hunt when identified", tip(
    "With LAMBS loaded, pursuers that identify you hand over to LAMBS Rush (on foot) or Hunt (mounted)."), True)

# ======================================================================= 18 Informants, theft, ramming, plates
cat("misc", "Informants, Theft, Ramming, Plates")
check("informantsEnabled", "Civilian informants", tip(
    "Civilians who see a soldier get into a vehicle or a hostile act may report it."), True)
slider("informantChance", "Informant chance", tip("Chance per civilian group that witnesses it."), 0, 1, 0.15, 0, True)
slider("informantDelay", "Informant delay (s)", tip("Time to make the report. Cancelled if the informant dies."), 0, 600, 45)
slider("informantRange", "Informant range (m)", tip("How far away a civilian can witness from."), 10, 1000, 200)
check("theftEnabled", "Stolen vehicles are known", tip(
    "Taking a vehicle last used by an AI group makes it known to that side if the owners are near or see it."), True)
slider("theftRadius", "Theft witness radius (m)", tip("Owners within this distance always notice the theft."), 0, 500, 50)
check("ramDetect", "Detect ramming", tip("Driving into or over enemy soldiers alerts their group at once."), True)
slider("ramSpeed", "Ramming from (km/h)", tip("Minimum speed for contact to count as ramming."), 1, 60, 5)
slider("ramSuspicion", "Ramming suspicion (%)", tip(
    "Suspicion the rammed group has at least after being rammed (at least SUSPICIOUS).",
    "A single ram only does this; ramming again does what 'Ramming = identified' says."), 0, 99, 75)
slider("ramRepeatCount", "Full reaction from ram #", tip(
    "A single bump can be an accident: the first rams only raise suspicion (Ramming suspicion).",
    "From this ram on (by the same vehicle, against the same group, within the window) 'Ramming = identified' applies.",
    "Example: 2 = the second ram gets you identified. 1 = the first one already does."), 1, 10, 2)
slider("ramRepeatWindow", "Repeated ramming window (s)", tip(
    "Rams count as repeated when the next comes within this long of the last one."), 10, 1800, 300)
check("ramCompromise", "Ramming = identified", tip(
    "Ramming again (see 'Full reaction from ram #') - a soldier, or their vehicle - gets everyone undercover in your",
    "vehicle identified by that group at once. Off = the group only becomes SUSPICIOUS (see Ramming suspicion)."), True)
check("ramBurn", "Ramming makes the vehicle known", tip(
    "The ramming vehicle is recognised on sight by that side (within 'Known vehicle range'), so swapping",
    "crews does not save it."), True)
check("swapForgive", "Fresh vehicle after being identified", tip(
    "An identified unit that switches to another vehicle unseen is only suspected again, not identified.",
    "The old vehicle stays known."), True)
slider("swapMinUnseen", "Unseen before switching (s)", tip(
    "The group must not have seen you for this long (and must not see you now) when you switch."), 0, 300, 15)
slider("swapBaseSuspicion", "Suspicion after switching (%)", tip("Starting suspicion after the first switch."), 0, 99, 30)
slider("swapPenalty", "Repeat switch penalty (%)", tip(
    "Extra starting suspicion for every earlier switch. Once it reaches 'Identified at', switching no longer works."), 0, 100, 30)
slider("swapMemory", "Switch memory (s)", tip("How long a group remembers earlier switches."), 60, 7200, 900)
check("plateRecognition", "Recognise reported number plates", tip(
    "A reported vehicle's number plate is reported too: any vehicle with that plate is identified as soon as",
    "the plate is read, whatever its side."), True)
slider("plateReadRange", "Plate reading range (m)", tip("Soldiers must be this close (with line of sight) to read a plate."), 5, 300, 50)
check("plateCombat", "Reported plate = COMBAT", tip("A group that reads a reported plate goes COMBAT at once."), True)

# ======================================================================= 19 AI reactions
cat("ai", "AI Reactions")
check("aiAware", "Suspicious groups go alert", tip(
    "SAFE / CARELESS groups switch to AWARE while suspicious, and back when calm."), True)
check("aiGlance", "AI glance at new vehicles", tip(
    "The soldier who first notices your vehicle glances at it (they turn their head, so they see more)."), True)
check("aiLook", "Suspicious AI keep looking", tip(
    "Once suspicious, the best placed soldier keeps looking at your vehicle until the group calms down."), True)
check("aiWatch", "Suspicious groups watch you", tip(
    "Every soldier of a suspicious group turns to watch the vehicle (stronger than looking)."), True)
check("aiCombatOnIdentify", "Identifying groups go COMBAT", tip("Groups that identify you switch to COMBAT."), True)

# ======================================================================= 20 Notifications
cat("notify", "Notifications")
check("notifyCover", "Show cover changes", tip("Hint when you gain or lose cover."), False)
check("notifyWatched", "Warn when watched", tip("Hint when an enemy group becomes suspicious of you."), False)
check("notifyCompromised", "Warn when identified", tip("Hint when an enemy group identifies you."), False)
check("notifyTruce", "Safe zone truce hints", tip("Hints when a truce starts, ends, is about to run out or is broken."), False)
check("notifyInspect", "Inspection hint", tip("Hint while an enemy patrol is inspecting your vehicle."), False)
check("notifyZeus", "Zeus messages", tip("Curators get messages for identifications, bulletins, pursuits and truce breaks."), True)
check("allowWatchedHints", "Allow suspicion feedback", tip(
    "Server permission for the watched / identified hints.",
    "Off = players get no hints about how suspicious the AI are."), False)

# ======================================================================= 21 Debug
cat("debug", "Debug")
lst("debugClients", "Who may use debug", tip(
    "Server permission for the per-player debug options below (log, overlay, live publishing).",
    "The server and headless clients always may. Players outside this list have them switched off",
    "whatever they set, so nobody can watch AI suspicion on their own."),
    [0, 1, 2], [("Logged-in admins", "Only the logged-in admin (and the host in a hosted game / singleplayer)."),
                ("Admins and Zeus", "Logged-in admins and players with a Zeus (curator) slot."),
                ("Everyone", "Every player may use them. Testing only.")], 1)
check("debugLog", "Debug log", tip(
    "Writes every RADS decision to the RPT of the machine that owns the AI (server / headless client) and of the player:",
    "identifications with full history, state changes, ramming, hits, shots, shares, syncs, truces, pursuits, cover changes."), True, glob=False)
lst("debugDetail", "Debug log detail", tip("What is logged besides events and identification reports."),
    [0, 1, 2], [("Events and reports", ""),
                ("Also big jumps", "An evaluation that adds a lot of suspicion is logged on its own."),
                ("Every evaluation", "Very verbose.")], 2, glob=False)
slider("debugJump", "Big jump from (%)", tip("With 'Also big jumps', an evaluation adding at least this much is logged."), 1, 100, 8, glob=False)
slider("debugHistory", "History length", tip("Evaluations kept per group and unit and printed with every report."), 1, 60, 15, glob=False)
check("debugPublish", "Publish suspicion live", tip(
    "Group owners broadcast suspicion every evaluation so overlays and Zeus Inspect stay live. Costs network traffic."), True, glob=False)
check("debugOverlay", "Debug overlay", tip(
    "Draws every nearby group's suspicion of you over its closest member (needs 'Publish suspicion live'). Per player."), True, False)
check("showZoneMarkers", "Show zone markers", tip("Creates map markers for detection zones (visible to everyone)."), True)

# ---------------------------------------------------------------- strings used by code (not settings)
EXTRA = {
    "cat": "RADS - Adaptive Detection",
    "undercover": "Undercover",
    "coverLost": "Cover lost",
    "watchedTitle": "You are being watched",
    "watchedText": "%1 is suspicious of you.",
    "identifiedTitle": "Identified!",
    "identifiedText": "%1 has identified you.",
    "truceEntered": "Safe zone: truce",
    "truceNoLimit": "The AI will not attack you while you stay peaceful.",
    "truceStayFor": "The AI will not attack you while you stay peaceful. You may stay %1 s.",
    "truceWarning": "Safe zone: leave within %1 s or the truce ends.",
    "truceLeft": "You left the safe zone: truce over.",
    "truceBroken": "Truce broken!",
    "inspectHintTitle": "Vehicle inspection",
    "inspectHint": "%1 is inspecting your vehicle. Stay put - driving off now means you are identified.",
    "statusTitle": "RADS: %1",
    "statusCover": "Cover: %1",
    "statusNone": "none",
    "statusActive": "active",
    "statusHeat": "Heat: %1 s",
    "statusWanted": "Wanted by: %1",
    "statusBurned": "Vehicle known to: %1",
    "statusTruce": "Truce: %1",
    "statusTruceLeft": "%1 s left",
    "statusTruceUnlimited": "no time limit",
    "statusAttention": "Attention: %1",
    "statusCalm": "calm",
    "statusNoticed": "noticed",
    "statusSuspicious": "suspicious",
    "statusClose": "close to identified",
    "statusIdentified": "Identified by %1 group(s)",
    "statusPursued": "Pursued by %1 group(s)",
}

# ======================================================================= output


def sqf_str(s):
    return '"' + s.replace('"', '""') + '"'


def valueinfo(e):
    k = e["kind"]
    if k == "CHECKBOX":
        return "true" if e["default"] else "false"
    if k == "EDITBOX":
        return sqf_str(e["default"])
    if k == "SLIDER":
        args = [num(e["lo"]), num(e["hi"]), num(e["default"]), str(e["dec"])]
        if e["pct"]:
            args.append("true")
        return "[" + ", ".join(args) + "]"
    if k == "LIST":
        values = ", ".join(str(v) for v in e["values"])
        labels = []
        for i, (label, t) in enumerate(e["options"]):
            key = f"{e['name']}_opt{i}"
            labels.append(f"[LSTRING({key}), LSTRING({key}_desc)]" if t else f"[LSTRING({key})]")
        return f"[[{values}], [{', '.join(labels)}], {e['default']}]"
    raise ValueError(k)


def num(v):
    if isinstance(v, float) and v.is_integer():
        v = int(v)
    return str(v)


def build_sqf():
    out = [
        "// CBA settings, generated by tools/gen_settings.py - edit the table there, not this file.",
        "// Every value is read live (MSET) each evaluation, so changes in Addon Options apply mid-mission.",
        "// Modules/API may layer runtime overrides on top (root_ads_fnc_setOverride).",
        "#define CAT LSTRING(cat)",
    ]
    for key, _title, _settings in CATS:
        out.append(f"#define SUB_{key.upper()} [CAT, LSTRING(cat_{key})]")
    for key, title, settings in CATS:
        out.append("")
        out.append(f"// ---------------------------------------------------------------- {title}")
        for e in settings:
            glob = "true" if e["glob"] else "false"
            out.append(f"[QGVAR({e['name']}), \"{e['kind']}\", [LSTRING({e['name']}), LSTRING({e['name']}_desc)], SUB_{key.upper()}, {valueinfo(e)}, {glob}] call CBA_fnc_addSetting;")

    # control data for the Zeus settings dialogs (modules fnc_settingsDialog)
    out.append("")
    out.append("// Control data per setting for the Zeus settings dialogs: [type, ...]")
    out.append("// SLIDER: min, max, decimals, percent. LIST: values, label keys.")
    meta = []
    for _key, _title, settings in CATS:
        for e in settings:
            k = e["kind"]
            if k == "SLIDER":
                m = f'["SLIDER", {num(e["lo"])}, {num(e["hi"])}, {e["dec"]}, {"true" if e["pct"] else "false"}]'
            elif k == "LIST":
                values = ", ".join(str(v) for v in e["values"])
                labels = ", ".join(f"LSTRING({e['name']}_opt{i})" for i in range(len(e["options"])))
                m = f'["LIST", [{values}], [{labels}]]'
            else:
                m = f'["{k}"]'
            meta.append(f'    ["{e["name"]}", {m}]')
    out.append("GVAR(settingMeta) = createHashMapFromArray [")
    out.append(",\n".join(meta))
    out.append("];")
    return "\n".join(out) + "\n"


def strings():
    keys = {}
    for k, v in EXTRA.items():
        keys[k] = v
    for key, title, settings in CATS:
        keys[f"cat_{key}"] = title
        for e in settings:
            keys[e["name"]] = e["title"]
            keys[e["name"] + "_desc"] = e["tip"]
            if e["kind"] == "LIST":
                for i, (label, t) in enumerate(e["options"]):
                    keys[f"{e['name']}_opt{i}"] = label
                    if t:
                        keys[f"{e['name']}_opt{i}_desc"] = t
    return keys


def build_xml(keys):
    out = ['<?xml version="1.0" encoding="utf-8"?>', '<Project name="root_ads">', '    <Package name="main">']
    for k in sorted(keys, key=str.lower):
        out.append(f'        <Key ID="STR_root_ads_main_{k}">')
        out.append(f'            <English>{html.escape(keys[k], quote=False)}</English>')
        out.append('        </Key>')
    out += ['    </Package>', '</Project>']
    return "\n".join(out) + "\n"


def doc_default(e):
    k = e["kind"]
    if k == "CHECKBOX":
        return "on" if e["default"] else "off"
    if k == "EDITBOX":
        return f"`{e['default']}`" if e["default"] else "(empty)"
    if k == "SLIDER":
        return f"{round(e['default'] * 100)}%" if e["pct"] else num(e["default"])
    return e["options"][e["default"]][0]


def doc_range(e):
    k = e["kind"]
    if k == "SLIDER":
        return f"{round(e['lo'] * 100)}-{round(e['hi'] * 100)}%" if e["pct"] else f"{num(e['lo'])} - {num(e['hi'])}"
    if k == "LIST":
        return " / ".join(o[0] for o in e["options"])
    return ""


def build_md():
    out = [
        "# RADS - CBA Settings",
        "",
        "<!-- generated by tools/gen_settings.py -->",
        "",
        "All settings live under **Addon Options > RADS - Adaptive Detection**. Every value is read live, so a change made "
        "mid-mission applies at the next evaluation. All settings are server settings: only the server (or a logged-in admin) can change "
        "them and clients cannot override them. The only exception is the debug options marked *per player*, and players can only use those when the server's 'Who may use debug' allows it. Hover a setting in game for the same explanation; the reset button shows its default.",
        "",
        "Runtime overrides from the Zeus/3DEN **Detection Settings** modules or `root_ads_fnc_setOverride` take precedence over these "
        "values until cleared. Variable names are `root_ads_main_<name>`.",
        "",
        "Multipliers: 1.0 = no change, 2.0 = suspicion builds twice as fast, 0.5 = half as fast.",
    ]
    for key, title, settings in CATS:
        out += ["", f"## {title[3:]}", "", "| Setting | Name | Default | Range / options | What it does |", "|---|---|---|---|---|"]
        for e in settings:
            name = e["title"] + ("" if e["glob"] else " *(per player)*")
            desc = e["tip"].replace(NL, " ")
            out.append(f"| {name} | `{e['name']}` | {doc_default(e)} | {doc_range(e)} | {desc} |")
    return "\n".join(out) + "\n"


def write(rel, text):
    path = os.path.join(ROOT, rel)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    print("wrote", rel)


if __name__ == "__main__":
    names = [e["name"] for _, _, s in CATS for e in s]
    assert len(names) == len(set(names)), "duplicate setting name"
    write("addons/main/initSettings.inc.sqf", build_sqf())
    write("addons/main/stringtable.xml", build_xml(strings()))
    write("docs/SETTINGS.md", build_md())
    print(len(names), "settings")
