#define ZEUS_MODULE(cls,fnc,name) \
    class cls: zen_modules_moduleBase { \
        author = "Root"; \
        _generalMacro = QUOTE(cls); \
        category = "ROOT_ADS"; \
        function = QFUNC(fnc); \
        displayName = name; \
        curatorCanAttach = 1; \
    }

#define ATTR_NUM(cls,label,tip,def) \
    class cls: Edit { \
        property = QUOTE(cls); \
        displayName = label; \
        tooltip = tip; \
        typeName = "NUMBER"; \
        defaultValue = def; \
    }

#define ATTR_STR(cls,label,tip,def) \
    class cls: Edit { \
        property = QUOTE(cls); \
        displayName = label; \
        tooltip = tip; \
        typeName = "STRING"; \
        defaultValue = def; \
    }

#define ATTR_BOOL(cls,label,tip,def) \
    class cls: Checkbox { \
        property = QUOTE(cls); \
        displayName = label; \
        tooltip = tip; \
        typeName = "BOOL"; \
        defaultValue = QUOTE(def); \
    }

// Keep / Off / On for boolean setting overrides
#define ATTR_TRI(cls,label,tip) \
    class cls: Combo { \
        property = QUOTE(cls); \
        displayName = label; \
        tooltip = tip; \
        typeName = "NUMBER"; \
        defaultValue = -1; \
        class Values { \
            class Keep { name = "Keep setting"; value = -1; }; \
            class Off { name = "Off"; value = 0; }; \
            class On { name = "On"; value = 1; }; \
        }; \
    }

#define EDEN_MODULE_BASE(name,fnc,trigger) \
    scope = 2; \
    scopeCurator = 0; \
    author = "Root"; \
    displayName = name; \
    category = "ROOT_ADS"; \
    function = QFUNC(fnc); \
    functionPriority = 1; \
    isGlobal = 0; \
    isTriggerActivated = trigger; \
    isDisposable = 0; \
    is3DEN = 0; \
    icon = "\a3\ui_f\data\igui\cfg\simpletasks\types\scout_ca.paa"

class CfgVehicles {
    // ------------------------------------------------------------------ Zeus (ZEN)
    class zen_modules_moduleBase;

    ZEUS_MODULE(ROOT_ADS_Zeus_Settings,zeusSettings,"Detection Settings");
    ZEUS_MODULE(ROOT_ADS_Zeus_AddZone,zeusAddZone,"Add Detection Zone");
    ZEUS_MODULE(ROOT_ADS_Zeus_RemoveZones,zeusRemoveZones,"Remove Detection Zones");
    ZEUS_MODULE(ROOT_ADS_Zeus_UnitCover,zeusUnitCover,"Unit Cover Profile");
    ZEUS_MODULE(ROOT_ADS_Zeus_Vehicle,zeusVehicle,"Vehicle Disguise");
    ZEUS_MODULE(ROOT_ADS_Zeus_GroupProfile,zeusGroupProfile,"AI Group Profile");
    ZEUS_MODULE(ROOT_ADS_Zeus_Compromise,zeusCompromise,"Compromise / Restore Cover");
    ZEUS_MODULE(ROOT_ADS_Zeus_Toggle,zeusToggle,"Enable / Disable RADS");
    ZEUS_MODULE(ROOT_ADS_Zeus_Bulletin,zeusBulletin,"Radio Bulletin");
    ZEUS_MODULE(ROOT_ADS_Zeus_Inspect,zeusInspect,"Inspect Detection Status");

    // ------------------------------------------------------------------ 3DEN
    class Logic;
    class Module_F: Logic {
        class AttributesBase {
            class Edit;
            class Combo;
            class Checkbox;
            class ModuleDescription;
        };
        class ModuleDescription;
    };

