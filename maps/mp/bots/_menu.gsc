/*
	_menu
	Author: INeedGames
	Date: 05/11/2021
	The ingame menu.
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\bots\_bot_utility;

init()
{
	if ( getdvar( "bots_main_menu" ) == "" )
	{
		setdvar( "bots_main_menu", true );
	}
	
	if ( !getdvarint( "bots_main_menu" ) )
	{
		return;
	}
	
	thread watchPlayers();
}

watchPlayers()
{
	for ( ;; )
	{
		wait 1;
		
		if ( !getdvarint( "bots_main_menu" ) )
		{
			return;
		}
		
		for ( i = level.players.size - 1; i >= 0; i-- )
		{
			player = level.players[ i ];
			
			if ( !player is_host() )
			{
				continue;
			}
			
			if ( isdefined( player.menuinit ) && player.menuinit )
			{
				continue;
			}
			
			player thread init_menu();
		}
	}
}

destroyFixed()
{
	if ( !isdefined( self ) )
	{
		return;
	}
	
	self destroy();
}

removeChildFixed( element )
{
	temp = [];
	
	for ( i = 0; i < self.children.size ; i++ )
	{
		if ( isdefined( self.children[ i ] ) && self.children[ i ] != element )
		{
			self.children[ i ].index = temp.size;
			temp[ temp.size ] = self.children[ i ];
		}
	}
	
	self.children = temp;
}

destroyElemFixed()
{
	if ( !isdefined( self ) )
	{
		return;
	}
	
	if ( isdefined( self.parent ) )
	{
		self.parent removeChildFixed( self );
	}
	
	self destroyelem();
}

kill_menu()
{
	self notify( "bots_kill_menu" );
	self.menuinit = undefined;
}

init_menu()
{
	self.menuinit = true;
	
	self.menuopen = false;
	self.submenu = "Main";
	self.curs[ "Main" ][ "X" ] = 0;
	self addOptions();
	
	self thread watchPlayerOpenMenu();
	self thread MenuSelect();
	self thread RightMenu();
	self thread LeftMenu();
	self thread UpMenu();
	self thread DownMenu();
	
	self thread watchDisconnect();
	
	self thread doGreetings();
}

watchDisconnect()
{
	self waittill_either( "disconnect", "bots_kill_menu" );
	
	if ( self.menuopen )
	{
		if ( isdefined( self.menutexty ) )
		{
			for ( i = 0; i < self.menutexty.size; i++ )
			{
				if ( isdefined( self.menutexty[ i ] ) )
				{
					self.menutexty[ i ] destroyElemFixed();
				}
			}
		}
		
		if ( isdefined( self.menutext ) )
		{
			for ( i = 0; i < self.menutext.size; i++ )
			{
				if ( isdefined( self.menutext[ i ] ) )
				{
					self.menutext[ i ] destroyElemFixed();
				}
			}
		}
		
		if ( isdefined( self.menu ) && isdefined( self.menu[ "X" ] ) )
		{
			if ( isdefined( self.menu[ "X" ][ "Shader" ] ) )
			{
				self.menu[ "X" ][ "Shader" ] destroyElemFixed();
			}
			
			if ( isdefined( self.menu[ "X" ][ "Scroller" ] ) )
			{
				self.menu[ "X" ][ "Scroller" ] destroyElemFixed();
			}
		}
		
		if ( isdefined( self.menuversionhud ) )
		{
			self.menuversionhud destroyFixed();
		}
	}
}

doGreetings()
{
	self endon ( "disconnect" );
	self endon ( "bots_kill_menu" );
	wait 1;
	self iprintln( "Welcome to Bot Warfare " + self.name + "!" );
	wait 5;
	self iprintln( "Press [{+actionslot 1}] to open menu!" );
}

watchPlayerOpenMenu()
{
	self endon ( "disconnect" );
	self endon ( "bots_kill_menu" );
	
	self notifyonplayercommand( "bots_open_menu", "+actionslot 1" );
	
	for ( ;; )
	{
		self waittill( "bots_open_menu" );
		
		if ( !self.menuopen )
		{
			self playlocalsound( "mouse_click" );
			self thread OpenSub( self.submenu );
		}
		else
		{
			self playlocalsound( "mouse_click" );
			
			if ( self.submenu != "Main" )
			{
				self ExitSub();
			}
			else
			{
				self ExitMenu();
				
				if ( !gameflag( "prematch_done" ) || level.gameended )
				{
					self freezecontrols( true );
				}
				else
				{
					self freezecontrols( false );
				}
			}
		}
	}
}

MenuSelect()
{
	self endon ( "disconnect" );
	self endon ( "bots_kill_menu" );
	
	self notifyonplayercommand( "bots_select", "+gostand" );
	
	for ( ;; )
	{
		self waittill( "bots_select" );
		
		if ( self.menuopen )
		{
			self playlocalsound( "mouse_click" );
			
			if ( self.submenu == "Main" )
			{
				self thread [[ self.option[ "Function" ][ self.submenu ][ self.curs[ "Main" ][ "X" ] ] ]]( self.option[ "Arg1" ][ self.submenu ][ self.curs[ "Main" ][ "X" ] ], self.option[ "Arg2" ][ self.submenu ][ self.curs[ "Main" ][ "X" ] ] );
			}
			else
			{
				self thread [[ self.option[ "Function" ][ self.submenu ][ self.curs[ self.submenu ][ "Y" ] ] ]]( self.option[ "Arg1" ][ self.submenu ][ self.curs[ self.submenu ][ "Y" ] ], self.option[ "Arg2" ][ self.submenu ][ self.curs[ self.submenu ][ "Y" ] ] );
			}
		}
	}
}

LeftMenu()
{
	self endon ( "disconnect" );
	self endon ( "bots_kill_menu" );
	
	self notifyonplayercommand( "bots_left", "+moveleft" );
	
	for ( ;; )
	{
		self waittill( "bots_left" );
		
		if ( self.menuopen && self.submenu == "Main" )
		{
			self playlocalsound( "mouse_over" );
			self.curs[ "Main" ][ "X" ]--;
			
			if ( self.curs[ "Main" ][ "X" ] < 0 )
			{
				self.curs[ "Main" ][ "X" ] = self.option[ "Name" ][ self.submenu ].size - 1;
			}
			
			self CursMove( "X" );
		}
	}
}

RightMenu()
{
	self endon ( "disconnect" );
	self endon ( "bots_kill_menu" );
	
	self notifyonplayercommand( "bots_right", "+moveright" );
	
	for ( ;; )
	{
		self waittill( "bots_right" );
		
		if ( self.menuopen && self.submenu == "Main" )
		{
			self playlocalsound( "mouse_over" );
			self.curs[ "Main" ][ "X" ]++;
			
			if ( self.curs[ "Main" ][ "X" ] > self.option[ "Name" ][ self.submenu ].size - 1 )
			{
				self.curs[ "Main" ][ "X" ] = 0;
			}
			
			self CursMove( "X" );
		}
	}
}

UpMenu()
{
	self endon ( "disconnect" );
	self endon ( "bots_kill_menu" );
	
	self notifyonplayercommand( "bots_up", "+forward" );
	
	for ( ;; )
	{
		self waittill( "bots_up" );
		
		if ( self.menuopen && self.submenu != "Main" )
		{
			self playlocalsound( "mouse_over" );
			self.curs[ self.submenu ][ "Y" ]--;
			
			if ( self.curs[ self.submenu ][ "Y" ] < 0 )
			{
				self.curs[ self.submenu ][ "Y" ] = self.option[ "Name" ][ self.submenu ].size - 1;
			}
			
			self CursMove( "Y" );
		}
	}
}

DownMenu()
{
	self endon ( "disconnect" );
	self endon ( "bots_kill_menu" );
	
	self notifyonplayercommand( "bots_down", "+back" );
	
	for ( ;; )
	{
		self waittill( "bots_down" );
		
		if ( self.menuopen && self.submenu != "Main" )
		{
			self playlocalsound( "mouse_over" );
			self.curs[ self.submenu ][ "Y" ]++;
			
			if ( self.curs[ self.submenu ][ "Y" ] > self.option[ "Name" ][ self.submenu ].size - 1 )
			{
				self.curs[ self.submenu ][ "Y" ] = 0;
			}
			
			self CursMove( "Y" );
		}
	}
}

OpenSub( menu, menu2 )
{
	if ( menu != "Main" && ( !isdefined( self.menu[ menu ] ) || !!isdefined( self.menu[ menu ][ "FirstOpen" ] ) ) )
	{
		self.curs[ menu ][ "Y" ] = 0;
		self.menu[ menu ][ "FirstOpen" ] = true;
	}
	
	logOldi = true;
	self.submenu = menu;
	
	if ( self.submenu == "Main" )
	{
		if ( isdefined( self.menutext ) )
		{
			for ( i = 0; i < self.menutext.size; i++ )
			{
				if ( isdefined( self.menutext[ i ] ) )
				{
					self.menutext[ i ] destroyElemFixed();
				}
			}
		}
		
		if ( isdefined( self.menu ) && isdefined( self.menu[ "X" ] ) )
		{
			if ( isdefined( self.menu[ "X" ][ "Shader" ] ) )
			{
				self.menu[ "X" ][ "Shader" ] destroyElemFixed();
			}
			
			if ( isdefined( self.menu[ "X" ][ "Scroller" ] ) )
			{
				self.menu[ "X" ][ "Scroller" ] destroyElemFixed();
			}
		}
		
		if ( isdefined( self.menuversionhud ) )
		{
			self.menuversionhud destroyFixed();
		}
		
		for ( i = 0 ; i < self.option[ "Name" ][ self.submenu ].size ; i++ )
		{
			self.menutext[ i ] = self createfontstring( "default", 1.6 );
			self.menutext[ i ] setpoint( "CENTER", "CENTER", -300 + ( i * 100 ), -226 );
			self.menutext[ i ] settext( self.option[ "Name" ][ self.submenu ][ i ] );
			
			if ( logOldi )
			{
				self.oldi = i;
			}
			
			if ( self.menutext[ i ].x > 300 )
			{
				logOldi = false;
				x = i - self.oldi;
				self.menutext[ i ] setpoint( "CENTER", "CENTER", ( ( ( -300 ) - ( i * 100 ) ) + ( i * 100 ) ) + ( x * 100 ), -196 );
			}
			
			self.menutext[ i ].alpha = 1;
			self.menutext[ i ].sort = 999;
		}
		
		if ( !logOldi )
		{
			self.menu[ "X" ][ "Shader" ] = self createRectangle( "CENTER", "CENTER", 0, -225, 1000, 90, ( 0, 0, 0 ), -2, 1, "white" );
		}
		else
		{
			self.menu[ "X" ][ "Shader" ] = self createRectangle( "CENTER", "CENTER", 0, -225, 1000, 30, ( 0, 0, 0 ), -2, 1, "white" );
		}
		
		self.menu[ "X" ][ "Scroller" ] = self createRectangle( "CENTER", "CENTER", self.menutext[ self.curs[ "Main" ][ "X" ] ].x, -225, 105, 22, ( 1, 0, 0 ), -1, 1, "white" );
		
		self CursMove( "X" );
		
		self.menuversionhud = initHudElem( "Bot Warfare " + level.bw_version, 0, 0 );
		
		self.menuopen = true;
	}
	else
	{
		if ( isdefined( self.menutexty ) )
		{
			for ( i = 0 ; i < self.menutexty.size ; i++ )
			{
				if ( isdefined( self.menutexty[ i ] ) )
				{
					self.menutexty[ i ] destroyElemFixed();
				}
			}
		}
		
		for ( i = 0 ; i < self.option[ "Name" ][ self.submenu ].size ; i++ )
		{
			self.menutexty[ i ] = self createfontstring( "default", 1.6 );
			self.menutexty[ i ] setpoint( "CENTER", "CENTER", self.menutext[ self.curs[ "Main" ][ "X" ] ].x, -160 + ( i * 20 ) );
			self.menutexty[ i ] settext( self.option[ "Name" ][ self.submenu ][ i ] );
			self.menutexty[ i ].alpha = 1;
			self.menutexty[ i ].sort = 999;
		}
		
		self CursMove( "Y" );
	}
}

CursMove( direction )
{
	self notify( "scrolled" );
	
	if ( self.submenu == "Main" )
	{
		if ( isdefined( self.menutext ) )
		{
			self.menu[ "X" ][ "Scroller" ].x = self.menutext[ self.curs[ "Main" ][ "X" ] ].x;
			self.menu[ "X" ][ "Scroller" ].y = self.menutext[ self.curs[ "Main" ][ "X" ] ].y;
			
			for ( i = 0; i < self.menutext.size; i++ )
			{
				if ( isdefined( self.menutext[ i ] ) )
				{
					self.menutext[ i ].fontscale = 1.5;
					self.menutext[ i ].color = ( 1, 1, 1 );
					self.menutext[ i ].glowalpha = 0;
				}
			}
		}
		
		self thread ShowOptionOn( direction );
	}
	else
	{
		if ( isdefined( self.menutexty ) )
		{
			for ( i = 0; i < self.menutexty.size; i++ )
			{
				if ( isdefined( self.menutexty[ i ] ) )
				{
					self.menutexty[ i ].fontscale = 1.5;
					self.menutexty[ i ].color = ( 1, 1, 1 );
					self.menutexty[ i ].glowalpha = 0;
				}
			}
		}
		
		if ( isdefined( self.menutext ) )
		{
			for ( i = 0; i < self.menutext.size; i++ )
			{
				if ( isdefined( self.menutext[ i ] ) )
				{
					self.menutext[ i ].fontscale = 1.5;
					self.menutext[ i ].color = ( 1, 1, 1 );
					self.menutext[ i ].glowalpha = 0;
				}
			}
		}
		
		self thread ShowOptionOn( direction );
	}
}

ShowOptionOn( variable )
{
	self endon( "scrolled" );
	self endon( "disconnect" );
	self endon( "exit" );
	self endon( "bots_kill_menu" );
	
	for ( time = 0;; time += 0.05 )
	{
		if ( !self isonground() && isalive( self ) && gameflag( "prematch_done" ) && !level.gameended )
		{
			self freezecontrols( false );
		}
		else
		{
			self freezecontrols( true );
		}
		
		self setclientdvar( "r_blur", "5" );
		self setclientdvar( "sc_blur", "15" );
		self addOptions();
		
		if ( self.submenu == "Main" )
		{
			if ( isdefined( self.curs[ self.submenu ][ variable ] ) && isdefined( self.menutext ) && isdefined( self.menutext[ self.curs[ self.submenu ][ variable ] ] ) )
			{
				self.menutext[ self.curs[ self.submenu ][ variable ] ].fontscale = 2.0;
				// self.menutext[ self.curs[ self.submenu ][ variable ] ].color = (randomint(256)/255, randomint(256)/255, randomint(256)/255);
				color = ( 6 / 255, 69 / 255, 173 + randomintrange( -5, 5 ) / 255 );
				
				if ( int( time * 4 ) % 2 )
				{
					color = ( 11 / 255, 0 / 255, 128 + randomintrange( -10, 10 ) / 255 );
				}
				
				self.menutext[ self.curs[ self.submenu ][ variable ] ].color = color;
			}
			
			if ( isdefined( self.menutext ) )
			{
				for ( i = 0; i < self.option[ "Name" ][ self.submenu ].size; i++ )
				{
					if ( isdefined( self.menutext[ i ] ) )
					{
						self.menutext[ i ] settext( self.option[ "Name" ][ self.submenu ][ i ] );
					}
				}
			}
		}
		else
		{
			if ( isdefined( self.curs[ self.submenu ][ variable ] ) && isdefined( self.menutexty ) && isdefined( self.menutexty[ self.curs[ self.submenu ][ variable ] ] ) )
			{
				self.menutexty[ self.curs[ self.submenu ][ variable ] ].fontscale = 2.0;
				// self.menutexty[ self.curs[ self.submenu ][ variable ] ].color = (randomint(256)/255, randomint(256)/255, randomint(256)/255);
				color = ( 6 / 255, 69 / 255, 173 + randomintrange( -5, 5 ) / 255 );
				
				if ( int( time * 4 ) % 2 )
				{
					color = ( 11 / 255, 0 / 255, 128 + randomintrange( -10, 10 ) / 255 );
				}
				
				self.menutexty[ self.curs[ self.submenu ][ variable ] ].color = color;
			}
			
			if ( isdefined( self.menutexty ) )
			{
				for ( i = 0; i < self.option[ "Name" ][ self.submenu ].size; i++ )
				{
					if ( isdefined( self.menutexty[ i ] ) )
					{
						self.menutexty[ i ] settext( self.option[ "Name" ][ self.submenu ][ i ] );
					}
				}
			}
		}
		
		wait 0.05;
	}
}

AddMenu( menu, num, text, function, arg1, arg2 )
{
	self.option[ "Name" ][ menu ][ num ] = text;
	self.option[ "Function" ][ menu ][ num ] = function;
	self.option[ "Arg1" ][ menu ][ num ] = arg1;
	self.option[ "Arg2" ][ menu ][ num ] = arg2;
}

AddBack( menu, back )
{
	self.menu[ "Back" ][ menu ] = back;
}

ExitSub()
{
	if ( isdefined( self.menutexty ) )
	{
		for ( i = 0; i < self.menutexty.size; i++ )
		{
			if ( isdefined( self.menutexty[ i ] ) )
			{
				self.menutexty[ i ] destroyElemFixed();
			}
		}
	}
	
	self.submenu = self.menu[ "Back" ][ self.submenu ];
	
	if ( self.submenu == "Main" )
	{
		self CursMove( "X" );
	}
	else
	{
		self CursMove( "Y" );
	}
}

ExitMenu()
{
	if ( isdefined( self.menutext ) )
	{
		for ( i = 0; i < self.menutext.size; i++ )
		{
			if ( isdefined( self.menutext[ i ] ) )
			{
				self.menutext[ i ] destroyElemFixed();
			}
		}
	}
	
	if ( isdefined( self.menu ) && isdefined( self.menu[ "X" ] ) )
	{
		if ( isdefined( self.menu[ "X" ][ "Shader" ] ) )
		{
			self.menu[ "X" ][ "Shader" ] destroyElemFixed();
		}
		
		if ( isdefined( self.menu[ "X" ][ "Scroller" ] ) )
		{
			self.menu[ "X" ][ "Scroller" ] destroyElemFixed();
		}
	}
	
	if ( isdefined( self.menuversionhud ) )
	{
		self.menuversionhud destroyFixed();
	}
	
	self.menuopen = false;
	self notify( "exit" );
	
	self setclientdvar( "r_blur", "0" );
	self setclientdvar( "sc_blur", "2" );
}

initHudElem( txt, xl, yl )
{
	hud = newclienthudelem( self );
	hud settext( txt );
	hud.alignx = "center";
	hud.aligny = "bottom";
	hud.horzalign = "center";
	hud.vertalign = "bottom";
	hud.x = xl;
	hud.y = yl;
	hud.foreground = true;
	hud.fontscale = 1;
	hud.font = "objective";
	hud.alpha = 1;
	hud.glow = 0;
	hud.glowcolor = ( 0, 0, 0 );
	hud.glowalpha = 1;
	hud.color = ( 1.0, 1.0, 1.0 );
	
	return hud;
}

createRectangle( align, relative, x, y, width, height, color, sort, alpha, shader )
{
	barElemBG = newclienthudelem( self );
	barElemBG.elemtype = "bar_";
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.align = align;
	barElemBG.relative = relative;
	barElemBG.xoffset = 0;
	barElemBG.yoffset = 0;
	barElemBG.children = [];
	barElemBG.sort = sort;
	barElemBG.color = color;
	barElemBG.alpha = alpha;
	barElemBG setparent( level.uiparent );
	barElemBG setshader( shader, width, height );
	barElemBG.hidden = false;
	barElemBG setpoint( align, relative, x, y );
	return barElemBG;
}

addOptions()
{
	self AddMenu( "Main", 0, "Manage bots", ::OpenSub, "man_bots", "" );
	self AddBack( "man_bots", "Main" );
	
	_temp = "";
	_tempDvar = getdvarint( "bots_manage_add" );
	self AddMenu( "man_bots", 0, "Add 1 bot", ::man_bots, "add", 1 + _tempDvar );
	self AddMenu( "man_bots", 1, "Add 3 bot", ::man_bots, "add", 3 + _tempDvar );
	self AddMenu( "man_bots", 2, "Add 7 bot", ::man_bots, "add", 7 + _tempDvar );
	self AddMenu( "man_bots", 3, "Add 11 bot", ::man_bots, "add", 11 + _tempDvar );
	self AddMenu( "man_bots", 4, "Add 17 bot", ::man_bots, "add", 17 + _tempDvar );
	self AddMenu( "man_bots", 5, "Kick a bot", ::man_bots, "kick", 1 );
	self AddMenu( "man_bots", 6, "Kick all bots", ::man_bots, "kick", getBotArray().size );
	
	_tempDvar = getdvarint( "bots_manage_fill_kick" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "man_bots", 7, "Kick bots when there are too many: " + _temp, ::man_bots, "autokick", _tempDvar );
	
	_tempDvar = getdvarint( "bots_manage_fill_mode" );
	
	switch ( _tempDvar )
	{
		case 0:
			_temp = "everyone";
			break;
			
		case 1:
			_temp = "just bots";
			break;
			
		case 2:
			_temp = "everyone, adjust to map";
			break;
			
		case 3:
			_temp = "just bots, adjust to map";
			break;
			
		case 4:
			_temp = "bots used as team balance";
			break;
			
		case 5:
			_temp = "bots used as team balance, adjust to map";
			break;
			
		default:
			_temp = "out of range";
			break;
	}
	
	self AddMenu( "man_bots", 8, "Bots to keep in-game counts: " + _temp, ::man_bots, "fillmode", _tempDvar );
	
	_tempDvar = getdvarint( "bots_manage_fill" );
	self AddMenu( "man_bots", 9, "Increase bots to keep in-game: " + _tempDvar, ::man_bots, "fillup", _tempDvar );
	self AddMenu( "man_bots", 10, "Decrease bots to keep in-game: " + _tempDvar, ::man_bots, "filldown", _tempDvar );
	
	_tempDvar = getdvarint( "bots_manage_fill_spec" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "man_bots", 11, "Count spectators as players: " + _temp, ::man_bots, "fillspec", _tempDvar );
	
	self AddDvarOption( "man_bots", 12, "bots_manage_fill_watchplayers" );
	self AddDvarOption( "man_bots", 13, "bots_main_kickBotsAtEnd" );
	self AddDvarOption( "man_bots", 14, "bots_main_chat" );
	
	//
	
	self AddMenu( "Main", 1, "Teams and difficulty", ::OpenSub, "man_team", "" );
	self AddBack( "man_team", "Main" );
	
	_tempDvar = getdvar( "bots_team" );
	self AddMenu( "man_team", 0, "Change bot team: " + _tempDvar, ::bot_teams, "team", _tempDvar );
	
	_tempDvar = getdvarint( "bots_team_amount" );
	self AddMenu( "man_team", 1, "Increase bots to be on axis team: " + _tempDvar, ::bot_teams, "teamup", _tempDvar );
	self AddMenu( "man_team", 2, "Decrease bots to be on axis team: " + _tempDvar, ::bot_teams, "teamdown", _tempDvar );
	
	_tempDvar = getdvarint( "bots_team_force" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "man_team", 3, "Force bots onto their team: " + _temp, ::bot_teams, "teamforce", _tempDvar );
	
	_tempDvar = getdvarint( "bots_team_mode" );
	
	if ( _tempDvar )
	{
		_temp = "only bots";
	}
	else
	{
		_temp = "everyone";
	}
	
	self AddMenu( "man_team", 4, "Team balancing counts: " + _temp, ::bot_teams, "teammode", _tempDvar );
	
	_tempDvar = getdvarint( "bots_skill" );
	
	switch ( _tempDvar )
	{
		case 0:
			_temp = "random for each bot";
			break;
			
		case 1:
			_temp = "easiest";
			break;
			
		case 2:
			_temp = "easy";
			break;
			
		case 3:
			_temp = "easy-medium";
			break;
			
		case 4:
			_temp = "medium";
			break;
			
		case 5:
			_temp = "hard";
			break;
			
		case 6:
			_temp = "very hard";
			break;
			
		case 7:
			_temp = "hardest";
			break;
			
		case 8:
			_temp = "custom";
			break;
			
		case 9:
			_temp = "completely random";
			break;
			
		default:
			_temp = "out of range";
			break;
	}
	
	self AddMenu( "man_team", 5, "Bot difficulty: " + _temp, ::bot_teams, "skill", _tempDvar );
	
	_tempDvar = getdvarint( "bots_skill_axis_hard" );
	self AddMenu( "man_team", 6, "Increase amount of hard bots on axis team: " + _tempDvar, ::bot_teams, "axishardup", _tempDvar );
	self AddMenu( "man_team", 7, "Decrease amount of hard bots on axis team: " + _tempDvar, ::bot_teams, "axisharddown", _tempDvar );
	
	_tempDvar = getdvarint( "bots_skill_axis_med" );
	self AddMenu( "man_team", 8, "Increase amount of med bots on axis team: " + _tempDvar, ::bot_teams, "axismedup", _tempDvar );
	self AddMenu( "man_team", 9, "Decrease amount of med bots on axis team: " + _tempDvar, ::bot_teams, "axismeddown", _tempDvar );
	
	_tempDvar = getdvarint( "bots_skill_allies_hard" );
	self AddMenu( "man_team", 10, "Increase amount of hard bots on allies team: " + _tempDvar, ::bot_teams, "allieshardup", _tempDvar );
	self AddMenu( "man_team", 11, "Decrease amount of hard bots on allies team: " + _tempDvar, ::bot_teams, "alliesharddown", _tempDvar );
	
	_tempDvar = getdvarint( "bots_skill_allies_med" );
	self AddMenu( "man_team", 12, "Increase amount of med bots on allies team: " + _tempDvar, ::bot_teams, "alliesmedup", _tempDvar );
	self AddMenu( "man_team", 13, "Decrease amount of med bots on allies team: " + _tempDvar, ::bot_teams, "alliesmeddown", _tempDvar );
	
	//
	
	self AddMenu( "Main", 2, "Bot settings", ::OpenSub, "set1", "" );
	self AddBack( "set1", "Main" );
	
	_tempDvar = getdvarint( "bots_loadout_reasonable" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "set1", 0, "Bots use only good class setups: " + _temp, ::bot_func, "reasonable", _tempDvar );
	
	_tempDvar = getdvarint( "bots_loadout_allow_op" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "set1", 1, "Bots can use op and annoying class setups: " + _temp, ::bot_func, "op", _tempDvar );
	
	_tempDvar = getdvarint( "bots_play_move" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "set1", 2, "Bots can move: " + _temp, ::bot_func, "move", _tempDvar );
	
	_tempDvar = getdvarint( "bots_play_knife" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "set1", 3, "Bots can knife: " + _temp, ::bot_func, "knife", _tempDvar );
	
	_tempDvar = getdvarint( "bots_play_fire" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "set1", 4, "Bots can fire: " + _temp, ::bot_func, "fire", _tempDvar );
	
	_tempDvar = getdvarint( "bots_play_nade" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "set1", 5, "Bots can nade: " + _temp, ::bot_func, "nade", _tempDvar );
	
	_tempDvar = getdvarint( "bots_play_take_carepackages" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "set1", 6, "Bots can take carepackages: " + _temp, ::bot_func, "care", _tempDvar );
	
	_tempDvar = getdvarint( "bots_play_obj" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "set1", 7, "Bots play the objective: " + _temp, ::bot_func, "obj", _tempDvar );
	
	_tempDvar = getdvarint( "bots_play_camp" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "set1", 8, "Bots can camp: " + _temp, ::bot_func, "camp", _tempDvar );
	
	_tempDvar = getdvarint( "bots_play_jumpdrop" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "set1", 9, "Bots can jump and dropshot: " + _temp, ::bot_func, "jump", _tempDvar );
	
	_tempDvar = getdvarint( "bots_play_target_other" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "set1", 10, "Bots shoot killstreaks and equipment: " + _temp, ::bot_func, "targetother", _tempDvar );
	
	_tempDvar = getdvarint( "bots_play_killstreak" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "set1", 11, "Bots can use killstreaks: " + _temp, ::bot_func, "killstreak", _tempDvar );
	
	_tempDvar = getdvarint( "bots_play_ads" );
	
	if ( _tempDvar )
	{
		_temp = "on";
	}
	else
	{
		_temp = "off";
	}
	
	self AddMenu( "set1", 12, "Bots can aim down sights: " + _temp, ::bot_func, "ads", _tempDvar );
	
	self AddDvarOption( "set1", 13, "bots_play_aim" );
	self AddDvarOption( "set1", 14, "bots_play_stance" );
	self AddDvarOption( "set1", 15, "bots_play_recoil" );
	
	//
	
	self AddMenu( "Main", 3, "Bot behavior", ::OpenSub, "behavior", "" );
	self AddBack( "behavior", "Main" );
	
	behaviors = strtok( "strafe,nade,sprint,camp,follow,crouch,switch,class,jump", "," );
	
	for ( i = 0; i < behaviors.size; i++ )
	{
		self AddDvarOption( "behavior", i, "bots_behavior_" + behaviors[ i ] );
	}
	
	//
	
	self AddMenu( "Main", 4, "More settings", ::OpenSub, "set2", "" );
	self AddBack( "set2", "Main" );
	
	self AddDvarOption( "set2", 0, "bots_skill_min" );
	self AddDvarOption( "set2", 1, "bots_skill_max" );
	self AddDvarOption( "set2", 2, "bots_skill_dynamic" );
	self AddDvarOption( "set2", 3, "bots_skill_dynamic_players" );
	self AddDvarOption( "set2", 4, "bots_loadout_rank" );
	self AddDvarOption( "set2", 5, "bots_loadout_prestige" );
	self AddDvarOption( "set2", 6, "bots_main_xp_kill" );
	self AddDvarOption( "set2", 7, "bots_main_xp_weapon" );
}

/*
	Makes an array of the given values
*/
makeList( a, b, c, d, e, f, g, h )
{
	list = [];
	
	if ( isdefined( a ) )
	{
		list[ list.size ] = a;
	}
	
	if ( isdefined( b ) )
	{
		list[ list.size ] = b;
	}
	
	if ( isdefined( c ) )
	{
		list[ list.size ] = c;
	}
	
	if ( isdefined( d ) )
	{
		list[ list.size ] = d;
	}
	
	if ( isdefined( e ) )
	{
		list[ list.size ] = e;
	}
	
	if ( isdefined( f ) )
	{
		list[ list.size ] = f;
	}
	
	if ( isdefined( g ) )
	{
		list[ list.size ] = g;
	}
	
	if ( isdefined( h ) )
	{
		list[ list.size ] = h;
	}
	
	return list;
}

