@echo off
title Racing Game - Build and Run

echo === RACING GAME - BUILD AND RUN ===
echo.

REM Check Unity path
set "UNITY_PATH=C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe"

if not exist "%UNITY_PATH%" (
    echo [ERROR] Unity Editor not found!
    echo Check path in BuildAndRun.bat
    pause
    exit /b 1
)

echo [INFO] Unity path: %UNITY_PATH%
echo.

REM Create Build folder
if not exist "Build" (
    mkdir Build
    echo [INFO] Created Build folder
)

echo === START BUILD ===
echo.

REM Run Unity build
echo [BUILD] Starting Unity Build...
"%UNITY_PATH%" -batchmode -quit -projectPath "%CD%" -executeMethod AutoBuildScript.PerformBuild -logFile "Build\Build.log"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo === BUILD SUCCESS ===
    echo.
    
    if exist "Build\RacingGame.exe" (
        echo [SUCCESS] EXE created: Build\RacingGame.exe
        echo.
        
        for %%A in ("Build\RacingGame.exe") do (
            echo [INFO] Size: %%~zA bytes
        )
        echo.
        
        echo Run game?
        set /p RUN="Y/N: "
        if /i "%RUN%"=="Y" (
            echo.
            echo [RUN] Starting game...
            start "" "Build\RacingGame.exe"
        )
    ) else (
        echo [WARNING] EXE not found!
        echo Check log: Build\Build.log
    )
) else (
    echo.
    echo === BUILD FAILED ===
    echo.
    echo [ERROR] Error code: %ERRORLEVEL%
    echo Check log: Build\Build.log
)

echo.
pause
