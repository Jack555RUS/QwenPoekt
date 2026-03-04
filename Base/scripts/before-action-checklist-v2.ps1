# before-action-checklist-v2.ps1 — Проверка перед действием (Версия 2)
# Версия: 2.0
# Дата: 4 марта 2026 г.
# Назначение: Улучшенная проверка с 3 уровнями, оценкой риска, журналом ошибок

param(
    [string]$Action,                    # delete, move, create, modify
    [string]$Target,                    # Цель действия (файл/папка)
    [string]$Reason,                    # Причина действия
    [ValidateSet('Fast', 'Medium', 'Full')]
    [string]$Level = 'Medium',          # Уровень проверки
    [switch]$Verbose,
    [switch]$Log,
    [switch]$Force                      # Пропустить подтверждения (для тестов)
)

$ErrorActionPreference = "Stop"

# Пути
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$LogsPath = Join-Path $BasePath "logs"
$ReportsPath = Join-Path $BasePath "reports"
$LogPath = Join-Path $LogsPath "before-action-v2-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$PreventedErrorsPath = Join-Path $ReportsPath "PREVENTED_ERRORS.md"

# Инициализация логов
if (-not (Test-Path $LogsPath)) { New-Item -ItemType Directory -Path $LogsPath -Force | Out-Null }
if (-not (Test-Path $ReportsPath)) { New-Item -ItemType Directory -Path $ReportsPath -Force | Out-Null }

# Цвета
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"
$Gray = "Gray"

function Write-Log {
    param($msg, $color = "Cyan")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $msg"
    
    if ($Log) {
        Add-Content -Path $LogPath -Value $logEntry
    }
    
    if ($Verbose) {
        Write-Host $logEntry -ForegroundColor $color
    }
}

function Get-RiskScore {
    param($Action, $Target, $BasePath)
    
    $score = 0
    $factors = @()
    
    # Фактор 1: Количество зависимостей (0-10 баллов)
    $dependencies = 0
    if (Test-Path $BasePath) {
        $dependencies = (Get-ChildItem $BasePath -Recurse -Include "*.md","*.ps1","*.json" -ErrorAction SilentlyContinue | 
            Select-String -Pattern [regex]::Escape($Target) -ErrorAction SilentlyContinue | 
            Select-Object -First 20).Count
    }
    $depScore = [Math]::Min($dependencies * 2, 10)
    $score += $depScore
    if ($depScore -gt 0) { $factors += "Зависимости: $depScore (найдено: $dependencies)" }
    
    # Фактор 2: Критичность файла (0-9 баллов)
    $criticalScore = 0
    if ($Target -like "*.md" -and $Target -like "*rule*") { $criticalScore = 9; $factors += "Критичность: $criticalScore (правило)" }
    elseif ($Target -like "*.ps1") { $criticalScore = 6; $factors += "Критичность: $criticalScore (скрипт)" }
    elseif ($Target -like "*.json") { $criticalScore = 3; $factors += "Критичность: $criticalScore (конфиг)" }
    else { $criticalScore = 2; $factors += "Критичность: $criticalScore (документ)" }
    $score += $criticalScore
    
    # Фактор 3: Тип действия (0-6 баллов)
    $actionScore = switch ($Action.ToLower()) {
        "delete" { 6 }
        "move" { 4 }
        "modify" { 3 }
        "create" { 1 }
        default { 2 }
    }
    $score += $actionScore
    $factors += "Действие: $actionScore ($Action)"
    
    # Итого (макс 25)
    $maxScore = 25
    $normalizedScore = [Math]::Min($score, $maxScore)
    
    # Уровень риска
    $riskLevel = if ($normalizedScore -ge 15) { "High" }
                 elseif ($normalizedScore -ge 5) { "Medium" }
                 else { "Low" }
    
    return @{
        Score = $normalizedScore
        MaxScore = $maxScore
        Level = $riskLevel
        Factors = $factors
        Dependencies = $dependencies
    }
}