/*
	Returns "on" or "off"
*/
onOff( value )
{
	if ( value )
	{
		return "on";
	}
	
	return "off";
}

/*
	Returns the name of the bot difficulty level
*/
skillName( skill )
{
	switch ( skill )
	{
		case 1:
			return "1 (easiest)";
			
		case 2:
			return "2 (easy)";
			
		case 3:
			return "3 (easy-medium)";
			
		case 4:
			return "4 (medium)";
			
		case 5:
			return "5 (hard)";
			
		case 6:
			return "6 (very hard)";
			
		case 7:
			return "7 (hardest)";
	}
	
	return "" + skill;
}

/*
	Returns a multiplier as text, ex. off, normal, x2
*/
multiplierText( value )
{
	if ( value <= 0 )
	{
		return "off";
	}
	
	if ( value == 1 )
	{
		return "normal";
	}
	
	return "x" + value;
}

/*
	Returns the readable name of a dvar for the menu
*/
menuDvarName( dvar )
{
	switch ( dvar )
	{
		case "bots_manage_fill_watchplayers":
			return "Wait for a player before adding bots";
			
		case "bots_main_kickBotsAtEnd":
			return "Kick bots when the match ends";
			
		case "bots_main_chat":
			return "Bot chat";
			
		case "bots_play_aim":
			return "Bots can aim";
			
		case "bots_play_stance":
			return "Bot stance";
			
		case "bots_play_recoil":
			return "Bot weapon recoil";
			
		case "bots_behavior_strafe":
			return "How often bots strafe in fights";
			
		case "bots_behavior_nade":
			return "How often bots throw grenades";
			
		case "bots_behavior_sprint":
			return "How often bots sprint";
			
		case "bots_behavior_camp":
			return "How often bots camp";
			
		case "bots_behavior_follow":
			return "How often bots follow others";
			
		case "bots_behavior_crouch":
			return "How often bots crouch";
			
		case "bots_behavior_switch":
			return "How often bots switch weapons";
			
		case "bots_behavior_class":
			return "How often bots change class";
			
		case "bots_behavior_jump":
			return "How often bots jump/drop shot";
			
		case "bots_skill_min":
			return "Lowest bot difficulty";
			
		case "bots_skill_max":
			return "Highest bot difficulty";
			
		case "bots_skill_dynamic":
			return "Auto difficulty";
			
		case "bots_skill_dynamic_players":
			return "By players";
			
		case "bots_loadout_rank":
			return "Bot rank";
			
		case "bots_loadout_prestige":
			return "Bot prestige";
			
		case "bots_main_xp_kill":
			return "XP for killing bots";
			
		case "bots_main_xp_weapon":
			return "Weapon XP for killing bots";
	}
	
	return dvar;
}

