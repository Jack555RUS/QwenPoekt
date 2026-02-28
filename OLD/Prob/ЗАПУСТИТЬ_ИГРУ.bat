@echo off
title Racing Game - Run

echo === RACING GAME - RUN ===
echo.

if exist "Build\RacingGame.exe" (
    echo [INFO] Starting game...
    echo.
    start "" "Build\RacingGame.exe"
    echo.
    echo Game started!
) else (
    echo [ERROR] Game not found!
    echo.
    echo Run BuildAndRun.bat first to build the game.
    echo.
    pause
)
