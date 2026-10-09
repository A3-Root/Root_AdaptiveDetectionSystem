#include "script_component.hpp"
ADDON = false;

// Restrained or surrendering units cannot pass as harmless occupants
MVAR(coverConditions) pushBack {
    params ["_unit"];
    !(_unit getVariable ["ace_captives_isHandcuffed", false]) && {!(_unit getVariable ["ace_captives_isSurrendering", false])}
};

// Titles live in the main stringtable so the category lines up with the main settings
[QGVAR(statusAction), "CHECKBOX", ["STR_root_ads_main_statusAction", "STR_root_ads_main_statusAction_desc"], ["STR_root_ads_main_cat", "STR_root_ads_main_cat_notify"], true, false] call CBA_fnc_addSetting;

ADDON = true;
