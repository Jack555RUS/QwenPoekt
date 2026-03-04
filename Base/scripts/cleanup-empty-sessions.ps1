# cleanup-empty-sessions.ps1 — Очистка пустых сессий
# Версия: 1.0
# Дата: 4 марта 2026 г.
# Назначение: Удаление сессий с <20 строками (пустые шаблоны)

param(
    [switch]$DryRun,      # Проверка без удаления
    [switch]$AutoConfirm, # Автоматическое подтверждение
    [int]$MinLines = 20   # Минимальное количество строк для сохранения
)

$ErrorActionPreference = "Stop"

# Пути
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$SessionsPath = Join-Path $BasePath "sessions"

# Цвета
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"

function Write-Status {
    param($status, $msg, $color)
    $symbol = switch ($status) {
        "OK" { "✅" }
        "WARN" { "⚠️" }
        "FAIL" { "❌" }
        "INFO" { "ℹ️" }
        "DEL" { "🗑️" }
    }
    Write-Host "$symbol $msg" -ForegroundColor $color
}

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           ОЧИСТКА ПУСТЫХ СЕССИЙ                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# ============================================
# 1. АНАЛИЗ СЕССИЙ
# ============================================

Write-Host "[1/3] Анализ сессий..." -ForegroundColor Cyan

$totalSessions = 0
$emptySessions = 0
$keepSessions = 0
$toDelete = @()
$toKeep = @()

$sessions = Get-ChildItem $SessionsPath -Directory | Where-Object { $_.Name -notlike "_*" }

foreach ($session in $sessions) {
    $totalSessions++
    $chatPath = Join-Path $session.FullName "chat.md"
    
    if (Test-Path $chatPath) {
        $lines = (Get-Content $chatPath | Measure-Object -Line).Lines
        
        if ($lines -ge $MinLines) {
            $keepSessions++
            $toKeep += @{
                Name = $session.Name
                Lines = $lines
                Path = $session.FullName
            }
        } else {
            $emptySessions++
            $toDelete += @{
                Name = $session.Name
                Lines = $lines
                Path = $session.FullName
            }
        }
    } else {
        $emptySessions++
        $toDelete += @{
            Name = $session.Name
            Lines = 0
            Path = $session.FullName
        }
    }
}

Write-Status "INFO" "Всего сессий: $totalSessions" $Cyan
Write-Status "OK" "Сохранить (≥$MinLines строк): $keepSessions" $Green
Write-Status "WARN" "Удалить (<$MinLines строк): $emptySessions" $Yellow

# ============================================
# 2. ПОДТВЕРЖДЕНИЕ
# ============================================

if (-not $AutoConfirm) {
    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    
    if ($DryRun) {
        Write-Host "РЕЖИМ ПРОВЕРКИ (ничего не удаляется)" -ForegroundColor Yellow
    } else {
        Write-Host "БУДУТ УДАЛЕНЫ $emptySessions сессий" -ForegroundColor Red
    }
    
    Write-Host "`nСохраняемые сессии:" -ForegroundColor Green
    foreach ($session in $toKeep) {
        Write-Host "  ✅ $($session.Name) — $($session.Lines) строк"
    }
    
    Write-Host "`nУдаляемые сессии:" -ForegroundColor Yellow
    foreach ($session in $toDelete[0..9]) {
        Write-Host "  🗑️ $($session.Name) — $($session.Lines) строк"
    }
    if ($toDelete.Count -gt 10) {
        Write-Host "  ... и ещё $($toDelete.Count - 10) сессий"
    }
    
    if (-not $DryRun) {
        $response = Read-Host "`nПродолжить удаление? (Y/N)"
        if ($response -ne 'Y' -and $response -ne 'y') {
            Write-Host "`n❌ Отменено пользователем" -ForegroundColor Red
            exit 0
        }
    }
}

# ============================================
# 3. УДАЛЕНИЕ
# ============================================

Write-Host "`n[2/3] $(if ($DryRun) {'Проверка'} else {'Удаление'})..." -ForegroundColor Cyan

$deletedCount = 0
$failedCount = 0
$freedSpace = 0

foreach ($session in $toDelete) {
    try {
        $sessionSize = (Get-ChildItem $session.Path -Recurse -File | Measure-Object -Property Length -Sum).Sum
        $freedSpace += $sessionSize
        
        if ($DryRun) {
            Write-Status "DEL" "БУДЕТ УДАЛЕНО: $($session.Name) ($([math]::Round($sessionSize / 1KB, 2)) KB)" $Yellow
        } else {
            Remove-Item $session.Path -Recurse -Force
            Write-Status "DEL" "УДАЛЕНО: $($session.Name) ($([math]::Round($sessionSize / 1KB, 2)) KB)" $Yellow
        }
        $deletedCount++
    } catch {
        Write-Status "FAIL" "ОШИБКА: $($session.Name) — $_" $Red
        $failedCount++
    }
}

# ============================================
# 4. ОТЧЁТ
# ============================================

Write-Host "`n[3/3] Отчёт..." -ForegroundColor Cyan

Write-Status "INFO" "Удалено сессий: $deletedCount" $Cyan
if ($failedCount -gt 0) {
    Write-Status "FAIL" "Ошибок: $failedCount" $Red
}
Write-Status "INFO" "Освобождено места: $([math]::Round($freedSpace / 1MB, 2)) MB" $Cyan
Write-Status "OK" "Сохранено сессий: $keepSessions" $Green

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "ПРОВЕРКА ЗАВЕРШЕНА (запустите без -DryRun для удаления)" -ForegroundColor Yellow
} else {
    Write-Host "ОЧИСТКА ЗАВЕРШЕНА" -ForegroundColor Green
}
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
