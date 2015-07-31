




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

	_heliTransport = "Land_UWreck_MV22_F" createVehicle _location;
	_smoke = "test_EmptyObjectForSmoke" createVehicle [0, 0, 0];
	_smoke attachTo [_heliTransport, [2, 0, 0.05]];
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
	_heliTransport = missionNamespace getVariable ("heliTransport");

	if (!isNil "_marker") then { deleteMarker _marker };
	if (count attachedObjects _heliTransport > 0) then { 
		{ 
			//detach _x; 
			// bug? can't delete smoke!
			hint format  ["%1", _x];
			deleteVehicle _x;
		} forEach attachedObjects _heliTransport;
		deleteVehicle _heliTransport ;
	};	
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

