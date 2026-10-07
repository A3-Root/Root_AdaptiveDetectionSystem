#include "..\script_component.hpp"
/*
 * Author: Root
 * Rolls for a long-range radio bulletin after an identification. A radioman needs time to send it;
 * killing or knocking them out first cancels it.
 *
 * Arguments:
 * 0: Group (local) <GROUP>
 * 1: Unit <OBJECT>
 * 2: Reason <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_unit", ["_reason", ""]];

if (!MSET(bulletinEnabled)) exitWith {};

private _chance = _grp getVariable [QGVAR(bulletinChance), -1];
if (_chance < 0) then { _chance = MSET(bulletinChance); };
if (random 1 >= _chance) exitWith {};

private _radioman = [_grp] call FUNC(findRadioman);
if (isNull _radioman) exitWith { RLOG_1("%1 has no radioman for a bulletin",_grp); };

private _min = MSET(bulletinDelayMin);
private _max = MSET(bulletinDelayMax) max _min;
private _veh = vehicle _unit;
RLOG_2("%1 radioman %2 is sending a bulletin",_grp,_radioman);

[{
    params ["_radioman", "_grp", "_unit", "_veh", "_reason"];
    if !([_radioman] call FUNC(isAwake)) exitWith { RLOG_1("bulletin from %1 cancelled",_grp); };
    [QGVAR(bulletin), [side _grp, getPosATL _radioman, MSET(bulletinRange), _unit, [objNull, _veh] select (_veh != _unit), _reason, _grp]] call CBA_fnc_globalEvent;
}, [_radioman, _grp, _unit, _veh, _reason], _min + random (_max - _min)] call CBA_fnc_waitAndExecute;
