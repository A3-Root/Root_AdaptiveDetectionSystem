#include "..\script_component.hpp"
/*
 * Author: Root
 * Current effective value of a RADS setting (runtime override, else CBA setting).
 *
 * Arguments:
 * 0: Setting name without prefix <STRING>
 *
 * Return Value:
 * Value <ANY>
 *
 * Public: No
 */

params [["_name", "", [""]]];

missionNamespace getVariable ["root_rads_main_ov_" + _name, missionNamespace getVariable ("root_rads_main_" + _name)]
