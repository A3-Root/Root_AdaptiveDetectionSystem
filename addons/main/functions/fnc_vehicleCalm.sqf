#include "..\script_component.hpp"
/*
 * Author: Root
 * Inspection calm of a vehicle, shared by every group on every machine (public vehicle variable):
 *  "inspect"  being inspected right now: waiting there is the point of the stop
 *  "cleared"  passed an inspection, short grace before normal suspicion resumes
 *  "failed"   the grace was broken by a give-away (no calm, cleared holds lifted)
 *  ""         none
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * [mode, seconds left, crew at clearance] <ARRAY>
 *
 * Public: No
 */

params ["_veh"];

(_veh getVariable [QGVAR(calm), []]) params [["_mode", ""], ["_until", -1], ["_crew", []]];
private _left = _until - CBA_missionTime;
if (_mode == "" || _left <= 0) exitWith { ["", 0, []] };
[_mode, _left, _crew]
