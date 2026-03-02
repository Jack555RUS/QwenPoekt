# ============================================================================
# CHECK RULE PROFILES
# ============================================================================
# Назначение: Проверка профилей правил на соответствие стандартам
# Использование: .\scripts\check-rule-profiles.ps1 [-Rule "путь"] [-Verbose]
# ============================================================================

param(
    [string]$RulesPath = "D:\QwenPoekt\Base\KNOWLEDGE_BASE",
    
    [string]$Rule = "",  # Если указано — проверить одно правило
    
    [string]$ReportPath = "D:\QwenPoekt\Base\reports\rule_profiles_report.md",
    
    [string]$TemplatePath = "D:\QwenPoekt\Base\_templates\PROFILE_TEMPLATE.md",
    
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"

# ============================================================================
# ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
# ============================================================================

$CheckDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$Stats = @{
    TotalRules = 0
    FullProfile = 0
    PartialProfile = 0
    NoProfile = 0
    AvgScore = 0
}

$Rules = @()

# ============================================================================
# ФУНКЦИИ
# ============================================================================

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Write-Error-Log {
    param([string]$Message)
    Write-Log "❌ $Message" -Color "Red"
}

function Write-Success-Log {
    param([string]$Message)
    Write-Log "✅ $Message" -Color "Green"
}

function Write-Warning-Log {
    param([string]$Message)
    Write-Log "⚠️  $Message" -Color "Yellow"
}

function Test-Path-Safe {
    param([string]$Path)
    try {
        return Test-Path $Path
    } catch {
        return $false
    }
}

function Get-Rule-Profile-Score {
    param([string]$FilePath)
    
    $score = @{
        Total = 0
        Metadata = 0
        Structure = 0
        Content = 0
        Links = 0
        Tests = 0
    }
    
    try {
        $content = Get-Content $FilePath -Raw
        
        # Проверка мета-полей (25 баллов) — ПОВЫШЕН ВЕС
        if ($content -match '(version|Версия):\s*[\d\.]+') { $score.Metadata += 5 }
        if ($content -match '(created|Дата создания):\s*\d{4}-\d{2}-\d{2}') { $score.Metadata += 5 }
        if ($content -match '(last_reviewed|Последняя проверка):\s*\d{4}-\d{2}-\d{2}') { $score.Metadata += 5 }
        if ($content -match '(author|Автор):') { $score.Metadata += 5 }
        if ($content -match '(status|Статус):\s*') { $score.Metadata += 5 }
        
        # Проверка структуры (20 баллов)
        if ($content -match '#\s+') { $score.Structure += 5 }
        if ($content -match '##\s+') { $score.Structure += 5 }
        if ($content -match '## 🔗 СВЯЗАННЫЕ ФАЙЛЫ') { $score.Structure += 5 }
        if ($content.Length -gt 100 -and $content -match '(## 📋 ОГЛАВЛЕНИЕ|## Содержание)') { $score.Structure += 5 }
        
        # Проверка содержания (25 баллов) — ПОВЫШЕН ВЕС
        if ($content -match '## 🎯 НАЗНАЧЕНИЕ') { $score.Content += 5 }
        if ($content -match '```') { $score.Content += 5 }  # Есть примеры кода
        if ($content -match '\*\*Пример\*\*|### Пример') { $score.Content += 5 }
        if ($content.Length -gt 50) { $score.Content += 5 }
        if ($content -match '## 📋|## 🔧|## 📖') { $score.Content += 5 }  # Есть разделы
        
        # Проверка связей (15 баллов) — СНИЖЕН ВЕС
        if ($content -match '\[`[^\]]+`\]\([^\)]+\)') {
            $linksCount = ([regex]::Matches($content, '\[`[^\]]+`\]\([^\)]+\)')).Count
            if ($linksCount -ge 5) { $score.Links += 15 }
            elseif ($linksCount -ge 3) { $score.Links += 10 }
            elseif ($linksCount -ge 1) { $score.Links += 5 }
        }
        
        # Проверка тестов (15 баллов) — СНИЖЕН ВЕС
        if ($content -match 'RULE_TEST_CASES') { $score.Tests += 10 }
        if ($content -match 'Тест|test|Test') { $score.Tests += 5 }
        
        $score.Total = $score.Metadata + $score.Structure + $score.Content + $score.Links + $score.Tests
        
        return $score
    } catch {
        return $score
    }
}

function Generate-Report {
    param(
        [array]$Rules,
        [hashtable]$Stats,
        [string]$ReportPath
    )
    
    $report = @"
# 📊 ОТЧЁТ ПРОВЕРКИ ПРОФИЛЕЙ ПРАВИЛ

**Дата проверки:** $CheckDate

---

## 📊 СТАТИСТИКА

| Метрика | Значение |
|---------|----------|
| **Всего правил** | $($Stats.TotalRules) |
| **Полный профиль** | $($Stats.FullProfile) |
| **Частичный профиль** | $($Stats.PartialProfile) |
| **Нет профиля** | $($Stats.NoProfile) |
| **Средняя оценка** | $($Stats.AvgScore)% |

---

## 📋 ПРАВИЛА

"@
    
    foreach ($rule in $Rules) {
        $report += @"
### $($rule.Name)

**Путь:** ``````$($rule.Path)``````

**Оценка:** $($rule.Score.Total)/100 ($($rule.Percent)%)

**Матрица профилей:**

| Профиль | Соответствие | Статус |
|---------|--------------|--------|
| **Мета-поля** | $($rule.Score.Metadata)/20 | $(if ($rule.Score.Metadata -ge 15) { '✅' } elseif ($rule.Score.Metadata -ge 10) { '⚠️' } else { '❌' }) |
| **Структура** | $($rule.Score.Structure)/20 | $(if ($rule.Score.Structure -ge 15) { '✅' } elseif ($rule.Score.Structure -ge 10) { '⚠️' } else { '❌' }) |
| **Содержание** | $($rule.Score.Content)/20 | $(if ($rule.Score.Content -ge 15) { '✅' } elseif ($rule.Score.Content -ge 10) { '⚠️' } else { '❌' }) |
| **Связи** | $($rule.Score.Links)/20 | $(if ($rule.Score.Links -ge 15) { '✅' } elseif ($rule.Score.Links -ge 10) { '⚠️' } else { '❌' }) |
| **Тесты** | $($rule.Score.Tests)/20 | $(if ($rule.Score.Tests -ge 15) { '✅' } elseif ($rule.Score.Tests -ge 10) { '⚠️' } else { '❌' }) |

**Статус:** $(if ($rule.Percent -ge 90) { '✅ Отлично' } elseif ($rule.Percent -ge 75) { '⚠️ Хорошо' } else { '❌ Требует улучшений' })

---
"@
    }
    
    $report += @"

## 🎯 РЕКОМЕНДАЦИИ

### Приоритет 1 (Критично):

"@
    
    $criticalRules = $Rules | Where-Object { $_.Percent -lt 75 }
    if ($criticalRules.Count -gt 0) {
        foreach ($rule in $criticalRules) {
            $report += "1. ⚠️ **$($rule.Name)** — $($rule.Path)`n"
        }
    } else {
        $report += "``````text`nКритичных проблем не найдено`n``````"
    }
    
    $report += @"

### Приоритет 2 (Важно):

"@
    
    $warningRules = $Rules | Where-Object { $_.Percent -ge 75 -and $_.Percent -lt 90 }
    if ($warningRules.Count -gt 0) {
        foreach ($rule in $warningRules) {
            $report += "1. ⚠️ **$($rule.Name)** — $($rule.Path)`n"
        }
    } else {
        $report += "``````text`nПредупреждений не найдено`n``````"
    }
    
    $report += @"

---

**Проверка завершена:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** check-rule-profiles.ps1
"@
    
    $report | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Success-Log "Отчёт сохранён: $ReportPath"
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ПРОВЕРКА ПРОФИЛЕЙ ПРАВИЛ ===" -Color "Yellow"
    Write-Log "Путь: $RulesPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Поиск правил
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Поиск правил..."
    
    if ($Rule -ne "") {
        # Проверить одно правило
        $ruleFiles = Get-ChildItem -Path $RulesPath -Recurse -Filter $Rule -ErrorAction SilentlyContinue
    } else {
        # Проверить все правила
        $ruleFiles = Get-ChildItem -Path $RulesPath -Recurse -Filter "*.md" -ErrorAction SilentlyContinue |
                     Where-Object { $_.FullName -match "00_CORE|05_METHODOLOGY" }
    }
    
    $Stats.TotalRules = $ruleFiles.Count
    
    Write-Log "  Найдено правил: $($Stats.TotalRules)"
    
    if ($Stats.TotalRules -eq 0) {
        Write-Warning-Log "Правила не найдены!"
        exit 0
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Проверка каждого правила
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Проверка профилей..."
    
    foreach ($file in $ruleFiles) {
        $score = Get-Rule-Profile-Score -FilePath $file.FullName
        $percent = [math]::Round(($score.Total / 100) * 100, 1)
        
        $Rules += @{
            Path = $file.FullName
            Name = $file.Name
            Score = $score
            Percent = $percent
        }
        
        if ($Verbose) {
            $color = switch ($percent) {
                {$_ -ge 90} { "Green" }
                {$_ -ge 75} { "Yellow" }
                default { "Red" }
            }
            Write-Log "  $($file.Name): $percent%" -Color $color
        }
        
        # Подсчёт статистики
        if ($percent -ge 90) {
            $Stats.FullProfile++
        } elseif ($percent -ge 75) {
            $Stats.PartialProfile++
        } else {
            $Stats.NoProfile++
        }
        
        $Stats.AvgScore += $percent
    }
    
    $Stats.AvgScore = [math]::Round($Stats.AvgScore / $Stats.TotalRules, 1)
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Генерация отчёта
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Генерация отчёта..."
    
    Generate-Report -Rules $Rules -Stats $Stats -ReportPath $ReportPath
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Финальный вывод
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Финальный вывод..."
    
    Write-Host ""
    Write-Success-Log "ПРОВЕРКА ЗАВЕРШЕНА!" -Color "Green"
    Write-Host ""
    Write-Host "Результаты:" -ForegroundColor "White"
    Write-Host "  Всего правил: $($Stats.TotalRules)" -ForegroundColor "White"
    Write-Host "  Полный профиль: $($Stats.FullProfile) ✅" -ForegroundColor "Green"
    Write-Host "  Частичный профиль: $($Stats.PartialProfile) ⚠️ " -ForegroundColor "Yellow"
    Write-Host "  Нет профиля: $($Stats.NoProfile) ❌" -ForegroundColor "Red"
    Write-Host "  Средняя оценка: $($Stats.AvgScore)%" -ForegroundColor $(if ($Stats.AvgScore -ge 90) { "Green" } elseif ($Stats.AvgScore -ge 75) { "Yellow" } else { "Red" })
    Write-Host ""
    Write-Host "Отчёт: $ReportPath" -ForegroundColor "Cyan"
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
