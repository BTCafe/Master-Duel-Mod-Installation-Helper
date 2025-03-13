@echo off

:start
cls
call :printLineBreak
echo Auto Copy Master Duel Mod 0.8 by BTC
call :printLineBreak
echo This is a simple script to automate the install process of Master Duel mods
echo Check for update here - https://www.nexusmods.com/yugiohmasterduel/mods/283
echo GitHub page - https://github.com/BTCafe/Master-Duel-Mod-Installation-Helper
call :printLineBreak

call :getModRegistry
if exist ".\Modded" (call :checkFolderStructure "Modded")
if exist ".\Original" (call :checkFolderStructure "Original")

if exist "%installPath%" (
	echo(
	echo Saved Path: %installPath%
	echo Previous install path detected, reusing it to save your time 
	echo *You can reset the install path by choosing option 4
	echo(
	call :setCompletePath "%installPath%"
	if exist ".\masterduel_Data" (
		rem This means we're modding Unity3d
		Goto selectionUnity
	) else (
		Goto selection
	)
) else (
	echo(
	echo Please enter the install folder of your Master Duel
	echo Example: D:\SteamLibrary\steamapps\common\Yu-Gi-Oh!  Master Duel
	echo(
	echo *On Steam 'right-click Master Duel icon - Manage - Browse Local Files' and then copy the address from File Manager
	echo *Video guide - https://www.youtube.com/watch?v=Ay0fdOYRBtE  
	echo(
	echo *WARNING - If your Master Duel is located inside ^(Program Files x86^) then you need to move it somewhere else
	echo before using this script. Weird things happen when dealing with PATH that includes ^(  ^) .... 
	echo Here's how to do that - https://help.steampowered.com/en/faqs/view/4BD4-4528-6B2E-8327
	echo(
	call :setInitialPath
	echo(
)

rem Checking how many account user have
set folderID=1234
set /a found=0
for /D %%G in ("%initialPath%\LocalData\*") do (
	set folderID=%%~nxG
	set /a found+=1
)
echo( 

if %found% EQU 1 (
	call :setCompletePath "%initialPath%\LocalData\%folderID%\0000"
	call :setRegistryAuto "%completePath%"
)

rem When user have multiple account make them choose which folder to be installed 
if %found% GTR 1 (
	call :printLineBreak
	echo Account List
	echo(
	for /D %%G in ("%initialPath%\LocalData\*") do (
		call :checkDir "%%G"
	)
	echo(
	echo Multiple Steam account detected, please copy the full path of one of the above folder
	echo Example: X:\SteamLibrary\steamapps\common\Yu-Gi-Oh!  Master Duel\LocalData\abcd123
	echo(
	echo * Without the "" 
	echo(
	call :setRegistryManual
)

rem Warn user when the path provided is incorrect
if %found% EQU 0 (
	cls
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
	@pause
	EXIT
)

:selection
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
cls
call :delRegistry
EXIT

:3
cls
call :printLineBreak
echo(
echo(
echo Trying to exit... press 3 again if this window still up
echo(
echo(
call :printLineBreak
EXIT

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

:checkFolderStructure
set /a statusStructure=1
dir /a-d "%1\*" >nul 2>nul && (
		rem echo File outside of folder, proceed to make folder for each
 	set /a statusStructure=0) || (
 		rem echo No file found, proceed as normal
 	)

if %statusStructure% EQU 0 (
	for %%G in (".\%1\*") do (
			set charactersFolder=%%~nxG
			call :repairFolder "%charactersFolder%" %1  
	)
)
rem echo %statusStructure%
EXIT /B

:repairFolder
rem Make a new folder based on the first two character of the file and then move those file inside it 
MD ".\%2\%charactersFolder:~0,2%" >nul
move ".\%2\%charactersFolder%" ".\%2\%charactersFolder:~0,2%" >nul
EXIT /B

:selectionUnity
call :printLineBreak
echo Please select what you want to do
echo 1) Install Unity Mod
echo 2) Revert to Original Unity 
echo 3) Exit 
echo 4) Reset Install Folder
echo(
echo Mod will be installed in: %completePath%
call :printLineBreak
echo If the game doesn't start, you can manually download the original Unity file from this link
echo https://drive.google.com/drive/folders/1WAk4M1Iz8Br0DX2I9bglHmrXqRwIJvXj?usp=drive_link
call :printLineBreak
CHOICE /M Select /C 1234 
echo(
call :printLineBreak

If Errorlevel 4 Goto 4
If Errorlevel 3 Goto 3
If Errorlevel 2 Goto 6
If Errorlevel 1 Goto 5

:6
call :setUnityPath
set originalUnity=%currentUnityFile%
if exist "%backupUnityFile%" (
	del "%currentUnityFile%"
	copy "%backupUnityFile%" "%originalUnity%"
) else (
	echo No backup file detected, you might need to download it manually from this link
	echo https://drive.google.com/drive/folders/1WAk4M1Iz8Br0DX2I9bglHmrXqRwIJvXj?usp=drive_link
)
call :printLineBreak
set modInstalled=false 
echo Original version restored
Goto end

:5
call :setUnityPath
if not exist "%backupUnityFile%" (
	call :printLineBreak
	copy "%currentUnityFile%" "%backupUnityFile%"
	echo Backup created
	call :printLineBreak
)
if exist ".\masterduel_Data" (
	robocopy .\masterduel_Data %unityPath% data.unity3d /s /e /is /NFL /NDL /NJH /nc /ns /np 
	set modInstalled=true
	echo Mod installed
) else (
	echo No modded folder found, make sure there's masterduel_Data folder containing the modded data.unity3d in it
)
Goto end

:getModRegistry
:: Check if install path exist in registry
reg query HKCU\Software\BTCafeMod >nul 2>&1

if %Errorlevel% EQU 0 (
	for /f "tokens=2,*" %%A in ('reg query "HKCU\Software\BTCafeMod" /v installPath ^| find "LocalData"') do (
	    set "installPath=%%B"
	)	
) else (
	echo No Previous Working Path Detected
)
EXIT /B

:setRegistryManual
set /p "newInstallPath=Enter Your New Install Path: "
cls
call :printLineBreak
echo(
reg add HKCU\Software\BTCafeMod /v installPath /d "%newInstallPath%"\0000 /f 
echo Your Install Path: %newInstallPath%
echo Correct Example: X:\SteamLibrary\steamapps\common\Yu-Gi-Oh!  Master Duel\LocalData\abcd123
echo(
call :printLineBreak
echo New install path inputted, please exit and run the script again to install the mod
echo(
echo If it still ask for new path then you enter it INCORRECTLY!
echo(
@pause
EXIT

:setRegistryAuto
cls
call :printLineBreak
echo(
reg add "HKCU\Software\BTCafeMod" /v installPath /d %completePath% /f 
echo Your Install Path: "%completePath%"
echo Correct Example: X:\SteamLibrary\steamapps\common\Yu-Gi-Oh!  Master Duel\LocalData\abcd123
echo(
call :printLineBreak
echo Found the install folder, please exit and run the script again to install the mod
echo(
@pause
EXIT

:delRegistry
cls
reg delete HKCU\Software\BTCafeMod /f
echo Install path reset, please exit and run the script again to input the new path...
@pause
EXIT /B

:setCompletePath
set completePath=%1
EXIT /B

:setInitialPath
set /p "initialPath=Enter Your Install Path: "

:: Check if the input is empty
if "%initialPath%"=="" (
    echo The path cannot be empty.
    goto setInitialPath
)
EXIT /B

:checkDir
echo %1
EXIT /B

:printLineBreak
echo =============================================================================================================
EXIT /B

:setUnityPath
rem Removes the last 15 character so we return to the two folders above
set basePath=%completePath:~0,-25%
set unityPath=%basePath%\masterduel_Data"

rem ~1,-1 is used here to remove the double quote so we can add the file we want to change
set currentUnityFile=%unityPath:~1,-1%\data.unity3d
set backupUnityFile=%unityPath:~1,-1%\data.unity3d.og
EXIT /B

:end
call :printLineBreak
echo(
@pause
Goto :start