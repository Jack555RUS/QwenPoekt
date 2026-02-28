@echo off
REM =============================================================================
REM Docker Test Script для ProbMenu (Windows .bat)
REM =============================================================================

echo ==================================================
echo   Docker Test - ProbMenu
echo ==================================================

REM Sozdanie direktorii
if not exist "TestResults" mkdir TestResults

echo.
echo Zapusk testov v konteinere...
docker compose --profile test run --rm test-runner

set TEST_RESULT=%ERRORLEVEL%

echo.
echo ==================================================
if %TEST_RESULT% EQU 0 (
    echo   VSE TESTY PROYDENY
) else (
    echo   TESTY NE PROYDENY (kod: %TEST_RESULT%)
)
echo ==================================================

exit /b %TEST_RESULT%