function Get-DependencyGraph {
    param($Path, $BasePath)
    
    $dependencies = @()
    if (Test-Path $BasePath) {
        $files = Get-ChildItem $BasePath -Recurse -Include "*.md","*.ps1","*.json" -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
            if ($content -match [regex]::Escape($Path)) {
                $dependencies += @{
                    Path = $file.FullName
                    Line = ($content -split "`n" | Select-String -Pattern [regex]::Escape($Path) | Select-Object -First 1).LineNumber
                }
            }
        }
    }
    
    return @{
        Files = $dependencies
        Count = $dependencies.Count
        Risk = if ($dependencies.Count -gt 10) { "High" } elseif ($dependencies.Count -gt 5) { "Medium" } else { "Low" }
    }
}

function Write-PreventedError {
    param($Action, $Target, $Risk, $Dependencies)
    
    $date = Get-Date -Format "yyyy-MM-dd"
    $time = Get-Date -Format "HH:mm:ss"
    
    $entry = @"

### $date $time — $Action

**Цель:** $Target
**Риск:** $($Risk.Level) ($($Risk.Score)/$($Risk.MaxScore))
**Зависимостей найдено:** $($Dependencies.Count)
**Предотвращено:** $((if ($Dependencies.Count -gt 0) { "Поломка $($Dependencies.Count) ссылок/файлов" } else { "Потенциальная ошибка" }))
**Решение:** $((if ($Dependencies.Count -gt 0) { "Обновить зависимости перед $Action" } else { "Продолжить с осторожностью" }))

"@
    
    if (-not (Test-Path $PreventedErrorsPath)) {
        $header = @"
# 🛡️ ЖУРНАЛ ПРЕДОТВРАЩЁННЫХ ОШИБОК

**Дата начала:** 4 марта 2026 г.  
**Статус:** ✅ Активно  
**Скрипт:** before-action-checklist-v2.ps1

---

## 📊 СТАТИСТИКА

| Показатель | Значение |
|------------|----------|
| **Всего записей** | 0 |
| **Предотвращено ошибок** | 0 |
| **Высокий риск** | 0 |
| **Средний риск** | 0 |
| **Низкий риск** | 0 |

---

## 📋 ЗАПИСИ

"@
        Set-Content -Path $PreventedErrorsPath -Value $header -Encoding UTF8
    }
    
    Add-Content -Path $PreventedErrorsPath -Value $entry -Encoding UTF8
}

# ============================================
# НАЧАЛО ПРОВЕРКИ
# ============================================

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         ПРОВЕРКА ПЕРЕД ДЕЙСТВИЕМ (v2)                    ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Log "Действие: $Action"
Write-Log "Цель: $Target"
Write-Log "Причина: $Reason"
Write-Log "Уровень: $Level"

# ============================================
# ШАГ 1: СТОП (пауза по уровню)
# ============================================

$pauseSeconds = switch ($Level) {
    'Fast' { 5 }
    'Medium' { 15 }
    'Full' { 30 }
}

Write-Host "[1/7] СТОП — Пауза $pauseSeconds секунд..." -ForegroundColor Cyan
Write-Host "  ⏳ Остановитесь на $pauseSeconds секунд" -ForegroundColor Yellow
Write-Host "  🧘 Глубокий вдох-выдох" -ForegroundColor Yellow
Write-Host "  ❓ Вопрос: `"Зачем я это делаю?`"" -ForegroundColor Yellow

if (-not $Force) {
    if ($Level -eq 'Full') {
        Start-Sleep -Seconds $pauseSeconds
    } else {
        $response = Read-Host "  Продолжить? (Y/N)"
        if ($response -ne 'Y' -and $response -ne 'y') {
            Write-Host "`n❌ Отменено пользователем" -ForegroundColor Red
            Write-Log "ОТМЕНЕНО пользователем" $Red
            exit 0
        }
    }
}

Write-Host "  ✅ Пауза завершена`n" -ForegroundColor Green

