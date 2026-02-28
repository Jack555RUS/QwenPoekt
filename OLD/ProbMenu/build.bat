@echo off
echo ============================================
echo   Сборка ProbMenu в EXE
echo ============================================
echo.

echo [1/3] Очистка предыдущей сборки...
dotnet clean ProbMenu.csproj >nul 2>&1

echo [2/3] Публикация Release версии...
dotnet publish ProbMenu.csproj -c Release -o publish --self-contained false

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ============================================
    echo   СБОРКА ЗАВЕРШЕНА УСПЕШНО!
    echo ============================================
    echo.
    echo EXE-файл: publish\ProbMenu.exe
    echo.
    echo Для запуска выполните:
    echo   start publish\ProbMenu.exe
    echo.
) else (
    echo.
    echo ============================================
    echo   ОШИБКА СБОРКИ!
    echo ============================================
    exit /b 1
)
