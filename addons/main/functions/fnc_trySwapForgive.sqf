#include "..\script_component.hpp"
/*
 * Author: Root
 * A group that identified a unit sees it in a different vehicle than the one it was identified in.
 * If the group did not see the swap, it loses the unit and only suspects the new vehicle; each
 * repeat starts it more suspicious until swapping no longer works. If it saw the swap (or the
 * swaps are used up), the new vehicle becomes the known one.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Entry <ARRAY>
 *
 * Return Value:
 * Forgiven (entry is no longer COMPROMISED) <BOOL>
 *
 * Public: No
 */

params ["_grp", "_entry"];

private _unit = _entry select D_UNIT;
private _veh = vehicle _unit;
if ((_entry select D_STATE) != ST_COMPROMISED
    || {!MSET(swapForgive)}
    || {isNull objectParent _unit}
    || {!(_unit getVariable [QGVAR(cover), false])}
    || {_veh == (_entry select D_COMPVEH)}
) exitWith {false};

private _fnc_known = {
    _entry set [D_COMPVEH, _veh];
    if (MSET(burnOnIdentify)) then {
        [_veh, side _grp, MSET(burnDuration), MSET(burnOnIdentifyRange), getPosATL _veh] call API(burnVehicle);
    };
};

private _lastSeen = ((leader _grp) targetKnowledge _unit) param [2, -1e10];
private _unseen = time - (_lastSeen max (_entry select D_LASTEXP));
if (RADS_DEBUG) then { ["SWAP", format ["identified in %1, now in %2: unseen=%3s (need %4s) seesNow=%5 previousSwaps=%6", typeOf (_entry select D_COMPVEH), typeOf _veh, _unseen toFixed 1, MSET(swapMinUnseen), [_grp, _unit] call FUNC(groupSees), _entry select D_SWAPS], _grp, _unit] call FUNC(debugLog); };
// Seen in the new vehicle: they watched the swap, the new vehicle is now the known one
if ([_grp, _unit] call FUNC(groupSees)) exitWith {
    if (RADS_DEBUG) then { ["SWAP", format ["watched the swap -> %1 is now the known vehicle", typeOf _veh], _grp, _unit] call FUNC(debugLog); };
    call _fnc_known;
    false
};
// Not seen, but lost sight too recently: still identified for now, re-checked every evaluation
if (_unseen < MSET(swapMinUnseen)) exitWith {
    if (RADS_DEBUG) then { ["SWAP", format ["too soon (%1 s unseen of %2 s needed), re-checking", _unseen toFixed 1, MSET(swapMinUnseen)], _grp, _unit] call FUNC(debugLog); };
    false
};

private _swaps = [0, _entry select D_SWAPS] select ((time - (_entry select D_SWAPTIME)) <= MSET(swapMemory));
private _seed = MSET(swapBaseSuspicion) + MSET(swapPenalty) * _swaps;
_entry set [D_SWAPS, _swaps + 1];
_entry set [D_SWAPTIME, time];
if (_seed >= MSET(identifyThreshold)) exitWith {
    RLOG_2("%1 not fooled by another vehicle swap of %2",_grp,_unit);
    call _fnc_known;
    false
};

_grp forgetTarget _unit;
_grp forgetTarget _veh;
_entry set [D_SUSP, _seed];
[_grp, _entry, [ST_SUSPICIOUS, ST_SEARCHING] select (_seed >= MSET(suspiciousThreshold)), format ["unseen vehicle swap #%1 (%2 -> %3), suspicion %4", _swaps + 1, typeOf (_entry select D_COMPVEH), typeOf _veh, _seed]] call FUNC(setState);
_entry set [D_PASSES, 0];
_entry set [D_STATIONARY, 0];
_entry set [D_VISIBLE, false];
_entry set [D_AGED, false];
_entry set [D_COMPVEH, objNull];

// Fool the group in the new vehicle right away (unless it is burned or does not fool this side)
if (([_veh, side _grp, getPosATL (leader _grp)] call FUNC(vehicleDisguise)) == 1 && {!(_grp getVariable [QGVAR(immune), false])}) then {
    [_grp, _entry, true, "fooled by an unseen vehicle swap"] call FUNC(setIgnored);
    private _ignoredVehs = _grp getVariable [QGVAR(ignoredVehs), []];
    if !(_veh in _ignoredVehs) then {
        _grp ignoreTarget [_veh, true];
        _ignoredVehs pushBack _veh;
        _grp setVariable [QGVAR(ignoredVehs), _ignoredVehs];
    };
};

[_grp, true] call FUNC(publishData);
if (RADS_DEBUG) then { ["SWAP", format ["fooled by the swap -> %1 at %2 pct", STATE_NAMES select (_entry select D_STATE), _seed], _grp, _unit] call FUNC(debugLog); };
true
