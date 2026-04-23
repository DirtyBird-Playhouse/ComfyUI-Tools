@echo off
setlocal enabledelayedexpansion
cls

:: --- AUTO-DETECTION ---
if exist ".\python_embeded" (
    set "ENV_TYPE=PORTABLE"
    set "ENV_FOLDER=python_embeded"
    set "PIP_CMD=.\python_embeded\python.exe -m pip"
) else if exist ".\venv" (
    set "ENV_TYPE=VENV"
    set "ENV_FOLDER=venv"
    set "PIP_CMD=.\venv\Scripts\python.exe -m pip"
) else (
    echo [ERROR] Could not find 'python_embeded' or 'venv' folder.
    echo Please place this script in your main ComfyUI directory.
    pause
    exit
)

:menu
cls
echo ===========================================
echo    COMFYUI %ENV_TYPE% MANAGER
echo ===========================================
echo 1. Backup Environment (Timestamped)
echo 2. Restore from Backup (Select Folder)
echo 3. Install a package
echo 4. Uninstall a package
echo 5. List all installed packages
echo 6. Exit
echo ===========================================
set /p choice="Choose an option (1-6): "

if %choice%==1 goto backup
if %choice%==2 goto restore
if %choice%==3 goto install
if %choice%==4 goto uninstall
if %choice%==5 goto list
if %choice%==6 exit
goto menu

:backup
:: Generate timestamp (YYYYMMDD_HHMM)
set "tstamp=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%"
set "tstamp=%tstamp: =0%"
set "BACKUP_NAME=backup_%ENV_FOLDER%_%tstamp%"

echo.
echo Creating backup: %BACKUP_NAME%...
xcopy /s /i /y ".\%ENV_FOLDER%" ".\%BACKUP_NAME%"
echo.
echo Backup complete!
pause
goto menu

:restore
echo.
echo Available backups:
dir /ad /b backup_%ENV_FOLDER%_*
echo.
set /p folder="Copy and Paste the full backup folder name to restore: "
if not exist ".\%folder%" (
    echo [ERROR] Folder not found!
    pause
    goto menu
)
echo.
echo WARNING: This will replace your current '%ENV_FOLDER%' with '%folder%'.
set /p confirm="Proceed? (y/n): "
if /i not "%confirm%"=="y" goto menu

:: Restore logic: delete current, COPY backup (to keep backup intact)
echo Restoring...
rd /s /q ".\%ENV_FOLDER%"
xcopy /s /i /y ".\%folder%" ".\%ENV_FOLDER%"
echo.
echo Restore complete!
pause
goto menu

:install
set /p pkg="Enter package name to INSTALL: "
%PIP_CMD% install %pkg%
pause
goto menu

:uninstall
set /p pkg="Enter package name to UNINSTALL: "
%PIP_CMD% uninstall %pkg%
pause
goto menu

:list
%PIP_CMD% list
pause
goto menu
