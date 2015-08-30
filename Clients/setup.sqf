/**
 * File: clientSetup.sqf
 * Description: 
 * Created by:
 * Date:
 * Version: 
 * Parameters: n/a
 * Returns: n/a
 */


diag_log "======= Start Clients\setup.sqf =======";

call SANDBOX_fnc_setupGUI;
call SANDBOX_fnc_createInGameGUI;
call SANDBOX_fnc_clientWeather; // call Clients\setup_weather.sqf



enableRadio false;
enableSentences false;
showSubtitles false;
0 fadeRadio 0;


diag_log "remove group of players when joined";
[] spawn {
	while{true} do {
		_units = units (group player);
		setGroupIconsVisible [false,false];
		if(count _units > 1) then {
			_grp = group player;
			[player] joinSilent (creategroup (side player));
			deletegroup _grp;
		};
	};
};


diag_log "spawn SANDBOX_DRAWBLACKZONE";

[] spawn {
	waituntil{!isNil 'SANDBOX_DRAWBLACKZONE'};
	_data = SANDBOX_DRAWBLACKZONE;
	{
		_type = _x select 0;
		_position = _x select 1;
		_dir = _x select 2;
		_texture = _x select 3;
		
		_obj = _type createVehicleLocal _position;
		_obj setDir _dir;
		_obj setPosATL _position;
		// _obj setObjectTexture [0,_texture];
		_obj setObjectTexture [0, "pictures\billboard.paa"];
		_obj enableSimulation false;
	} forEach _data;
};

// Afegim com a Event Handler els trons :D que s'executen a nivell de client
// El server només li diu la posición on caurà :)
"SANDBOX_LS_PVAR" addPublicVariableEventHandler {
	(_this select 1) spawn SANDBOX_lightning; // remember u called it before line 16:
};

"SANDBOX_DT_PVAR" addPublicVariableEventHandler {
	(_this select 1) spawn BIS_fnc_dynamicText;
};


diag_log "======= End Clients\setup.sqf =======";


