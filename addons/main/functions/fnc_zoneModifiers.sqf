#include "..\script_component.hpp"
/*
 * Author: Root
 * Combined effect of all active zones at a position for an observing side.
 *
 * Arguments:
 * 0: Position <ARRAY>
 * 1: Observer side, sideUnknown = any <SIDE>
 *
 * Return Value:
 * [noCover <BOOL>, buildMultiplier <NUMBER>, decayMultiplier <NUMBER>, safeHaven <BOOL>]
 *
 * Public: No
 */

params ["_pos", ["_side", sideUnknown]];

private _noCover = false;
private _build = 1;
private _decay = 1;
private _safe = false;

{
    if ([_x] call FUNC(isZoneActive) && {_pos inArea (_x select Z_AREA)}) then {
        private _sides = _x select Z_SIDES;
        private _applies = _side == sideUnknown || {_sides isEqualTo []} || {_side in _sides};
        switch (_x select Z_MODE) do {
            case ZONE_NOCOVER: { _noCover = true; };
            case ZONE_SAFE: { if (_applies) then { _safe = true; }; };
            default {
                if (_applies) then {
                    _build = _build * (_x select Z_BUILD);
                    _decay = _decay * (_x select Z_DECAY);
                };
            };
        };
    };
} forEach GVAR(zones);

[_noCover, _build, _decay, _safe]
