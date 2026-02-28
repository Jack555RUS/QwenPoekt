@echo off
REM =============================================================================
REM Docker Run Script для ProbMenu (Windows .bat)
REM =============================================================================

set PROFILE=%1
if "%PROFILE%"=="" set PROFILE=app

echo ==================================================
echo   Docker Run - ProbMenu
echo   Profil': %PROFILE%
echo ==================================================

REM Sozdanie direktoriy
if not exist "appdata" mkdir appdata
if not exist "Builds" mkdir Builds
if not exist "TestResults" mkdir TestResults

echo.
echo Zapusk konteinerov...
docker compose --profile %PROFILE% up %2

echo.
echo ==================================================
echo   Konteinery zapushheny!
echo ==================================================

echo.
echo Status:
docker compose ps

if "%PROFILE%"=="dev" (
    echo.
    echo Servisy dostupny:
    echo   Adminer (BD):  http://localhost:8080
    echo   Redis:         localhost:6379
    echo   PostgreSQL:    localhost:5432
)
