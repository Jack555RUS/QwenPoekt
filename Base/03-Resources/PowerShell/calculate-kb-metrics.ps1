# ============================================================================
# CALCULATE KB METRICS
# Расчёт метрик качества Базы Знаний
# ============================================================================
# Использование: .\scripts\calculate-kb-metrics.ps1 [-Path "путь"] [-OutputPath "путь"]
# ============================================================================

param(
    [string]$Path = "D:\QwenPoekt\Base\KNOWLEDGE_BASE",
    [string]$OutputPath = "D:\QwenPoekt\Base\reports\KB_METRICS.md",
    [string]$JsonOutputPath = "D:\QwenPoekt\Base\reports\kb_metrics.json"
)

$ErrorActionPreference = "Continue"

# ============================================================================
# ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
# ============================================================================

$MetricsDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$Metrics = @{
    Completeness = 0
    Accuracy = 0
    Connectivity = 0
    Uniqueness = 0
    Readability = 0
    Overall = 0
}

$Details = @{
    filesWithMetadata = 0
    filesWithVersion = 0
    filesWithDate = 0
    filesWithStatus = 0
    filesWithTOC = 0
    filesWithTags = 0
    filesWithRelated = 0
    avgDaysSinceReview = 0
    filesWithLinks = 0
    avgLinksPerFile = 0
    duplicateCount = 0
    avgFileSize = 0
    filesWithCode = 0
    filesWithTables = 0
    filesWithHeaders = 0
}

# ============================================================================
# ФУНКЦИИ
# ============================================================================

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Calculate-Completeness {
    param([System.IO.FileInfo[]]$Files)
    
    $total = $Files.Count
    if ($total -eq 0) { return 0 }
    
    $scores = @{
        version = 0
        date = 0
        status = 0
        toc = 0
        tags = 0
        related = 0
    }
    
    foreach ($file in $Files) {
        try {
            $content = Get-Content $file.FullName -Raw -ErrorAction Stop
            
            if ($content -match '\*\*Версия:\*\*') { $scores.version++ }
            if ($content -match '\*\*Дата:\*\*') { $scores.date++ }
            if ($content -match '\*\*Статус:\*\*') { $scores.status++ }
            if ($content -match '## 📖 СОДЕРЖАНИЕ|## Содержание') { $scores.toc++ }
            if ($content -match '#тег|Теги:|Tags:') { $scores.tags++ }
            if ($content -match 'Связанные файлы|Related|See Also') { $scores.related++ }
        } catch {}
    }
    
    $Details.filesWithVersion = $scores.version
    $Details.filesWithDate = $scores.date
    $Details.filesWithStatus = $scores.status
    $Details.filesWithTOC = $scores.toc
    $Details.filesWithTags = $scores.tags
    $Details.filesWithRelated = $scores.related
    $Details.filesWithMetadata = $scores.version + $scores.date + $scores.status
    
    # Максимум 100 баллов
    $maxScore = $total * 6
    $actualScore = ($scores.version + $scores.date + $scores.status + $scores.toc + $scores.tags + $scores.related)
    
    return [math]::Round(($actualScore / $maxScore) * 100, 1)
}

function Calculate-Accuracy {
    param([System.IO.FileInfo[]]$Files)
    
    $total = $Files.Count
    if ($total -eq 0) { return 100 }
    
    $totalDays = 0
    $filesWithReview = 0
    
    foreach ($file in $Files) {
        try {
            $content = Get-Content $file.FullName -Raw -ErrorAction Stop
            
            if ($content -match '\*\*Дата:\*\*\s*([\d-]+)') {
                $date = [DateTime]::Parse($matches[1])
                $days = (New-TimeSpan -Start $date -End (Get-Date)).Days
                $totalDays += [math]::Min($days, 365)  # Максимум 1 год
                $filesWithReview++
            }
        } catch {}
    }
    
    if ($filesWithReview -eq 0) { return 50 }  # Нет данных → средняя точность
    
    $Details.avgDaysSinceReview = [math]::Round($totalDays / $filesWithReview, 0)
    
    # Чем меньше дней, тем выше точность (максимум 100 при 0 дней, минимум 0 при 365+)
    $avgDays = $totalDays / $filesWithReview
    $score = [math]::Max(0, 100 - ($avgDays / 3.65))  # 100 - (days/3.65)
    
    return [math]::Round($score, 1)
}

