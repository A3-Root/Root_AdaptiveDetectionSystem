#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = "Root's Adaptive Detection System - Modules";
        units[] = {
            "ROOT_ADS_Zeus_Settings",
            "ROOT_ADS_Zeus_SyncSettings",
            "ROOT_ADS_Zeus_PursuitSettings",
            "ROOT_ADS_Zeus_TruceSettings",
            "ROOT_ADS_Zeus_AddZone",
            "ROOT_ADS_Zeus_RemoveZones",
            "ROOT_ADS_Zeus_UnitCover",
            "ROOT_ADS_Zeus_Vehicle",
            "ROOT_ADS_Zeus_GroupProfile",
            "ROOT_ADS_Zeus_GearReference",
            "ROOT_ADS_Zeus_OrderPursuit",
            "ROOT_ADS_Zeus_Compromise",
            "ROOT_ADS_Zeus_Toggle",
            "ROOT_ADS_Zeus_Bulletin",
            "ROOT_ADS_Zeus_Inspect",
            "ROOT_ADS_Module_Settings",
            "ROOT_ADS_Module_PursuitSettings",
            "ROOT_ADS_Module_Zone",
            "ROOT_ADS_Module_UnitCover",
            "ROOT_ADS_Module_Vehicle",
            "ROOT_ADS_Module_GroupProfile",
            "ROOT_ADS_Module_GearReference",
            "ROOT_ADS_Module_Compromise",
            "ROOT_ADS_Module_Toggle",
            "ROOT_ADS_Module_Bulletin"
        };
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"root_ads_main", "cba_main", "zen_custom_modules", "zen_dialog", "A3_Modules_F", "A3_Modules_F_Curator"};
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