    class ROOT_ADS_Module_Settings: Module_F {
        EDEN_MODULE_BASE("Detection Settings",edenSettings,0);
        class Attributes: AttributesBase {
            ATTR_TRI(ROOT_ADS_S_enabled,"Enable RADS","Master switch for this mission.");
            ATTR_NUM(ROOT_ADS_S_buildRate,"Build rate (%/s)","Suspicion per second at full exposure. -1 = keep setting.",-1);
            ATTR_NUM(ROOT_ADS_S_decayRate,"Decay rate (%/s)","Suspicion lost per second unseen. -1 = keep setting.",-1);
            ATTR_NUM(ROOT_ADS_S_suspiciousThreshold,"Suspicious threshold (%)","-1 = keep setting.",-1);
            ATTR_NUM(ROOT_ADS_S_identifyThreshold,"Identify threshold (%)","-1 = keep setting.",-1);
            ATTR_NUM(ROOT_ADS_S_maxRange,"Max observation range (m)","-1 = keep setting.",-1);
            ATTR_NUM(ROOT_ADS_S_identifyRange,"Close identification range (m)","-1 = keep setting.",-1);
            ATTR_NUM(ROOT_ADS_S_instantRange,"Face-to-face range (m)","-1 = keep setting.",-1);
            ATTR_NUM(ROOT_ADS_S_forgetAfter,"Forget after (s)","-1 = keep setting.",-1);
            ATTR_NUM(ROOT_ADS_S_memoryTime,"Memory after exit (s)","-1 = keep setting.",-1);
            ATTR_NUM(ROOT_ADS_S_heatDuration,"Heat after firing (s)","-1 = keep setting.",-1);
            ATTR_NUM(ROOT_ADS_S_firedRadius,"Firing reveal radius (m)","-1 = keep setting.",-1);
            class ROOT_ADS_S_shareMode: Combo {
                property = "ROOT_ADS_S_shareMode";
                displayName = "Share on identification";
                tooltip = "What nearby friendly groups learn.";
                typeName = "NUMBER";
                defaultValue = -1;
                class Values {
                    class Keep { name = "Keep setting"; value = -1; };
                    class None { name = "Nothing"; value = 0; };
                    class Suspicion { name = "Suspicion"; value = 1; };
                    class Full { name = "Full identification"; value = 2; };
                };
            };
            ATTR_NUM(ROOT_ADS_S_shareRadius,"Share radius (m)","-1 = keep setting.",-1);
            ATTR_TRI(ROOT_ADS_S_bulletinEnabled,"Radio bulletins","Long-range radio bulletins on identification.");
            ATTR_NUM(ROOT_ADS_S_bulletinChance,"Bulletin chance (0-1)","-1 = keep setting.",-1);
            ATTR_NUM(ROOT_ADS_S_bulletinRange,"Bulletin range (m, 0 = side-wide)","-1 = keep setting.",-1);
            ATTR_NUM(ROOT_ADS_S_burnDuration,"Burned vehicle duration (s)","-1 = keep setting.",-1);
            ATTR_NUM(ROOT_ADS_S_wantedDuration,"Wanted duration (s)","-1 = keep setting.",-1);
            ATTR_TRI(ROOT_ADS_S_informantsEnabled,"Civilian informants","Civilians may report what they saw.");
            ATTR_TRI(ROOT_ADS_S_theftEnabled,"Stolen vehicles","Owners notice their vehicle being taken.");
            ATTR_TRI(ROOT_ADS_S_aiAware,"Suspicious groups go AWARE","");
            ATTR_TRI(ROOT_ADS_S_aiWatch,"Suspicious groups watch the vehicle","");
            ATTR_TRI(ROOT_ADS_S_aiInvestigate,"Suspicious groups investigate","");
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            description = "Overrides RADS CBA settings for this mission. Values of -1 / 'Keep setting' leave the CBA value alone. Can be trigger-activated by syncing a trigger.";
        };
    };

