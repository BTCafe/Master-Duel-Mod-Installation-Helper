@echo off

cls
call :printLineBreak
echo Auto Copy Master Duel Mod 0.5 by BTC
call :printLineBreak
echo This is a simple script to automate the install process of Master Duel mods
echo Check for update here - https://www.nexusmods.com/yugiohmasterduel/mods/283
call :printLineBreak
call :getStatus

if defined savedPath (
	echo(
	echo Previous working path detected, reusing it to save your time... 
	echo *You can change the folder path by deleting the 'ModStatus.ini' file or choosing option 4
	set initialPath=%savedPath%
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

rem Getting the installation folder path
set folderID=1234
set /a found=0
for /D %%G in ("%initialPath%\LocalData\*") do (
	set folderID=%%~nxG
	set /a found+=1
)

set completePath=%initialPath%\LocalData\%folderID%\0000\
echo( 

rem Warn user when they have multiple account playing Master Duel since the script currently can only install in one account 
if %found% GTR 1 (
	call :printLineBreak
	echo CAUTION - Multiple Steam account detected, mod will only be installed in one of them %folderID%
	rem echo(
	rem echo Account List
	rem for /D %%G in ("%initialPath%\LocalData\*") do (
	rem 	call :checkDir %%~nxG
	rem )
	rem echo(
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
	echo(
	echo Installation aborted
	set "initialPath="
	Goto end
)

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
echo 3) Cancel Installation
echo 4) Reset Install Path
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
set "initialPath="
echo Install path reset, run the script again to input a new path
Goto end

:3
echo Installation aborted
Goto end

:2
robocopy .\Original\ "%completePath%\" /s /e /is /NFL /NDL /NJH /nc /ns /np 
set modInstalled=false 
echo Original version restored
Goto end

:1
robocopy .\Modded\ "%completePath%\" /s /e /is /NFL /NDL /NJH /nc /ns /np 
set modInstalled=true
echo Mod installed
Goto end

:end
call :printLineBreak
call :updateStatus
echo(

@pause

:getStatus
if exist ModStatus.ini ( 
	for /f "delims== tokens=1,2" %%G in (ModStatus.ini) do (
		set %%G=%%H
	)
) else (
	set modDescription=No info
	set modInstalled=unknown
)
EXIT /B

:updateStatus
(
	echo modDescription=%modDescription%
	echo modInstalled=%modInstalled%
	echo savedPath=%initialPath%
) > ModStatus.ini
EXIT /B

:inputPath
set /p "initialPath=Enter Your Install Path: "

:: Check if the input is empty
if "%initialPath%"=="" (
    echo The path cannot be empty.
    goto inputPath
)
EXIT /B

:checkDir
echo %1
EXIT /B

:printLineBreak
echo =============================================================================================================
EXIT /B