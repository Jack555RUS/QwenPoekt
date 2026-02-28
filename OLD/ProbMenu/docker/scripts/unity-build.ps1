# =============================================================================
# Unity Build Script для Docker
# =============================================================================
# Скрипт для сборки Unity проекта в Docker-контейнере
# =============================================================================

param(
    [string]$BuildName = "DragRace",
    [ValidateSet("Win64", "Win32", "Linux64", "Mac64")]
    [string]$Platform = "Win64",
    [switch]$Clean
)

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot | Split-Path -Parent
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Unity Docker Build" -ForegroundColor Cyan
Write-Host "  Время: $Timestamp" -ForegroundColor Cyan
Write-Host "  Платформа: $Platform" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Set-Location $ProjectRoot

# Создание директории для сборок
$BuildsDir = Join-Path $ProjectRoot "Builds"
if (-not (Test-Path $BuildsDir)) {
    New-Item -ItemType Directory -Path $BuildsDir -Force | Out-Null
}

if ($Clean) {
    Write-Host "`nОчистка предыдущих сборок..." -ForegroundColor Yellow
    Get-ChildItem $BuildsDir -Recurse | Remove-Item -Recurse -Force
}

# Проверка лицензии Unity
if (-not $env:UNITY_LICENSE) {
    Write-Host "`nWARNING: UNITY_LICENSE не установлена!" -ForegroundColor Yellow
    Write-Host "Для сборки Unity требуется лицензия." -ForegroundColor Yellow
    Write-Host "Получите лицензию: https://license.unity3d.com/manual" -ForegroundColor Gray
}

# Запуск Unity Builder в Docker
Write-Host "`n[1/2] Запуск Unity Builder..." -ForegroundColor Yellow

$DockerArgs = @(
    "compose", "--profile", "unity", "run", "--rm"
    "-e", "UNITY_LICENSE=$env:UNITY_LICENSE"
    "-e", "UNITY_EMAIL=$env:UNITY_EMAIL"
    "-e", "UNITY_PASSWORD=$env:UNITY_PASSWORD"
    "unity-builder"
)

# Команда для сборки внутри контейнера
$UnityCommand = @"
unity-builder 
  --projectPath /unity-project 
  --buildPath /builds 
  --buildName $BuildName 
  --buildTarget $Platform
  --executeMethod BuildScript.PerformBuild
"@

docker compose $DockerArgs

$BuildExitCode = $LASTEXITCODE

# Проверка результата
Write-Host "`n[2/2] Проверка сборки..." -ForegroundColor Yellow
if (Test-Path $BuildsDir) {
    $Files = Get-ChildItem $BuildsDir -Recurse -File
    if ($Files.Count -gt 0) {
        Write-Host "  Найдено файлов: $($Files.Count)" -ForegroundColor Green
        $Files | ForEach-Object { Write-Host "    - $($_.Name)" -ForegroundColor Gray }
    } else {
        Write-Host "  Файлы сборки не найдены!" -ForegroundColor Red
    }
}

Write-Host "`n==================================================" -ForegroundColor Cyan
if ($BuildExitCode -eq 0) {
    Write-Host "  Сборка завершена успешно!" -ForegroundColor Green
} else {
    Write-Host "  Сборка не удалась (код: $BuildExitCode)" -ForegroundColor Red
}
Write-Host "==================================================" -ForegroundColor Cyan

Write-Host "`nПуть к сборкам: $BuildsDir" -ForegroundColor White

exit $BuildExitCode