/*
	Returns the values the menu cycles through for a dvar
*/
menuDvarValues( dvar )
{
	switch ( dvar )
	{
		case "bots_manage_fill_watchplayers":
		case "bots_main_kickBotsAtEnd":
		case "bots_play_aim":
			return makeList( 0, 1 );
			
		case "bots_main_chat":
			return makeList( 0, 0.5, 1, 2 );
			
		case "bots_play_stance":
			return makeList( "none", "crouch", "prone", "stand" );
			
		case "bots_play_recoil":
			return makeList( 0, 0.5, 1, 1.5, 2 );
			
		case "bots_skill_min":
		case "bots_skill_max":
			return makeList( 1, 2, 3, 4, 5, 6, 7 );
			
		case "bots_skill_dynamic":
			return makeList( 0, 1, 2 );
			
		case "bots_skill_dynamic_players":
			return makeList( "2,2,2,4,4,4,4,7", "1,1,4,4,7", "1,2,3,4,5,6,7", "7,6,5,4,3,2,1" );
			
		case "bots_loadout_rank":
			return makeList( -1, 0, 1, 10, 20, 40, 60, 80 );
			
		case "bots_loadout_prestige":
			return makeList( -1, -2, 0, 5, 10, 15, 20 );
			
		case "bots_main_xp_kill":
		case "bots_main_xp_weapon":
			return makeList( 0, 0.5, 1, 2, 3 );
	}
	
	// bots_behavior_*
	return makeList( -1, 0, 5, 10, 25, 50, 75, 100 );
}

