@echo off

if not exist ".\source\" mkdir .\source\
if not exist ".\source\scripts\" mkdir .\source\scripts\
if not exist ".\source\maps\" mkdir .\source\maps\

xcopy /y /s /e .\scripts\ .\source\scripts\
xcopy /y /s /e .\maps\ .\source\maps\

preGSC.exe -noforeach -nopause
