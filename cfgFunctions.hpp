class cfgFunctions {
	class SANDBOX {
		class Server {
			class serverStart {
				file = "Server\start.sqf";
			};
			class serverSetup {
				file = "Server\setup.sqf";
			};
			class serverConfig {
				file = "Server\config.sqf";
			};
			class playerConfig {
				file = "Server\Players\player_config.sqf";
			};
			class mapSetup {
				file = "Server\Map\map_setup.sqf";
			};
		};
		class Client {
			// Root client
			class clientSetup {
				file = "Clients\setup.sqf";
			};
			class clientWeather {
				file = "Clients\Map\setup_weather.sqf";
			};
			class setupGUI {
				file = "Clients\GUI\setup_gui.sqf";
			};
			class createInGameGUI {
				file = "Clients\GUI\inGame_create.sqf";
			};
		};
	};
};