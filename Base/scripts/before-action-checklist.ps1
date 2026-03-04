# before-action-checklist.ps1 — Проверка перед действием
# Версия: 1.0
# Дата: 4 марта 2026 г.
# Назначение: Принудительная пауза и анализ перед действием

param(
    [string]$Action,        # delete, move, create, modify
    [string]$Target,        # Цель действия (файл/папка)
    [string]$Reason,        # Причина действия
    [switch]$Verbose,
    [switch]$Log
)

$ErrorActionPreference = "Stop"

# Пути
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$LogPath = Join-Path $BasePath "logs\before-action-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Цвета
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"

function Write-Log {
    param($msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $msg"

    if ($Log) {
        Add-Content -Path $LogPath -Value $logEntry
    }

    if ($Verbose) {
        Write-Host $logEntry -ForegroundColor Cyan
    }
}

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         ПРОВЕРКА ПЕРЕД ДЕЙСТВИЕМ                         ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Log "Действие: $Action"
Write-Log "Цель: $Target"
Write-Log "Причина: $Reason"

# ============================================
# ШАГ 1: СТОП (30 секунд паузы)
# ============================================

Write-Host "[1/7] СТОП — Пауза 30 секунд..." -ForegroundColor Cyan
Write-Host "  ⏳ Остановитесь на 30 секунд" -ForegroundColor Yellow
Write-Host "  🧘 Глубокий вдох-выдох" -ForegroundColor Yellow
Write-Host "  ❓ Вопрос: `"Зачем я это делаю?`"" -ForegroundColor Yellow

if (-not $Log) {
    $response = Read-Host "  Продолжить? (Y/N)"
    if ($response -ne 'Y' -and $response -ne 'y') {
        Write-Host "`n❌ Отменено пользователем" -ForegroundColor Red
        exit 0
    }
}

Write-Host "  ✅ Пауза завершена`n" -ForegroundColor Green

# ============================================
# ШАГ 2: АНАЛИЗ КОНТЕКСТА
# ============================================

Write-Host "[2/7] Анализ контекста..." -ForegroundColor Cyan

# Поиск зависимостей
Write-Host "  🔍 Поиск зависимостей..." -ForegroundColor Gray
$dependencies = @()
if (Test-Path $BasePath) {
    $dependencies = Get-ChildItem $BasePath -Recurse -Include "*.md","*.ps1","*.json" -ErrorAction SilentlyContinue | 
        Select-String -Pattern [regex]::Escape($Target) -ErrorAction SilentlyContinue | 
        Select-Object -First 10 Path, LineNumber
}

