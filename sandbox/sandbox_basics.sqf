
/**
 * Create a simple group on Player is the Leader
 * 
*/

sandbox_spawnBlueForUnits = 
{
	// spawn units close to player
	_pos = [getPos player, 0, 10, 2, 0, 35, 0] call BIS_fnc_findSafePos;
	_bluefor0 = group player createUnit ["B_soldier_exp_F", _pos, [], 100, "FORM"];
	sleep 0.25;
	_bluefor1 = group player createUnit ["B_Soldier_A_F", _pos, [], 100, "FORM"];
	sleep 0.25;
	_bluefor2 = group player createUnit ["B_Soldier_SL_F", _pos, [], 100, "FORM"];
	sleep 0.25;
	// player is leader
	// group player selectLeader player;
};





/**
 * Spawns a Enemy heli and moves towards to player
 * Using bis_fnc_spawnvehicle a BIS_fnc_spawnGroup
 * Example: Open Debugger and exec this:
 * [getMarkerPos "EastBASE", getMarkerPos "WestBASE"] call sandbox_spawnHeliEnemy;
 */
sandbox_spawnHeliEnemy = { 
	
	private ["_spawnAt", "_targetAt"];
	_spawnAt = _this select 0;
	_targetAt = _this select 1;
	// Create a flying vehicle type with all crew (including turrets)
	
	_grpEAST = creategroup east;
	// spawms at EAST mark
	_posHeli = [_spawnAt, 10, 20, 10, 0, 5, 0] call BIS_fnc_findSafePos;
	//_heliEnemyTransport = "I_Heli_Transport_02_F" createVehicle _posHeli;
	_heliEnemyTransport = "O_Heli_Transport_04_covered_F" createVehicle _posHeli;
	

	// FAILED bis_fnc_spawnvehicle with moveInCargo
	//_posHeliArmed = [getPos player, 100, 200, 10, 0, 5, 0] call BIS_fnc_findSafePos;
	// _heliEnemyTransport = [_posHeliTransport, 180, "O_Heli_Transport_04_ammo_black_F", _grpEAST] call bis_fnc_spawnvehicle;
	//_heliEnemyTransport = [_posHeliTransport, 180, "O_Truck_02_transport_F", independent] call bis_fnc_spawnvehicle;
	//_heliEnemyAttack = [_posHeliArmed, 180, "O_Heli_Light_02_F", _grpEAST] call bis_fnc_spawnvehicle;

	_posGrp = [_spawnAt, 10, 30, 20, 0, 5, 0] call BIS_fnc_findSafePos;
	_enemyGroup1 = [_posGrp, side _grpEAST, [
		"O_sniper_F",
		"O_soldier_UAV_F",
		"O_soldier_UAV_F",
		"O_soldier_UAV_F", 
		"O_helicrew_F",
		"I_Soldier_AAA_F",
		"I_Soldier_AAA_F",
		"O_Soldier_AA_F",
		"O_Soldier_AA_F",
		"O_Soldier_AA_F",
		"O_Soldier_AA_F",
		"O_support_GMG_F",
		"O_support_GMG_F",
		"O_support_GMG_F",
		"O_support_GMG_F"
	],[],[],[],[],[],180] call BIS_fnc_spawnGroup;
	

	{ _x moveInCargo _heliEnemyTransport; sleep 0.5; } foreach units _enemyGroup1;
	
	_pilot = _grpEAST createUnit ["C_Driver_4_F", [0, 0, 0], [], 100, "FORM"];
	_pilot moveInDriver _heliEnemyTransport;

	_wp1 = _grpEAST addwaypoint [_targetAt, 250]; // finding a safer position for landing
	_wp1 setWaypointType "TR UNLOAD";
	_wp1 setWaypointStatements ["","hint 'They are coming!'; _heliEnemyTransport land ""GET OUT"""];

	// Wait till the player's group is out of the helo.
	waitUntil{{_x in _heliEnemyTransport} count units group _unit == 0};

	// Once they are out, set a waypoint to the Target Base 
	_wp2 = _grpEAST addWaypoint [_targetAt, 0];
	_wp2 setwaypointtype "MOVE";
	_wp2 setWaypointSpeed "FULL";
	_wp2 setWaypointBehaviour "COMBAT";
};

/**
 * Spawns a HeliTransport and moves to a given position
 * Waypoints style
 * Example: 
 * [getPos player] call sandbox_spawnHeliTransport;
 */

