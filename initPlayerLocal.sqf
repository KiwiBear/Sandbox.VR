// Executed locally when player joins mission (includes both mission start and JIP). See initialization order for details about when the script is exactly executed.
// https://community.bistudio.com/wiki/Event_Scripts

// onPreloadFinished: https://community.bistudio.com/wiki/onPreloadFinished
// Defines an action performed after the preload screen finished.
onPreloadFinished {
	enableEnvironment false; // Enable/disable environmental effects (ambient life + sound).
	TRUE_UID = getplayeruid player;
	call SANDBOX_fnc_clientSetup;
	[] spawn SANDBOX_fnc_clientStart;
};		