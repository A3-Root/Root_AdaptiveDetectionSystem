#include "..\script_component.hpp"
/*
 * Author: Root
 * True when the vehicle carries a real weapon on any turret (horns, smoke and flare launchers and
 * laser designators do not count). Cached per vehicle class.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 *
 * Return Value:
 * Armed <BOOL>
 *
 * Public: No
 */

params ["_veh"];

if (isNil QGVAR(armedCache)) then { GVAR(armedCache) = createHashMap; };
private _type = typeOf _veh;
private _cached = GVAR(armedCache) get _type;
if (!isNil "_cached") exitWith {_cached};

private _harmless = ["horn", "smoke", "flare", "cmlauncher", "laserdesignator", "searchlight"];
private _armed = (([[-1]] + allTurrets [_veh, false]) findIf {
    (_veh weaponsTurret _x) findIf {
        private _weapon = toLower _x;
        _harmless findIf {_x in _weapon} == -1
    } > -1
}) > -1;

GVAR(armedCache) set [_type, _armed];
_armed
