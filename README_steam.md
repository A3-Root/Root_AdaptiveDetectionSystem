[h1]Root's Adaptive Detection System (RADS)[/h1]

[b]Undercover vehicle gameplay with AI that have to notice you first.[/b]

In vanilla Arma, enemy AI open fire the moment a player climbs into a civilian car or a captured enemy truck. RADS replaces that with gradual, per-group suspicion. If nobody sees you get in a car, then you are not 'suspicious' enough for the enemies to engage immediately. Drive past too often, loiter near the AI or shoot from the window, and they will work it out.

Fully integrated with CBA, ZEN, Zeus, and Eden, with optional ACE3 support. Load the mod on the server and every client. Works in singleplayer, multiplayer, on dedicated servers, and with headless clients.

[b]Current version:[/b] 1.0.0.6

[hr]
[h2]Requirements[/h2]
[list]
[*]Arma 3 [b]2.18[/b] or newer
[*][url=https://steamcommunity.com/workshop/filedetails/?id=450814997]CBA_A3[/url]
[*][url=https://steamcommunity.com/workshop/filedetails/?id=1779063631]Zeus Enhanced (ZEN)[/url]
[*][url=https://steamcommunity.com/sharedfiles/filedetails/?id=463939057]ACE3[/url] (optional)
[/list]
[hr]
[h2]What RADS Adds[/h2]
[table]
[tr][th]System[/th][th]Gameplay[/th][/tr]
[tr][td][b]Vehicle cover[/b][/td][td]Civilian vehicles and vehicles of the observing side disguise their occupants; your own side's unarmed vehicles can too, at a much higher risk. Their own faction's vehicles barely get a second look. Per-vehicle modes, multipliers, whitelists, and blacklists.[/td][/tr]
[tr][td][b]Entry snapshot[/b][/td][td]Groups that saw you get in, or were already fighting you, keep their knowledge. Groups that never saw you are fooled.[/td][/tr]
[tr][td][b]Suspicion[/b][/td][td]Builds from line of sight through the glass, distance, light, weather, seat, gear (item by item against the enemy's own kit), driving, loitering, repeated passes, convoys, and visible damage. Closed armor slows it down; hiding your face by reversing up to a checkpoint does not work. Decays when out of sight.[/td][/tr]
[tr][td][b]Checkpoints that talk[/b][/td][td]Suspicion built by the guards at the entry reaches the guards at the exit, unless you changed vehicle or kit in between.[/td][/tr]
[tr][td][b]Pursuit and stops[/b][/td][td]Suspicious foot patrols chase you; mounted patrols follow, flash and honk. Stop and they dismount and inspect you; drive off and you are identified and reported. LAMBS Danger aware.[/td][/tr]
[tr][td][b]Safe zone truce[/b][/td][td]Roleplay areas where the enemy will not attack players, even on foot, until someone shoots, rams or overstays.[/td][/tr]
[tr][td][b]Hostile acts[/b][/td][td]Shooting from the vehicle or hurting an AI blows your cover. Ramming makes the group suspicious at once.[/td][/tr]
[tr][td][b]Forgetting[/b][/td][td]Break contact long enough and the group forgets you. An unseen swap to a fresh vehicle can lose them, but every repeat makes them more suspicious.[/td][/tr]
[tr][td][b]Radio bulletins[/b][/td][td]A radioman may broadcast your vehicle and number plate over long range, and any enemy who sees them later engages on sight. Silence him before he finishes and the call never goes out. Adjustable through CBA settings, Zeus and 3DEN modules, and the API.[/td][/tr]
[tr][td][b]Extras[/b][/td][td]Civilian informants, stolen-vehicle detection, nearby groups confirming each other, and optional AI reactions (AWARE, watch, investigate).[/td][/tr]
[/table]
[hr]
[h2]For Players[/h2]
[h3]Going Undercover[/h3]
[olist]
[*]Get into a civilian vehicle, or a vehicle belonging to the enemy, while no hostile group is watching.
[*]Drive normally. Every group that can see you builds suspicion on its own.
[*]Keep your distance, avoid loitering, and do not pass the same position over and over.
[*]Get out, or shoot, and normal detection takes over.
[/olist]
[h3]What Gives You Away[/h3]
[list]
[*][b]Being seen up close:[/b] face-to-face range, a clear view through the windows, and parking next to a group.
[*][b]Your gear:[/b] your own military uniform, a ballistic helmet or vest, NVGs in daylight, and a visible rifle or launcher. Gear only counts when they are close enough to see it.
[*][b]Your driving:[/b] speeding past a group, approaching off-road, driving without lights at night, and honking at a checkpoint.
[*][b]Your vehicle:[/b] bullet holes, broken glass, and fire, plus a vehicle or number plate that has already been reported.
[*][b]Hostile acts:[/b] firing, hitting or running over an AI, and aiming a turret at them.
[/list]
[h3]Losing Them[/h3]
Break line of sight and wait. A group that identified you forgets you after a while without contact. Switching to a fresh vehicle out of sight can also lose them, but the vehicle you were identified in stays known, and each swap leaves them more suspicious.
[hr]
[h2]For Zeus Curators[/h2]
Open Zeus and select [b]Modules → Root's Adaptive Detection[/b].
[table]
[tr][th]Module[/th][th]Purpose[/th][/tr]
[tr][td][b]Detection Settings[/b][/td][td]Live mission-wide overrides of the main settings, without a restart.[/td][/tr]
[tr][td][b]Sync / Pursuit / Truce Settings[/b][/td][td]Live overrides for suspicion sync, pursuits and checkpoint stops, and safe zone truces.[/td][/tr]
[tr][td][b]Enemy Gear Reference[/b][/td][td]Collect, edit and copy what a side's AI wear, so players dressed like them blend in.[/td][/tr]
[tr][td][b]Order Pursuit / Call Off[/b][/td][td]Send a patrol after an undercover unit, or call it off.[/td][/tr]
[tr][td][b]Add / Remove Detection Zone[/b][/td][td]Checkpoint and base multipliers, restricted (no cover) areas, and safe havens, with side filter, delay, duration, and time-of-day window.[/td][/tr]
[tr][td][b]Unit Cover Profile[/b][/td][td]Exempt, always covered, or a custom suspicion multiplier for units, groups, sides, or players.[/td][/tr]
[tr][td][b]Vehicle Disguise[/b][/td][td]Always disguise, never disguise, or burned (recognised on sight) for a vehicle.[/td][/tr]
[tr][td][b]AI Group Profile[/b][/td][td]Vigilance multiplier, immunity to disguises, share radius, and bulletin chance.[/td][/tr]
[tr][td][b]Compromise / Restore Cover[/b][/td][td]Blow a unit's cover, or make every hostile group forget it.[/td][/tr]
[tr][td][b]Enable / Disable RADS[/b][/td][td]Toggle the system now or after a delay, permanently or for a duration.[/td][/tr]
[tr][td][b]Radio Bulletin[/b][/td][td]Burn a vehicle or mark units wanted for chosen sides, or clear them.[/td][/tr]
[tr][td][b]Inspect Detection Status[/b][/td][td]See every nearby group's suspicion of a unit.[/td][/tr]
[/table]
[hr]
[h2]For Mission Makers[/h2]
RADS modules are available in [b]Systems (F5) → Modules → Root's Adaptive Detection[/b]. Synchronize units or vehicles to them, or sync a trigger to activate them later.
[b]Eden setup supports:[/b]
[list]
[*]Mission-level setting overrides, where -1 keeps the CBA value.
[*]Detection zones drawn with the module area, with side filter, delay, duration, and time-of-day window.
[*]Unit cover profiles for synced units or all players, including late joiners.
[*]Vehicle disguise and burned status, AI group vigilance, compromise/restore, and radio bulletins.
[/list]
[b]Scripting API:[/b] 23 public [code]root_ads_fnc_*[/code] functions (zones and truces, overrides, vehicle modes, unit and group profiles, gear reference, pursuits, convoys, compromise, restore, burn, wanted, status) plus CBA events for identifications, cover changes, bulletins, syncs, pursuit alerts and truce breaks.
[hr]
[h2]CBA Settings[/h2]
Configure RADS from [b]Main Menu → Options → Addon Options → RADS - Adaptive Detection[/b]. All 258 settings apply live, mid-mission, and every tooltip explains in plain words what higher and lower values do. They cover:
[list]
[*]Covered sides, evaluation rate, ranges, and which vehicles give cover.
[*]Suspicion build-up and decay, thresholds, observer behaviour, environment, seat, gear, and driving.
[*]Vehicle faction, armored vehicles, gear matching, and hidden-crew tricks.
[*]Hostile acts, safe zone truces, memory and forgetting, knowledge sharing and suspicion sync, radio bulletins, convoys, pursuits and checkpoint stops, informants, theft, ramming, vehicle swaps, and number plates.
[*]Optional AI reactions, player and Zeus notifications, and a detailed RPT debug log.
[/list]
[hr]
[h2]Credits[/h2]
[b]Author:[/b] Root (xMidnightSnowx)
[hr]
[h2]License[/h2]
[b]APL-SA:[/b] Arma Public License Share Alike
[url=https://www.bohemia.net/community/licenses/arma-public-license-share-alike]Read Full License here[/url]
[img]https://i.postimg.cc/pTxntLMW/APL-SA.png[/img]
You may redistribute the mod publicly only with clear author credit and a link to this Workshop page. Do not redistribute it privately without credit or port it to games other than Arma without explicit permission from me.
[hr]
[h2]Links[/h2]
[url=https://github.com/A3-Root/Root_AdaptiveDetectionSystem][img]https://i.imgur.com/lPLHihO.gif[/img][/url]
[url=https://discord.gg/77th-jsoc-official][img]https://i.imgur.com/8B7UcQ2.gif[/img][/url]
[hr]
Tags: #Arma3 #Steam #Workshop #Mod #Root #AI #Detection #Stealth #Undercover #Zeus #Editor #Eden #CBA #ZEN
gaming,game,arma,arma 3,mod,modding,script,sqf,ai,detection,stealth,undercover,disguise,infiltration,covert,spy,civilian,vehicle,car,checkpoint,suspicion,knowledge,reveal,ignore,radio,bulletin,informant,number plate,zeus,editor,eden,cba,zen,ace,milsim,military,simulation,tactical,realistic,multiplayer,dedicated server,headless client
