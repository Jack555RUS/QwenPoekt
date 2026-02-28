# =============================================================================
# Docker Test Script для ProbMenu
# =============================================================================
# Скрипт для запуска тестов в Docker-контейнере
# =============================================================================

param(
    [switch]$Coverage,
    [switch]$Verbose,
    [string]$Filter
)

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot | Split-Path -Parent
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Docker Test - ProbMenu" -ForegroundColor Cyan
Write-Host "  Время: $Timestamp" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Set-Location $ProjectRoot

# Создание директории для результатов
$TestResultsDir = Join-Path $ProjectRoot "TestResults"
if (-not (Test-Path $TestResultsDir)) {
    New-Item -ItemType Directory -Path $TestResultsDir -Force | Out-Null
}

# Проверка Docker
Write-Host "`n[1/4] Проверка Docker..." -ForegroundColor Yellow
docker --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker не установлен!" -ForegroundColor Red
    exit 1
}

# Запуск тестов
Write-Host "`n[2/4] Запуск тестов в контейнере..." -ForegroundColor Yellow

$TestArgs = @("compose", "--profile", "test", "run", "--rm")
if ($Verbose) {
    $TestArgs += "-e", "DOTNET_ENVIRONMENT=Test"
}

$TestArgs += "test-runner"

if ($Filter) {
    $TestArgs += "--", "--filter", $Filter
}
if ($Coverage) {
    $TestArgs += "--", "--collect:`"XPlat Code Coverage`""
}

docker compose $TestArgs

$TestExitCode = $LASTEXITCODE

# Отображение результатов
Write-Host "`n[3/4] Результаты тестов:" -ForegroundColor Yellow
if (Test-Path $TestResultsDir) {
    Get-ChildItem $TestResultsDir -Recurse -File | Select-Object Name, Length, LastWriteTime
}

# Статус
Write-Host "`n[4/4] Статус:" -ForegroundColor Yellow
if ($TestExitCode -eq 0) {
    Write-Host "  ВСЕ ТЕСТЫ ПРОЙДЕНЫ ✓" -ForegroundColor Green
} else {
    Write-Host "  ТЕСТЫ НЕ ПРОЙДЕНЫ ✗ (код: $TestExitCode)" -ForegroundColor Red
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host "  Тестирование завершено!" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

exit $TestExitCode
