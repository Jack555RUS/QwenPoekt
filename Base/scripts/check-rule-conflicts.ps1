# ============================================================================
# CHECK RULE DUPLICATES AND CONFLICTS
# ============================================================================
# Назначение: Проверка правил на дубляж, пересечения и противоречия
# Использование: .\scripts\check-rule-conflicts.ps1 [-Verbose]
# ============================================================================

param(
    [string]$RulesPath = "D:\QwenPoekt\Base\KNOWLEDGE_BASE",
    
    [string]$ReportPath = "D:\QwenPoekt\Base\reports\rule_conflicts_report.md",
    
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"

# ============================================================================
# ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
# ============================================================================

$CheckDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$Stats = @{
    TotalRules = 0
    Duplicates = 0
    Overlaps = 0
    Conflicts = 0
    TotalIssues = 0
}

$Issues = @()

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

function Find-Duplicate-Content {
    param([array]$Rules)
    
    Write-Log "Поиск дубликатов содержания..."
    
    $duplicates = @()
    
    for ($i = 0; $i -lt $Rules.Count; $i++) {
        for ($j = $i + 1; $j -lt $Rules.Count; $j++) {
            $rule1 = $Rules[$i]
            $rule2 = $Rules[$j]
            
            # Сравнение по названию
            if ($rule1.Name -eq $rule2.Name) {
                $duplicates += @{
                    Type = "Duplicate Name"
                    Rule1 = $rule1.Path
                    Rule2 = $rule2.Path
                    Severity = "High"
                }
            }
            
            # Сравнение по содержанию (простая эвристика)
            $content1 = $rule1.Content
            $content2 = $rule2.Content
            
            if ($content1 -and $content2) {
                $similarity = Get-Text-Similarity -Text1 $content1 -Text2 $content2
                
                if ($similarity -gt 0.8) {
                    $duplicates += @{
                        Type = "Duplicate Content"
                        Rule1 = $rule1.Path
                        Rule2 = $rule2.Path
                        Similarity = [math]::Round($similarity * 100, 1)
                        Severity = "Medium"
                    }
                }
            }
        }
    }
    
    return $duplicates
}

function Get-Text-Similarity {
    param([string]$Text1, [string]$Text2)
    
    # Простая эвристика: количество общих слов
    $words1 = $Text1.ToLower() -split '\s+' | Where-Object { $_.Length -gt 3 }
    $words2 = $Text2.ToLower() -split '\s+' | Where-Object { $_.Length -gt 3 }
    
    $common = $words1 | Where-Object { $words2 -contains $_ }
    
    $total = [math]::Max($words1.Count, $words2.Count)
    
    if ($total -eq 0) { return 0 }
    
    return $common.Count / $total
}

function Find-Overlapping-Topics {
    param([array]$Rules)
    
    Write-Log "Поиск пересечений тем..."
    
    $overlaps = @()
    
    # Ключевые слова для анализа
    $keywords = @(
        "тест", "test", "Test",
        "пример", "example", "Example",
        "команда", "command", "Command",
        "правило", "rule", "Rule",
        "стандарт", "standard", "Standard"
    )
    
    foreach ($keyword in $keywords) {
        $matchingRules = $Rules | Where-Object { $_.Content -match $keyword }
        
        if ($matchingRules.Count -gt 3) {
            $overlaps += @{
                Type = "Overlapping Topic"
                Keyword = $keyword
                Rules = $matchingRules.Path
                Count = $matchingRules.Count
                Severity = "Low"
            }
        }
    }
    
    return $overlaps
}

function Find-Conflicting-Instructions {
    param([array]$Rules)
    
    Write-Log "Поиск противоречивых инструкций..."
    
    $conflicts = @()
    
    # Паттерны для поиска противоречий
    $patterns = @(
        @{Pattern = "должен|must|should"; Negative = "не должен|must not|should not"},
        @{Pattern = "обязательно|always"; Negative = "не обязательно|not always"},
        @{Pattern = "запрещено|forbidden"; Negative = "разрешено|allowed"}
    )
    
    foreach ($rule in $Rules) {
        foreach ($pattern in $patterns) {
            if ($rule.Content -match $pattern.Pattern -and $rule.Content -match $pattern.Negative) {
                $conflicts += @{
                    Type = "Conflicting Instructions"
                    Rule = $rule.Path
                    Pattern = $pattern.Pattern
                    Severity = "High"
                }
            }
        }
    }
    
    return $conflicts
}

function Generate-Report {
    param(
        [array]$Issues,
        [hashtable]$Stats,
        [string]$ReportPath
    )
    
    $report = @"
# 📊 ОТЧЁТ ПРОВЕРКИ ПРАВИЛ НА ДУБЛЯЖ И ПРОТИВОРЕЧИЯ

**Дата проверки:** $CheckDate

---

## 📊 СТАТИСТИКА

| Метрика | Значение |
|---------|----------|
| **Всего правил** | $($Stats.TotalRules) |
| **Дубликаты** | $($Stats.Duplicates) |
| **Пересечения** | $($Stats.Overlaps) |
| **Противоречия** | $($Stats.Conflicts) |
| **Всего проблем** | $($Stats.TotalIssues) |

---

## 🔍 НАЙДЕННЫЕ ПРОБЛЕМЫ

"@
    
    if ($Issues.Count -gt 0) {
        # Группировка по типу
        $grouped = $Issues | Group-Object -Property Type
        
        foreach ($group in $grouped) {
            $report += @"

### $($group.Name) ($($group.Count))

"@
            
            foreach ($issue in $group.Group) {
                if ($issue.Type -eq "Duplicate Name" -or $issue.Type -eq "Duplicate Content") {
                    $report += @"
**Проблема:** $($issue.Type)
- Правило 1: ``````$($issue.Rule1)``````
- Правило 2: ``````$($issue.Rule2)``````
$(if ($issue.Similarity) { "- Схожесть: $($issue.Similarity)%" })
- Серьёзность: **$($issue.Severity)**

---
"@
                }
                elseif ($issue.Type -eq "Overlapping Topic") {
                    $report += @"
**Проблема:** $($issue.Type)
- Ключевое слово: ``````$($issue.Keyword)``````
- Количество правил: $($issue.Count)
- Правила:
$($issue.Rules | ForEach-Object { "  - ``````$_``````" })
- Серьёзность: **$($issue.Severity)**

---
"@
                }
                elseif ($issue.Type -eq "Conflicting Instructions") {
                    $report += @"
**Проблема:** $($issue.Type)
- Правило: ``````$($issue.Rule)``````
- Паттерн: ``````$($issue.Pattern)``````
- Серьёзность: **$($issue.Severity)**

---
"@
                }
            }
        }
    } else {
        $report += "``````text`nПроблем не найдено`n``````"
    }
    
    $report += @"

## 🎯 РЕКОМЕНДАЦИИ

### Приоритет 1 (Критично):

"@
    
    $highSeverity = $Issues | Where-Object { $_.Severity -eq "High" }
    if ($highSeverity.Count -gt 0) {
        foreach ($issue in $highSeverity) {
            $report += "1. ⚠️ **$($issue.Type)** — $($issue.Rule)`n"
        }
    } else {
        $report += "``````text`nКритичных проблем не найдено`n``````"
    }
    
    $report += @"

### Приоритет 2 (Важно):

"@
    
    $mediumSeverity = $Issues | Where-Object { $_.Severity -eq "Medium" }
    if ($mediumSeverity.Count -gt 0) {
        foreach ($issue in $mediumSeverity) {
            $report += "1. ⚠️ **$($issue.Type)** — $($issue.Rule1)`n"
        }
    } else {
        $report += "``````text`nПредупреждений не найдено`n``````"
    }
    
    $report += @"

### Приоритет 3 (Желательно):

"@
    
    $lowSeverity = $Issues | Where-Object { $_.Severity -eq "Low" }
    if ($lowSeverity.Count -gt 0) {
        foreach ($issue in $lowSeverity) {
            $report += "1. 📝 **$($issue.Type)** — $($issue.Keyword)`n"
        }
    } else {
        $report += "``````text`nРекомендаций не найдено`n``````"
    }
    
    $report += @"

---

**Проверка завершена:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** check-rule-conflicts.ps1
"@
    
    $report | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Success-Log "Отчёт сохранён: $ReportPath"
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ПРОВЕРКА ПРАВИЛ НА ДУБЛЯЖ И ПРОТИВОРЕЧИЯ ===" -Color "Yellow"
    Write-Log "Путь: $RulesPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Загрузка правил
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Загрузка правил..."
    
    $ruleFiles = Get-ChildItem -Path $RulesPath -Recurse -Filter "*.md" -ErrorAction SilentlyContinue |
                 Where-Object { $_.FullName -match "00_CORE|05_METHODOLOGY" }
    
    $Stats.TotalRules = $ruleFiles.Count
    
    Write-Log "  Найдено правил: $($Stats.TotalRules)"
    
    $Rules = @()
    foreach ($file in $ruleFiles) {
        $content = Get-Content $file.FullName -Raw
        $Rules += @{
            Path = $file.FullName
            Name = $file.Name
            Content = $content
        }
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Поиск дубликатов
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Поиск дубликатов..."
    
    $duplicates = Find-Duplicate-Content -Rules $Rules
    $Stats.Duplicates = $duplicates.Count
    $Issues += $duplicates
    
    Write-Log "  Найдено дубликатов: $($Stats.Duplicates)"
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Поиск пересечений
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Поиск пересечений..."
    
    $overlaps = Find-Overlapping-Topics -Rules $Rules
    $Stats.Overlaps = $overlaps.Count
    $Issues += $overlaps
    
    Write-Log "  Найдено пересечений: $($Stats.Overlaps)"
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Поиск противоречий
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Поиск противоречий..."
    
    $conflicts = Find-Conflicting-Instructions -Rules $Rules
    $Stats.Conflicts = $conflicts.Count
    $Issues += $conflicts
    
    Write-Log "  Найдено противоречий: $($Stats.Conflicts)"
    
    # ------------------------------------------------------------------------
    # Подсчёт итогов
    # ------------------------------------------------------------------------
    $Stats.TotalIssues = $Stats.Duplicates + $Stats.Overlaps + $Stats.Conflicts
    
    # ------------------------------------------------------------------------
    # ШАГ 5: Генерация отчёта
    # ------------------------------------------------------------------------
    Write-Log "Шаг 5: Генерация отчёта..."
    
    Generate-Report -Issues $Issues -Stats $Stats -ReportPath $ReportPath
    
    # ------------------------------------------------------------------------
    # ШАГ 6: Финальный вывод
    # ------------------------------------------------------------------------
    Write-Log "Шаг 6: Финальный вывод..."
    
    Write-Host ""
    Write-Success-Log "ПРОВЕРКА ЗАВЕРШЕНА!" -Color "Green"
    Write-Host ""
    Write-Host "Результаты:" -ForegroundColor "White"
    Write-Host "  Всего правил: $($Stats.TotalRules)" -ForegroundColor "White"
    Write-Host "  Дубликаты: $($Stats.Duplicates)" -ForegroundColor $(if ($Stats.Duplicates -gt 0) { "Yellow" } else { "Green" })
    Write-Host "  Пересечения: $($Stats.Overlaps)" -ForegroundColor $(if ($Stats.Overlaps -gt 0) { "Yellow" } else { "Green" })
    Write-Host "  Противоречия: $($Stats.Conflicts)" -ForegroundColor $(if ($Stats.Conflicts -gt 0) { "Red" } else { "Green" })
    Write-Host "  Всего проблем: $($Stats.TotalIssues)" -ForegroundColor $(if ($Stats.TotalIssues -gt 0) { "Yellow" } else { "Green" })
    Write-Host ""
    Write-Host "Отчёт: $ReportPath" -ForegroundColor "Cyan"
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
