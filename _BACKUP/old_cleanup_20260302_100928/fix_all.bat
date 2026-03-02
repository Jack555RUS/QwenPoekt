@echo off
REM Исправление всех файлов проекта DragRaceUnity

echo ============================================================================
echo Исправление Logger и Input конфликтов
echo ============================================================================
echo.

REM Список файлов для исправления
set FILES=
UI\MainMenuController.cs
UI\GameMenuController.cs
UI\GarageUI.cs
UI\TuningUI.cs
UI\ShopUI.cs
UI\DashboardUI.cs
Audio\AudioManager.cs
Audio\EngineSound.cs
Audio\TireSound.cs
Effects\CarEffects.cs
Input\InputManager.cs
Physics\CarPhysics.cs
Racing\RaceManager.cs
Racing\RaceCamera.cs
Racing\CareerManager.cs
Racing\TrafficLight.cs
SaveSystem\SaveManager.cs
Settings\SettingsManager.cs

echo Добавление using Logger = ProbMenu.Core.Logger; во все файлы...
echo.

for %%f in (%FILES%) do (
    echo Исправление: %%f
    powershell -Command "Get-Content 'Assets\Scripts\%%f' | ForEach-Object { if ($_ -match '^using System;') { $_; 'using Logger = ProbMenu.Core.Logger;' } else { $_ } } | Set-Content 'Assets\Scripts\%%f.tmp' -NoNewline; Move-Item -Force 'Assets\Scripts\%%f.tmp' 'Assets\Scripts\%%f'"
)

echo.
echo ============================================================================
echo Готово!
echo ============================================================================
pause
