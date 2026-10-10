#include "..\script_component.hpp"
/*
 * Author: Root
 * Event (every machine): a covered vehicle rammed a member of a group (on foot or in a vehicle).
 * The group owner identifies everyone undercover in the vehicle and makes the vehicle known
 * (defaults), or only makes the group SUSPICIOUS when 'Ramming = identified' is off.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Driver <OBJECT>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_unit"];

if (isNull _grp || {!local _grp} || {isNull _unit} || {isPlayer (leader _grp)}) exitWith {};

private _veh = vehicle _unit;
if (RADS_DEBUG) then { ["RAM", format ["group rammed by covered vehicle %1 (identify=%2, burn=%3, suspicion=%4)", typeOf _veh, MSET(ramCompromise), MSET(ramBurn), MSET(ramSuspicion)], _grp, _unit] call FUNC(debugLog); };

if (MSET(ramCompromise)) exitWith {
    [_grp, _unit, "rammed", MSET(bulletinOnHostile)] call FUNC(compromise);
    // the whole vehicle is given away, whatever 'Identify the whole crew' says
    if (_veh != _unit) then {
        {
            if (alive _x && {_x getVariable [QGVAR(cover), false]} && {[side _grp, _x] call FUNC(isHostile)}) then {
                [_grp, _x, "rammed (in the ramming vehicle)", false, false] call FUNC(compromise);
            };
        } forEach ((crew _veh) - [_unit]);
        if (MSET(ramBurn)) then {
            private _known = (_veh getVariable [QGVAR(burnedBy), []]) findIf {(_x select 0) == side _grp && {(_x select 1) > CBA_missionTime}} > -1;
            if (!_known) then {
                [_veh, side _grp, MSET(burnDuration), MSET(burnOnIdentifyRange), getPosATL _veh] call API(burnVehicle);
                if (RADS_DEBUG) then { ["RAM", format ["%1 is now known to %2 for %3 s (ramming)", typeOf _veh, side _grp, MSET(burnDuration)], _grp, _unit] call FUNC(debugLog); };
            };
        };
    };
};

private _entry = [_grp, _unit, false] call FUNC(classify);
if ((_entry select D_STATE) == ST_COMPROMISED) exitWith {};
if ((_grp getVariable [QGVAR(pursuitTarget), objNull]) == _unit) then { [_grp, "hostile act (rammed)"] call FUNC(pursuitUnfreeze); };

_entry set [D_SUSP, ((_entry select D_SUSP) max MSET(ramSuspicion)) min (MSET(identifyThreshold) - 1)];
_entry set [D_LASTEXP, time];
if ((_entry select D_STATE) == ST_UNAWARE) then {
    [_grp, _entry, ST_SUSPICIOUS, format ["rammed by covered vehicle %1 at %2 km/h", typeOf vehicle _unit, round speed vehicle _unit]] call FUNC(setState);
    if (isPlayer _unit) then { [QGVAR(watched), [_grp], _unit] call CBA_fnc_targetEvent; };
};
[_grp, _entry, true] call FUNC(behaviourHooks);
[_grp, true] call FUNC(publishData);
if (RADS_DEBUG) then { [_entry, format ["t=%1 RAMMED -> suspicion %2 state %3", CBA_missionTime toFixed 1, (_entry select D_SUSP) toFixed 1, STATE_NAMES select (_entry select D_STATE)]] call FUNC(debugHistory); };
