@echo off
::setlocal enabledelayedexpansion
setlocal
set loc = %~dp0
set relpath = ..\LaunchBox\LaunchBox.exe
echo Root path:
echo %loc
echo Rel path: %relpath%

set final= %loc% and %relpath%
echo Final value: %final%
pause