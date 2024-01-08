@echo off

xcopy /y ci .
rm scripts\bots_adapter_piw5.gsc

gsc-tool.exe parse iw5 pc .
