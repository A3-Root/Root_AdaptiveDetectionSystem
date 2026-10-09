#include "..\script_component.hpp"
/*
 * Author: Root
 * The active safe zone with a truce at a position.
 *
 * Arguments:
 * 0: Position ATL <ARRAY>
 * 1: Observer side the zone must apply to, sideUnknown = any <SIDE> (default: sideUnknown)
 *
 * Return Value:
 * Zone, [] when there is none <ARRAY>
 *
 * Public: No
 */

params ["_pos", ["_side", sideUnknown]];

private _index = GVAR(zones) findIf {
    (_x select Z_MODE) == ZONE_SAFE
    && {[_x] call FUNC(isZoneActive)}
    && {_pos inArea (_x select Z_AREA)}
    && {_side == sideUnknown || {(_x select Z_SIDES) isEqualTo []} || {_side in (_x select Z_SIDES)}}
    && {([_x] call FUNC(zoneTruce)) select T_ENABLED}
};
[[], GVAR(zones) select _index] select (_index > -1)
