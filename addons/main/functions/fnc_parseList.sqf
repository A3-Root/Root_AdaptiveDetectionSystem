#include "..\script_component.hpp"
/*
 * Author: Root
 * Splits a comma-separated settings string into a lower-case array (cached per string).
 *
 * Arguments:
 * 0: List string <STRING>
 *
 * Return Value:
 * Entries <ARRAY>
 *
 * Public: No
 */

params [["_string", "", [""]]];

if (isNil QGVAR(listCache)) then { GVAR(listCache) = createHashMap; };

private _cached = GVAR(listCache) get _string;
if (!isNil "_cached") exitWith { _cached };

private _list = ((_string splitString ", ;") select {_x != ""}) apply {toLower _x};
GVAR(listCache) set [_string, _list];
_list
