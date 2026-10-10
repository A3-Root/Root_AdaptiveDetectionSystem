#include "script_component.hpp"

// Every machine may own AI groups (server, headless clients, clients leading AI or spawning it),
// so event receivers and the evaluation loop run everywhere and act only on local groups.
[QGVAR(coverChanged), FUNC(onCoverChanged)] call CBA_fnc_addEventHandler;
[QGVAR(hostileAct), FUNC(onHostileAct)] call CBA_fnc_addEventHandler;
[QGVAR(forceCompromise), FUNC(onForceCompromise)] call CBA_fnc_addEventHandler;
[QGVAR(restoreCover), FUNC(onRestoreCover)] call CBA_fnc_addEventHandler;
[QGVAR(share), FUNC(onShare)] call CBA_fnc_addEventHandler;
[QGVAR(bulletin), FUNC(onBulletin)] call CBA_fnc_addEventHandler;
[QGVAR(rammed), FUNC(onRammed)] call CBA_fnc_addEventHandler;
[QGVAR(honked), FUNC(onHonked)] call CBA_fnc_addEventHandler;
[QGVAR(truceBroken), FUNC(onTruceBroken)] call CBA_fnc_addEventHandler;
[QGVAR(syncSusp), FUNC(onSyncSuspicion)] call CBA_fnc_addEventHandler;
[QGVAR(inspectCleared), FUNC(onInspectCleared)] call CBA_fnc_addEventHandler;
[QGVAR(alertRecall), FUNC(onAlertRecall)] call CBA_fnc_addEventHandler;
[QGVAR(pursuitAlert), FUNC(onPursuitAlert)] call CBA_fnc_addEventHandler;
[QGVAR(startPursuit), { params ["_grp", "_unit"]; if (local _grp) then { [_grp, _unit, true] call FUNC(pursuitStart); }; }] call CBA_fnc_addEventHandler;
[QGVAR(stopPursuit), { params ["_grp"]; if (local _grp) then { [_grp, "called off (Zeus/API)"] call FUNC(pursuitEnd); }; }] call CBA_fnc_addEventHandler;
[QGVAR(engineOn), { params ["_veh"]; if (local _veh) then { _veh engineOn true; }; }] call CBA_fnc_addEventHandler;
[QGVAR(signalBurst), FUNC(signalBurst)] call CBA_fnc_addEventHandler;
[QGVAR(gearRefChanged), { { _x setVariable [QGVAR(gearRefCache), nil]; } forEach allGroups; }] call CBA_fnc_addEventHandler;

// Server is the authority for shared mission state (zones, overrides, burned vehicles, wanted units)
if (isServer) then {
    [QGVAR(api), {
        params ["_fnc", "_args"];
        if !(_fnc in ["addZone", "removeZone", "setOverride", "clearOverrides", "burnVehicle", "markWanted", "clearBulletins", "setEnabled", "setVehicleMode", "setUnitMode", "setGroupProfile", "setStartSuspicion", "setGearReference", "setZoneTruce"]) exitWith {};
        _args call (missionNamespace getVariable [format ["root_ads_fnc_%1", _fnc], {}]);
    }] call CBA_fnc_addEventHandler;
};

// Enemy gear reference from the mission's own AI, once everything has spawned
if (isServer) then {
    [{
        if (!MSET(gearRefAutoCollect)) exitWith {};
        {
            if (([_x] call API(getGearReference)) findIf {_x != ""} == -1) then { [_x, true] call API(collectSideGear); };
        } forEach [east, west, independent];
    }, [], 10] call CBA_fnc_waitAndExecute;
};

if (hasInterface) then {
    [QGVAR(compromised), FUNC(onCompromisedClient)] call CBA_fnc_addEventHandler;
    [QGVAR(inspected), {
        params ["_grp", "_active"];
        if (!GVAR(notifyInspect)) exitWith {};
        if (_active) then {
            hint parseText format ["<t color='#ffcc00' size='1.1'>%1</t><br/>%2", localize LSTRING(inspectHintTitle), format [localize LSTRING(inspectHint), groupId _grp]];
        } else {
            hintSilent "";
        };
    }] call CBA_fnc_addEventHandler;
    [QGVAR(watched), {
        params ["_grp"];
        if !(GVAR(notifyWatched) && {MSET(allowWatchedHints)}) exitWith {};
        hintSilent parseText format ["<t color='#ffcc00'>%1</t><br/>%2", localize LSTRING(watchedTitle), format [localize LSTRING(watchedText), groupId _grp]];
    }] call CBA_fnc_addEventHandler;
    [QGVAR(message), {
        params ["_text"];
        if (!GVAR(notifyZeus) || {isNull getAssignedCuratorLogic player} || {isNil "zen_common_fnc_showMessage"}) exitWith {};
        [_text] call zen_common_fnc_showMessage;
    }] call CBA_fnc_addEventHandler;

    call FUNC(initPlayer);
    // the horn is not always reported as a shot: catch the fire key of a driver with a horn too
    addUserActionEventHandler ["DefaultAction", "Activate", {
        private _veh = vehicle player;
        if (_veh != player && {driver _veh == player} && {((_veh weaponsTurret [-1]) findIf {"horn" in toLower _x}) > -1}) then {
            [player, "fire key"] call FUNC(hornPressed);
        };
    }];
    [FUNC(ramCheck), 0.2] call CBA_fnc_addPerFrameHandler;
    addMissionEventHandler ["Draw3D", { if (GVAR(debugOverlay) && {DEBUG_OK}) then { call FUNC(debugDraw) }; }];

    // the server decides who may use the debug options (admins / Zeus / everyone)
    [{
        private _ok = call FUNC(debugAllowed);
        if (_ok isEqualTo GVAR(debugOK)) exitWith {};
        GVAR(debugOK) = _ok;
        diag_log text format ["[RADS] debug options %1 for this player by the server ('Who may use debug' = %2)", ["blocked", "allowed"] select _ok, MSET(debugClients)];
    }, 2] call CBA_fnc_addPerFrameHandler;
};

[FUNC(tick), 0] call CBA_fnc_addPerFrameHandler;

// Non-player units forced into cover (API/modules) are updated by whichever machine owns them
[{
    {
        if (local _x && {!isPlayer _x}) then { [_x] call FUNC(updateCover); };
    } forEach (missionNamespace getVariable [QGVAR(extraUnits), []]);
}, 1] call CBA_fnc_addPerFrameHandler;
