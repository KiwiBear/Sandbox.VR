/**
 *  Sandbox setup 
 */


/**
 * taken from ArmA3 Wasteland init.sqf
 * https://github.com/A3Wasteland/ArmA3_Wasteland.Altis/blob/master/init.sqf
 */

#define DEBUG true;
#define DEBUG_LEVEL 3;

// return the absolute dir path where is located the mission
_descExtPath = str missionConfigFile;
currMissionDir = compileFinal str (_descExtPath select [0, count _descExtPath - 15]);

// global variables
startPlayerPosition = getPos player; 



// https://community.bistudio.com/wiki/cutText
9999 cutText ["Welcome to ArmA 3 Sandbox, please follow the instructions", "PLAIN", 1, true];

#include "sandbox\sandbox_start.sqf";