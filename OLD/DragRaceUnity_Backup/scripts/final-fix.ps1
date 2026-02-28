# Финальное исправление всех ошибок компиляции

Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "Финальное исправление ошибок DragRaceUnity" -ForegroundColor White
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""

$basePath = "D:\QwenPoekt\ProbMenu\DragRaceUnity\Assets\Scripts"

# 1. Исправление StartSceneController.cs - замена Debug.Log на Logger
Write-Host "1. Исправление StartSceneController.cs..." -ForegroundColor Green
$startScenePath = Join-Path $basePath "Core\StartSceneController.cs"
if (Test-Path $startScenePath) {
    $content = Get-Content $startScenePath -Raw
    $content = $content -replace 'using UnityEngine\.UI;', "using UnityEngine.UI;`nusing Logger = ProbMenu.Core.Logger;"
    $content = $content -replace 'Debug\.Log\(', 'Logger.I('
    $content = $content -replace 'Debug\.LogWarning\(', 'Logger.W('
    $content = $content -replace 'Debug\.LogError\(', 'Logger.E('
    Set-Content -Path $startScenePath -Value $content -NoNewline -Encoding UTF8
    Write-Host "   ✅ StartSceneController.cs исправлен" -ForegroundColor Green
}

# 2. Исправление RaceManager.cs - проверить using
Write-Host "2. Проверка RaceManager.cs..." -ForegroundColor Green
$raceManagerPath = Join-Path $basePath "Racing\RaceManager.cs"
if (Test-Path $raceManagerPath) {
    $content = Get-Content $raceManagerPath -Raw
    if ($content -notmatch 'using Logger = ProbMenu\.Core\.Logger;') {
        $content = $content -replace 'using ProbMenu\.Physics;', "using ProbMenu.Physics;`nusing Logger = ProbMenu.Core.Logger;"
        Set-Content -Path $raceManagerPath -Value $content -NoNewline -Encoding UTF8
        Write-Host "   ✅ RaceManager.cs исправлен" -ForegroundColor Green
    } else {
        Write-Host "   ✅ RaceManager.cs уже исправлен" -ForegroundColor Green
    }
}

# 3. Проверка всех файлов на ProbMenu.Input
Write-Host "3. Поиск ProbMenu.Input в файлах..." -ForegroundColor Green
$files = Get-ChildItem -Path $basePath -Recurse -Filter *.cs
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match 'ProbMenu\.Input\.GetKey') {
        Write-Host "   ⚠️  Найден ProbMenu.Input в: $($file.Name)" -ForegroundColor Yellow
        $content = $content -replace 'ProbMenu\.Input\.GetKey\(', 'UnityEngine.Input.GetKey('
        $content = $content -replace 'ProbMenu\.Input\.GetKeyDown\(', 'UnityEngine.Input.GetKeyDown('
        $content = $content -replace 'ProbMenu\.Input\.GetKeyUp\(', 'UnityEngine.Input.GetKeyUp('
        Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
        Write-Host "      Исправлено на UnityEngine.Input" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "Финальное исправление завершено!" -ForegroundColor Green
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Следующие шаги:" -ForegroundColor Yellow
Write-Host "1. Откройте Unity" -ForegroundColor White
Write-Host "2. Дождитесь реимпорта" -ForegroundColor White
Write-Host "3. Проверьте Console (должно быть 0 ошибок)" -ForegroundColor White