sandbox_spawnHeliTransport = {
	private ["_spawnAt"];

	_spawnAt = _this select 0;

	// get everyone inside that belongs to the player group
	// http://www.armaholic.com/page.php?id=6197 ?
	// this is the "fast" way
	//{ _x moveInCargo _heliTransport; sleep 2.0} foreach units group player;

	// spawns a helitransport close to trigger
	_pos = [_spawnAt, 10, 50, 25, 0, 5, 0] call BIS_fnc_findSafePos;
	_heliTransport = "B_Heli_Transport_03_F" createVehicle _pos;
	_heliTransport setVectorDir [random(1), random(1), 0];

	// spawns a pilot and move in Cargo as a driver
	sleep 1.0;
	_grpCIV = createGroup civilian;
	_pos = [[0, 0, 0], 10, 50, 5, 0, 5, 0] call BIS_fnc_findSafePos;
	_pilot = _grpCIV createUnit ["C_Driver_4_F", _pos, [], 100, "FORM"];
	hint "";
	_pilot moveInDriver _heliTransport;
	_pilot action ["engineOn", _heliTransport];
	

	// temporaly, we change the group according the Civ driver
	// if not, they never getin to the vehicle
	hint "Everyone moves to the Heli!";
	_units =  units group player;
	units group player joinSilent _grpCIV;

	_wp1 = _grpCIV addWaypoint [getPos _heliTransport, 0];
	_wp1 setWaypointType "GETIN";
	_wp1 setWaypointSpeed "FULL";
	_wp1 setwaypointstatements ["true", "({_x in _heliTransport} count units _grpCIV) == (count units _grpCIV)"];

	// move a point
	_wp2 = _grpCIV addWaypoint [getMarkerPos 'WestBASE', 0];
	_wp2 setWaypointType "MOVE";
	_wp2 setWaypointSpeed "FULL";
	_wp2 setwaypointstatements ["true", "hint 'An enemy helicopter is coming to Base...'; [getMarkerPos 'EastBASE', getMarkerPos 'WestBASE'] call sandbox_spawnHeliEnemy;"];

	_wp3 = _grpCIV  addWaypoint [getMarkerPos 'WestBASE', 0];
	_wp3 setWaypointType "GETOUT";
	_wp3 setWaypointSpeed "LIMITED";
	// return to the original group
	// get out and spawns a enemey heli
	_wp3 setwaypointstatements ["true", "hint 'landing...'; _grpBlueFor = createGroup west; units group player joinSilent _grpBlueFor; "];
};


sandbox_enemyChasePlayer = 
{

	// call the function, call help team!
	hint "Added a new action to call friendly units!";
	player addAction ["Add friendly units", {
		[] call sandbox_spawnBlueForUnits;
	}];


	// spawn opfor soldier random safe location 
	[] call sandbox_spawnOpForUnits;
	
	hint "Good job!";
	// Now we remove the whole spheres and create one in a random place close to player
	// Sure we can trasverse the class Vehicles and detect its type but for now...
	// https://community.bistudio.com/wiki/missionConfigFile
	
	_numVehicles = getNumber (missionConfigFile >> "MissionSQM" >> "Mission" >>  "Vehicles" >> "items");

	for "_i" from 0 to _numVehicles - 1 do {
		_class = format ["Item%1", _i];
		_vehicle  = getText (missionConfigFile >> "MissionSQM" >> "Mission" >> "Vehicles" >> _class >> "vehicle" );
		sleep 0.25;
		if (_vehicle == "Sign_Sphere200cm_F") then {
			_text  = getText (missionConfigFile >> "MissionSQM" >> "Mission" >> "Vehicles" >> _class >> "text" );
			deleteVehicle call compile _text;
		};
		if (_vehicle == "Sign_Arrow_Large_F") then {
			_text  = getText (missionConfigFile >> "MissionSQM" >> "Mission" >> "Vehicles" >> _class >> "text" );
			call compile _text setPos [0, 0, getPos Arrow select 2];
		}
	};
	
	
	_posX = (getPos player select 0) + (round(random 50) - 10);
	_posY = (getPos player select 1) + (round(random 50) - 10);
	_posZ = getPos player select 2;
	_sphere = "Sign_Sphere200cm_F" createVehicle [_posX, _posY, _posZ];
	// move Arrow to new sphere
	_z = getPos Arrow select 2;
	Arrow setPos [getPos _sphere select 0, getPos _sphere select 1, _z];
	
	hintSilent "Nothing to see. Wait! a new sphere has been spotted close to you!";
	
	// create a trigger to deal with it
	_pos = [_posX, _posY, _posZ];

	// see how it works a trigger when pass a call function with arguments
	_trigger = createTrigger["EmptyDetector", getPos _sphere];
	_trigger setTriggerArea [2, 2, 0, false];
	_trigger setTriggerActivation ["WEST", "PRESENT", false];
	_trigger setTriggerStatements [
		"player in thislist",
		format [
			"[%1] call sandbox_spawnHeliTransport",
			_pos
		],
		""
	];
	hint format ["%1", _pos];	
};