# ============================================
# ШАГ 2: АНАЛИЗ КОНТЕКСТА + ОЦЕНКА РИСКА
# ============================================

Write-Host "[2/7] Анализ контекста + оценка риска..." -ForegroundColor Cyan

$risk = Get-RiskScore -Action $Action -Target $Target -BasePath $BasePath

Write-Host "  📊 Оценка риска: $($risk.Score)/$($risk.MaxScore) ($($risk.Level))" -ForegroundColor $(
    if ($risk.Level -eq 'High') { $Red }
    elseif ($risk.Level -eq 'Medium') { $Yellow }
    else { $Green }
)

if ($Verbose) {
    foreach ($factor in $risk.Factors) {
        Write-Host "    • $factor" -ForegroundColor Gray
    }
}

# Поиск зависимостей
$depGraph = Get-DependencyGraph -Path $Target -BasePath $BasePath
Write-Host "  🔗 Зависимостей найдено: $($depGraph.Count)" -ForegroundColor $(
    if ($depGraph.Count -gt 10) { $Red }
    elseif ($depGraph.Count -gt 5) { $Yellow }
    else { $Green }
)

if ($Verbose -and $depGraph.Count -gt 0) {
    Write-Host "  Файлы:" -ForegroundColor Gray
    foreach ($dep in $depGraph.Files | Select-Object -First 5) {
        Write-Host "    • $($dep.Path)" -ForegroundColor Gray
    }
    if ($depGraph.Count -gt 5) {
        Write-Host "    ... и ещё $($depGraph.Count - 5)" -ForegroundColor Gray
    }
}

Write-Log "Риск: $($risk.Score)/$($risk.MaxScore) ($($risk.Level))"
Write-Log "Зависимости: $($depGraph.Count)"

# ============================================
# ШАГ 3: ИЗУЧЕНИЕ ДОКУМЕНТАЦИИ
# ============================================

if ($Level -ne 'Fast') {
    Write-Host "`n[3/7] Проверка документации..." -ForegroundColor Cyan
    
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
    
    $antiPatternsPath = Join-Path $BasePath "ANTI_PATTERNS.md"
    if (Test-Path $antiPatternsPath) {
        $antiPattern = Select-String -Path $antiPatternsPath -Pattern $Action -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($antiPattern) {
            Write-Host "  ⚠️ Возможно нарушение анти-паттерна!" -ForegroundColor Yellow
            Write-Host "    $($antiPattern.Line)" -ForegroundColor Gray
            Write-Log "АНТИ-ПАТТЕРН: $($antiPattern.Line)" $Yellow
        }
    }
    
    Write-Log "Проверка документации: завершено"
} else {
    Write-Host "`n[3/7] Пропущено (Fast уровень)`n" -ForegroundColor Gray
}

# ============================================
# ШАГ 4: ПРОВЕРКА ГИПОТЕЗ
# ============================================

if ($Level -eq 'Full') {
    Write-Host "`n[4/7] Проверка гипотез..." -ForegroundColor Cyan
    
    Write-Host "  📋 Вопросы:" -ForegroundColor Gray
    Write-Host "    1. Это уже существует?" -ForegroundColor Gray
    Write-Host "    2. Можно ли расширить существующее?" -ForegroundColor Gray
    Write-Host "    3. Изобретаем велосипед?" -ForegroundColor Gray
    
    if (-not $Force) {
        $hypothesis = Read-Host "  Все ли ответы получены? (Y/N)"
        if ($hypothesis -ne 'Y' -and $hypothesis -ne 'y') {
            Write-Host "`n⏳ Вернитесь после изучения" -ForegroundColor Yellow
            Write-Log "ГИПОТЕЗЫ: Не подтверждены" $Yellow
            exit 0
        }
    }
    
    Write-Host "  ✅ Гипотезы проверены`n" -ForegroundColor Green
    Write-Log "Гипотезы: подтверждены"
} else {
    Write-Host "`n[4/7] Пропущено ($Level уровень)`n" -ForegroundColor Gray
}

