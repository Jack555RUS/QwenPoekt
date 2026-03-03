# apply-powershell-profile.ps1 — Применение оптимизированного PowerShell профиля
# Версия: 1.0
# Дата: 2 марта 2026 г.

$ErrorActionPreference = "Stop"

Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         ПРИМЕНЕНИЕ POWERSHELL ПРОФИЛЯ                    ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Пути
$ProfilePath = $PROFILE
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$OptimizedProfilePath = Join-Path $ScriptPath "powershell-profile-optimized.ps1"

Write-Host "[1/4] Проверка путей..." -ForegroundColor Cyan
Write-Host "  Профиль: $ProfilePath" -ForegroundColor Gray
Write-Host "  Скрипт: $OptimizedProfilePath" -ForegroundColor Gray

# Проверка существования скрипта
if (Test-Path $OptimizedProfilePath) {
    Write-Host "  ✅ Скрипт оптимизации найден" -ForegroundColor Green
} else {
    Write-Host "  ❌ Скрипт оптимизации не найден: $OptimizedProfilePath" -ForegroundColor Red
    exit 1
}

# Создание резервной копии
Write-Host ""
Write-Host "[2/4] Создание резервной копии..." -ForegroundColor Cyan

if (Test-Path $ProfilePath) {
    $BackupPath = "$ProfilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -Path $ProfilePath -Destination $BackupPath -Force
    Write-Host "  ✅ Резервная копия: $BackupPath" -ForegroundColor Green
} else {
    Write-Host "  ℹ️  Профиль не найден, создаём новый" -ForegroundColor Yellow
}

# Копирование оптимизированного профиля
Write-Host ""
Write-Host "[3/4] Копирование оптимизированного профиля..." -ForegroundColor Cyan

# Создать директорию если не существует
$ProfileDir = Split-Path -Parent $ProfilePath
if (-not (Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
    Write-Host "  ✅ Создана директория: $ProfileDir" -ForegroundColor Green
}

# Копирование
Copy-Item -Path $OptimizedProfilePath -Destination $ProfilePath -Force
Write-Host "  ✅ Профиль применён: $ProfilePath" -ForegroundColor Green

# Проверка
Write-Host ""
Write-Host "[4/4] Проверка..." -ForegroundColor Cyan

$content = Get-Content $ProfilePath -Raw
if ($content -match "NODE_OPTIONS") {
    Write-Host "  ✅ NODE_OPTIONS найден в профиле" -ForegroundColor Green
} else {
    Write-Host "  ❌ NODE_OPTIONS не найден!" -ForegroundColor Red
    exit 1
}

if ($content -match "function lt") {
    Write-Host "  ✅ function lt найден (исправлено!)" -ForegroundColor Green
} else {
    Write-Host "  ❌ function lt не найден!" -ForegroundColor Red
    exit 1
}

# Итог
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              ✅ ПРОФИЛЬ ПРИМЕНЁН УСПЕШНО!                 ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "📁 Профиль: $ProfilePath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Для применения:" -ForegroundColor Yellow
Write-Host "  1. Перезапустите PowerShell" -ForegroundColor Gray
Write-Host "  2. Или выполните: . `$PROFILE" -ForegroundColor Gray
Write-Host ""
Write-Host "Проверка:" -ForegroundColor Yellow
Write-Host "  node-memory  — проверить память Node.js" -ForegroundColor Gray
Write-Host "  git-opt      — проверить Git настройки" -ForegroundColor Gray
Write-Host "  cls2         — очистить экран + GC" -ForegroundColor Gray
Write-Host ""