/**
 * Dynamic Player Markers
 * http://www.armaholic.com/page.php?id=25481
 * bug!: duplicated marks :?
 * How can I disable the marks:? http://www.armaholic.com/forums.php?m=posts&q=10065
 * Server.cfg -> difficult? 
 */
sandbox_playerMarkerPosition = 
{
	if (isDedicated) exitWith {hint "is Server!"};

	_playerMarkerPosition = missionNamespace getVariable (playerMarkerPosition);
	if (!isNil{_playerMarkerPosition}) exitWith {hint "playerMarkerPosition script is running!"};

	missionNamespace setVariable ["playerMarkerPosition", true];

	hint format ["%1 can be tracked on map. Press 'M' Key to see it in action", name player];

	while {true} do {
		
		waitUntil {
		  sleep 0.025;
		  true;
		};

		_markerNumber = 0;

		{
			_unit = _x;

			_vehicle = vehicle _unit;
			_pos = getPosATL _vehicle;

			_markerNumber = _markerNumber + 1;
			_marker = format["um%1", _markerNumber];

			if (getMarkerType _marker == "") then {
				createMarkerLocal [_marker, _pos];
			} else {
				_marker setMarkerPosLocal _pos;
			};
			_marker setMarkerDirLocal getDir _vehicle;
			_marker setMarkerTypeLocal "mil_triangle";
			_marker setMarkerTextLocal format ["%1 : %2", name _x, _marker];

			_color = [side _x, true] call bis_fnc_sidecolor;
			_marker setMarkerColorLocal _color;

			if (_vehicle == vehicle player) then {
				_marker setMarkerSizeLocal [1.5, 1.5];
			} else {
				_marker setMarkerSizeLocal [0.5, 0.7];
			};
		} forEach allUnits;
	};
};



/*
 	Description:
 	Spawns a DayZ Helicrash in a specific circular zone
 
 	Paramater(s):
 		_this select 0: ARRAY -  Position of the center pf the zone
 		_this select 1: SCALAR - Min distance from position
 		_this select 2: SCALAR - Max distance from position
 		_this select 3: BOOLEAN (Optional) - If big smoke attached to helicrash is visible or not. By defaults is TRUE
 		_this select 4: BOOLEAN (Optional) - mark on the map where is the helicrash. By default is TRUE. Draws an red ELLIPSE 

	Returns: Helicrash Wreck Object

	USAGE: _heliCrashObj = [getPos player, 10, 200] call SB_fnc_spawnHelicrash;

	TODO:
*/
SB_fnc_spawnHelicrash =
{
	private ["_location", "_min", "_max", "_smoke", "_marked"];
	_location = _this select 0;
	_min = _this select 1;
	_max = _this select 2;
	_smoke = if (count _this > 3) then { _this select 3 } else { true };
	_marked = if (count _this > 4) then { _this select 4} else { true };


	_posHeliCrash = [_location, _min, _max, 10, 0, 25, 0] call BIS_fnc_findSafePos;
	_heliCrashObj = "Land_UWreck_Heli_Attack_02_F" createVehicle _posHeliCrash;
	_heliCrashObj setVectorDir [random 1, random 1, 0];

	if (_smoke) then {
		_smokeObj = "test_EmptyObjectForSmoke" createVehicle [0, 0, 0];
		_smokeObj attachTo [_heliCrashObj, [2, 0, 0.025]];
		_heliCrashObj setVariable ["smoke", _smoke];
	};

	if (_marked) then {
		_marker = createMarkerLocal[format ["helimarker%1", ceil random 9999], _posHeliCrash];
		_marker setMarkerShapeLocal "ELLIPSE";
		_marker setMarkerColorLocal "ColorRed";
		_marker setMarkerAlphaLocal 0.75;
		_marker setMarkerSizeLocal [150, 150];
		_marker setMarkerTextLocal "HeliCrash";
		_heliCrashObj setVariable ["marker", _marker];
	};

	// Returns the helicrash Object 
	_heliCrashObj
};

