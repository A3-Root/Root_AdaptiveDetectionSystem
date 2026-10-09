#include "\x\cba\addons\main\script_macros_common.hpp"

#define DFUNC(var1) TRIPLES(ADDON,fnc,var1)

#ifdef DISABLE_COMPILE_CACHE
    #undef PREP
    #define PREP(fncName) DFUNC(fncName) = compile preprocessFileLineNumbers QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)
#else
    #undef PREP
    #define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call CBA_fnc_compileFunction
#endif

// Public API: functions\api\fnc_<name>.sqf -> root_ads_fnc_<name>
#define PREP_API(fncName) [QPATHTOF(functions\api\DOUBLES(fnc,fncName).sqf), QUOTE(TRIPLES(PREFIX,fnc,fncName))] call CBA_fnc_compileFunction
#define API(fncName) TRIPLES(PREFIX,fnc,fncName)
#define QAPI(fncName) QUOTE(API(fncName))

// All mod state lives under the main component namespace so every component shares it
#define MVAR(var) TRIPLES(PREFIX,main,var)
#define QMVAR(var) QUOTE(MVAR(var))
#define MFUNC(var) TRIPLES(PREFIX,main,DOUBLES(fnc,var))

// Live setting read: runtime override (Zeus/3DEN/API) wins over the CBA setting value
#define MSET(var) (missionNamespace getVariable [QUOTE(TRIPLES(PREFIX,main,DOUBLES(ov,var))), MVAR(var)])

// Per-group, per-unit knowledge entry layout
#define D_UNIT 0
#define D_SUSP 1
#define D_STATE 2
#define D_LASTEXP 3
#define D_LASTUPD 4
#define D_PASSES 5
#define D_VISIBLE 6
#define D_STATIONARY 7
#define D_IGNORED 8
#define D_HOOKS 9
#define D_COMPTIME 10
#define D_VEH 11
#define D_AGED 12
#define D_SWAPS 13
#define D_SWAPTIME 14
#define D_COMPVEH 15
#define D_HISTORY 16
#define D_META 17
#define D_SIG 18
#define D_SYNCSENT 19
#define D_CLEARED 20
#define NEW_ENTRY(unit) [unit, 0, ST_UNAWARE, -1000, time, 0, false, 0, false, false, -1000, vehicle unit, false, 0, -1e6, objNull, [], 0, "", 0, -1]

#define ST_UNAWARE 0
#define ST_SUSPICIOUS 1
#define ST_SEARCHING 2
#define ST_COMPROMISED 3

// Zone layout: [id, area, mode, buildMul, decayMul, sides, start, end, hourFrom, hourTo, label, marker, truce]
#define Z_ID 0
#define Z_AREA 1
#define Z_MODE 2
#define Z_BUILD 3
#define Z_DECAY 4
#define Z_SIDES 5
#define Z_START 6
#define Z_END 7
#define Z_HFROM 8
#define Z_HTO 9
#define Z_LABEL 10
#define Z_MARKER 11
#define Z_TRUCE 12

// Truce options of a safe zone: [enabled, maxStay, warnBefore, careless, breakScope, breakOnAim]
#define T_ENABLED 0
#define T_MAXSTAY 1
#define T_WARN 2
#define T_CARELESS 3
#define T_SCOPE 4
#define T_AIM 5

#define ZONE_MULTIPLIER 0
#define ZONE_NOCOVER 1
#define ZONE_SAFE 2

#define STATE_NAMES ["UNAWARE", "SUSPICIOUS", "SEARCHING", "COMPROMISED"]

// Gear slots compared against the enemy reference kit
#define GEAR_SLOTS ["uniform", "vest", "headgear", "primary", "launcher", "backpack", "facewear"]

#define RADS_DEBUG (MSET(debugLog))
#define RLOG(msg) if (RADS_DEBUG) then { diag_log text format ["[RADS] %1", msg] }
#define RLOG_1(msg,a1) if (RADS_DEBUG) then { diag_log text format ["[RADS] " + msg, a1] }
#define RLOG_2(msg,a1,a2) if (RADS_DEBUG) then { diag_log text format ["[RADS] " + msg, a1, a2] }
#define RLOG_3(msg,a1,a2,a3) if (RADS_DEBUG) then { diag_log text format ["[RADS] " + msg, a1, a2, a3] }
#define RLOG_4(msg,a1,a2,a3,a4) if (RADS_DEBUG) then { diag_log text format ["[RADS] " + msg, a1, a2, a3, a4] }
