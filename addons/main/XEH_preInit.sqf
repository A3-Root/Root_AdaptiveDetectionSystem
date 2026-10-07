#include "script_component.hpp"
ADDON = false;

#include "XEH_PREP.hpp"
#include "initSettings.inc.sqf"

// Extra cover conditions registered by compat addons: {params ["_unit"]; bool}
GVAR(coverConditions) = [];
GVAR(queue) = [];
GVAR(cycleStart) = -1;
GVAR(covered) = [];

if (isNil QGVAR(zones)) then { GVAR(zones) = []; };

ADDON = true;