/*
 	Description:
 	Remove a DayZ Helicrash (include smoke and marker)
 
 	Paramater(s):
 		_this select 0: OBJECT - Helicrash Vehicle Object

	Returns: NONE

	USAGE: [_heliCrashObj] call SB_fnc_removeHelicrash;

	TODO: Bug if marker is null and function doesn't check it?
	
*/
SB_fnc_removeHelicrash =
{
	private ["_helicrashObj"];

	_helicrashObj = _this select 0;

	// delete marker 
	_marker = _heliCrashObj getVariable ("marker");
	deleteMarkerLocal _marker; 
	// deleteMarkerLocal format["%1", _heliCrashObj getVariable ("marker")]};

	// delete smoke particles object
	if (_heliCrashObj getVariable ("smoke")) then {
		{
			if (typeOf _x == "#particlesource") then { 
				deleteVehicle _x;
			};	
		} forEach (_heliCrashObj nearObjects 3);
	};

	// delete wreck chopper
	deleteVehicle _helicrashObj;
};


/**
 * A simple teleport Map Click position
 * onMapSingleClick
 * https://community.bistudio.com/wiki/onMapSingleClick
 */
/*
 	Description:
 	A simple teleport Map Click position
 
 	Paramater(s): NONE

	Returns: NONE

	USAGE: [] call SB_fnc_mapTeleport;

	TODO: Okay, it's a silly function... maybe needs to see how others have implemented it ;)
*/
SB_fnc_mapTeleport =
{	
	onMapSingleClick "vehicle player setPos _pos; true;";
};	


/*
 	Description:
 
 	Paramater(s):

	Returns: NONE

	USAGE: [] spawn SB_fnc_SimpleTrigger;

	TODO: 

*/

SB_fnc_SimpleTrigger = 
{

	// some trigger values
	_radius = 125;
	_timeDuration = 10;

	// set trigger location
	_posTrigger = getPos player;
	_xPos = _posTrigger select 0;
	_yPos = _posTrigger select 1;
	_xPos = _xPos + (random 500) - 250;
	_yPos = _yPos + (random 500) - 250;
	_posTrigger set [0, _xPos];
	_posTrigger set [1, _yPos];

	// lets draw a mark for our trigger for debug purposes
	_markerTrigger = createMarkerLocal[format ["trigger%1", ceil random 9999], _posTrigger];
	_markerTrigger setMarkerShapeLocal "ELLIPSE";
	_markerTrigger setMarkerBrushLocal "SolidBorder";
	_markerTrigger setMarkerColorLocal "ColorBlue";
	_markerTrigger setMarkerAlphaLocal 0.65;
	_markerTrigger setMarkerSizeLocal [_radius, _radius];


	// different ways to activate a trigger
	// 1. Attach to a player of a vehicle object (need "this" on first setTriggerStatements) and no need of setTriggerActivation
	// _trigger triggerAttachVehicle [player];
	// 2. Set an activation (player get inside trigger)
	// _trigger setTriggerActivation ["VEHICLE", "PRESENT", true];

	_trigger = createTrigger["EmptyDetector", _posTrigger];
	_trigger setTriggerArea [_radius, _radius, 0, false];
	_trigger setTriggerActivation ["ANY", "NOT PRESENT", true];
	_trigger setTriggerTimeout[_timeDuration, _timeDuration, _timeDuration, false];
	_trigger setTriggerStatements [
		"not(player in thislist)",
		"hint 'Trigger is on'; [thisTrigger] spawn SB_fnc_damagePlayer;",
		"hint 'Trigger is off'"
	];


	// countdown before trigger is on!
	0 = _trigger spawn {

		// Triggers have their own schedule. If you create a trigger with timeout and try to read triggerTimeoutCurrent immediately it will return -1. This is because the countdown will not start until the next scheduled trigger check is due, and this could take up to 0.5 seconds.
		waitUntil { triggerTimeoutCurrent _this > 0 };
		//waitUntil { triggerTimeoutCurrent _this > 0 && triggerTimeoutCurrent _this <= (floor _timeDuration / 2 ) } exitWith { deleteMarkerLocal _markerTrigger};
		waitUntil {
		  if (floor triggerTimeoutCurrent _this <= 0) exitWith {true};
		  hintSilent parseText format [
	        "<t size='10' color='#ffff00' shadow='2'>%1</t>",
	        floor triggerTimeoutCurrent _this
	    	];
	    	false
		};
	};

	// update radius every 10 seconds
	while {true} do 
	{
		sleep 10;
		hint "Update Zone";
		_radius = _radius - 5;
		_trigger setTriggerArea [_radius, _radius, 0, false];
		_markerTrigger setMarkerSizeLocal [_radius, _radius];
	};
};

