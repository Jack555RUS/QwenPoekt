@echo off
REM =============================================================================
REM Docker Build Script для ProbMenu (Windows .bat)
REM =============================================================================

set VERSION=%1
if "%VERSION%"=="" set VERSION=latest

echo ==================================================
echo   Docker Build - ProbMenu
echo   Versiya: %VERSION%
echo ==================================================

echo.
echo [1/3] Proverka Docker...
docker --version
if errorlevel 1 (
    echo ERROR: Docker ne ustanovlen!
    exit /b 1
)

echo.
echo [2/3] Sborka obraza probmenu:%VERSION%...
docker build -t probmenu:%VERSION% -t probmenu:latest -f Dockerfile .

if errorlevel 1 (
    echo ERROR: Sborka ne udalas!
    exit /b 1
)

echo.
echo [3/3] Spisok obrazov:
docker images | findstr probmenu

echo.
echo ==================================================
echo   Sborka zavershena uspeshno!
echo ==================================================
echo.
echo Ispol'zovanie:
echo   docker-compose --profile app up -d
echo   docker-compose --profile dev up -d