/*
	Returns the readable text of a dvar's current value for the menu
*/
menuDvarValueText( dvar )
{
	switch ( dvar )
	{
		case "bots_manage_fill_watchplayers":
		case "bots_main_kickBotsAtEnd":
		case "bots_play_aim":
			return onOff( getdvarint( dvar ) );
			
		case "bots_main_chat":
		case "bots_play_recoil":
		case "bots_main_xp_kill":
		case "bots_main_xp_weapon":
			return multiplierText( getdvarfloat( dvar ) );
			
		case "bots_play_stance":
			switch ( getdvar( dvar ) )
			{
				case "crouch":
					return "crouch only";
					
				case "prone":
					return "prone only";
					
				case "stand":
					return "stand only";
			}
			
			return "normal";
			
		case "bots_skill_min":
		case "bots_skill_max":
			return skillName( getdvarint( dvar ) );
			
		case "bots_skill_dynamic":
			switch ( getdvarint( dvar ) )
			{
				case 1:
					return "by human player count";
					
				case 2:
					return "harder when a bot is losing";
			}
			
			return "off";
			
		case "bots_skill_dynamic_players":
			switch ( getdvar( dvar ) )
			{
				case "2,2,2,4,4,4,4,7":
					return "1-3 easy, 4-7 medium, 8+ hardest";
					
				case "1,1,4,4,7":
					return "1-2 easiest, 3-4 medium, 5+ hardest";
					
				case "1,2,3,4,5,6,7":
					return "harder with more players";
					
				case "7,6,5,4,3,2,1":
					return "easier with more players";
			}
			
			return "custom (" + getdvar( dvar ) + ")";
			
		case "bots_loadout_rank":
			value = getdvarint( dvar );
			
			if ( value == -1 )
			{
				return "same as the players";
			}
			
			if ( value == 0 )
			{
				return "random";
			}
			
			return "level " + value;
			
		case "bots_loadout_prestige":
			value = getdvarint( dvar );
			
			if ( value == -1 )
			{
				return "same as the host";
			}
			
			if ( value == -2 )
			{
				return "random";
			}
			
			if ( value == 0 )
			{
				return "none";
			}
			
			return "prestige " + value;
	}
	
	// bots_behavior_*
	value = getdvarint( dvar );
	
	if ( value < 0 )
	{
		return "by difficulty";
	}
	
	if ( value == 0 )
	{
		return "never";
	}
	
	if ( value >= 100 )
	{
		return "always";
	}
	
	return value + "%";
}

