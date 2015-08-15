/*
 	Description:
 	Spawn a basic random EAST unit within a time frequency (defined by _spawn_time). Based on Dynamic AI Spawn (http://www.armaholic.com/page.php?id=28107)
 
 	Paramater(s): NONE AT THE MOMENT...
 		_this select 0: ARRAY Position - center of spawn
 		_this select 1: SCALAR - min start distance from the center
		_this select 2: SCALAR - max distance from the center
		_this select 3: SCALAR - Wait time before spawns another unit

	Returns: NONE

	USAGE: [] spawn SB_fnc_spawnRandomEastUnits;

	TODO: 
		- Add exitwith to escape of a infinite spawn of units
		- Instead of a simple unit, maybe it will be better a group
		- Waypoints
		- Better AI skills
		- Customize gears
		- Despawn after a time without contact with players
	
*/


SB_fnc_spawnRandomEastUnits = 
{

	diag_log "******************** SB_fnc_spawnRandomEastUnits ********************";
	
	//private ["_spawnOrigin", "_startDistance", "_maxDistance", "_spawn_time", "_odds", "_bkpOrigin", "_bkpSpawnTime"];

	private ["_skill_level_odds", "_odds", "_skill_count", "_max_enemy_distance"];

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

	_max_enemy_distance = 50;	// This is the maximum distance a group can be from the player as the group follows the player around

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
					_man createUnit [_spawn_position, _this_group, "this allowFleeing 0", _skill_level, "Private"];			
					diag_log format ["- %1", _man];
				};

				// Formation type and waypoints

				_formation = _formation_type select floor random count _formation_type;
				diag_log format ["Formation %1", _formation];

				// Set Waypoints to the group

				_numWP = 5;

				for "_i" from 0  to (_numWP - 1) do 
				{
					// we can add some random here...
					_wp = _this_group addWaypoint [position player, _max_enemy_distance];
					_wp setWaypointBehaviour "STEALTH";
					_wp setWaypointType "MOVE";
					_wp setWaypointFormation _formation;
					_wp setWaypointSpeed "FULL";
					_wp setwaypointstatements ["True", ""];


					if (_i == (_numWP - 1)) then 
					{
						_wp setWaypointType "CYCLE";
					};

					diag_log format ["WP %1: %2", _i, _wp];
				};




			}; // end of if (_group_counter < _number_groups)
		};	// end of (time > _wait_time)
	//}; // end of while 
}; // end of function
