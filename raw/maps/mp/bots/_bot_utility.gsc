
		switch ( mapname )
		{
			

			case "mp_test":
				level.waypoints = maps\mp\bots\waypoints\testmap::TestMap();
				break;
                        
                        case "mp_aground_ss":
				level.waypoints = maps\mp\bots\waypoints\aground::Aground();
				break;

                        case "mp_radar":
				level.waypoints = maps\mp\bots\waypoints\outpost::Outpost();
				break;


			default:
				maps\mp\bots\waypoints\_custom_map::main( mapname );
				break;