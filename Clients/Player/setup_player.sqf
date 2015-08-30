// Aquí deixem a 0 els players i los vestimos de Sufjan Stevens
// Muahahahahahha

removeAllContainers player;
removeAllWeapons player;
removeAllAssignedItems player;
removeHeadgear player;
removeGoggles player;
removeAllItems player;
player setVariable ["BIS_noCoreConversations", true];
player setVariable ["JoinedGame",true,true];
player disableConversation true;
player enableFatigue false;	

player linkItem "itemGPS";
player linkItem "itemMap";

player addUniform "U_B_CombatUniform_mcam_tshirt";
player addHeadgear "H_Shemag_khk";
[player,"sandboxID"] call BIS_fnc_setUnitInsignia;  // <-- see description.ext