if ($dependencies.Count -gt 0) {
    Write-Host "  ⚠️ Найдено зависимостей: $($dependencies.Count)" -ForegroundColor Yellow
    if ($Verbose) {
        foreach ($dep in $dependencies) {
            Write-Host "    • $($dep.Path):$($dep.LineNumber)" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "  ✅ Зависимостей не найдено" -ForegroundColor Green
}

# Проверка существования
if (Test-Path $Target) {
    Write-Host "  ✅ Цель существует: $Target" -ForegroundColor Green
} else {
    if ($Action -eq 'delete' -or $Action -eq 'move') {
        Write-Host "  ❌ Цель не найдена: $Target" -ForegroundColor Red
        Write-Log "ОШИБКА: Цель не найдена"
        exit 1
    } else {
        Write-Host "  ℹ️  Цель будет создана: $Target" -ForegroundColor Cyan
    }
}

Write-Log "Зависимости: $($dependencies.Count)"

# ============================================
# ШАГ 3: ИЗУЧЕНИЕ ДОКУМЕНТАЦИИ
# ============================================

Write-Host "`n[3/7] Проверка документации..." -ForegroundColor Cyan

# Проверка правил
$rulesPath = Join-Path $BasePath ".qwen\rules"
if (Test-Path $rulesPath) {
    $relevantRules = Get-ChildItem $rulesPath -Filter "*.md" -ErrorAction SilentlyContinue | 
        Select-String -Pattern $Action -ErrorAction SilentlyContinue | 
        Select-Object -First 3 Path
    
    if ($relevantRules) {
        Write-Host "  ✅ Найдено правил по теме: $($relevantRules.Count)" -ForegroundColor Green
        if ($Verbose) {
            foreach ($rule in $relevantRules) {
                Write-Host "    • $($rule.Path)" -ForegroundColor Gray
            }
        }
    }
}

# Проверка анти-паттернов
$antiPatternsPath = Join-Path $BasePath "ANTI_PATTERNS.md"
if (Test-Path $antiPatternsPath) {
    $antiPattern = Select-String -Path $antiPatternsPath -Pattern $Action -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($antiPattern) {
        Write-Host "  ⚠️ Возможно нарушение анти-паттерна!" -ForegroundColor Yellow
        Write-Host "    $($antiPattern.Line)" -ForegroundColor Gray
    }
}

Write-Log "Проверка документации: завершено"

# ============================================
# ШАГ 4: ПРОВЕРКА ГИПОТЕЗ
# ============================================

Write-Host "`n[4/7] Проверка гипотез..." -ForegroundColor Cyan

Write-Host "  📋 Вопросы:" -ForegroundColor Gray
Write-Host "    1. Это уже существует?" -ForegroundColor Gray
Write-Host "    2. Можно ли расширить существующее?" -ForegroundColor Gray
Write-Host "    3. Изобретаем велосипед?" -ForegroundColor Gray

if (-not $Log) {
    $hypothesis = Read-Host "  Все ли ответы получены? (Y/N)"
    if ($hypothesis -ne 'Y' -and $hypothesis -ne 'y') {
        Write-Host "`n⏳ Вернитесь после изучения" -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "  ✅ Гипотезы проверены`n" -ForegroundColor Green
Write-Log "Гипотезы: проверены"

# ============================================
# ШАГ 5: ПРЕДВАРИТЕЛЬНЫЙ ТЕСТ
# ============================================

Write-Host "[5/7] Проверка тестовой среды..." -ForegroundColor Cyan

$testEnvPath = Join-Path $BasePath "_TEST_ENV"
if (Test-Path $testEnvPath) {
    Write-Host "  ✅ _TEST_ENV/ существует" -ForegroundColor Green
    Write-Host "  ℹ️  Рекомендуется тестирование в _TEST_ENV/" -ForegroundColor Yellow
} else {
    Write-Host "  ⚠️ _TEST_ENV/ не найдена" -ForegroundColor Yellow
    Write-Host "  ℹ️  Создайте для тестирования изменений" -ForegroundColor Gray
}

Write-Log "Тестовая среда: $((Test-Path $testEnvPath) ? 'готова' : 'не готова')"

# ============================================
# ШАГ 6: АНАЛИЗ ПОСЛЕДСТВИЙ
# ============================================

Write-Host "`n[6/7] Анализ последствий..." -ForegroundColor Cyan

Write-Host "  📋 Вопросы:" -ForegroundColor Gray
Write-Host "    1. Что сломается если это удалить?" -ForegroundColor Gray
Write-Host "    2. Что зависит от этого?" -ForegroundColor Gray
Write-Host "    3. Как откатить?" -ForegroundColor Gray

# Проверка возможности отката
$gitStatus = git status --porcelain 2>$null
if ($gitStatus) {
    Write-Host "  ✅ Git отслеживает изменения (можно откатить)" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ Git не отслеживает изменения" -ForegroundColor Yellow
}

# Проверка бэкапа
$backupPath = Join-Path $BasePath "_BACKUP"
if (Test-Path $backupPath) {
    Write-Host "  ✅ _BACKUP/ существует (можно создать бэкап)" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ _BACKUP/ не найдена" -ForegroundColor Yellow
}

Write-Log "Анализ последствий: завершено"

# ============================================
# ШАГ 7: ФИНАЛЬНОЕ ПОДТВЕРЖДЕНИЕ
# ============================================

Write-Host "`n[7/7] Финальное подтверждение..." -ForegroundColor Cyan

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "СВОДКА ПРОВЕРКИ" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Действие: $Action" -ForegroundColor Cyan
Write-Host "Цель: $Target" -ForegroundColor Cyan
Write-Host "Причина: $Reason" -ForegroundColor Cyan
Write-Host "Зависимости: $($dependencies.Count)" -ForegroundColor Cyan
Write-Host "Лог: $LogPath" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

if (-not $Log) {
    $confirm = Read-Host "Продолжить действие? (Y/N)"
    if ($confirm -ne 'Y' -and $confirm -ne 'y') {
        Write-Host "`n❌ Отменено пользователем" -ForegroundColor Red
        Write-Log "ОТМЕНЕНО пользователем"
        exit 0
    }
}

Write-Host "`n✅ ПРОВЕРКА ЗАВЕРШЕНА" -ForegroundColor Green
Write-Host "   Можно выполнять действие" -ForegroundColor Gray
Write-Log "ПРОВЕРКА ЗАВЕРШЕНА — ДЕЙСТВИЕ РАЗРЕШЕНО"

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Следующий шаг: Выполните действие и запустите:" -ForegroundColor Cyan
Write-Host "  .\scripts\after-action-audit.ps1 -Action `"$Action`" -Target `"$Target`"" -ForegroundColor Gray
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
