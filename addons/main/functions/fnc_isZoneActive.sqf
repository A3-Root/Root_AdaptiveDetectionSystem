#include "..\script_component.hpp"
/*
 * Author: Root
 * True when a detection zone is inside its mission-time window and daytime window.
 *
 * Arguments:
 * 0: Zone <ARRAY>
 *
 * Return Value:
 * Active <BOOL>
 *
 * Public: No
 */

params ["_zone"];

private _now = CBA_missionTime;
if (_now < (_zone select Z_START)) exitWith {false};
private _end = _zone select Z_END;
if (_end >= 0 && _now > _end) exitWith {false};

private _from = _zone select Z_HFROM;
private _to = _zone select Z_HTO;
if (_from < 0 || _to < 0) exitWith {true};

private _hour = dayTime;
if (_from <= _to) then {
    _hour >= _from && _hour < _to
} else {
    // window wraps past midnight
    _hour >= _from || _hour < _to
}