/*
Simple damage script to player.
*/

SB_fnc_damagePlayer = 
{
	private ["_trigger","_inrcreaseDamage", "_damageBase"];

	_trigger = _this select 0;
	_inrcreaseDamage = 0.1;
	_damageBase = damage player;

	//hint "Player is afected by an infection!";
	
	while {alive player} do 
	{
		// display damage player
		hintSilent parseText format [
            "<t size='5' color='#ff0000' shadow='2'>%1</t>",
            damage player
        	];
        // if player enters the safe zone trigger is off
		if (not(triggerActivated _trigger)) exitWith {};

		// player explodes (and dead) if damage is too high
		if ((damage player) > 0.85) then {
			"HelicopterExploSmall" createVehicle position player;
		};
		// increase the damage and set to player
		_damageBase = (damage player) + _inrcreaseDamage;
		player setDamage _damageBase;

		sleep 5; //time frequency increase damage value
	};
};


/*
 	Description:
 	Spawn a basic random EAST unit within a time frequency (defined by _spawn_time). Based on Dynamic AI Spawn (http://www.armaholic.com/page.php?id=28107)
 
 	Paramater(s):
 		_this select 0: ARRAY Position - center of spawn
 		_this select 1: SCALAR - min start distance from the center
		_this select 2: SCALAR - max distance from the center
		_this select 3: SCALAR - Wait time before spawns another unit

	Returns: NONE

	USAGE: [position player, 20, 40, 60] spawn SB_fnc_spawnRandomEastUnits;

	TODO: 
		- Add exitwith to escape of a infinite spawn of units
		- Instead of a simple unit, maybe it will be better a group
		- Waypoints
		- Better AI skills
		- Customize gears
		- Despawn after a time without contact with players
	
*/

SB_fnc_testReportFile = 
{
	_log = "Hello";
	diag_log time;
	diag_log format ["%1 playing at %2", player, time];
	diag_log str [
		format ["time: %1", time],
		format ["player: %1", player],
		format ["_log: %1", _log]
	];
};




