#include "..\script_component.hpp"
/*
 * Author: Root
 * 3DEN: observer profile for the groups of synced AI units.
 *
 * Arguments:
 * 0: Module logic <OBJECT>
 * 1: Synced units <ARRAY>
 * 2: Activated <BOOL>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_logic", ["_units", []], ["_activated", true]];

if (!isServer || {!_activated}) exitWith {};

private _groups = [];
{
    private _unit = effectiveCommander _x;
    if (_unit isKindOf "CAManBase" && {!isPlayer _unit}) then { _groups pushBackUnique (group _unit); };
} forEach (synchronizedObjects _logic);

private _mult = _logic getVariable ["ROOT_ADS_G_mult", 1];
private _immune = _logic getVariable ["ROOT_ADS_G_immune", false];
private _share = _logic getVariable ["ROOT_ADS_G_shareRadius", -1];
private _chance = _logic getVariable ["ROOT_ADS_G_bulletinChance", -1];
private _role = _logic getVariable ["ROOT_ADS_G_role", "patrol"];
private _follow = _logic getVariable ["ROOT_ADS_G_followThreshold", -1];
{ [_x, _mult, _immune, _share, _chance, _role, _follow] call API(setGroupProfile); } forEach _groups;
