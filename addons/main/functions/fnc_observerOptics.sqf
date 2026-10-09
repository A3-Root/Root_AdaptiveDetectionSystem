#include "..\script_component.hpp"
/*
 * Author: Root
 * Range multiplier of an observer's optics: soldiers in a vehicle's gunner / commander seats look
 * through sights and see farther (linear range, the field of view is unchanged). Per-vehicle value
 * from the Vehicle module / API (setVehicleMode "optics") wins. Cached per observer for 5 s.
 *
 * Arguments:
 * 0: Observer <OBJECT>
 *
 * Return Value:
 * Range multiplier (1 = naked eye) <NUMBER>
 *
 * Public: No
 */

params ["_observer"];

private _veh = objectParent _observer;
if (isNull _veh || {!MSET(vehOpticsEnabled)}) exitWith {1};

private _cache = _observer getVariable [QGVAR(opticsCache), [-1, objNull, false, 1]];
_cache params ["_until", "_cachedVeh", "_cachedOut", "_cachedMult"];
private _out = isTurnedOut _observer;
if (time < _until && _cachedVeh == _veh && _cachedOut == _out) exitWith {_cachedMult};

private _custom = _veh getVariable [QGVAR(opticsMult), -1];
private _mult = switch (true) do {
    case (_out): { 1 };
    case (_observer == driver _veh): { MSET(vehDriverOpticsMult) };
    default {
        private _role = assignedVehicleRole _observer;
        if (toLower (_role param [0, ""]) != "turret") then {1} else {
            private _turret = [_veh, _role param [1, []]] call CBA_fnc_getTurret;
            // firing-from-vehicle seats use the soldier's own weapon sights
            if (getNumber (_turret >> "isPersonTurret") > 0 || {getText (_turret >> "gunnerOpticsModel") == "" && {!isClass (_turret >> "OpticsIn")}}) then {1} else {
                [_custom, MSET(vehOpticsMult)] select (_custom < 0)
            };
        };
    };
};

_observer setVariable [QGVAR(opticsCache), [time + 5, _veh, _out, _mult]];
if (RADS_DEBUG && {_mult != _cachedMult || _cachedVeh != _veh}) then {
    ["OPTICS", format ["%1 in %2 (%3) sees with optics x%4 (vehicle override %5)", name _observer, typeOf _veh, ["seat", "turned out"] select _out, _mult toFixed 2, _custom], group _observer] call FUNC(debugLog);
};
_mult
