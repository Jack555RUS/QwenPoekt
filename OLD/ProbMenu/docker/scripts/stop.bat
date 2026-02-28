@echo off
REM =============================================================================
REM Docker Stop Script для ProbMenu (Windows .bat)
REM =============================================================================

echo ==================================================
echo   Docker Stop - ProbMenu
echo ==================================================

echo.
echo Ostanovka konteinerov...
docker compose down

echo.
echo ==================================================
echo   Ostanovka zavershena!
echo ==================================================
