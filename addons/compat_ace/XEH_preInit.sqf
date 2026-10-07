#include "script_component.hpp"
ADDON = false;

// Restrained or surrendering units cannot pass as harmless occupants
MVAR(coverConditions) pushBack {
    params ["_unit"];
    !(_unit getVariable ["ace_captives_isHandcuffed", false]) && {!(_unit getVariable ["ace_captives_isSurrendering", false])}
};

[QGVAR(statusAction), "CHECKBOX", ["ACE self-action: cover status", "Adds 'Check cover status' to the ACE self-interaction menu while in a vehicle."], ["RADS - Adaptive Detection", "16 Notifications"], true, false] call CBA_fnc_addSetting;

ADDON = true;
