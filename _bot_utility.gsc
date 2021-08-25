                      

                        case "mp_nola":
				level.waypoints = maps\mp\bots\waypoints\parish::Parish();
				break;

                        
                        case "mp_hillside_ss":
				level.waypoints = maps\mp\bots\waypoints\getaway::Getaway();
				break;




			 default:
				maps\mp\bots\waypoints\_custom_map::main( mapname );
				break;
		}
