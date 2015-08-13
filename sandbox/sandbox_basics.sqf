
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
 	Description: A simple trigger
 
 	Paramater(s):

	Returns: NONE

	USAGE: [] spawn SB_fnc_SimpleTrigger;

	TODO: 

*/

SB_fnc_SimpleTrigger = 
{

	diag_log "/************** SB_fnc_SimpleTrigger **************/";
	// some trigger values
	_radius = 125;
	_timeDuration = 10;

	// set trigger location
	_posTrigger = getPos player;
	_xPos = _posTrigger select 0;
	_yPos = _posTrigger select 1;
	_xPos = _xPos + (random 750) - 250;
	_yPos = _yPos + (random 750) - 250;
	_posTrigger set [0, _xPos];
	_posTrigger set [1, _yPos];

	diag_log format ["Center of Trigger: %1", _posTrigger];

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

	diag_log format ["Trigger: %1", _trigger];


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
 	Description: A way of damaging player every n time amount
 
 	Paramater(s):
 		_this select 0: OBJECT Trigger (mandatory)

	Returns: NONE

	USAGE: [_trigger] spawn SB_fnc_damagePlayer; 

	TODO: 

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
 
 	Paramater(s):

	Returns: group GROUP

	USAGE:	
		_unit = [getPos player, getPos _trigger, group player] spawn SB_fnc_spawnUnit;
		_unit = [getPos player, getPos _trigger] spawn SB_fnc_spawnUnit;

	TODO: 

*/

SB_fnc_spawnUnit = 
{
	private ["_spawnLocation", "_targetLocation", "_group", "_unit"];

	// conf options
	_minSpawnDistance = 10;
	_maxSpawnDistance = 50;

	_spawnLocation = _this select 0;
	_targetLocation = _this select 1;
	diag_log format ["_targetLocation: %1", _targetLocation];

	
	_group = if (count _this > 2) then {_this select 2} else {nil};
	diag_log format ["1- _group: %1", _group];

	private ["_i", "_kgroup", "_kgroups", "_kgroupsOdds", "_cnt", "_odds"];
	_kgroups = [civilian, independent, west, east];
	_kgroupsOdds = [100, 70, 50, 5];
	_cnt = count _kgroups;
	diag_log format ["_cnt: %1", _cnt];
	_odds = random (100);
	diag_log format ["_odds: %1", _odds];

	for "_i" from 0 to (_cnt -1) do
	{
		if (_odds < (_kgroupsOdds select _i)) then 
		{
			_kgroup = _kgroups select _i;
		};
	};
	diag_log format ["_kgroup: %1", _kgroup];

	if (isNil "_group") then {_group = createGroup _kgroup};
	diag_log format ["2- _group: %1", side _group];

	// Kind of units (8 for each)
	_kunitsWEST = ["B_Soldier_02_f", "B_Soldier_F", "B_Soldier_GL_F", "B_soldier_exp_F", "B_soldier_AA_F", "B_soldier_AA_F", "B_spotter_F", "B_sniper_F"];
	_kunitsEAST = ["O_Soldier_F", "O_soldierU_F", "O_support_Mort_F", "O_G_Soldier_GL_F", "O_soldierU_AAA_F", "O_soldier_exp_F", "O_spotter_F", "O_sniper_F"];
	_kunitsIND = ["I_G_Soldier_F", "I_G_Soldier_GL_F", "I_Soldier_M_F", "I_Soldier_AA_F", "I_Soldier_LAT_F", "I_Soldier_exp_F", "I_Spotter_F", "I_Sniper_F"];
	_kunitsCIV = ["C_man_1", "C_man_polo_1_F_afro", "C_man_polo_2_F_euro", "C_man_p_fugitive_F_asia", "C_man_p_fugitive_F_euro", "C_man_p_fugitive_F_afro", "C_man_w_worker_F", "C_Nikos_aged"];

	_kunitsOdds = [100, 90, 80, 70, 50, 30, 20, 10];
	_kunitsGroups = [_kunitsWEST, _kunitsEAST, _kunitsIND, _kunitsCIV];

	// select group depending on _group
	private ["_i", "_odds", "_kunit", "_kunitGroup", "_cnt"];

	if (side _group == west) then {_kunitGroup = _kunitsGroups select 0};
	if (side _group == east) then {_kunitGroup = _kunitsGroups select 1};
	if (side _group == independent) then {_kunitGroup = _kunitsGroups select 2};
	if (side _group == civilian) then {_kunitGroup = _kunitsGroups select 3};

	_cnt = count _kunitGroup;
	diag_log format ["_kunitGroup: %1, _tmp: %2", _kunitGroup, _cnt];
	_odds = random (100);
	diag_log format ["_odds: %1", _odds];
	
	for "_i" from 0 to (_cnt - 1) do
	{
		if (_odds < _kunitsOdds select _i) then 
		{
			_kunit = _kunitGroup select _i;
			diag_log _kunit;
		};
	};
	
	diag_log format ["Unit %1 | group %2", _kunit, _group];
	diag_log format ["_spawnLocation: %1", _spawnLocation];
	// _unit = _kunit createUnit [_spawnLocation, _group, "this allowFleeing 0", 0.9, "Private"];
	_unit = _group createUnit[_kunit, _spawnLocation, [], 5, "NONE"];
	_unit allowFleeing 0; // https://community.bistudio.com/wiki/allowFleeing

	_radius = 50;
	_xx = _targetLocation select 0;
	_yy = _targetLocation select 1;
	_dir = random 360;
	_pos = [(_xx + (random _radius) * sin _dir), (_yy + (random _radius) * cos _dir), 0];
	_unit doMove _pos; // transform unit text in object
	_unit // Return 
};



/*
 	Description:
 
 	Paramater(s):

	Returns: NONE

	USAGE: [] spawn SB_fnc_testReportFile; Next open cmder and chdir to %userprofile%\AppData\Local\Arma 3 and execute "tail -f <arma3 report name file>.rpt

	TODO: 

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

