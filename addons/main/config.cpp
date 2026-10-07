#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = "Root's Adaptive Detection System - Main";
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"cba_main", "cba_settings", "cba_xeh", "cba_events", "cba_common"};
        author = "Root";
        url = "https://github.com/A3-Root/Root_AdaptiveDetectionSystem";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
