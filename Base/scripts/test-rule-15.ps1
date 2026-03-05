# test-rule-15.ps1 — Тестирование Правила 15 (BASE INDEX AUTO-UPDATE)
# Версия: 1.0
# Дата: 5 марта 2026 г.
# Назначение: Проверка DoD после обновления BASE_INDEX

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         ПРОВЕРКА DoD — ПРАВИЛО 15                        ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Переход в корень Base (на уровень выше scripts)
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$BaseIndex = Join-Path $BasePath "000-BASE_INDEX.md"
$RulesPath = Join-Path $BasePath ".qwen\rules"

# Счётчики
$passedTests = 0
$failedTests = 0
$totalTests = 7

# ============================================
# 1. BASE_INDEX существует?
# ============================================

Write-Host "[1/7] BASE_INDEX существует?..." -ForegroundColor Cyan

if (Test-Path $BaseIndex) {
    Write-Host "  ✅ ДА" -ForegroundColor Green
    $passedTests++
} else {
    Write-Host "  ❌ НЕТ" -ForegroundColor Red
    $failedTests++
}

# ============================================
# 2. Все ссылки работают?
# ============================================

Write-Host "`n[2/7] Проверка ссылок на правила..." -ForegroundColor Cyan

$rules = @(
    "00-auto-context.md",
    "01-core.md",
    "02-workflow.md",
    "03-git.md",
    "04-safety.md",
    "05-commands.md",
    "06-resume.md",
    "07-session-persistence.md",
    "08-mass-operations.md",
    "08-mcp-saver.md",
    "09-logic-and-analysis.md",
    "10-think-before-action.md",
    "11-knowledge-sufficiency.md",
    "12-software-best-practices.md",
    "13-user-alignment.md",
    "14-context-management.md",
    "15-base-index-auto-update.md",
    "16-go-command.md"
)

$brokenLinks = 0
foreach ($rule in $rules) {
    $path = Join-Path $RulesPath $rule
    if (Test-Path $path) {
        if ($Verbose) {
            Write-Host "  ✅ $rule" -ForegroundColor Green
        }
    } else {
        Write-Host "  ❌ $rule (НЕ НАЙДЕН)" -ForegroundColor Red
        $brokenLinks++
    }
}

Write-Host "`n  Итого битых ссылок: $brokenLinks" -ForegroundColor $(if ($brokenLinks -eq 0) { "Green" } else { "Red" })

if ($brokenLinks -eq 0) {
    $passedTests++
} else {
    $failedTests++
}

# ============================================
# 3. Количество правил верно?
# ============================================

Write-Host "`n[3/7] Подсчёт правил..." -ForegroundColor Cyan

$actualCount = (Get-ChildItem $RulesPath -Filter "*.md" | Where-Object { $_.Name -notmatch "^99-|^test-|^all_" }).Count
Write-Host "  Фактически: $actualCount правил" -ForegroundColor Gray
Write-Host "  В BASE_INDEX: 18 правил" -ForegroundColor Gray

if ($actualCount -eq 18) {
    Write-Host "  ✅ Сходится" -ForegroundColor Green
    $passedTests++
} else {
    Write-Host "  ⚠️ НЕ сходится" -ForegroundColor Yellow
    $failedTests++
}

# ============================================
# 4. Структура обновлена?
# ============================================

Write-Host "`n[4/7] Проверка структуры..." -ForegroundColor Cyan

$content = Get-Content $BaseIndex -Raw
if ($content -match "16-go-command\.md") {
    Write-Host "  ✅ Правило 16 в структуре" -ForegroundColor Green
    $passedTests++
} else {
    Write-Host "  ❌ Правило 16 НЕ найдено" -ForegroundColor Red
    $failedTests++
}

# ============================================
# 5. История обновлена?
# ============================================

Write-Host "`n[5/7] Проверка истории изменений..." -ForegroundColor Cyan

if ($content -match "2026-03-05.*1\.5.*Правило 16") {
    Write-Host "  ✅ История обновлена (v1.5)" -ForegroundColor Green
    $passedTests++
} else {
    Write-Host "  ❌ История НЕ обновлена" -ForegroundColor Yellow
    $failedTests++
}

# ============================================
# 6. Версия обновлена?
# ============================================

Write-Host "`n[6/7] Проверка версии..." -ForegroundColor Cyan

if ($content -match "\*\*Версия:\*\*\s*1\.5") {
    Write-Host "  ✅ Версия 1.5" -ForegroundColor Green
    $passedTests++
} else {
    Write-Host "  ⚠️ Версия НЕ найдена или неверная" -ForegroundColor Yellow
    $failedTests++
}

# ============================================
# 7. Бэкап создан (Git)?
# ============================================

Write-Host "`n[7/7] Проверка Git статуса..." -ForegroundColor Cyan

$gitStatus = git status --porcelain 2>$null
if ($gitStatus -and $gitStatus.Trim().Length -gt 0) {
    Write-Host "  ⚠️ Есть незакоммиченные изменения" -ForegroundColor Yellow
    $gitStatus | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
    $failedTests++
} else {
    Write-Host "  ✅ Все изменения закоммичены" -ForegroundColor Green
    $passedTests++
}

# ============================================
# ИТОГ
# ============================================

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         ПРОВЕРКА DoD ЗАВЕРШЕНА                           ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n📊 РЕЗУЛЬТАТЫ:" -ForegroundColor Cyan
Write-Host "  Пройдено тестов: $passedTests из $totalTests" -ForegroundColor $(if ($passedTests -eq $totalTests) { "Green" } else { "Yellow" })
Write-Host "  Провалено тестов: $failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })

if ($passedTests -eq $totalTests) {
    Write-Host "`n✅ ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ! Правило 15 соблюдено." -ForegroundColor Green
} else {
    Write-Host "`n⚠️ НЕ ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ. Требуется исправление." -ForegroundColor Yellow
}
