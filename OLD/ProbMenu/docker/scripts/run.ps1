# =============================================================================
# Docker Run Script для ProbMenu
# =============================================================================
# Скрипт для запуска Docker-контейнеров
# =============================================================================

param(
    [ValidateSet("app", "dev", "full", "test", "unity")]
    [string]$Profile = "app",
    [switch]$Detach,
    [switch]$Build,
    [switch]$Watch
)

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot | Split-Path -Parent
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Docker Run - ProbMenu" -ForegroundColor Cyan
Write-Host "  Время: $Timestamp" -ForegroundColor Cyan
Write-Host "  Профиль: $Profile" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Set-Location $ProjectRoot

# Проверка Docker
Write-Host "`n[1/3] Проверка Docker..." -ForegroundColor Yellow
docker compose version
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker Compose не установлен!" -ForegroundColor Red
    exit 1
}

# Создание необходимых директорий
Write-Host "`n[2/3] Создание директорий..." -ForegroundColor Yellow
$Dirs = @("appdata", "Builds", "TestResults")
foreach ($dir in $Dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  Создано: $dir" -ForegroundColor Gray
    }
}

# Запуск контейнеров
Write-Host "`n[3/3] Запуск контейнеров (профиль: $Profile)..." -ForegroundColor Yellow

$ComposeArgs = @("compose")
if ($Build) {
    $ComposeArgs += "--build"
}
$ComposeArgs += @("--profile", $Profile, "up")
if ($Detach) {
    $ComposeArgs += "-d"
}
if ($Watch) {
    $ComposeArgs += "--watch"
}

docker compose $ComposeArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Запуск контейнеров не удался!" -ForegroundColor Red
    exit 1
}

# Информация о запущенных контейнерах
Write-Host "`n==================================================" -ForegroundColor Green
Write-Host "  Контейнеры запущены!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

Write-Host "`nСтатус контейнеров:" -ForegroundColor Cyan
docker compose ps

Write-Host "`nПолезные команды:" -ForegroundColor Cyan
Write-Host "  docker compose logs -f          # Просмотр логов" -ForegroundColor White
Write-Host "  docker compose down             # Остановка всех" -ForegroundColor White
Write-Host "  docker compose ps               # Статус контейнеров" -ForegroundColor White

if ($Profile -eq "dev" -or $Profile -eq "full") {
    Write-Host "`nСервисы доступны:" -ForegroundColor Cyan
    Write-Host "  Adminer (БД):  http://localhost:8080" -ForegroundColor White
    Write-Host "  Redis:         localhost:6379" -ForegroundColor White
    Write-Host "  PostgreSQL:    localhost:5432" -ForegroundColor White
}
