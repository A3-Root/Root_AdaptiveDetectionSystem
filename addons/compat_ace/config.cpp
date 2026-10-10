#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = "Root's Adaptive Detection System - ACE Compatibility";
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"root_ads_main", "ace_common"};
        skipWhenMissingDependencies = 1;
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
