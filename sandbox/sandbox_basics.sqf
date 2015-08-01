
/**
 * Enemy chase player
 */

sandbox_enemyChasePlayer = 
{
	// spawn opfor soldier random safe location 
	_min = 0;
	_max = 150;
	_minDistance = 125;
	_atWater = 0;
	_average = 5;
	_shoremode = 0;

	_pos =  [getPos player, _min, _max, _minDistance, _atWater, _average, _shoremode] call BIS_fnc_findSafePos;

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

	// Create a group player and spawns close to the player
	_groupWest = group player;
	_max = 5;
	_minDistance = 1;
	_pos =  [getPos player, _min, _max, _minDistance, _atWater, _average, _shoremode] call BIS_fnc_findSafePos;
	_bluefor0 = _groupWest createUnit ["B_soldier_exp_F", _pos, [], 100, "FORM"];
	sleep 0.25;
	_bluefor1 = _groupWest createUnit ["B_Soldier_A_F", _pos, [], 100, "FORM"];
	sleep 0.25;
	_bluefor2 = _groupWest createUnit ["B_Soldier_SL_F", _pos, [], 100, "FORM"];
	sleep 0.25;

	// player is leader
	group player selectLeader player;

	hint format ["Be aware! Enemy is chasing you at %1!", _pos];

	// http://forums.bistudio.com/showthread.php?119376-Making-enemy-units-chase-player&highlight=chase
	while {true} do {
		// https://community.bistudio.com/wiki/leader
		leader _groupEast doMove (getPos player);
		sleep 2;
		{
		  if (!alive _x) then {
		  	hint format ["Left %1 enemies to kill", count units _groupEast];
		  	deleteVehicle _x;
		  }
		} forEach units _groupEast;

		if (count units _groupEast == 0) exitWith {
			hint "Great! you can acces next step";
		};
	};
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

	_heliTransport = "Land_UWreck_Heli_Attack_02_F" createVehicle _location;
	_heliTransport setVectorDir [1, 0.3, 0];
	_smoke = "test_EmptyObjectForSmoke" createVehicle [0, 0, 0];
	_smoke attachTo [_heliTransport, [2, 0, 0.025]];
	_heliTransport setVariable ["effects", _smoke, true];
	missionNamespace setVariable ["heliTransport", _heliTransport];
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
	_heliTransport = missionNamespace getVariable ("heliTransport");
	// _effects = _heliTransport getVariable ("effects");
	{
		if (typeOf _x == "#particlesource") then 
		{ 
			deleteVehicle _x
		}
	} forEach (_heliTransport nearObjects 3);
	// deleteVehicle _effects;
	deleteVehicle _heliTransport;
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

	// move arrow to next position
	/*
	_z = getPos Arrow select 2;
	Arrow setPos [
		getPos UtilTesting1_2 select 0,
		getPos UtilTesting1_2 select 1,
		_z
	];
	*/
};

