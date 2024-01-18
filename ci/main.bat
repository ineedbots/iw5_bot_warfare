@echo off

xcopy /y ci .
rm scripts\mp\bots_adapter_piw5.gsc

gsc-tool.exe -m comp -g iw5 -s pc .
