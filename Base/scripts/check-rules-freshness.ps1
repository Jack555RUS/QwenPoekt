# ============================================================================
# CHECK RULES FRESHNESS
# ============================================================================
# Назначение: Проверка правил на актуальность (last_reviewed)
# Использование: .\scripts\check-rules-freshness.ps1 [-MaxAge 90]
# ============================================================================

param(
    [string]$RulesPath = "D:\QwenPoekt\Base\KNOWLEDGE_BASE",
    
    [int]$MaxAge = 90,  # Дней до предупреждения
    
    [string]$ReportPath = "D:\QwenPoekt\Base\reports\rules_freshness_report.md",
    
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"

# ============================================================================
# ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
# ============================================================================

$CheckDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$Stats = @{
    TotalRules = 0
    FreshRules = 0
    StaleRules = 0
    MissingField = 0
    ArchivedRules = 0
}

$StaleRules = @()
$MissingFieldRules = @()
$ArchivedRules = @()

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

function Get-Rule-Metadata {
    param([string]$FilePath)
    
    try {
        $content = Get-Content $FilePath -Raw
        
        $metadata = @{
            Path = $FilePath
            Name = Split-Path $FilePath -Leaf
            LastReviewed = $null
            Created = $null
            Status = "Unknown"
            Version = "Unknown"
        }
        
        # Извлечь last_reviewed
        if ($content -match '\*\*Последняя проверка:\*\*\s+(\d{4}-\d{2}-\d{2})') {
            $metadata.LastReviewed = [datetime]$matches[1]
        }
        
        # Извлечь created
        if ($content -match '\*\*Дата создания:\*\*\s+(\d{4}-\d{2}-\d{2})') {
            $metadata.Created = [datetime]$matches[1]
        }
        
        # Извлечь status
        if ($content -match '\*\*Статус:\*\*\s+(✅|⚠️|❌)\s+(\w+)') {
            $metadata.Status = $matches[2]
        }
        
        # Извлечь version
        if ($content -match '\*\*Версия:\*\*\s+([\d\.]+)') {
            $metadata.Version = $matches[1]
        }
        
        return $metadata
    } catch {
        return $null
    }
}

function Check-Rule-Freshness {
    param(
        [string]$FilePath,
        [int]$MaxAge
    )
    
    $metadata = Get-Rule-Metadata -FilePath $FilePath
    
    if (!$metadata) {
        $Stats.MissingField++
        $MissingFieldRules += $FilePath
        return "Error"
    }
    
    # Проверка на архив
    if ($metadata.Status -eq "Архив" -or $metadata.Status -eq "Archive") {
        $Stats.ArchivedRules++
        $ArchivedRules += $FilePath
        return "Archived"
    }
    
    # Проверка last_reviewed
    if (!$metadata.LastReviewed) {
        $Stats.MissingField++
        $MissingFieldRules += $FilePath
        return "Missing"
    }
    
    $age = (Get-Date) - $metadata.LastReviewed
    
    if ($age.Days -gt $MaxAge) {
        $Stats.StaleRules++
        $StaleRules += @{
            Path = $FilePath
            LastReviewed = $metadata.LastReviewed
            DaysOld = $age.Days
        }
        return "Stale"
    } else {
        $Stats.FreshRules++
        return "Fresh"
    }
}

function Generate-Report {
    param(
        [hashtable]$Stats,
        [array]$StaleRules,
        [array]$MissingFieldRules,
        [array]$ArchivedRules,
        [string]$ReportPath
    )
    
    $report = @"
# Отчёт проверки актуальности правил

**Дата проверки:** $CheckDate
**Максимальный возраст:** $MaxAge дней

---

## 📊 Статистика

| Метрика | Значение |
|---------|----------|
| **Всего правил** | $($Stats.TotalRules) |
| **Актуальные** | $($Stats.FreshRules) |
| **Устаревшие** | $($Stats.StaleRules) |
| **Без last_reviewed** | $($Stats.MissingField) |
| **В архиве** | $($Stats.ArchivedRules) |

**% актуальных:** $([math]::Round(($Stats.FreshRules / $Stats.TotalRules) * 100, 1))%

---

## ⚠️  Устаревшие правила (требуют проверки)

"@
    
    if ($StaleRules.Count -gt 0) {
        foreach ($rule in $StaleRules) {
            $report += @"
### $($rule.Name)

**Путь:** ``````$($rule.Path)``````
**Последняя проверка:** $($rule.LastReviewed.ToString("yyyy-MM-dd"))
**Дней назад:** $($rule.DaysOld)

**Рекомендация:** Проверить и обновить `last_reviewed`

---
"@
        }
    } else {
        $report += "``````text`nУстаревших правил не найдено`n``````"
    }
    
    $report += @"

---

## ❌ Правила без last_reviewed

"@
    
    if ($MissingFieldRules.Count -gt 0) {
        foreach ($rule in $MissingFieldRules) {
            $ruleName = Split-Path $rule -Leaf
            $report += "- ``````$ruleName`````` (`$rule`)`n"
        }
    } else {
        $report += "``````text`nВсе правила имеют last_reviewed`n``````"
    }
    
    $report += @"

---

## 📋 Рекомендации

1. **Проверить устаревшие правила** — обновить `last_reviewed` или переместить в архив
2. **Добавить last_reviewed** в правила без этого поля
3. **Запустить повторно** через $($MaxAge / 2) дней

---

## 📋 План действий

``````powershell
# 1. Проверить устаревшие правила
.\scripts\check-rules-freshness.ps1

# 2. Открыть устаревшие правила для проверки
code "путь/к/правилу.md"

# 3. Обновить last_reviewed
**Последняя проверка:** $(Get-Date -Format "yyyy-MM-dd")

# 4. Закоммитить изменения
git add .
git commit -m "Update: актуализация правил"
``````

---

**Проверка завершена:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** check-rules-freshness.ps1
"@
    
    $report | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Success-Log "Отчёт сохранён: $ReportPath"
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ПРОВЕРКА АКТУАЛЬНОСТИ ПРАВИЛ ===" -Color "Yellow"
    Write-Log "Путь: $RulesPath"
    Write-Log "Максимальный возраст: $MaxAge дней"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Поиск правил
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Поиск правил..."
    
    $ruleFiles = Get-ChildItem -Path $RulesPath -Recurse -Filter "*.md" -ErrorAction SilentlyContinue |
                 Where-Object { $_.FullName -match "01_RULES|00_CORE|05_METHODOLOGY" }
    
    $Stats.TotalRules = $ruleFiles.Count
    
    Write-Log "  Найдено правил: $($Stats.TotalRules)"
    
    if ($Stats.TotalRules -eq 0) {
        Write-Warning-Log "Правила не найдены!"
        exit 0
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Проверка каждого правила
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Проверка актуальности..."
    
    foreach ($file in $ruleFiles) {
        $status = Check-Rule-Freshness -FilePath $file.FullName -MaxAge $MaxAge
        
        if ($Verbose) {
            $color = switch ($status) {
                "Fresh" { "Green" }
                "Stale" { "Yellow" }
                "Missing" { "Red" }
                "Archived" { "Gray" }
                "Error" { "Red" }
            }
            Write-Log "  $($file.Name): $status" -Color $color
        }
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Генерация отчёта
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Генерация отчёта..."
    
    Generate-Report -Stats $Stats -StaleRules $StaleRules -MissingFieldRules $MissingFieldRules -ArchivedRules $ArchivedRules -ReportPath $ReportPath
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Финальный вывод
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Финальный вывод..."
    
    Write-Host ""
    Write-Success-Log "ПРОВЕРКА ЗАВЕРШЕНА!" -Color "Green"
    Write-Host ""
    Write-Host "Результаты:" -ForegroundColor "White"
    Write-Host "  Всего правил: $($Stats.TotalRules)" -ForegroundColor "White"
    Write-Host "  Актуальные: $($Stats.FreshRules) ✅" -ForegroundColor "Green"
    Write-Host "  Устаревшие: $($Stats.StaleRules) ⚠️ " -ForegroundColor "Yellow"
    Write-Host "  Без last_reviewed: $($Stats.MissingField) ❌" -ForegroundColor "Red"
    Write-Host "  В архиве: $($Stats.ArchivedRules) 📦" -ForegroundColor "Gray"
    Write-Host ""
    Write-Host "Отчёт: $ReportPath" -ForegroundColor "Cyan"
    Write-Host ""
    
    if ($Stats.StaleRules -gt 0) {
        Write-Warning-Log "Найдено $($Stats.StaleRules) устаревших правил!"
        Write-Host ""
        Write-Host "Для обновления:" -ForegroundColor "Cyan"
        Write-Host "  1. Откройте каждое устаревшее правило" -ForegroundColor "Gray"
        Write-Host "  2. Обновите **Последняя проверка:** $(Get-Date -Format "yyyy-MM-dd")" -ForegroundColor "Gray"
        Write-Host "  3. Закоммитьте изменения" -ForegroundColor "Gray"
        Write-Host ""
    }
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