function Calculate-Connectivity {
    param([System.IO.FileInfo[]]$Files, [string]$GraphJsonPath)
    
    $total = $Files.Count
    if ($total -eq 0) { return 0 }
    
    # Пытаемся загрузить данные из графа
    if (Test-Path $GraphJsonPath) {
        try {
            $graphData = Get-Content $GraphJsonPath -Raw | ConvertFrom-Json
            
            $totalEdges = $graphData.stats.totalEdges
            $isolated = $graphData.stats.isolated
            
            $Details.filesWithLinks = $total - $isolated
            $Details.avgLinksPerFile = [math]::Round($totalEdges / $total, 2)
            
            # Формула: (файлы со связями / всего файлов) * 100
            $connectivityScore = (($total - $isolated) / $total) * 100
            
            # Бонус за среднее количество связей
            $bonus = [math]::Min($Details.avgLinksPerFile * 5, 20)
            
            return [math]::Round($connectivityScore + $bonus, 1)
        } catch {}
    }
    
    # Упрощённый расчёт без графа
    $filesWithLinks = 0
    $totalLinks = 0
    
    foreach ($file in $Files) {
        try {
            $content = Get-Content $file.FullName -Raw -ErrorAction Stop
            $links = [regex]::Matches($content, '\[([^\]]+)\]\(([^\)]+)\)')
            
            if ($links.Count -gt 0) {
                $filesWithLinks++
                $totalLinks += $links.Count
            }
        } catch {}
    }
    
    $Details.filesWithLinks = $filesWithLinks
    $Details.avgLinksPerFile = [math]::Round($totalLinks / $total, 2)
    
    return [math]::Round((($filesWithLinks / $total) * 80) + ([math]::Min($Details.avgLinksPerFile * 2, 20)), 1)
}

function Calculate-Uniqueness {
    param([System.IO.FileInfo[]]$Files)
    
    $total = $Files.Count
    if ($total -eq 0) { return 100 }
    
    $hashes = @{}
    $duplicates = 0
    
    foreach ($file in $Files) {
        try {
            $hash = Get-FileHash $file.FullName -Algorithm SHA256 -ErrorAction Stop
            
            if ($hashes.ContainsKey($hash.Hash)) {
                $duplicates++
            } else {
                $hashes[$hash.Hash] = $file.FullName
            }
        } catch {}
    }
    
    $Details.duplicateCount = $duplicates
    
    # 100 - процент дубликатов
    $score = 100 - (($duplicates / $total) * 100)
    
    return [math]::Round($score, 1)
}

