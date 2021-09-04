@echo off
::Paste the server key from https://platform.plutonium.pw/serverkeys here
set key=
::RemoteCONtrol password, needed for most management tools like IW4MADMIN and B3. Do not skip if you installing IW4MADMIN.
set rcon_password=
::Name of the config file the server should use. (default: dedicated.cfg)
set cfg=server.cfg
::Name of the server shown in the title of the cmd window. This will NOT bet shown ingame.
set name=IW5 Bot Warfare
::Port used by the server (default: 27016)
set port=27020
::What ip to bind too
set ip=0.0.0.0
::Mod name (default "")
set mod=
::Only change this when you don't want to keep the bat files in the game folder. MOST WON'T NEED TO EDIT THIS!
set gamepath=%cd%
::IMPORTANT! Make sure the filename is unique for each server you clone!
set g_log=logs\games_mp.log

title PlutoniumIW5 MP - %name% - Server restarter
echo Visit plutonium.pw / Join the Discord (a6JM2Tv) for NEWS and Updates!
echo Server "%name%" will load "%cfg%" and listen on port "%port%" UDP with IP "%ip%"!
echo To shut down the server close this window first!
echo (%date%)  -  (%time%) %name% server start.

cd /D %LOCALAPPDATA%\Plutonium
:server
start /wait /abovenormal bin\plutonium-bootstrapper-win32.exe iw5mp "%gamepath%" -dedicated +unattended -sv_config "%cfg%" -key "%key%" -net_ip "%ip%" -net_port "%port%" -rcon_password "%rcon_password%" -fs_game "%mod%" -g_log "%g_log%" +start_map_rotate
echo (%date%)  -  (%time%) WARNING: %name% server closed or dropped... server restarts.
goto Server
