// setup.sqf
// setup for SANDBOX

SANDBOX_InGame = false;
SANDBOX_ServerOn = true;
SANDBOX_GamesPlayed = 0;


call SANDBOX_fnc_serverConfig; // empty file at the moment
call SANDBOX_fnc_playerConfig; // min and max number players
call SANDBOX_fnc_mapSetup; 


