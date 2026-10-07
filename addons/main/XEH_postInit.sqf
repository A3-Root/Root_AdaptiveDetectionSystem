#include "script_component.hpp"

// Every machine may own AI groups (server, headless clients, clients leading AI or spawning it),
// so event receivers and the evaluation loop run everywhere and act only on local groups.
[QGVAR(coverChanged), FUNC(onCoverChanged)] call CBA_fnc_addEventHandler;
[QGVAR(hostileAct), FUNC(onHostileAct)] call CBA_fnc_addEventHandler;
[QGVAR(forceCompromise), FUNC(onForceCompromise)] call CBA_fnc_addEventHandler;
[QGVAR(restoreCover), FUNC(onRestoreCover)] call CBA_fnc_addEventHandler;
[QGVAR(share), FUNC(onShare)] call CBA_fnc_addEventHandler;
[QGVAR(bulletin), FUNC(onBulletin)] call CBA_fnc_addEventHandler;

// Server is the authority for shared mission state (zones, overrides, burned vehicles, wanted units)
if (isServer) then {
    [QGVAR(api), {
        params ["_fnc", "_args"];
        if !(_fnc in ["addZone", "removeZone", "setOverride", "clearOverrides", "burnVehicle", "markWanted", "clearBulletins", "setEnabled", "setVehicleMode", "setUnitMode", "setGroupProfile"]) exitWith {};
        _args call (missionNamespace getVariable [format ["root_rads_fnc_%1", _fnc], {}]);
    }] call CBA_fnc_addEventHandler;
};

if (hasInterface) then {
    [QGVAR(compromised), FUNC(onCompromisedClient)] call CBA_fnc_addEventHandler;
    [QGVAR(watched), {
        params ["_grp"];
        if !(GVAR(notifyWatched) && {MSET(allowWatchedHints)}) exitWith {};
        hintSilent parseText format ["<t color='#ffcc00'>You are being watched</t><br/>%1 is suspicious of you.", groupId _grp];
    }] call CBA_fnc_addEventHandler;
    [QGVAR(message), {
        params ["_text"];
        if (!GVAR(notifyZeus) || {isNull getAssignedCuratorLogic player} || {isNil "zen_common_fnc_showMessage"}) exitWith {};
        [_text] call zen_common_fnc_showMessage;
    }] call CBA_fnc_addEventHandler;

    call FUNC(initPlayer);
    addMissionEventHandler ["Draw3D", { if (GVAR(debugOverlay)) then { call FUNC(debugDraw) }; }];
};

[FUNC(tick), 0] call CBA_fnc_addPerFrameHandler;

// Non-player units forced into cover (API/modules) are updated by whichever machine owns them
[{
    {
        if (local _x && {!isPlayer _x}) then { [_x] call FUNC(updateCover); };
    } forEach (missionNamespace getVariable [QGVAR(extraUnits), []]);
}, 1] call CBA_fnc_addPerFrameHandler;