/*
	Adds a menu option that cycles through the values of the dvar
*/
AddDvarOption( menu, num, dvar )
{
	self AddMenu( menu, num, menuDvarName( dvar ) + ": " + menuDvarValueText( dvar ), ::cycle_dvar, dvar, undefined );
}

/*
	Sets the dvar to its next menu value, starts over at the first if the current value is not one of them
*/
cycle_dvar( dvar, unused )
{
	values = menuDvarValues( dvar );
	index = -1;
	
	for ( i = 0; i < values.size; i++ )
	{
		if ( isstring( values[ i ] ) )
		{
			if ( getdvar( dvar ) == values[ i ] )
			{
				index = i;
				break;
			}
		}
		else
		{
			diff = getdvarfloat( dvar ) - values[ i ];
			
			if ( diff * diff < 0.0001 )
			{
				index = i;
				break;
			}
		}
	}
	
	index++;
	
	if ( index >= values.size )
	{
		index = 0;
	}
	
	setdvar( dvar, values[ index ] );
	self iprintln( menuDvarName( dvar ) + ": " + menuDvarValueText( dvar ) );
}

bot_func( a, b )
{
	switch ( a )
	{
		case "reasonable":
			setdvar( "bots_loadout_reasonable", !b );
			self iprintln( "Bots using reasonable setups: " + onOff( !b ) );
			break;
			
		case "op":
			setdvar( "bots_loadout_allow_op", !b );
			self iprintln( "Bots using op setups: " + onOff( !b ) );
			break;
			
		case "move":
			setdvar( "bots_play_move", !b );
			self iprintln( "Bots move: " + onOff( !b ) );
			break;
			
		case "knife":
			setdvar( "bots_play_knife", !b );
			self iprintln( "Bots knife: " + onOff( !b ) );
			break;
			
		case "fire":
			setdvar( "bots_play_fire", !b );
			self iprintln( "Bots fire: " + onOff( !b ) );
			break;
			
		case "nade":
			setdvar( "bots_play_nade", !b );
			self iprintln( "Bots nade: " + onOff( !b ) );
			break;
			
		case "care":
			setdvar( "bots_play_take_carepackages", !b );
			self iprintln( "Bots take carepackages: " + onOff( !b ) );
			break;
			
		case "obj":
			setdvar( "bots_play_obj", !b );
			self iprintln( "Bots play the obj: " + onOff( !b ) );
			break;
			
		case "camp":
			setdvar( "bots_play_camp", !b );
			self iprintln( "Bots camp: " + onOff( !b ) );
			break;
			
		case "jump":
			setdvar( "bots_play_jumpdrop", !b );
			self iprintln( "Bots jump: " + onOff( !b ) );
			break;
			
		case "targetother":
			setdvar( "bots_play_target_other", !b );
			self iprintln( "Bots target other: " + onOff( !b ) );
			break;
			
		case "killstreak":
			setdvar( "bots_play_killstreak", !b );
			self iprintln( "Bots use killstreaks: " + onOff( !b ) );
			break;
			
		case "ads":
			setdvar( "bots_play_ads", !b );
			self iprintln( "Bots ads: " + onOff( !b ) );
			break;
	}
}

