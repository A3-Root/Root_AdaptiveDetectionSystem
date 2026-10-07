#include "..\..\script_component.hpp"
/*
 * Author: Root
 * Removes a detection zone by id, or all zones. Runs on the server (forwarded automatically).
 *
 * Arguments:
 * 0: Zone id, "" or "all" = every zone <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Example:
 * ["rads_zone_1"] call root_rads_fnc_removeZone
 *
 * Public: Yes
 */

params [["_id", "", [""]]];

if (!isServer) exitWith { [QGVAR(api), ["removeZone", _this]] call CBA_fnc_serverEvent; };

private _all = _id in ["", "all"];
private _keep = [];
{
    if (_all || {(_x select Z_ID) == _id}) then {
        if ((_x select Z_MARKER) != "") then { deleteMarker (_x select Z_MARKER); };
    } else {
        _keep pushBack _x;
    };
} forEach GVAR(zones);

if (count _keep != count GVAR(zones)) then {
    GVAR(zones) = _keep;
    publicVariable QGVAR(zones);
};
