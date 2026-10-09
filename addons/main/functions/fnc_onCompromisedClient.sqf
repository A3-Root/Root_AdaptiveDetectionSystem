#include "..\script_component.hpp"
/*
 * Author: Root
 * Event (clients): tells the identified player, and curators, about an identification.
 *
 * Arguments:
 * 0: Group <GROUP>
 * 1: Unit <OBJECT>
 * 2: Reason <STRING>
 * 3: Side <SIDE>
 *
 * Return Value:
 * None
 *
 * Public: No
 */

params ["_grp", "_unit", "_reason", "_side"];

if (_unit == player && GVAR(notifyCompromised) && MSET(allowWatchedHints)) then {
    hint parseText format ["<t color='#ff4444' size='1.2'>%1</t><br/>%2", localize LSTRING(identifiedTitle), format [localize LSTRING(identifiedText), groupId _grp]];
};

if (GVAR(notifyZeus) && {!isNull getAssignedCuratorLogic player} && {!isNil "zen_common_fnc_showMessage"}) then {
    [format ["RADS: %1 (%2) identified %3 - %4", groupId _grp, _side, name _unit, _reason]] call zen_common_fnc_showMessage;
};
