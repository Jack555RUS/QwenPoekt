@echo off
REM =============================================================================
REM Unity Build Script для Docker (Windows .bat)
REM =============================================================================

set BUILD_NAME=%1
if "%BUILD_NAME%"=="" set BUILD_NAME=DragRace
set PLATFORM=%2
if "%PLATFORM%"=="" set PLATFORM=Win64

echo ==================================================
echo   Unity Docker Build
echo   Platforma: %PLATFORM%
echo ==================================================

REM Sozdanie direktorii
if not exist "Builds" mkdir Builds

REM Proverka litsenzii
if "%UNITY_LICENSE%"=="" (
    echo WARNING: UNITY_LICENSE ne ustanovlena!
    echo Dlya sborki Unity trebuetsya litsenziya.
)

echo.
echo Zapusk Unity Builder...
docker compose --profile unity run --rm unity-builder

echo.
echo ==================================================
echo   Sborka zavershena!
echo ==================================================
echo Put' k sborkam: .\Builds
