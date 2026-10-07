class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preInit));
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_postInit));
    };
};

// Hostile acts against AI and attacks on covered vehicles. These fire where the hit object is local,
// which follows AI ownership (server/HC/client) automatically.
class Extended_Hit_EventHandlers {
    class CAManBase {
        ADDON = QUOTE(call FUNC(handleUnitHit));
    };
    class LandVehicle {
        ADDON = QUOTE(call FUNC(handleVehicleHit));
    };
    class Air {
        ADDON = QUOTE(call FUNC(handleVehicleHit));
    };
    class Ship {
        ADDON = QUOTE(call FUNC(handleVehicleHit));
    };
};

class Extended_Killed_EventHandlers {
    class CAManBase {
        ADDON = QUOTE(call FUNC(handleUnitKilled));
    };
};

// Records which AI group last crewed a vehicle so a later theft can burn it
class Extended_GetIn_EventHandlers {
    class AllVehicles {
        ADDON = QUOTE(call FUNC(handleVehicleCrewed));
    };
};

class Extended_GetOut_EventHandlers {
    class AllVehicles {
        ADDON = QUOTE(call FUNC(handleVehicleCrewed));
    };
};
