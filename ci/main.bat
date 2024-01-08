@echo off

xcopy /y ci .
rm scripts\bots_adapter_piw5.gsc

gsc-tool.exe comp iw5 pc .
