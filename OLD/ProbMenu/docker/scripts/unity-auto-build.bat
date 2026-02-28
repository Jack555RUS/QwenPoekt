@echo off
REM Автоматическая сборка Unity проекта в Docker

echo ============================================================================
echo Автоматическая сборка Unity в Docker
echo ============================================================================
echo.

REM Проверка переменных окружения
if "%UNITY_EMAIL%"=="" (
    echo ОШИБКА: UNITY_EMAIL не установлен
    echo Установите: setx UNITY_EMAIL "your@email.com"
    exit /b 1
)

if "%UNITY_PASSWORD%"=="" (
    echo ОШИБКА: UNITY_PASSWORD не установлен
    echo Установите: setx UNITY_PASSWORD "your-password"
    exit /b 1
)

REM Запуск PowerShell скрипта
powershell -ExecutionPolicy Bypass -File "%~dp0unity-auto-build.ps1"

pause
