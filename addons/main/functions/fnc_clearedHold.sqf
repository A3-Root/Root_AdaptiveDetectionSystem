#include "..\script_component.hpp"
/*
 * Author: Root
 * A unit recently passed an inspection (or the group heard the all-clear): the group stays calm
 * until suspicion climbs inspectClearMargin above the level it was cleared at.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Entry <ARRAY>
 *
 * Return Value:
 * Held calm <BOOL>
 *
 * Public: No
 */

params ["_grp", "_entry"];

if (time >= (_entry select D_CLEARED)) exitWith {false};
// the players gave themselves away after the clearance: no more benefit of the doubt
if ((([vehicle (_entry select D_UNIT)] call FUNC(vehicleCalm)) select 0) == "failed") exitWith {false};
private _level = (_grp getVariable [QGVAR(clearedLevel), createHashMap]) getOrDefault [hashValue (_entry select D_UNIT), 0];
(_entry select D_SUSP) < (_level + MSET(inspectClearMargin))
