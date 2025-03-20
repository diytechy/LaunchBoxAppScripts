@echo off
setlocal

:: Define a relative path
set relativePath=..\LaunchBox\BigBox.exe
set overlayPS=ScreenOverlayOnProperty.ps1
:: Combine script's path with the relative path
set LBPath=%~dp0%relativePath%
set OLPath=%~dp0%overlayPS%
::echo Full Path: %fullPath%
call %LBPath%
powershell.exe -ExecutionPolicy Bypass -WindowStyle Minimized -file "%OLPath%"
endlocal