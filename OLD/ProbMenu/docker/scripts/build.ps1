# =============================================================================
# Docker Build Script для ProbMenu
# =============================================================================
# Скрипт для сборки всех Docker-образов проекта
# =============================================================================

param(
    [string]$Version = "latest",
    [switch]$NoCache,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot | Split-Path -Parent
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Docker Build - ProbMenu" -ForegroundColor Cyan
Write-Host "  Время: $Timestamp" -ForegroundColor Cyan
Write-Host "  Версия: $Version" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Set-Location $ProjectRoot

# Проверка Docker
Write-Host "`n[1/4] Проверка Docker..." -ForegroundColor Yellow
docker --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker не установлен или не запущен!" -ForegroundColor Red
    exit 1
}

# Сборка основного образа
Write-Host "`n[2/4] Сборка образа probmenu..." -ForegroundColor Yellow
$BuildArgs = @(
    "build"
    "-t", "probmenu:$Version"
    "-t", "probmenu:latest"
    "-f", "Dockerfile"
    "."
)
if ($NoCache) {
    $BuildArgs += "--no-cache"
}
if (-not $Verbose) {
    $BuildArgs += "--progress", "plain"
}
docker $BuildArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Сборка probmenu не удалась!" -ForegroundColor Red
    exit 1
}

# Сборка образа для тестов
Write-Host "`n[3/4] Сборка образа probmenu-test..." -ForegroundColor Yellow
docker build -t probmenu-test:$Version -f Dockerfile . --target build

if ($LASTEXITCODE -ne 0) {
    Write-Host "WARNING: Сборка test-образа не удалась!" -ForegroundColor Yellow
}

# Итоговая информация
Write-Host "`n[4/4] Список образов:" -ForegroundColor Yellow
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | Select-String "probmenu"

Write-Host "`n==================================================" -ForegroundColor Green
Write-Host "  Сборка завершена успешно!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host "`nИспользование:" -ForegroundColor Cyan
Write-Host "  docker-compose --profile app up -d" -ForegroundColor White
Write-Host "  docker-compose --profile dev up -d" -ForegroundColor White
Write-Host "  docker-compose --profile full up -d" -ForegroundColor White