function Calculate-Readability {
    param([System.IO.FileInfo[]]$Files)
    
    $total = $Files.Count
    if ($total -eq 0) { return 0 }
    
    $scores = @{
        size = 0
        code = 0
        tables = 0
        headers = 0
    }
    
    $totalSize = 0
    
    foreach ($file in $Files) {
        try {
            $content = Get-Content $file.FullName -Raw -ErrorAction Stop
            $lines = $content.Split("`n").Count
            $totalSize += $file.Length
            
            # Размер (оптимально 500-2000 строк)
            if ($lines -ge 50 -and $lines -le 2000) { $scores.size++ }
            
            # Примеры кода
            if ($content -match '```') { $scores.code++ }
            
            # Таблицы
            if ($content -match '\|.*\|') { $scores.tables++ }
            
            # Заголовки
            if ($content -match '^#{1,6}\s' -mi) { $scores.headers++ }
        } catch {}
    }
    
    $Details.avgFileSize = [math]::Round($totalSize / $total, 0)
    $Details.filesWithCode = $scores.code
    $Details.filesWithTables = $scores.tables
    $Details.filesWithHeaders = $scores.headers
    
    # Максимум 100 баллов
    $maxScore = $total * 4
    $actualScore = ($scores.size + $scores.code + $scores.tables + $scores.headers)
    
    return [math]::Round(($actualScore / $maxScore) * 100, 1)
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

Write-Host ""
Write-Log "=== РАСЧЁТ МЕТРИК КАЧЕСТВА ===" -Color "Yellow"
Write-Log "Дата: $MetricsDate" -Color "Yellow"
Write-Log "Путь: $Path" -Color "Yellow"
Write-Host ""

# Сбор всех файлов
Write-Log "1. Сбор файлов..." -Color "Cyan"
$allFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.md" -File
Write-Log "   Найдено файлов: $($allFiles.Count)" -Color "Green"
Write-Host ""

# Расчёт метрик
Write-Log "2. Расчёт метрик..." -Color "Cyan"

$Metrics.Completeness = Calculate-Completeness -Files $allFiles
Write-Log "   Completeness (полнота): $($Metrics.Completeness)/100" -Color $(if ($Metrics.Completeness -ge 80) { "Green" } elseif ($Metrics.Completeness -ge 60) { "Yellow" } else { "Red" })

$Metrics.Accuracy = Calculate-Accuracy -Files $allFiles
Write-Log "   Accuracy (актуальность): $($Metrics.Accuracy)/100" -Color $(if ($Metrics.Accuracy -ge 80) { "Green" } elseif ($Metrics.Accuracy -ge 60) { "Yellow" } else { "Red" })

$GraphJsonPath = Join-Path (Split-Path $OutputPath -Parent) "knowledge_graph.json"
$Metrics.Connectivity = Calculate-Connectivity -Files $allFiles -GraphJsonPath $GraphJsonPath
Write-Log "   Connectivity (связность): $($Metrics.Connectivity)/100" -Color $(if ($Metrics.Connectivity -ge 80) { "Green" } elseif ($Metrics.Connectivity -ge 60) { "Yellow" } else { "Red" })

$Metrics.Uniqueness = Calculate-Uniqueness -Files $allFiles
Write-Log "   Uniqueness (уникальность): $($Metrics.Uniqueness)/100" -Color $(if ($Metrics.Uniqueness -ge 80) { "Green" } elseif ($Metrics.Uniqueness -ge 60) { "Yellow" } else { "Red" })

$Metrics.Readability = Calculate-Readability -Files $allFiles
Write-Log "   Readability (читаемость): $($Metrics.Readability)/100" -Color $(if ($Metrics.Readability -ge 80) { "Green" } elseif ($Metrics.Readability -ge 60) { "Yellow" } else { "Red" })

# Общий score (взвешенная средняя)
$Metrics.Overall = [math]::Round(
    ($Metrics.Completeness * 0.2) +
    ($Metrics.Accuracy * 0.25) +
    ($Metrics.Connectivity * 0.2) +
    ($Metrics.Uniqueness * 0.15) +
    ($Metrics.Readability * 0.2),
    1
)

Write-Host ""
Write-Log "3. Генерация отчёта..." -Color "Cyan"

$reportContent = @"
# 📊 МЕТРИКИ КАЧЕСТВА БАЗЫ ЗНАНИЙ — $MetricsDate

**Дата:** $MetricsDate  
**Скрипт:** calculate-kb-metrics.ps1  
**Путь:** $Path

---

## 🏆 ОБЩАЯ ОЦЕНКА

**Quality Score: $($Metrics.Overall)/100**

$(if ($Metrics.Overall -ge 80) { "✅ **Отлично!** База знаний в прекрасном состоянии." } elseif ($Metrics.Overall -ge 60) { "🟡 **Хорошо.** Есть области для улучшения." } else { "❌ **Требует внимания.** Необходима работа над качеством." })

---

## 📈 ДЕТАЛЬНЫЕ МЕТРИКИ

| Метрика | Оценка | Вес | Описание |
|---------|--------|-----|----------|
| **Completeness** | $($Metrics.Completeness)/100 | 20% | Полнота метаданных |
| **Accuracy** | $($Metrics.Accuracy)/100 | 25% | Актуальность информации |
| **Connectivity** | $($Metrics.Connectivity)/100 | 20% | Связность файлов |
| **Uniqueness** | $($Metrics.Uniqueness)/100 | 15% | Отсутствие дубликатов |
| **Readability** | $($Metrics.Readability)/100 | 20% | Читаемость контента |

---

## 📊 ДЕТАЛИЗАЦИЯ

### Completeness (Полнота метаданных)

| Поле | Файлов | Процент |
|------|--------|---------|
| Версия | $($Details.filesWithVersion) | $(if ($allFiles.Count -gt 0) { [math]::Round($Details.filesWithVersion / $allFiles.Count * 100, 1) } else { 0 })% |
| Дата | $($Details.filesWithDate) | $(if ($allFiles.Count -gt 0) { [math]::Round($Details.filesWithDate / $allFiles.Count * 100, 1) } else { 0 })% |
| Статус | $($Details.filesWithStatus) | $(if ($allFiles.Count -gt 0) { [math]::Round($Details.filesWithStatus / $allFiles.Count * 100, 1) } else { 0 })% |
| Оглавление | $($Details.filesWithTOC) | $(if ($allFiles.Count -gt 0) { [math]::Round($Details.filesWithTOC / $allFiles.Count * 100, 1) } else { 0 })% |
| Теги | $($Details.filesWithTags) | $(if ($allFiles.Count -gt 0) { [math]::Round($Details.filesWithTags / $allFiles.Count * 100, 1) } else { 0 })% |
| Связанные файлы | $($Details.filesWithRelated) | $(if ($allFiles.Count -gt 0) { [math]::Round($Details.filesWithRelated / $allFiles.Count * 100, 1) } else { 0 })% |

---

### Accuracy (Актуальность)

| Показатель | Значение |
|------------|----------|
| **Средний возраст** | $($Details.avgDaysSinceReview) дней |
| **Рекомендация** | $(if ($Details.avgDaysSinceReview -gt 90) { "⚠️ Провести ревизию файлов" } else { "✅ Актуальность в норме" }) |

---

### Connectivity (Связность)

| Показатель | Значение |
|------------|----------|
| **Файлов со связями** | $($Details.filesWithLinks) |
| **Среднее кол-во ссылок** | $($Details.avgLinksPerFile) |
| **Рекомендация** | $(if ($Details.avgLinksPerFile -lt 2) { "⚠️ Добавить больше перекрёстных ссылок" } else { "✅ Связность хорошая" }) |

---

### Uniqueness (Уникальность)

| Показатель | Значение |
|------------|----------|
| **Дубликатов** | $($Details.duplicateCount) |
| **Рекомендация** | $(if ($Details.duplicateCount -gt 0) { "⚠️ Проверить дубликаты" } else { "✅ Дубликатов нет" }) |

---

### Readability (Читаемость)

| Показатель | Файлов | Процент |
|------------|--------|---------|
| Оптимальный размер | $($allFiles.Count - $Details.filesWithCode + $Details.filesWithCode) | $(if ($allFiles.Count -gt 0) { [math]::Round(($allFiles.Count - $Details.filesWithCode + $Details.filesWithCode) / $allFiles.Count * 100, 1) } else { 0 })% |
| С примерами кода | $($Details.filesWithCode) | $(if ($allFiles.Count -gt 0) { [math]::Round($Details.filesWithCode / $allFiles.Count * 100, 1) } else { 0 })% |
| С таблицами | $($Details.filesWithTables) | $(if ($allFiles.Count -gt 0) { [math]::Round($Details.filesWithTables / $allFiles.Count * 100, 1) } else { 0 })% |
| С заголовками | $($Details.filesWithHeaders) | $(if ($allFiles.Count -gt 0) { [math]::Round($Details.filesWithHeaders / $allFiles.Count * 100, 1) } else { 0 })% |
| **Средний размер** | $($Details.avgFileSize) байт | - |

---

## 🎯 РЕКОМЕНДАЦИИ

### Приоритет 1 (Критично):
$($Metrics.Overall -lt 60 ? @"
- [ ] Провести полную ревизию базы
- [ ] Добавить метаданные во все файлы
- [ ] Проверить и удалить дубликаты
"@ : "- ✅ Нет критичных проблем")

### Приоритет 2 (Важно):
$($Metrics.Completeness -lt 80 ? @"
- [ ] Добавить версии во все файлы
- [ ] Добавить даты и статусы
- [ ] Добавить оглавления
"@ : "- ✅ Полнота метаданных хорошая")

### Приоритет 3 (Желательно):
$($Metrics.Connectivity -lt 80 ? @"
- [ ] Добавить перекрёстные ссылки
- [ ] Связать изолированные файлы
"@ : "- ✅ Связность хорошая")

---

## 📈 ТРЕНДЫ

**Следующий шаг:** Запустить аудит через неделю для отслеживания прогресса.

---

**Статус:** ✅ МЕТРИКИ РАССЧИТАНЫ

**Формула Overall:**
\`\`\`
Overall = (Completeness × 0.2) + (Accuracy × 0.25) + (Connectivity × 0.2) + 
          (Uniqueness × 0.15) + (Readability × 0.2)
\`\`\`
"@

$reportContent | Out-File -FilePath $OutputPath -Encoding UTF8

# JSON экспорт
$jsonData = @{
    date = $MetricsDate
    overall = $Metrics.Overall
    metrics = @{
        completeness = $Metrics.Completeness
        accuracy = $Metrics.Accuracy
        connectivity = $Metrics.Connectivity
        uniqueness = $Metrics.Uniqueness
        readability = $Metrics.Readability
    }
    weights = @{
        completeness = 0.2
        accuracy = 0.25
        connectivity = 0.2
        uniqueness = 0.15
        readability = 0.2
    }
    details = $Details
    totalFiles = $allFiles.Count
}

$jsonData | ConvertTo-Json -Depth 5 | Out-File -FilePath $JsonOutputPath -Encoding UTF8

Write-Log "   Отчёт сохранён: $OutputPath" -Color "Green"
Write-Log "   JSON сохранён: $JsonOutputPath" -Color "Green"
Write-Host ""

# ============================================================================
# ИТОГИ
# ============================================================================

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Log "ИТОГИ:" -Color "Cyan"
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "  Completeness:  $($Metrics.Completeness)/100" -ForegroundColor $(if ($Metrics.Completeness -ge 80) { "Green" } elseif ($Metrics.Completeness -ge 60) { "Yellow" } else { "Red" })
Write-Host "  Accuracy:      $($Metrics.Accuracy)/100" -ForegroundColor $(if ($Metrics.Accuracy -ge 80) { "Green" } elseif ($Metrics.Accuracy -ge 60) { "Yellow" } else { "Red" })
Write-Host "  Connectivity:  $($Metrics.Connectivity)/100" -ForegroundColor $(if ($Metrics.Connectivity -ge 80) { "Green" } elseif ($Metrics.Connectivity -ge 60) { "Yellow" } else { "Red" })
Write-Host "  Uniqueness:    $($Metrics.Uniqueness)/100" -ForegroundColor $(if ($Metrics.Uniqueness -ge 80) { "Green" } elseif ($Metrics.Uniqueness -ge 60) { "Yellow" } else { "Red" })
Write-Host "  Readability:   $($Metrics.Readability)/100" -ForegroundColor $(if ($Metrics.Readability -ge 80) { "Green" } elseif ($Metrics.Readability -ge 60) { "Yellow" } else { "Red" })
Write-Host ""
Write-Host "  ─────────────────────────────────" -ForegroundColor Gray
Write-Host "  OVERALL:       $($Metrics.Overall)/100" -ForegroundColor $(if ($Metrics.Overall -ge 80) { "Green" } elseif ($Metrics.Overall -ge 60) { "Yellow" } else { "Red" })
Write-Host ""

if ($Metrics.Overall -ge 80) {
    Write-Host "✅ ОТЛИЧНО! База знаний в прекрасном состоянии." -ForegroundColor Green
} elseif ($Metrics.Overall -ge 60) {
    Write-Host "🟡 ХОРОШО. Есть области для улучшения." -ForegroundColor Yellow
} else {
    Write-Host "❌ ТРЕБУЕТ ВНИМАНИЯ. Необходима работа над качеством." -ForegroundColor Red
}

Write-Host ""
Write-Host "Нажмите любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
