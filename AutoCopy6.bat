@echo off

:start
cls
call :printLineBreak
echo Auto Copy Master Duel Mod 0.6 by BTC
call :printLineBreak
echo This is a simple script to automate the install process of Master Duel mods
echo Check for update here - https://www.nexusmods.com/yugiohmasterduel/mods/283
call :printLineBreak

call :getModInfo
call :getModRegistry

if defined installPath (
	echo(
	echo Previous working path detected 
	echo *You can change the folder path by choosing option 4
	call :setCompletePath "%installPath%"
	rem There needs to be a check to make sure install path from registry points to an existing folder 
	Goto selection
) else (
	echo(
	echo Please enter the install folder of your Master Duel
	echo Example: D:\SteamLibrary\steamapps\common\Yu-Gi-Oh!  Master Duel
	echo(
	echo *On Steam 'right-click Master Duel icon - Manage - Browse Local Files' and then copy the address from File Manager
	echo *Video guide - https://www.youtube.com/watch?v=Ay0fdOYRBtE  
	echo(
	echo *WARNING - If your Master Duel is located in Program Files x86 then you cannot install using this script.
	echo You need to install it manually until I found out how to fix it 
	echo(
	call :inputPath
	echo(
)

rem Checking how many account user have
set folderID=1234
set /a found=0
for /D %%G in ("%initialPath%\LocalData\*") do (
	set folderID=%%~nxG
	set /a found+=1
)
set checkingPath="%initialPath%\LocalData\%folderID%\0000" 
call :setCompletePath "%checkingPath%"
echo( 

rem When user have multiple account make them choose which folder to be installed 
if %found% GTR 1 (
	call :printLineBreak
	echo Account List
	for /D %%G in ("%initialPath%\LocalData\*") do (
		call :checkDir "%%G"
	)
	echo(
	echo Multiple Steam account detected, please copy the full path of one of the above folder
	echo Example - X:\SteamLibrary\steamapps\common\Yu-Gi-Oh!  Master Duel\abcd123
	echo(
	echo * Without the "" 
	echo(
	call :setRegistryManual
)

rem Warn user when the path provided is incorrect
if %found% EQU 0 (
	call :printLineBreak
	echo WARNING - No Master Duel installation found on the provided path, make sure you enter the correct one. 
	echo(
	echo Check this video to see the correct way of obtaining it
	echo https://www.youtube.com/watch?v=Ay0fdOYRBtE
	echo(
	echo Path Provided: %completePath%
	echo Correct Path Example: X:\SteamLibrary\steamapps\common\Yu-Gi-Oh!  Master Duel
	echo(
	echo Installation aborted
	set "initialPath="
	@pause
	Goto :EOF
)

:selection
call :printLineBreak
echo(
echo Mod Description: %modDescription%

if /i %modInstalled% EQU true (echo Mod Installed: TRUE)
if /i %modInstalled% EQU false (echo Mod Installed: FALSE)
if /i %modInstalled% EQU unknown (echo Mod Installed: UNKNOWN)

echo(
call :printLineBreak
echo Please select what you want to do
echo 1) Install the Mod
echo 2) Revert to Original version 
echo 3) Exit 
echo 4) Reset Install Folder
echo(
echo Mod will be installed in: %completePath%
call :printLineBreak
CHOICE /M Select /C 1234 
echo(
call :printLineBreak

If Errorlevel 4 Goto 4
If Errorlevel 3 Goto 3
If Errorlevel 2 Goto 2
If Errorlevel 1 Goto 1

:4
call :delRegistry
Goto :EOF

:3
echo Trying to exit... press 3 again if this window still up
Goto :EOF

:2
robocopy .\Original\ %completePath% /s /e /is /NFL /NDL /NJH /nc /ns /np 
set modInstalled=false 
echo Original version restored
Goto end

:1
robocopy .\Modded\ %completePath% /s /e /is /NFL /NDL /NJH /nc /ns /np 
set modInstalled=true
echo Mod installed
Goto end


:getModInfo
if exist ModStatus.ini ( 
	for /f "delims== tokens=1,2" %%G in (ModStatus.ini) do (
		set %%G=%%H
	)
) else (
	set modDescription=No info
	set modInstalled=unknown
)
EXIT /B

:getModRegistry
:: Check if install path exist in registry
reg query HKCU\Software\BTCafeMod >nul 2>&1

if %Errorlevel% EQU 0 (
	for /f "tokens=2,*" %%A in ('reg query "HKCU\Software\BTCafeMod" /v installPath ^| find "LocalData"') do (
	    set "installPath=%%B"
	)	
) 
EXIT /B

:setRegistryManual
set /p "newInstallPath=Enter Your New Install Path: "
call :printLineBreak
reg add HKCU\Software\BTCafeMod /v installPath /d "%newInstallPath%"\0000 /f 
echo New Install Path: %newInstallPath%
echo Correct Example - X:\SteamLibrary\steamapps\common\Yu-Gi-Oh!  Master Duel\abcd123
call :printLineBreak
echo The script will restart now...	
echo If it still ask for new path then you enter it incorrectly!
@pause
Goto start

:delRegistry
reg delete HKCU\Software\BTCafeMod /f
echo Registry deleted, please run the script again and input the new path...
@pause
EXIT /B

:setCompletePath
set completePath=%1
EXIT /B

:inputPath
set /p "initialPath=Enter Your Install Path: "

:: Check if the input is empty
if "%initialPath%"=="" (
    echo The path cannot be empty.
    goto inputPath
)
EXIT /B

:updateStatus
(
	echo modDescription=%modDescription%
	echo modInstalled=%modInstalled%
) > ModStatus.ini
echo Registry Path - "%completePath%"
call :printLineBreak
EXIT /B

:checkDir
echo %1
EXIT /B

:printLineBreak
echo =============================================================================================================
EXIT /B

:end
call :printLineBreak
call :updateStatus
echo(
@pause
Goto :start