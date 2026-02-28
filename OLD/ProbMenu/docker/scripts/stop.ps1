# =============================================================================
# Docker Stop Script для ProbMenu
# =============================================================================
# Скрипт для остановки и очистки Docker-контейнеров
# =============================================================================

param(
    [switch]$RemoveVolumes,
    [switch]$RemoveImages,
    [switch]$All
)

$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot | Split-Path -Parent
$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Docker Stop - ProbMenu" -ForegroundColor Cyan
Write-Host "  Время: $Timestamp" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

Set-Location $ProjectRoot

# Остановка контейнеров
Write-Host "`n[1/3] Остановка контейнеров..." -ForegroundColor Yellow
docker compose down

if ($RemoveVolumes) {
    Write-Host "`n[2/3] Удаление томов..." -ForegroundColor Yellow
    docker compose down -v
}

if ($RemoveImages) {
    Write-Host "`n[2/3] Удаление образов..." -ForegroundColor Yellow
    docker compose down --rmi local
}

# Очистка неиспользуемых ресурсов (если запрошено)
if ($All) {
    Write-Host "`n[3/3] Полная очистка..." -ForegroundColor Yellow
    docker system prune -f
}

Write-Host "`n==================================================" -ForegroundColor Green
Write-Host "  Остановка завершена!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Статус оставшихся контейнеров
Write-Host "`nОставшиеся контейнеры:" -ForegroundColor Cyan
docker ps -a --filter "name=probmenu" --format "table {{.Names}}\t{{.Status}}"