SB_fnc_spawnRandomEastUnits = 
{

	diag_log "******************** SB_fnc_spawnRandomEastUnits ********************";
	
	//private ["_spawnOrigin", "_startDistance", "_maxDistance", "_spawn_time", "_odds", "_bkpOrigin", "_bkpSpawnTime"];

	private ["_skill_level_odds", "_odds", "_skill_count"];

	// basic configuration
	_min_groups = 2; // minimum number of groups that will be created
	_max_groups = 6; // maximum number of groups that will be created

	_min_group_units = 3; // minimum number of units a group can contain
	_max_group_units = 7; // maximum number of units a group can contain

	// location reference to spawn the unit
	_spawnOrigin = _this select 0;
	_bkpOrigin = _spawnOrigin;
	
	// _startDistance = _this select 1;
	_startDistance = 1; // minimum distance from the trigger point
	
	// _maxDistance = _this select 2;
	_maxDistance = 25; // maximum distance from the trigger point
	
	// Declare 8 different groups 
	_kgroup0 = createGroup east;
	_kgroup1 = createGroup east;
	_kgroup2 = createGroup east;
	_kgroup3 = createGroup east;
	_kgroup4 = createGroup east;
	_kgroup5 = createGroup east;
	_kgroup6 = createGroup east;
	_kgroup7 = createGroup east;

	// Kind of units
	_kunits = [
		"O_Soldier_F", // Rifleman
		"O_soldierU_F", // Rifleman
		"O_support_Mort_F", // Gunner
		"O_G_Soldier_GL_F", // Grenadier
		"O_soldierU_AAA_F", // Asst. Missile Specialist
		"O_soldier_exp_F", // Explosive Specialist
		"O_spotter_F", // Spoter
		"O_sniper_F" // Sniper
	];

	// Chance of what type of unit that group will contain in percentages. 100% means that unit will spawn always.
	// that means that O_sniper_F unit on _krifleman_odds_kgroup0 is 10% chance to be created
	// this rules works for next properties
	_kunits_odds_kgroup0 = [100, 90, 80, 60, 40, 10, 15, 10];
	_kunits_odds_kgroup1 = [100, 70, 50, 40, 40, 40, 15, 35];
	_kunits_odds_kgroup2 = [100, 90, 70, 50, 40, 40, 75, 85];
	_kunits_odds_kgroup3 = [100, 90, 80, 50, 40, 25, 15, 25];
	_kunits_odds_kgroup4 = [100, 90, 85, 50, 40, 30, 25, 15];
	_kunits_odds_kgroup5 = [100, 80, 80, 70, 40, 40, 15, 15];
	_kunits_odds_kgroup6 = [100, 90, 70, 60, 40, 40, 10, 15];
	_kunits_odds_kgroup7 = [100, 10, 5, 10, 20, 70, 100, 100];


	_group_spawn_delay_min=[60,60,60,60,60,120,120,120,120]; 
	_group_spawn_delay_max=[80,120,120,80,240,240,240,240,240]; 
	_sleep_delay = 20;						// This MUST be at least two times less than any of the _group_spawn_delay numbers

	_speed_type = ["LIMITED", "NORMAL", "FULL"];
	_speed_odds = [100, 50, 20];

	_formation_type=["NO CHANGE","COLUMN","STAG COLUMN","WEDGE","ECH LEFT","ECH RIGHT","VEE","LINE","FILE","DIAMOND"];
	_formation_odds = [100,90,80,70,60,50,40,30,20,10];
	
	
	_skill_group = [0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9];
	_skill_level_group = ["Novice", "Rookie", "Rookie", "Recruit", "Recruit", "Veteran", "Veteran", "Expert"];
	_skill_level_odds = [100, 95, 80, 50, 45, 30, 10, 5];


	// Those variables are needed to help us to spawn the group
	_all_kgroups = [_kgroup0, _kgroup1, _kgroup2, _kgroup3, _kgroup4, _kgroup5, _kgroup6, _kgroup7];
	_all_kunits_odds = [_kunits_odds_kgroup0, _kunits_odds_kgroup1, _kunits_odds_kgroup2, _kunits_odds_kgroup3, _kunits_odds_kgroup4, _kunits_odds_kgroup5, _kunits_odds_kgroup6, _kunits_odds_kgroup7];
	
	_number_groups = floor(random (_max_groups - _min_groups)) + _min_groups;
	_kunit_number = count _kunits;
	_formation_count = count _formation_type;
	_skill_count = count _skill_level_group;

	_group_counter = 0;
	
	_wait_time = 0;

	_delay_min = _group_spawn_delay_min select _group_counter;
	
	_delay_max = _group_spawn_delay_max select _group_counter;

	_delay_time = (random (_delay_max - _delay_min)) + _delay_min;

	// _wait_time = _wait_time + _delay_time;
	_wait_time = 0;

	_skill_index = 0;

	// Debug variables
	// diag_log format ["_wait_time "]
	diag_log str [
		format ["_wait_time: %1", _wait_time],
		format ["_delay_time: %1", _delay_time],
		format ["_delay_max: %1", _delay_max],
		format ["_delay_min: %1", _delay_min],
		format ["_number_groups: %1", _number_groups]
	];

	private ["_i", "_j", "_table_odds", "_skill_index", "_this_unit"];
	
	//while {alive player} do
	//{
		if (time > _wait_time)	then 
		{
			if (_group_counter < _number_groups) then 
			{

				// start iteration array groups
				_this_group = _all_kgroups select _group_counter;
				_this_unit_odds = _all_kunits_odds select _group_counter;

				_group_size = floor (random (_max_group_units - _min_group_units)) + _min_group_units;

				// units spawn close to player... or nearest to player
				_spawn_position = position player;

				_xpos = _spawn_position select 0;
				_ypos = _spawn_position select 1;
				_zpos = _spawn_position select 2;
				
				_distance = _startDistance + random (_maxDistance - _startDistance);

				// maybe those units are moving to the centr of the "safe zone" :D
				// and explodes if they didn't reached it!
				_angle = random 360;
				
				_xxpos = (_distance * cos _angle);
				_yypos = (_distance * sin _angle);

				_xpos = _xpos + _xxpos;
				_ypos = _ypos + _yypos;

				_spawn_position set [0, _xpos];
				_spawn_position set [1, _ypos];
				_spawn_position set [2, _zpos];


				// we roll a dice of 100 faces
				_odds = random (100);
				diag_log format ["_odds: %1", _odds];

				// iterate the skill level
				// this give the general skill level of the members of the group
				// as you see the basics is the lowest level (100%). 
				
				_skill_count = (count _skill_group) - 1;

				for "_i" from 0 to _skill_count do
				{
					_table_odds = _skill_level_odds select _i;
					
					if (_odds < _table_odds) then 
					{
						_skill_index = _i;
					};
				};

				_skill_level = _skill_group select _skill_index;
				_skill_level_name = _skill_level_group select _skill_index;

				diag_log str [
					format ["Group: %1", _this_group],
					format ["_group_size: %1", _group_size],
					format ["_skill_level: %1", _skill_level],
					format ["_skill_level_name: %1", _skill_level_name],
					format ["_spawn_position: %1", _spawn_position]
				];

				// time to create units
				diag_log format ["Units of group %1", _this_group];
				for "_i" from 0 to (_group_size - 1) do
				{
					_odds = random (100);

					for "_j" from 0 to (_kunit_number - 1) do
					{
						_table_odds = _this_unit_odds select _j;

						if (_odds < _table_odds) then 
						{
							_this_unit = _j;
						};

					};
					// select kunit 
					_man = _kunits select _this_unit;
					_man createUnit [_spawn_position, _this_group, "this 	allowFleeing 0", _skill_level, "Private"];			
					diag_log format ["- %1", _man];
				};

				// Formation type and waypoints

				_formation = _formation_type select floor random count _formation_type;
				diag_log format ["Formation %1"]


			}; // end of if (_group_counter < _number_groups)
		};	// end of (time > _wait_time)
	//}; // end of while 
}; // end of function



