@echo off
setlocal

:: Define a relative path
set relativePath=..\LaunchBox\LaunchBox.exe

:: Combine script's path with the relative path
set fullPath=%~dp0%relativePath%

echo Full Path: %fullPath%
call %fullPath%

endlocal
pause
