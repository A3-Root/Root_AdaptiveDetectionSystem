[h1]Root's Adaptive Detection System (RADS)[/h1]

[b]Undercover vehicle gameplay with AI that have to notice you first.[/b]

In vanilla Arma, enemy AI open fire the moment a player climbs into a civilian car or a captured enemy truck. RADS replaces that with gradual suspicion, tracked by every AI group for every player. Drive past too often, loiter at their checkpoint, wear the wrong kit or shoot from the window, and they will work it out. A suspicious patrol will follow you, honk you to a stop and inspect you face to face.

Integrated with CBA, ZEN, Zeus and Eden, with optional ACE3 and LAMBS Danger support. Load on the server and every client. Works in SP, MP, dedicated servers and with headless clients.

[b]Current version:[/b] 2.0.0.0

[img]https://i.ibb.co/gMT6hNMc/20261010172615-1.jpg[/img]
[hr]
[h2]Requirements[/h2]
[list]
[*]Arma 3 [b]2.18[/b] or newer
[*][url=https://steamcommunity.com/workshop/filedetails/?id=450814997]CBA_A3[/url]
[*][url=https://steamcommunity.com/workshop/filedetails/?id=1779063631]Zeus Enhanced (ZEN)[/url]
[*][url=https://steamcommunity.com/sharedfiles/filedetails/?id=463939057]ACE3[/url] (optional)
[*][url=https://steamcommunity.com/sharedfiles/filedetails/?id=1858075458]LAMBS Danger[/url] (optional)
[/list]
[hr]
[h2]What RADS Adds[/h2]
[list]
[*][b]Vehicle cover:[/b] civilian and observer-side vehicles disguise their occupants; enemy vehicles optionally, at higher risk. Per-vehicle modes and lists.
[*][b]Entry snapshot:[/b] groups that saw you get in keep their knowledge; the rest are fooled.
[*][b]Suspicion:[/b] builds from line of sight through the glass, distance, light, weather, seat, gear (matched against the enemy's own kit), driving, loitering and damage. Decays out of sight.
[*][b]Armored vehicles:[/b] closed hulls show only the vehicle; only driving behaviour, honking, aiming or loitering give you away.
[*][b]No cheap tricks:[/b] reversing up to a checkpoint or parking rear-on is judged through the vehicle.
[*][b]Checkpoints that talk:[/b] the entry guards' suspicion reaches the exit guards unless you changed vehicle or kit.
[*][b]Pursuit and stops:[/b] patrols follow you and honk and flash you to a stop. Refuse and the area is alerted.
[*][b]Inspections:[/b] passengers dismount first, gunners stay on the gun. Pass and they wave you on and calm down; drive off and you are identified, and the crew remount before hunting you.
[*][b]Horn and ramming:[/b] honking escalates until they search for you; repeated ramming blows your cover.
[*][b]Radio bulletins:[/b] a radioman may broadcast your vehicle and plate. Silence him first.
[*][b]Also:[/b] safe zone truces, forgetting and vehicle swaps, convoys, informants, per-AI starting suspicion and a live debug overlay.
[/list]
[hr]
[h2]For Players[/h2]
[img]https://i.ibb.co/PsvbPSRg/20261010181737-1.jpg[/img]
[list]
[*]Get into a civilian or enemy vehicle while no hostile group is watching, and drive normally.
[*][b]Gives you away:[/b] being seen up close, parking beside them, mismatched gear, speeding, off-road, no lights at night, the horn, damage, a reported plate, and any hostile act.
[*][b]Getting stopped:[/b] pull over in time, keep hatches closed and weapons down, and you will be waved on.
[*][b]Losing them:[/b] break line of sight and wait. Swapping vehicles unseen helps, but each swap makes them more suspicious.
[/list]
[hr]
[h2]For Zeus Curators[/h2]
[b]Modules → Root's Adaptive Detection[/b]:
[img]https://i.ibb.co/rK2mD6F5/20261010172940-1.jpg[/img]
[list]
[*][b]Detection / Sync / Pursuit & Checkpoint / Truce Settings:[/b] live mission-wide overrides.
[*][b]Add / Remove Detection Zone:[/b] checkpoint multipliers, restricted areas and safe havens.
[*][b]Unit Cover Profile, Vehicle Disguise, AI Group Profile, AI Starting Suspicion.[/b]
[*][b]Enemy Gear Reference:[/b] collect and edit what a side's AI wear.
[*][b]Order Pursuit / Call Off, Compromise / Restore Cover, Enable / Disable, Radio Bulletin.[/b]
[*][b]Inspect Detection Status:[/b] every nearby group's suspicion of a unit.
[/list]
[hr]
[h2]For Mission Makers[/h2]
Eden modules in [b]Systems (F5) → Modules → Root's Adaptive Detection[/b], trigger-friendly: settings overrides, detection zones, unit, vehicle and group profiles, starting suspicion, gear reference, compromise / restore, enable / disable and radio bulletins.
[img]https://i.ibb.co/pj6jknDs/20261010-Arma-3-GGames-Steamsteamappscommon-Arma-3-Arma3-x64-e-1053.png[/img]
[b]Scripting API:[/b] 24 [code]root_ads_fnc_*[/code] functions plus CBA events. Reference on GitHub.
[hr]
[h2]CBA Settings[/h2]
[b]Addon Options → RADS - Adaptive Detection[/b]: 291 settings, all live mid-mission, with plain-language tooltips. Server-wide and admin-only; the server decides who may use the debug tools.
[img]https://i.ibb.co/zVjxVGKQ/20261010172824-1.jpg[/img]
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
gaming,game,arma,arma 3,mod,modding,script,sqf,ai,detection,stealth,undercover,disguise,infiltration,covert,spy,civilian,vehicle,car,checkpoint,inspection,pursuit,traffic stop,suspicion,radio,bulletin,informant,number plate,horn,convoy,armor,zeus,editor,eden,cba,zen,ace,lambs,milsim,military,tactical,realistic,multiplayer,dedicated server,headless client