/*
			_man = _krifleman call BIS_fnc_selectRandom; 
			_skill_level = _skill_levels_unit call BIS_fnc_selectRandom;

			//_spawnOrigin = [_spawnOrigin, 1.5, 10.5, 5.0, 0, 1.5, 0] call BIS_fnc_findSafePos;
			_man createUnit [_spawnOrigin, _kgroup, "this allowFleeing 0", _skill_level, "Private"];
			
			

			// search a safe position

			hintSilent parseText format ["<t size='2' color='#ff0000' shadow='1'>Spawn a new EAST %1 with skills %2 at %3 (%4)</t>", _man, _skill_level, _spawnOrigin, time];

			sleep 2;

			_odds = random 60;
			_wait_time = time + _bkpSpawnTime + _odds;

			hintSilent parseText format ["<t size='2' color='#ffff00' shadow='2'>%1 seconds left for next unit spawn", floor (_wait_time - time)];

			_spawnOrigin = _bkpOrigin;
		};
		sleep _sleep_delay;	
	};	
*/	
	


	/*

	// spawn a simple enemy group close to player
	_pos =  [getPos player, 50, 125, 75, 0, 35, 0] call BIS_fnc_findSafePos;	
	// https://community.bistudio.com/wiki/createUnit
	_groupEast = createGroup east;

	_opfor0 = _groupEast createUnit ["O_Soldier_F", _pos, [], 100, "FORM"];
	sleep 0.25;
	_opfor1 = _groupEast createUnit ["O_Soldier_AA_F", _pos, [], 100, "FORM"];
	sleep 0.25;
	_opfor2 = _groupEast createUnit ["O_G_officer_F", _pos, [], 100, "FORM"];
	sleep 0.25;
	_opfor3 = _groupEast createUnit ["O_soldierU_medic_F", _pos, [], 100, "FORM"];
	sleep 0.25;

	// http://forums.bistudio.com/showthread.php?119376-Making-enemy-units-chase-player&highlight=chase
	
	while {true} do {
		// https://community.bistudio.com/wiki/leader
		leader _groupEast doMove (getPos player);
		sleep 1.5;
		{
		  if (!alive _x) then {
		  	hintSilent format ["Left %1 enemies to kill", count units _groupEast];
		  	deleteVehicle _x;
		  }
		} forEach units _groupEast;

		if (count units _groupEast == 0) exitWith {};	
	};
	*/






