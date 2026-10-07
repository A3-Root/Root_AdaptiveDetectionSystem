#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = "Root's Adaptive Detection System - Modules";
        units[] = {
            "ROOT_RADS_Zeus_Settings",
            "ROOT_RADS_Zeus_AddZone",
            "ROOT_RADS_Zeus_RemoveZones",
            "ROOT_RADS_Zeus_UnitCover",
            "ROOT_RADS_Zeus_Vehicle",
            "ROOT_RADS_Zeus_GroupProfile",
            "ROOT_RADS_Zeus_Compromise",
            "ROOT_RADS_Zeus_Toggle",
            "ROOT_RADS_Zeus_Bulletin",
            "ROOT_RADS_Zeus_Inspect",
            "ROOT_RADS_Module_Settings",
            "ROOT_RADS_Module_Zone",
            "ROOT_RADS_Module_UnitCover",
            "ROOT_RADS_Module_Vehicle",
            "ROOT_RADS_Module_GroupProfile",
            "ROOT_RADS_Module_Compromise",
            "ROOT_RADS_Module_Toggle",
            "ROOT_RADS_Module_Bulletin"
        };
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"root_rads_main", "cba_main", "zen_custom_modules", "zen_dialog", "A3_Modules_F", "A3_Modules_F_Curator"};
        author = "Root";
        url = "https://github.com/A3-Root/Root_AdaptiveDetectionSystem";
        VERSION_CONFIG;
    };
};

class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preInit));
    };
};

#include "CfgFactionClasses.hpp"
#include "CfgVehicles.hpp"
