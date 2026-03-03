# start-session.ps1 — Проверка и восстановление сессии
# Версия: 1.0
# Дата: 2 марта 2026 г.
# Назначение: Автоматическая проверка контекста при старте сессии

param(
    [switch]$Resume,
    [switch]$Verbose,
    [switch]$NoColor
)

$ErrorActionPreference = "Stop"

# Цвета вывода
function Write-Info { param($msg) if (-not $NoColor) { Write-Host $msg -ForegroundColor Cyan } else { Write-Host $msg } }
function Write-Success { param($msg) if (-not $NoColor) { Write-Host $msg -ForegroundColor Green } else { Write-Host $msg } }
function Write-Warning { param($msg) if (-not $NoColor) { Write-Host $msg -ForegroundColor Yellow } else { Write-Host $msg } }
function Write-Error { param($msg) if (-not $NoColor) { Write-Host $msg -ForegroundColor Red } else { Write-Host $msg } }

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║         ПРОВЕРКА СЕССИИ $(Get-Date -Format 'yyyy-MM-dd HH:mm')                  ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"

# Пути
$BasePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ReportsPath = Join-Path $BasePath "reports"
$SessionHandoverPath = Join-Path $ReportsPath "SESSION_HANDOVER.md"
$ResumeMarkerPath = Join-Path $BasePath ".resume_marker.json"
$CurrentTaskPath = Join-Path $BasePath "ТЕКУЩАЯ_ЗАДАЧА.md"
$ErrorLogPath = Join-Path $BasePath "ERROR_LOG.md"

# ============================================
# 1. ПРОВЕРКА МАРКЕРА ВОССТАНОВЛЕНИЯ
# ============================================

Write-Info "[1/4] Проверка маркера восстановления..."

$HasResumeMarker = Test-Path $ResumeMarkerPath
$HasSessionHandover = Test-Path $SessionHandoverPath

if ($HasResumeMarker) {
    Write-Success "  ✅ Маркер восстановления найден"
    
    try {
        $ResumeData = Get-Content $ResumeMarkerPath -Raw | ConvertFrom-Json
        
        Write-Host ""
        Write-Info "╔══════════════════════════════════════════════════════════╗"
        Write-Info "║              НАЙДЕНА ПРЕДЫДУЩАЯ СЕССИЯ!                  ║"
        Write-Info "╚══════════════════════════════════════════════════════════╝"
        Write-Host ""
        Write-Info "📊 Информация о сессии:"
        Write-Host "  Дата: $($ResumeData.Date)" -ForegroundColor Gray
        Write-Host "  Причина: $($ResumeData.Reason)" -ForegroundColor Gray
        Write-Host "  Задача: $($ResumeData.CurrentTask)" -ForegroundColor Gray
        Write-Host "  След. шаг: $($ResumeData.NextStep)" -ForegroundColor Gray
        Write-Host ""
        
        if ($Resume) {
            Write-Success "  ✅ Режим восстановления активирован"
            Write-Host ""
            Write-Info "📄 Открываю SESSION_HANDOVER.md..."
            Write-Host ""
            
            # Показываем содержимое SESSION_HANDOVER.md
            if ($HasSessionHandover) {
                Get-Content $SessionHandoverPath | Select-Object -First 50
            }
            
            Write-Host ""
            Write-Info "╔══════════════════════════════════════════════════════════╗"
            Write-Info "║              КОНТЕКСТ ВОССТАНОВЛЕН! ✅                   ║"
            Write-Info "╚══════════════════════════════════════════════════════════╝"
            Write-Host ""
            Write-Info "Для продолжения:"
            Write-Info "  1. Прочитайте SESSION_HANDOVER.md полностью"
            Write-Info "  2. Проверьте ТЕКУЩАЯ_ЗАДАЧА.md"
            Write-Info "  3. Продолжите с последней задачи"
            Write-Host ""
            
            # Возвращаем данные для ИИ
            return @{
                HasPreviousSession = $true
                ResumeData = $ResumeData
                SessionFile = $SessionHandoverPath
            }
        } else {
            Write-Info "💡 Используйте команду \`/resume\` для автоматического восстановления"
            Write-Host ""
            Write-Info "Или прочитайте вручную:"
            Write-Info "  - SESSION_HANDOVER.md — контекст сессии"
            Write-Info "  - ТЕКУЩАЯ_ЗАДАЧА.md — активные задачи"
            Write-Host ""
        }
    } catch {
        Write-Warning "  ⚠️ Ошибка чтения маркера: $_"
    }
} else {
    Write-Info "  ℹ️  Маркер восстановления не найден"
    Write-Info "  → Новая сессия (без предыдущего контекста)"
}

