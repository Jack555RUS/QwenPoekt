@echo off
REM ============================================================================
REM ЗАПУСК НАСТРОЙКИ РАСПИСАНИЯ БЭКАПА
REM ============================================================================
REM Этот файл запускает schedule-backup-tasks.ps1 от имени администратора
REM ============================================================================

echo.
echo === НАСТРОЙКА РАСПИСАНИЯ БЭКАПА ===
echo.
echo Требуется запуск от имени администратора!
echo.
echo Запуск PowerShell с повышенными правами...
echo.

powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File \"%~dp0scripts\schedule-backup-tasks.ps1\"'"

echo.
echo Окно запущено! Проверьте результат в окне PowerShell.
echo.
pause
