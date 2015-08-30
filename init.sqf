/**
 *  Sandbox initialization code 
 */

enableSaving[false, false];

/**
 * taken from ArmA3 Wasteland init.sqf
 * https://github.com/A3Wasteland/ArmA3_Wasteland.Altis/blob/master/init.sqf
 */


#define DEBUG true;
#define DEBUG_LEVEL 3;

// global variables
SANDBOX_GameStarted = false;

// return the absolute dir path where is located the mission
_descExtPath = str missionConfigFile;
currMissionDir = compileFinal str (_descExtPath select [0, count _descExtPath - 15]);


