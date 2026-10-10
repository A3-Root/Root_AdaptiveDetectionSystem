#include "script_component.hpp"
ADDON = false;

// Restrained or surrendering units cannot pass as harmless occupants
MVAR(coverConditions) pushBack {
    params ["_unit"];
    !(_unit getVariable ["ace_captives_isHandcuffed", false]) && {!(_unit getVariable ["ace_captives_isSurrendering", false])}
};

ADDON = true;