    class ROOT_ADS_Module_Zone: Module_F {
        EDEN_MODULE_BASE("Detection Zone",edenZone,1);
        canSetArea = 1;
        canSetAreaShape = 1;
        class AttributeValues {
            size3[] = {200, 200, -1};
            isRectangle = 0;
        };
        class Attributes: AttributesBase {
            ATTR_STR(ROOT_ADS_Z_label,"Label","Name shown in Zeus lists.","""""");
            class ROOT_ADS_Z_mode: Combo {
                property = "ROOT_ADS_Z_mode";
                displayName = "Mode";
                tooltip = "Multiplier: scale suspicion speed. No cover: restricted area, disguises do not work. Safe haven: no suspicion builds.";
                typeName = "NUMBER";
                defaultValue = 0;
                class Values {
                    class Mult { name = "Multiplier"; value = 0; };
                    class NoCover { name = "No cover (restricted)"; value = 1; };
                    class Safe { name = "Safe haven"; value = 2; };
                };
            };
            ATTR_NUM(ROOT_ADS_Z_build,"Build multiplier","Suspicion build multiplier inside the zone (Multiplier mode).",2);
            ATTR_NUM(ROOT_ADS_Z_decay,"Decay multiplier","Suspicion decay multiplier inside the zone (Multiplier mode).",1);
            ATTR_STR(ROOT_ADS_Z_sides,"Observer sides","Comma-separated sides affected (east, west, independent). Empty = all.","""""");
            ATTR_NUM(ROOT_ADS_Z_delay,"Delay (s)","Seconds after activation before the zone is active.",0);
            ATTR_NUM(ROOT_ADS_Z_duration,"Duration (s)","0 = permanent.",0);
            ATTR_NUM(ROOT_ADS_Z_hourFrom,"Active from hour","Daytime window start (0-24). -1 = always.",-1);
            ATTR_NUM(ROOT_ADS_Z_hourTo,"Active until hour","Daytime window end (0-24). -1 = always.",-1);
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            description = "Detection zone using the module area. Activates at mission start, or when a synced trigger fires.";
        };
    };

    class ROOT_ADS_Module_UnitCover: Module_F {
        EDEN_MODULE_BASE("Unit Cover Profile",edenUnitCover,1);
        class Attributes: AttributesBase {
            class ROOT_ADS_U_mode: Combo {
                property = "ROOT_ADS_U_mode";
                displayName = "Mode";
                tooltip = "Normal, exempt (never covered) or forced (covered in any vehicle regardless of side, heat and zones).";
                typeName = "STRING";
                defaultValue = """normal""";
                class Values {
                    class Normal { name = "Normal"; value = "normal"; };
                    class Exempt { name = "Exempt"; value = "exempt"; };
                    class Force { name = "Always covered"; value = "force"; };
                };
            };
            ATTR_NUM(ROOT_ADS_U_mult,"Suspicion multiplier","How fast AI grow suspicious of these units.",1);
            ATTR_NUM(ROOT_ADS_U_duration,"Duration (s)","Revert to normal after this long. 0 = permanent.",0);
            ATTR_BOOL(ROOT_ADS_U_allPlayers,"All players","Apply to every player instead of synced units.",false);
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            description = "Cover profile for synced units (or all players).";
        };
    };

    class ROOT_ADS_Module_Vehicle: Module_F {
        EDEN_MODULE_BASE("Vehicle Disguise",edenVehicle,1);
        class Attributes: AttributesBase {
            class ROOT_ADS_V_mode: Combo {
                property = "ROOT_ADS_V_mode";
                displayName = "Mode";
                tooltip = "Auto: by side and settings. Disguise: always. Never: no cover. Burned: recognised on sight.";
                typeName = "STRING";
                defaultValue = """disguise""";
                class Values {
                    class Auto { name = "Auto"; value = "auto"; };
                    class Disguise { name = "Always disguise"; value = "disguise"; };
                    class Never { name = "Never disguise"; value = "never"; };
                    class Burned { name = "Burned (all sides)"; value = "burned"; };
                };
            };
            ATTR_STR(ROOT_ADS_V_burnSides,"Burned for sides","Comma-separated sides that know this vehicle (east, west, independent). Empty = none.","""""");
            ATTR_NUM(ROOT_ADS_V_duration,"Duration (s)","Revert after this long. 0 = permanent.",0);
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            description = "Disguise behaviour for synced vehicles.";
        };
    };

