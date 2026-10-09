#include "..\script_component.hpp"
/*
 * Author: Root
 * Short fingerprint of how a unit looks from outside: its vehicle and its main kit. Shared and
 * synced suspicion only sticks while the fingerprint stays the same, so changing vehicle,
 * uniform, vest, headgear or weapon shakes it off.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Signature <STRING>
 *
 * Public: No
 */

params ["_unit"];

private _veh = vehicle _unit;
hashValue [[netId _veh, ""] select (_veh == _unit), uniform _unit, vest _unit, headgear _unit, primaryWeapon _unit]