bot_teams( a, b )
{
	switch ( a )
	{
		case "team":
			switch ( b )
			{
				case "autoassign":
					setdvar( "bots_team", "allies" );
					self iprintlnbold( "Changed bot team to allies." );
					break;
					
				case "allies":
					setdvar( "bots_team", "axis" );
					self iprintlnbold( "Changed bot team to axis." );
					break;
					
				case "axis":
					setdvar( "bots_team", "custom" );
					self iprintlnbold( "Changed bot team to custom." );
					break;
					
				default:
					setdvar( "bots_team", "autoassign" );
					self iprintlnbold( "Changed bot team to autoassign." );
					break;
			}
			
			break;
			
		case "teamup":
			setdvar( "bots_team_amount", b + 1 );
			self iprintln( ( b + 1 ) + " bot(s) will try to be on axis team." );
			break;
			
		case "teamdown":
			setdvar( "bots_team_amount", b - 1 );
			self iprintln( ( b - 1 ) + " bot(s) will try to be on axis team." );
			break;
			
		case "teamforce":
			setdvar( "bots_team_force", !b );
			self iprintln( "Force bots onto their team: " + onOff( !b ) );
			break;
			
		case "teammode":
			setdvar( "bots_team_mode", !b );
			self iprintln( "Team balancing only counts bots: " + onOff( !b ) );
			break;
			
		case "skill":
			switch ( b )
			{
				case 0:
					self iprintlnbold( "Bot difficulty: easiest" );
					setdvar( "bots_skill", 1 );
					break;
					
				case 1:
					self iprintlnbold( "Bot difficulty: easy" );
					setdvar( "bots_skill", 2 );
					break;
					
				case 2:
					self iprintlnbold( "Bot difficulty: easy-medium" );
					setdvar( "bots_skill", 3 );
					break;
					
				case 3:
					self iprintlnbold( "Bot difficulty: medium" );
					setdvar( "bots_skill", 4 );
					break;
					
				case 4:
					self iprintlnbold( "Bot difficulty: hard" );
					setdvar( "bots_skill", 5 );
					break;
					
				case 5:
					self iprintlnbold( "Bot difficulty: very hard" );
					setdvar( "bots_skill", 6 );
					break;
					
				case 6:
					self iprintlnbold( "Bot difficulty: hardest" );
					setdvar( "bots_skill", 7 );
					break;
					
				case 7:
					self iprintlnbold( "Bot difficulty: custom (set the hard and medium bots per team below)" );
					setdvar( "bots_skill", 8 );
					break;
					
				case 8:
					self iprintlnbold( "Bot difficulty: completely random (takes effect after a restart)" );
					setdvar( "bots_skill", 9 );
					break;
					
				default:
					self iprintlnbold( "Bot difficulty: random for each bot (takes effect after a restart)" );
					setdvar( "bots_skill", 0 );
					break;
			}
			
			break;
			
		case "axishardup":
			setdvar( "bots_skill_axis_hard", ( b + 1 ) );
			self iprintln( ( ( b + 1 ) ) + " hard bots will be on axis team." );
			break;
			
		case "axisharddown":
			setdvar( "bots_skill_axis_hard", ( b - 1 ) );
			self iprintln( ( ( b - 1 ) ) + " hard bots will be on axis team." );
			break;
			
		case "axismedup":
			setdvar( "bots_skill_axis_med", ( b + 1 ) );
			self iprintln( ( ( b + 1 ) ) + " med bots will be on axis team." );
			break;
			
		case "axismeddown":
			setdvar( "bots_skill_axis_med", ( b - 1 ) );
			self iprintln( ( ( b - 1 ) ) + " med bots will be on axis team." );
			break;
			
		case "allieshardup":
			setdvar( "bots_skill_allies_hard", ( b + 1 ) );
			self iprintln( ( ( b + 1 ) ) + " hard bots will be on allies team." );
			break;
			
		case "alliesharddown":
			setdvar( "bots_skill_allies_hard", ( b - 1 ) );
			self iprintln( ( ( b - 1 ) ) + " hard bots will be on allies team." );
			break;
			
		case "alliesmedup":
			setdvar( "bots_skill_allies_med", ( b + 1 ) );
			self iprintln( ( ( b + 1 ) ) + " med bots will be on allies team." );
			break;
			
		case "alliesmeddown":
			setdvar( "bots_skill_allies_med", ( b - 1 ) );
			self iprintln( ( ( b - 1 ) ) + " med bots will be on allies team." );
			break;
	}
}

