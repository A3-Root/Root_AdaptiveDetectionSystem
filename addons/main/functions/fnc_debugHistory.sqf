#include "..\script_component.hpp"
/*
 * Author: Root
 * Appends a line to an entry's debug history, keeping only the configured number of lines.
 *
 * Arguments:
 * 0: Entry <ARRAY>
 * 1: Line <STRING>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_entry", "_line"];

private _history = _entry param [D_HISTORY, []];
_history pushBack _line;
while {count _history > (round MSET(debugHistory) max 1)} do { _history deleteAt 0; };
_entry set [D_HISTORY, _history];
