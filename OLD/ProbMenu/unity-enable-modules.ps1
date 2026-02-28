# =============================================================================
# Скрипт включения Built-in модулей Unity
# =============================================================================

param(
    [string]$ProjectPath = "D:\QwenPoekt\ProbMenu\DragRaceUnity"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Enabling Built-in Unity Modules" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Путь к файлу настроек проекта
$packagesPath = Join-Path $ProjectPath "Packages"

# Создаём папку Packages если нет
if (-not (Test-Path $packagesPath)) {
    New-Item -ItemType Directory -Path $packagesPath -Force | Out-Null
    Write-Host "[OK] Created Packages folder" -ForegroundColor Green
}

# manifest.json с built-in модулями
$manifest = @{
    dependencies = @{
        "com.unity.inputsystem" = "1.7.0"
        "com.unity.test-framework" = "1.3.9"
        "com.unity.ugui" = "1.0.0"
        "com.unity.modules.audio" = "1.0.0"
        "com.unity.modules.particlesystem" = "1.0.0"
        "com.unity.modules.physics" = "1.0.0"
        "com.unity.modules.physics2d" = "1.0.0"
        "com.unity.modules.ui" = "1.0.0"
        "com.unity.modules.uielements" = "1.0.0"
        "com.unity.modules.animation" = "1.0.0"
        "com.unity.modules.imageconversion" = "1.0.0"
    }
}

# Сохранение manifest.json
$manifestPath = Join-Path $packagesPath "manifest.json"
$manifest | ConvertTo-Json -Depth 10 | Out-File $manifestPath -Encoding UTF8 -NoNewline

Write-Host "[OK] Updated manifest.json with built-in modules" -ForegroundColor Green
Write-Host ""
Write-Host "Added modules:" -ForegroundColor Cyan

$manifest.dependencies.GetEnumerator() | ForEach-Object {
    Write-Host "  + $($_.Key) v$($_.Value)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Now open Unity to import the packages:" -ForegroundColor Yellow
Write-Host "  Unity Hub → Open Project → $ProjectPath" -ForegroundColor Gray
Write-Host ""
