# summarize-context.ps1 — Суммаризация контекста сессии
# Версия: 1.0
# Дата: 2026-03-04
# Назначение: Сжатие истории диалога с сохранением ключевых фактов

param(
    [string]$SessionPath = "sessions/",
    [double]$Threshold = 0.5,      # Порог суммаризации (50%)
    [int]$MaxTokens = 128000,      # Лимит токенов
    [int]$SummaryLength = 5,       # Количество предложений в summary
    [switch]$Verbose,
    [switch]$DryRun                # Сухой запуск (без записи)
)

$ErrorActionPreference = "Continue"

# Пути
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$ReportPath = Join-Path $BasePath "reports\SUMMARIZATION_REPORT.md"

# ----------------------------------------------------------------------------
# ФУНКЦИИ
# ----------------------------------------------------------------------------

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host $Message -ForegroundColor $Color
}

function Get-TokenCount {
    param([string]$Text)
    # Приблизительный подсчёт: 1 токен = 4 символа
    return [Math]::Floor($Text.Length / 4)
}

function Summarize-Message {
    param(
        [string]$Message,
        [int]$MaxLength = 100  # Максимум символов
    )
    
    # Простая суммаризация: первое предложение + ключевые слова
    $firstSentence = ($Message -split '[.!?]')[0]
    
    if ($firstSentence.Length -le $MaxLength) {
        return $firstSentence
    }
    
    return $firstSentence.Substring(0, $MaxLength) + "..."
}

function Extract-KeyFacts {
    param([string]$ChatHistory)
    
    $facts = @()
    
    # Поиск чисел (8 разделов, 350 строк, etc.)
    $numberPattern = '\d+\s+\w+'
    $numbers = [regex]::Matches($ChatHistory, $numberPattern)
    foreach ($match in $numbers) {
        if ($match.Value -match '(\d+)\s+(раздел|строк|файл|час|минут|токен)') {
            $facts += $match.Value
        }
    }
    
    # Поиск имён собственных (INDEX.md, PowerShell, etc.)
    $namePattern = '[A-Z][a-zA-Z0-9_-]+\.(md|ps1|json|js|ts|cs)'
    $names = [regex]::Matches($ChatHistory, $namePattern)
    foreach ($match in $names) {
        $facts += "Файл: $($match.Value)"
    }
    
    # Поиск решений (Решили:, Решение:, Вывод:)
    $decisionPattern = '(Решили|Решение|Вывод|Итог):\s*([^.]+)'
    $decisions = [regex]::Matches($ChatHistory, $decisionPattern)
    foreach ($match in $decisions) {
        $facts += "$($match.Groups[1].Value): $($match.Groups[2].Value)"
    }
    
    # Удаление дубликатов
    return $facts | Select-Object -Unique
}

function Invoke-ContextSummarization {
    param(
        [string]$ChatHistory,
        [double]$Threshold,
        [int]$MaxTokens,
        [int]$SummaryLength
    )
    
    # Подсчёт токенов
    $tokenCount = Get-TokenCount -Text $ChatHistory
    $maxThreshold = [Math]::Floor($MaxTokens * $Threshold)
    
    Write-Log "Токенов: $tokenCount / $MaxTokens (порог: $maxThreshold)" -Color "Cyan"
    
    # Проверка порога
    if ($tokenCount -le $maxThreshold) {
        Write-Log "ℹ️  Суммаризация не требуется (ниже порога)" -Color "Gray"
        return $null
    }
    
    Write-Log "⚠️  Превышен порог суммаризации!" -Color "Yellow"
    
    # Разбиение на сообщения (по заголовкам ##)
    $messages = $ChatHistory -split "\n(?=## )"
    Write-Log "Сообщений: $($messages.Count)" -Color "Gray"
    
    # Суммаризация каждого сообщения
    $summaries = @()
    foreach ($message in $messages) {
        if ($message.Trim().Length -gt 0) {
            $summary = Summarize-Message -Message $message -MaxLength 200
            $summaries += $summary
        }
    }
    
    # Объединение (ограничение по количеству предложений)
    $finalSummary = ($summaries | Select-Object -First $SummaryLength) -join "`n"
    
    # Выделение ключевых фактов
    $keyFacts = Extract-KeyFacts -ChatHistory $ChatHistory
    
    # Подсчёт сэкономленных токенов
    $summaryTokens = Get-TokenCount -Text $finalSummary
    $savedTokens = $tokenCount - $summaryTokens
    $savedPercent = [Math]::Round(($savedTokens / $tokenCount) * 100, 2)
    
    return @{
        Summary = $finalSummary
        KeyFacts = $keyFacts
        OriginalTokens = $tokenCount
        SavedTokens = $savedTokens
        SavedPercent = $savedPercent
        SummaryTokens = $summaryTokens
    }
}

function Generate-Report {
    param([object]$Result, [string]$SessionName)
    
    $report = @"
# 📊 ОТЧЁТ О СУММАРИЗАЦИИ КОНТЕКСТА

**Дата:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Сессия:** $SessionName

---

## 📊 СТАТИСТИКА

| Метрика | Значение |
|---------|----------|
| **Оригинал (токены)** | $($Result.OriginalTokens) |
| **Суммаризация (токены)** | $($Result.SummaryTokens) |
| **Сэкономлено** | $($Result.SavedTokens) ($($Result.SavedPercent)%) |

---

## 📝 СУММАРИЗАЦИЯ

``````
$($Result.Summary)
``````

---

## 🔑 КЛЮЧЕВЫЕ ФАКТЫ

$($Result.KeyFacts | ForEach-Object { "- $_" } | Out-String)

---

## 🔧 ПАРАМЕТРЫ

| Параметр | Значение |
|----------|----------|
| **Порог** | $($Threshold * 100)% |
| **Лимит токенов** | $MaxTokens |
| **Длина summary** | $SummaryLength предложений |

---

**Скрипт:** summarize-context.ps1
**Версия:** 1.0
**Дата:** 2026-03-04
"@

    return $report
}

