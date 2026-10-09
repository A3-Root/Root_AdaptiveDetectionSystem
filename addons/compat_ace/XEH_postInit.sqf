#include "script_component.hpp"

if (!hasInterface) exitWith {};

private _action = [
    QGVAR(checkCover),
    localize "STR_root_ads_main_checkCover",
    "\a3\ui_f\data\igui\cfg\simpletasks\types\scout_ca.paa",
    { hint parseText ([_player] call MFUNC(coverStatusText)); },
    { GVAR(statusAction) && {!isNull objectParent _player} }
] call ace_interact_menu_fnc_createAction;

["CAManBase", 1, ["ACE_SelfActions"], _action, true] call ace_interact_menu_fnc_addActionToClass;