# ============================================
# 2. ПРОВЕРКА SESSION_HANDOVER.md
# ============================================

Write-Info "[2/4] Проверка SESSION_HANDOVER.md..."

if ($HasSessionHandover) {
    Write-Success "  ✅ SESSION_HANDOVER.md найден"
    
    if (-not $Resume) {
        Write-Info "  💡 Файл существует, но маркер не активен"
        Write-Info "  → Возможно, сессия была завершена ранее"
    }
} else {
    Write-Info "  ℹ️  SESSION_HANDOVER.md не найден"
    Write-Info "  → Новая сессия (без предыдущего контекста)"
}

# ============================================
# 3. ПРОВЕРКА GIT СТАТУСА
# ============================================

Write-Info "[3/4] Проверка Git статуса..."

try {
    $GitBranch = git branch --show-current 2>$null
    $GitStatus = git status --porcelain 2>$null
    $UncommittedChanges = ($GitStatus | Measure-Object).Count
    
    Write-Success "  ✅ Git репозиторий найден"
    Write-Host "  Ветка: $GitBranch" -ForegroundColor Gray
    
    if ($UncommittedChanges -gt 0) {
        Write-Warning "  ⚠️ Найдено $UncommittedChanges незакоммиченных изменений"
        if ($Verbose) {
            Write-Host ""
            Write-Host "Изменения:" -ForegroundColor Yellow
            $GitStatus | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
            Write-Host ""
        }
    } else {
        Write-Success "  ✅ Нет незакоммиченных изменений"
    }
} catch {
    Write-Warning "  ⚠️ Git не найден или ошибка: $_"
}

# ============================================
# 4. ПРОВЕРКА ТЕКУЩИХ ЗАДАЧ
# ============================================

Write-Info "[4/4] Проверка текущих задач..."

if (Test-Path $CurrentTaskPath) {
    Write-Success "  ✅ ТЕКУЩАЯ_ЗАДАЧА.md найден"
    
    # Извлечение активных задач
    $Content = Get-Content $CurrentTaskPath -Raw
    if ($Content -match '(?s)## 🎯 АКТИВНЫЕ ЗАДАЧИ.*?(?=##|\Z)') {
        $ActiveTasksSection = $matches[0]
        $ActiveTasks = ($ActiveTasksSection -split '\n' | Where-Object { $_ -match '^\|.*\|$' -and $_ -notmatch '\|--------\|' -and $_ -notmatch '^\|--------\|' }) | Select-Object -First 5
        
        if ($ActiveTasks.Count -gt 0) {
            Write-Host ""
            Write-Info "📋 Активные задачи:"
            $ActiveTasks | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
            Write-Host ""
        }
    }
} else {
    Write-Warning "  ⚠️ ТЕКУЩАЯ_ЗАДАЧА.md не найден"
}

# ============================================
# ИТОГ
# ============================================

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Success "║              ПРОВЕРКА ЗАВЕРШЕНА ✅                     ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

# Рекомендации
if ($HasResumeMarker -and -not $Resume) {
    Write-Info "📌 Рекомендации:"
    Write-Host ""
    Write-Info "  Для восстановления контекста:"
    Write-Info "  1. Используйте команду /resume"
    Write-Info "  2. Или прочитайте SESSION_HANDOVER.md вручную"
    Write-Host ""
} elseif ($HasResumeMarker -and $Resume) {
    Write-Success "  Контекст восстановлен! Готов к работе."
    Write-Host ""
} else {
    Write-Info "📌 Рекомендации:"
    Write-Host ""
    Write-Info "  Новая сессия:"
    Write-Info "  1. Прочитайте AGENTS.md (точка входа)"
    Write-Info "  2. Проверьте ТЕКУЩАЯ_ЗАДАЧА.md"
    Write-Info "  3. Начните работу"
    Write-Host ""
}

# Возврат данных для ИИ
return @{
    HasPreviousSession = $HasResumeMarker
    HasSessionHandover = $HasSessionHandover
    GitBranch = $GitBranch
    UncommittedChanges = $UncommittedChanges
    CurrentTaskPath = $CurrentTaskPath
}
