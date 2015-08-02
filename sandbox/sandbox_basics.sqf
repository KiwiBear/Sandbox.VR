
/**
 * Create a simple group on Player is the Leader
 * 
*/

sandbox_spawnBlueForUnits = 
{
	// spawn units close to player
	_pos = [getPos player, 0, 10, 2, 0, 5, 0] call BIS_fnc_findSafePos;
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
 * Create a simple opfor group of 4 units chasing Player 
 * 
*/

sandbox_spawnOpForUnits = 
{
	// spawn a simple enemy group close to player
	_pos =  [getPos player, 50, 150, 75, 0, 5, 0] call BIS_fnc_findSafePos;	
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
};


/**
 * Spawns a HeliTransport and moves to a given position
 */

sandbox_spawnHeliTransport = {
	private ["_position"];

	_position = _this select 0;

	/*
	_heliPosX = (_position select 0) + (random(50) + 5);
	_heliPosY = (_position select 1) + (random(50) + 5);
	_heliPosZ = _position select 2;
	
	hint format ["Spawn a HeliTransport at %1", [_heliPosX, _heliPosY, _heliPosZ]];	
	*/

	// Create a certain vehicle type with all crew (including turrets)
	// Problem? is flying!
	/*
	_pos = [_position, 0, 20, 10, 0, 5, 0] call BIS_fnc_findSafePos;
	_Helicrew1 = creategroup WEST;
	_heliTransport = [_pos, 180, "B_Heli_Transport_03_F", _Helicrew1] call bis_fnc_spawnvehicle;

	
	_wp1 = _Helicrew1 addWaypoint [getPos player, 0];
	_wp1 setWaypointType "MOVE";
	_wp1 setWaypointSpeed "FULL";

	_wp2 = _Helicrew1  addWaypoint [getPos player, 0];
	_wp2 setWaypointType "TR UNLOAD";
	_wp2 setWaypointSpeed "LIMITED";
	_wp2 setwaypointstatements ["this land 'land'"];


	_wp3 = group player addWaypoint [getPos _heliTransport, 0];
	_wp3 setWaypointType "GETIN";
	_wp3 setWaypointSpeed "LIMITED";
	*/

	
	// spawns a helitransport close to trigger
	_pos = [_position, 10, 50, 25, 0, 5, 0] call BIS_fnc_findSafePos;
	_heliTransport = "B_Heli_Transport_03_F" createVehicle _pos;
	_heliTransport setVectorDir [random(1), random(1), 0];

	// spawns a pilot and move in Cargo as a driver
	sleep 1.0;
	_grpCIV = createGroup civilian;
	_pos = [_position, 10, 50, 5, 0, 5, 0] call BIS_fnc_findSafePos;
	_pilot = _grpCIV createUnit ["C_Driver_4_F", _pos, [], 100, "FORM"];
	hint "";
	_pilot moveInDriver _heliTransport;
	_pilot action ["engineOn", _heliTransport];
	

	// get everyone inside that belongs to the player group
	// http://www.armaholic.com/page.php?id=6197 ?
	// this is the "fast" way
	//{ _x moveInCargo _heliTransport; sleep 2.0} foreach units group player;

	// temporaly, we change the group according the Civ driver
	// if not, they never getin to the vehicle
	hint "Everyone moves to the Heli!";
	_units =  units group player;
	units group player joinSilent  _grpCIV;

	_wp1 = _grpCIV addWaypoint [getPos _heliTransport, 0];
	_wp1 setWaypointType "GETIN";
	_wp1 setWaypointSpeed "FULL";


	// move a point
	_pos = [_position, 1000, 1500, 20, 0, 5, 0] call BIS_fnc_findSafePos;
	_wp2 = _grpCIV addWaypoint [_pos, 0];
	_wp2 setWaypointType "MOVE";
	_wp2 setWaypointSpeed "FULL";

	//... and landing on it
	_wp3 = _grpCIV  addWaypoint [_pos, 0];
	_wp3 setWaypointType "TR UNLOAD";
	_wp3 setWaypointSpeed "LIMITED";
	_wp3 setwaypointstatements ["this land 'land'"];


	_pilot action ["engineOff", _heliTransport];
	_wp4 = _grpCIV  addWaypoint [_pos, 0];
	_wp4 setWaypointType "GETOUT";
	_wp4 setWaypointSpeed "LIMITED";


	// Bluefor again :)
	// maybe need to syncronize
	// I dunno how to 
	// _grpBlueFor = createGroup west;
	//_units join _grpBlueFor;
	// _units join grpNull;

	// return to the original group

	// time to create a new step :)
};


sandbox_enemyChasePlayer = 
{

	// call the function, call help team!
	hint "Added a new action to call friendly units!";
	player addAction ["Add friendly units", {
		[] call sandbox_spawnBlueForUnits;
	}];


	// spawn opfor soldier random safe location 
	sleep 2.0;
	hint format ["Be aware! Enemy is chasing you at %1!", _pos];
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


/** 
 * Spawns a simple helicrash like DayZ (marker optional)
 */
sandbox_spawnHeliCrash = 
{
	private ["_location", "_markedPosition"];

	_location = _this select 0;
	_markedPosition = _this select 1;

	if (_markedPosition) then {
		_marker = createMarker["helimarker", _location];
		_marker setMarkerShape "ICON";
		_marker setMarkerType "o_air";
		_marker setMarkerColor "ColorRed";
		_marker setMarkerText "HeliCrash";
		missionNamespace setVariable ["marker", _marker];
	} else {
		missionNamespace setVariable ["marker", nil];
	};

	_heliCrash = "Land_UWreck_Heli_Attack_02_F" createVehicle _location;
	_heliCrash setVectorDir [1, 0.3, 0];
	_smoke = "test_EmptyObjectForSmoke" createVehicle [0, 0, 0];
	_smoke attachTo [_heliCrash, [2, 0, 0.025]];
	_heliCrash setVariable ["effects", _smoke, true];
	missionNamespace setVariable ["heliCrash", _heliCrash];
};


/**
 * A simple teleport Map Click position
 * onMapSingleClick
 * https://community.bistudio.com/wiki/onMapSingleClick
 */

sandbox_mapTeleport = 
{	
	hint format ["%1 can teleport. Do one click a position on Map close to the Helicopter", name player];
	onMapSingleClick "vehicle player setPos _pos; true;";

	_marker = missionNamespace getVariable ("marker");
	if (!isNil "_marker") then { deleteMarker _marker };

	// Issue to delete particles effects like smoke or fire attached to vehicles	
	// http://forums.bistudio.com/showthread.php?165184-Delete-Fire-Effect/page2
	_heliCrash = missionNamespace getVariable ("heliCrash");
	// _effects = _heliTransport getVariable ("effects");
	{
		if (typeOf _x == "#particlesource") then 
		{ 
			deleteVehicle _x
		}
	} forEach (_heliCrash nearObjects 3);
	// deleteVehicle _effects;
	deleteVehicle _heliCrash;
};	
/**
 * Return to the starter position defined at init.sqf
 */

sandbox_returnStartPosition = 
{

	[[4000.0015,4099.8701], true] call sandbox_spawnHeliCrash;

	hint "Added a new action to go back to the start point";
	player addAction ["Go back to the start point", {
		vehicle player setPos startPlayerPosition;
	}];
};

