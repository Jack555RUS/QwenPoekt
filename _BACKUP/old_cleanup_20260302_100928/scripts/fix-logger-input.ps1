# Исправление всех файлов проекта DragRaceUnity

Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "Исправление Logger и Input конфликтов" -ForegroundColor White
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""

$basePath = "D:\QwenPoekt\ProbMenu\DragRaceUnity\Assets\Scripts"

# Список файлов для исправления
$files = @(
    "UI\MainMenuController.cs",
    "UI\GameMenuController.cs",
    "UI\GarageUI.cs",
    "UI\TuningUI.cs",
    "UI\ShopUI.cs",
    "UI\DashboardUI.cs",
    "Audio\AudioManager.cs",
    "Audio\EngineSound.cs",
    "Audio\TireSound.cs",
    "Effects\CarEffects.cs",
    "Input\InputManager.cs",
    "Physics\CarPhysics.cs",
    "Racing\RaceManager.cs",
    "Racing\RaceCamera.cs",
    "Racing\CareerManager.cs",
    "Racing\TrafficLight.cs",
    "SaveSystem\SaveManager.cs",
    "Settings\SettingsManager.cs"
)

foreach ($file in $files) {
    $path = Join-Path $basePath $file
    if (Test-Path $path) {
        Write-Host "Исправление: $file" -ForegroundColor Green
        
        $content = Get-Content $path -Raw
        
        # 1. Заменить using static на using Logger = 
        $content = $content -replace 'using static ProbMenu\.Core\.Logger;', 'using Logger = ProbMenu.Core.Logger;'
        
        # 2. Заменить ProbMenu.Input на UnityEngine.Input
        $content = $content -replace 'ProbMenu\.Input\.GetKey\(', 'UnityEngine.Input.GetKey('
        $content = $content -replace 'ProbMenu\.Input\.GetKeyDown\(', 'UnityEngine.Input.GetKeyDown('
        $content = $content -replace 'ProbMenu\.Input\.GetKeyUp\(', 'UnityEngine.Input.GetKeyUp('
        
        # Сохранить
        Set-Content -Path $path -Value $content -NoNewline -Encoding UTF8
    } else {
        Write-Host "НЕ НАЙДЕН: $file" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "Готово! Исправлено файлов: $($files.Count)" -ForegroundColor Green
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Теперь откройте Unity и проверьте Console (должно быть 0 ошибок)" -ForegroundColor Yellow