# ----------------------------------------------------------------------------
# ОСНОВНАЯ ЛОГИКА
# ----------------------------------------------------------------------------

Write-Log ""
Write-Log "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Log "║         СУММАРИЗАЦИЯ КОНТЕКСТА СЕССИИ                    ║" -ForegroundColor Cyan
Write-Log "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Log ""
Write-Log "Параметры:" -ForegroundColor Yellow
Write-Log "  Путь: $SessionPath" -ForegroundColor Gray
Write-Log "  Порог: $($Threshold * 100)%" -ForegroundColor Gray
Write-Log "  Лимит токенов: $MaxTokens" -ForegroundColor Gray
Write-Log "  Длина summary: $SummaryLength предложений" -ForegroundColor Gray
Write-Log "  Сухой запуск: $(if ($DryRun) { 'Да' } else { 'Нет' })" -ForegroundColor Gray
Write-Log ""

# Поиск последней сессии
Write-Log "📊 Поиск последней сессии..." -Color "Cyan"

if (Test-Path $SessionPath) {
    $latestSession = Get-ChildItem $SessionPath | Sort-Object LastWriteTime -Descending | Select-Object -First 1
} else {
    Write-Log "❌ Папка сессий не найдена: $SessionPath" -Color "Red"
    exit 1
}

if (-not $latestSession) {
    Write-Log "❌ Сессии не найдены!" -ForegroundColor Red
    exit 1
}

Write-Log "✅ Сессия: $($latestSession.Name)" -ForegroundColor Green

# Чтение истории
$chatPath = Join-Path $latestSession.FullName "chat.md"

if (Test-Path $chatPath) {
    $chatHistory = Get-Content $chatPath -Raw -Encoding UTF8
    Write-Log "📄 Файл: $chatPath" -ForegroundColor Gray
    Write-Log "   Размер: $([Math]::Round((Get-Item $chatPath).Length / 1KB, 2)) KB" -ForegroundColor Gray
} else {
    Write-Log "❌ Файл chat.md не найден!" -ForegroundColor Red
    exit 1
}

# Суммаризация
Write-Log ""
Write-Log "🔄 Суммаризация..." -Color "Cyan"

$result = Invoke-ContextSummarization `
    -ChatHistory $chatHistory `
    -Threshold $Threshold `
    -MaxTokens $MaxTokens `
    -SummaryLength $SummaryLength

if ($result) {
    Write-Log "✅ Суммаризация выполнена!" -ForegroundColor Green
    Write-Log "   Сэкономлено токенов: $($result.SavedTokens) ($($result.SavedPercent)%)" -ForegroundColor Green
    
    if (-not $DryRun) {
        # Сохранение суммаризации
        $summaryPath = Join-Path $latestSession.FullName "summary.md"
        $result.Summary | Out-File -FilePath $summaryPath -Encoding UTF8 -NoBOM
        Write-Log "   Summary: $summaryPath" -ForegroundColor Gray
        
        # Сохранение ключевых фактов
        $factsPath = Join-Path $latestSession.FullName "key-facts.json"
        $result.KeyFacts | ConvertTo-Json | Out-File -FilePath $factsPath -Encoding UTF8 -NoBOM
        Write-Log "   Key Facts: $factsPath" -ForegroundColor Gray
        
        # Обновление .resume_marker.json
        $markerPath = Join-Path $BasePath ".resume_marker.json"
        if (Test-Path $markerPath) {
            $marker = Get-Content $markerPath | ConvertFrom-Json
            $marker.ContextSummary = $result.Summary
            $marker.ContextSummaryDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $marker | ConvertTo-Json | Set-Content $markerPath
            Write-Log "   Resume Marker: $markerPath" -ForegroundColor Gray
        }
        
        # Генерация отчёта
        $report = Generate-Report -Result $result -SessionName $latestSession.Name
        $report | Out-File -FilePath $ReportPath -Encoding UTF8 -NoBOM
        Write-Log "   Отчёт: $ReportPath" -ForegroundColor Gray
    } else {
        Write-Log "   (DryRun: файлы не записаны)" -ForegroundColor Gray
    }
    
    # Вывод summary
    Write-Log ""
    Write-Log "📝 СУММАРИЗАЦИЯ:" -ForegroundColor Cyan
    Write-Log "─────────────────────────────────────────────────────────"
    Write-Log $result.Summary -ForegroundColor White
    Write-Log "─────────────────────────────────────────────────────────"
    
    # Вывод ключевых фактов
    Write-Log ""
    Write-Log "🔑 КЛЮЧЕВЫЕ ФАКТЫ:" -ForegroundColor Cyan
    foreach ($fact in $result.KeyFacts) {
        Write-Log "  - $fact" -ForegroundColor White
    }
} else {
    Write-Log "ℹ️  Суммаризация не требуется (контекст не заполнен)" -ForegroundColor Gray
}

Write-Log ""
Write-Log "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Log "Следующий шаг: Проверить summary.md в папке сессии" -ForegroundColor White
Write-Log "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
