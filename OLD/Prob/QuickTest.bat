@echo off
title Racing Game - Quick Test

echo === RACING GAME - QUICK TEST ===
echo.
echo This will open Unity Editor for testing.
echo.

set "UNITY_PATH=C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe"

if not exist "%UNITY_PATH%" (
    echo [ERROR] Unity not found!
    pause
    exit /b 1
)

echo [INFO] Opening project in Unity...
echo.
echo After Unity opens:
echo   1. Open Assets/Scenes/MainMenu.unity
echo   2. Press Play to test the menu
echo   3. Check console for errors
echo.

start "" "%UNITY_PATH%" -projectPath "%CD%"

echo Unity is starting...
echo.
echo Close this window when done.
pause