# ============================================
# ШАГ 5: ПРЕДВАРИТЕЛЬНЫЙ ТЕСТ
# ============================================

if ($Level -ne 'Fast') {
    Write-Host "[5/7] Проверка тестовой среды..." -ForegroundColor Cyan
    
    $testEnvPath = Join-Path $BasePath "_TEST_ENV"
    if (Test-Path $testEnvPath) {
        Write-Host "  ✅ _TEST_ENV/ существует" -ForegroundColor Green
        if ($Level -eq 'Full' -and -not $Force) {
            $testConfirm = Read-Host "  Протестировать в _TEST_ENV/? (Y/N)"
            if ($testConfirm -eq 'Y' -or $testConfirm -eq 'y') {
                Write-Host "  ℹ️  Скопируйте в _TEST_ENV/ и запустите тесты" -ForegroundColor Yellow
            }
        }
    } else {
        Write-Host "  ⚠️ _TEST_ENV/ не найдена" -ForegroundColor Yellow
        Write-Host "  ℹ️  Рекомендуется создать для тестирования" -ForegroundColor Gray
    }
    
    Write-Log "Тестовая среда: $((Test-Path $testEnvPath) ? 'готова' : 'не готова')"
} else {
    Write-Host "[5/7] Пропущено (Fast уровень)`n" -ForegroundColor Gray
}

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

# Запись в журнал предотвращённых ошибок
Write-PreventedError -Action $Action -Target $Target -Risk $risk -Dependencies $depGraph.Files
Write-Log "Журнал ошибок: обновлён"

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
Write-Host "Уровень: $Level" -ForegroundColor Cyan
Write-Host "Риск: $($risk.Score)/$($risk.MaxScore) ($($risk.Level))" -ForegroundColor $(
    if ($risk.Level -eq 'High') { $Red }
    elseif ($risk.Level -eq 'Medium') { $Yellow }
    else { $Green }
)
Write-Host "Зависимости: $($depGraph.Count)" -ForegroundColor Cyan
Write-Host "Лог: $LogPath" -ForegroundColor Cyan

# Блокировка для высокого риска (только Full уровень)
if ($Level -eq 'Full' -and $risk.Level -eq 'High' -and -not $Force) {
    Write-Host "`n🔴 ВЫСОКИЙ РИСК — требуется подтверждение!" -ForegroundColor Red
    Write-Host "   Рекомендуется:" -ForegroundColor Yellow
    Write-Host "   1. Обновить зависимости" -ForegroundColor Yellow
    Write-Host "   2. Протестировать в _TEST_ENV/" -ForegroundColor Yellow
    Write-Host "   3. Создать backup" -ForegroundColor Yellow
    
    $highRiskConfirm = Read-Host "   Продолжить несмотря на риск? (Y/N)"
    if ($highRiskConfirm -ne 'Y' -and $highRiskConfirm -ne 'y') {
        Write-Host "`n❌ Отменено из-за высокого риска" -ForegroundColor Red
        Write-Log "ОТМЕНЕНО: Высокий риск" $Red
        exit 0
    }
}

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

if (-not $Force) {
    $confirm = Read-Host "`nПродолжить действие? (Y/N)"
    if ($confirm -ne 'Y' -and $confirm -ne 'y') {
        Write-Host "`n❌ Отменено пользователем" -ForegroundColor Red
        Write-Log "ОТМЕНЕНО пользователем" $Red
        exit 0
    }
}

Write-Host "`n✅ ПРОВЕРКА ЗАВЕРШЕНА" -ForegroundColor Green
Write-Host "   Можно выполнять действие" -ForegroundColor Gray
Write-Log "ПРОВЕРКА ЗАВЕРШЕНА — ДЕЙСТВИЕ РАЗРЕШЕНО" $Green

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Следующий шаг: Выполните действие и запустите:" -ForegroundColor Cyan
Write-Host "  .\scripts\after-action-audit.ps1 -Action `"$Action`" -Target `"$Target`"" -ForegroundColor Gray
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
