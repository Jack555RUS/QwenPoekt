# ============================================================================
# AUDIT ALL — ЕДИНАЯ ТОЧКА ВХОДА
# Запуск всех аудитов Базы Знаний
# ============================================================================
# Использование: .\scripts\AUDIT_ALL.ps1 [-Path "путь"] [-WhatIf]
# ============================================================================

param(
    [string]$Path = "D:\QwenPoekt\Base",
    [switch]$WhatIf
)

$ErrorActionPreference = "Continue"
$ScriptsPath = Split-Path $MyInvocation.MyCommand.Path -Parent
$ReportsPath = Join-Path $Path "reports"
$AuditDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# ============================================================================
# ФУНКЦИИ
# ============================================================================

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Test-Script {
    param([string]$ScriptName)
    $scriptPath = Join-Path $ScriptsPath $ScriptName
    if (Test-Path $scriptPath) {
        return $scriptPath
    }
    return $null
}

function Run-Script {
    param(
        [string]$ScriptPath,
        [string]$Name,
        [hashtable]$Params = @{}
    )
    
    Write-Host ""
    Write-Log "═══════════════════════════════════════════════════════════" -Color "Cyan"
    Write-Log "  ЗАПУСК: $Name" -Color "Yellow"
    Write-Log "═══════════════════════════════════════════════════════════" -Color "Cyan"
    Write-Host ""
    
    $startTime = Get-Date
    $success = $true
    
    try {
        & $ScriptPath @Params -ErrorAction Stop
    } catch {
        Write-Log "❌ ОШИБКА: $_" -Color "Red"
        $success = $false
    }
    
    $endTime = Get-Date
    $duration = New-TimeSpan -Start $startTime -End $endTime
    
    return @{
        Name = $Name
        Success = $success
        Duration = $duration
        StartTime = $startTime
        EndTime = $endTime
    }
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

Write-Host ""
Write-Host "████████████████████████████████████████████████████████████" -ForegroundColor Cyan
Write-Host "█                                                          █" -ForegroundColor Cyan
Write-Host "█              A U D I T   A L L                           █" -ForegroundColor Cyan
Write-Host "█         Единая точка входа для аудитов                   █" -ForegroundColor Cyan
Write-Host "█                                                          █" -ForegroundColor Cyan
Write-Host "████████████████████████████████████████████████████████████" -ForegroundColor Cyan
Write-Host ""

Write-Log "Дата: $AuditDate" -Color "White"
Write-Log "Путь: $Path" -Color "White"

if ($WhatIf) {
    Write-Log "⚠️  РЕЖИМ WHATIF - тестовый запуск" -Color "Yellow"
    Write-Host ""
}

Write-Host ""
Write-Log "ПРОВЕРКА СКРИПТОВ..." -Color "Yellow"
Write-Host ""

# Проверка наличия скриптов
$scripts = @{
    "weekly-knowledge-audit.ps1" = $false
    "full-file-audit.ps1" = $false
    "build-knowledge-graph.ps1" = $false
    "calculate-kb-metrics.ps1" = $false
}

foreach ($scriptName in $scripts.Keys) {
    $scriptPath = Test-Script -ScriptName $scriptName
    if ($scriptPath) {
        $scripts[$scriptName] = $true
        Write-Log "  ✅ $scriptName" -Color "Green"
    } else {
        $scripts[$scriptName] = $false
        Write-Log "  ❌ $scriptName (не найден)" -Color "Red"
    }
}

Write-Host ""

# Запуск скриптов
$results = @()

if ($scripts["weekly-knowledge-audit.ps1"]) {
    $results += Run-Script -ScriptPath (Test-Script "weekly-knowledge-audit.ps1") -Name "weekly-knowledge-audit.ps1" -Params @{}
}

if ($scripts["full-file-audit.ps1"]) {
    $results += Run-Script -ScriptPath (Test-Script "full-file-audit.ps1") -Name "full-file-audit.ps1" -Params @{
        Path = (Join-Path $Path "KNOWLEDGE_BASE")
        OutputPath = (Join-Path $ReportsPath "FILE_AUDIT_REPORT.md")
    }
}

if ($scripts["build-knowledge-graph.ps1"]) {
    $results += Run-Script -ScriptPath (Test-Script "build-knowledge-graph.ps1") -Name "build-knowledge-graph.ps1" -Params @{
        Path = (Join-Path $Path "KNOWLEDGE_BASE")
        OutputPath = (Join-Path $ReportsPath "KNOWLEDGE_GRAPH.md")
        JsonOutputPath = (Join-Path $ReportsPath "knowledge_graph.json")
    }
}

if ($scripts["calculate-kb-metrics.ps1"]) {
    $results += Run-Script -ScriptPath (Test-Script "calculate-kb-metrics.ps1") -Name "calculate-kb-metrics.ps1" -Params @{
        Path = (Join-Path $Path "KNOWLEDGE_BASE")
        OutputPath = (Join-Path $ReportsPath "KB_METRICS.md")
        JsonOutputPath = (Join-Path $ReportsPath "kb_metrics.json")
    }
}

# Генерация сводного отчёта
Write-Host ""
Write-Log "═══════════════════════════════════════════════════════════" -Color "Cyan"
Write-Log "  ГЕНЕРАЦИЯ СВОДНОГО ОТЧЁТА" -Color "Yellow"
Write-Log "═══════════════════════════════════════════════════════════" -Color "Cyan"
Write-Host ""

$masterReportPath = Join-Path $ReportsPath "MASTER_AUDIT_REPORT.md"

$successCount = ($results | Where-Object { $_.Success }).Count
$totalCount = $results.Count

$reportContent = @"
# 📊 MASTER AUDIT REPORT — $AuditDate

**Дата:** $AuditDate  
**Скрипт:** AUDIT_ALL.ps1  
**Путь:** $Path

---

## 📊 ОБЗОР

| Показатель | Значение |
|------------|----------|
| **Всего скриптов** | $totalCount |
| **Успешно** | $successCount |
| **Провалено** | $($totalCount - $successCount) |
| **Общее время** | $(($results | Measure-Object Duration -Sum).Sum.ToString('hh\:mm\:ss')) |

---

## 📋 РЕЗУЛЬТАТЫ

| Скрипт | Статус | Время начала | Время окончания | Длительность |
|--------|--------|--------------|-----------------|--------------|
$(foreach ($result in $results) {
    $status = if ($result.Success) { "✅" } else { "❌" }
    "| $($result.Name) | $status | $($result.StartTime.ToString('HH:mm:ss')) | $($result.EndTime.ToString('HH:mm:ss')) | $($result.Duration.ToString('hh\:mm\:ss')) |"
})

---

## 📁 ОТЧЁТЫ

### Сгенерированные файлы:

$(if (Test-Path (Join-Path $ReportsPath "FILE_AUDIT_REPORT.md")) { "- ✅ [FILE_AUDIT_REPORT.md](./FILE_AUDIT_REPORT.md)" } else { "- ❌ FILE_AUDIT_REPORT.md" })
$(if (Test-Path (Join-Path $ReportsPath "KNOWLEDGE_GRAPH.md")) { "- ✅ [KNOWLEDGE_GRAPH.md](./KNOWLEDGE_GRAPH.md)" } else { "- ❌ KNOWLEDGE_GRAPH.md" })
$(if (Test-Path (Join-Path $ReportsPath "KB_METRICS.md")) { "- ✅ [KB_METRICS.md](./KB_METRICS.md)" } else { "- ❌ KB_METRICS.md" })
$(if (Test-Path (Join-Path $ReportsPath "knowledge_graph.json")) { "- ✅ knowledge_graph.json" } else { "- ❌ knowledge_graph.json" })
$(if (Test-Path (Join-Path $ReportsPath "kb_metrics.json")) { "- ✅ kb_metrics.json" } else { "- ❌ kb_metrics.json" })

---

## 🎯 РЕКОМЕНДАЦИИ

$($successCount -eq $totalCount ? @"
### ✅ ВСЕ СКРИПТЫ ВЫПОЛНЕНЫ УСПЕШНО!

- Проверить отчёты в папке \`reports/\`
- Открыть \`KB_DASHBOARD.html\` для визуализации
- Сравнить с предыдущими результатами
"@ : @"
### ⚠️ НЕКОТОРЫЕ СКРИПТЫ ЗАВЕРШИЛИСЬ С ОШИБКАМИ

$(foreach ($result in $results | Where-Object { -not $_.Success }) {
    "- ❌ $($result.Name) — проверить лог"
})

**Рекомендация:** Запустить проблемные скрипты отдельно с флагом \`-Verbose\`
"@)

---

## 📈 ТРЕНДЫ

**Следующий аудит:** Запустить через неделю для сравнения результатов.

**Команда:**
\`\`\`powershell
.\scripts\AUDIT_ALL.ps1
\`\`\`

---

**Статус:** $(if ($successCount -eq $totalCount) { "✅ ВСЕ СКРИПТЫ ВЫПОЛНЕНЫ" } else { "⚠️ ЕСТЬ ОШИБКИ" })

**Сгенерировано:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

$reportContent | Out-File -FilePath $masterReportPath -Encoding UTF8

Write-Log "   Сводный отчёт: $masterReportPath" -Color "Green"
Write-Host ""

# Итоги
Write-Host ""
Write-Host "████████████████████████████████████████████████████████████" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })
Write-Host "█                                                          █" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })
Write-Host "█                    И Т О Г И                             █" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })
Write-Host "█                                                          █" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })
Write-Host "████████████████████████████████████████████████████████████" -ForegroundColor $(if ($successCount -eq $totalCount) { "Green" } else { "Yellow" })
Write-Host ""

Write-Host "  Скриптов выполнено: $totalCount" -ForegroundColor White
Write-Host "  ✅ Успешно: $successCount" -ForegroundColor Green
Write-Host "  ❌ Провалено: $($totalCount - $successCount)" -ForegroundColor Red
Write-Host "  Общее время: $(($results | Measure-Object Duration -Sum).Sum.ToString('hh\:mm\:ss'))" -ForegroundColor White
Write-Host ""

if ($successCount -eq $totalCount) {
    Write-Host "✅ ВСЕ СКРИПТЫ ВЫПОЛНЕНЫ УСПЕШНО!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📁 Отчёты:" -ForegroundColor Cyan
    Write-Host "   - $ReportsPath\FILE_AUDIT_REPORT.md" -ForegroundColor Gray
    Write-Host "   - $ReportsPath\KNOWLEDGE_GRAPH.md" -ForegroundColor Gray
    Write-Host "   - $ReportsPath\KB_METRICS.md" -ForegroundColor Gray
    Write-Host "   - $ReportsPath\MASTER_AUDIT_REPORT.md" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🌐 Dashboard:" -ForegroundColor Cyan
    Write-Host "   - $ReportsPath\KB_DASHBOARD.html" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "⚠️ ЕСТЬ ОШИБКИ" -ForegroundColor Yellow
    Write-Host "   См. MASTER_AUDIT_REPORT.md для деталей" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Нажмите любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
