#include "..\script_component.hpp"
/*
 * Author: Root
 * Effective truce options of a safe zone: the zone's own options, or the CBA defaults when the
 * zone was created without any.
 *
 * Arguments:
 * 0: Zone <ARRAY>
 *
 * Return Value:
 * [enabled, maxStay, warnBefore, careless, breakScope, breakOnAim] <ARRAY>
 *
 * Public: No
 */

params ["_zone"];

if ((_zone select Z_MODE) != ZONE_SAFE || {!MSET(truceEnabled)}) exitWith {[false, 0, 0, false, 0, false]};

private _own = _zone param [Z_TRUCE, []];
if (_own isNotEqualTo []) exitWith {_own};

[true, MSET(truceMaxStay), MSET(truceWarn), MSET(truceCareless), MSET(truceBreakScope), MSET(truceBreakOnAim)]