man_bots( a, b )
{
	switch ( a )
	{
		case "add":
			setdvar( "bots_manage_add", b );
			
			if ( b == 1 )
			{
				self iprintln( "Adding " + b + " bot." );
			}
			else
			{
				self iprintln( "Adding " + b + " bots." );
			}
			
			break;
			
		case "kick":
			result = false;
			
			for ( i = 0; i < b; i++ )
			{
				tempBot = random( getBotArray() );
				
				if ( isdefined( tempBot ) )
				{
					kick( tempBot getentitynumber(), "EXE_PLAYERKICKED" );
					result = true;
				}
				
				wait 0.25;
			}
			
			if ( !result )
			{
				self iprintln( "No bots to kick" );
			}
			
			break;
			
		case "autokick":
			setdvar( "bots_manage_fill_kick", !b );
			self iprintln( "Kick bots when there are too many: " + onOff( !b ) );
			break;
			
		case "fillmode":
			switch ( b )
			{
				case 0:
					setdvar( "bots_manage_fill_mode", 1 );
					self iprintln( "Bots to keep in-game counts: just bots" );
					break;
					
				case 1:
					setdvar( "bots_manage_fill_mode", 2 );
					self iprintln( "Bots to keep in-game counts: everyone, adjust to map" );
					break;
					
				case 2:
					setdvar( "bots_manage_fill_mode", 3 );
					self iprintln( "Bots to keep in-game counts: just bots, adjust to map" );
					break;
					
				case 3:
					setdvar( "bots_manage_fill_mode", 4 );
					self iprintln( "Bots to keep in-game counts: bots used as team balance" );
					break;
					
				case 4:
					setdvar( "bots_manage_fill_mode", 5 );
					self iprintln( "Bots to keep in-game counts: bots used as team balance, adjust to map" );
					break;
					
				default:
					setdvar( "bots_manage_fill_mode", 0 );
					self iprintln( "Bots to keep in-game counts: everyone" );
					break;
			}
			
			break;
			
		case "fillup":
			setdvar( "bots_manage_fill", b + 1 );
			self iprintln( "Increased to maintain " + ( b + 1 ) + " bot(s)." );
			break;
			
		case "filldown":
			setdvar( "bots_manage_fill", b - 1 );
			self iprintln( "Decreased to maintain " + ( b - 1 ) + " bot(s)." );
			break;
			
		case "fillspec":
			setdvar( "bots_manage_fill_spec", !b );
			self iprintln( "Count spectators as players: " + onOff( !b ) );
			break;
	}
}