    class ROOT_ADS_Module_GroupProfile: Module_F {
        EDEN_MODULE_BASE("AI Group Profile",edenGroupProfile,0);
        class Attributes: AttributesBase {
            ATTR_NUM(ROOT_ADS_G_mult,"Suspicion multiplier","Vigilance of the synced units' groups (2-3 = checkpoint guards, 0.5 = sleepy).",1);
            ATTR_BOOL(ROOT_ADS_G_immune,"Immune to disguises","These groups see through every disguise (vanilla detection).",false);
            ATTR_NUM(ROOT_ADS_G_shareRadius,"Share radius (m)","-1 = setting.",-1);
            ATTR_NUM(ROOT_ADS_G_bulletinChance,"Bulletin chance (0-1)","-1 = setting.",-1);
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            description = "Observer profile for the groups of synced AI units.";
        };
    };

    class ROOT_ADS_Module_Compromise: Module_F {
        EDEN_MODULE_BASE("Compromise / Restore Cover",edenCompromise,1);
        class Attributes: AttributesBase {
            class ROOT_ADS_C_action: Combo {
                property = "ROOT_ADS_C_action";
                displayName = "Action";
                tooltip = "Compromise: hostile groups identify the units. Restore: hostile groups forget them.";
                typeName = "NUMBER";
                defaultValue = 0;
                class Values {
                    class Compromise { name = "Compromise"; value = 0; };
                    class Restore { name = "Restore cover"; value = 1; };
                    class RestoreClear { name = "Restore cover + clear burned/wanted"; value = 2; };
                };
            };
            ATTR_STR(ROOT_ADS_C_sides,"Observer sides","Comma-separated sides (east, west, independent). Empty = all hostile.","""""");
            ATTR_NUM(ROOT_ADS_C_radius,"Radius (m)","-1 = unlimited.",-1);
            ATTR_BOOL(ROOT_ADS_C_allPlayers,"All players","Apply to every player instead of synced units.",true);
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            description = "Sync a trigger: when it fires, the synced units (or all players) are compromised or get their cover back.";
        };
    };

    class ROOT_ADS_Module_Toggle: Module_F {
        EDEN_MODULE_BASE("Enable / Disable RADS",edenToggle,1);
        class Attributes: AttributesBase {
            class ROOT_ADS_T_action: Combo {
                property = "ROOT_ADS_T_action";
                displayName = "Action";
                tooltip = "";
                typeName = "NUMBER";
                defaultValue = 0;
                class Values {
                    class Disable { name = "Disable"; value = 0; };
                    class Enable { name = "Enable"; value = 1; };
                    class Clear { name = "Back to CBA setting"; value = 2; };
                };
            };
            ATTR_NUM(ROOT_ADS_T_delay,"Delay (s)","Seconds after activation.",0);
            ATTR_NUM(ROOT_ADS_T_duration,"Duration (s)","Revert after this long. 0 = permanent.",0);
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            description = "Turns RADS on or off at mission start, after a delay, or when a synced trigger fires.";
        };
    };

    class ROOT_ADS_Module_Bulletin: Module_F {
        EDEN_MODULE_BASE("Radio Bulletin",edenBulletin,1);
        class Attributes: AttributesBase {
            ATTR_STR(ROOT_ADS_B_sides,"Receiving sides","Comma-separated sides (east, west, independent).","""east""");
            ATTR_BOOL(ROOT_ADS_B_burn,"Burn vehicles","Synced vehicles (and vehicles of synced units) are recognised on sight.",true);
            ATTR_BOOL(ROOT_ADS_B_wanted,"Mark wanted","Synced units are wanted.",true);
            ATTR_BOOL(ROOT_ADS_B_clear,"Clear instead","Remove burned/wanted status instead of adding it.",false);
            ATTR_NUM(ROOT_ADS_B_duration,"Duration (s)","-1 = setting.",-1);
            ATTR_NUM(ROOT_ADS_B_range,"Range (m)","From the module position. 0 = side-wide.",0);
            class ModuleDescription: ModuleDescription {};
        };
        class ModuleDescription: ModuleDescription {
            description = "Sync units/vehicles (and optionally a trigger): broadcasts them as hostile to the receiving sides.";
        };
    };
};
