# classify-broken-links.ps1 — Классификация битых ссылок
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Анализ и категоризация битых ссылок

param(
    [string]$ReportPath = "reports\LINK_CHECK_REPORT.md"
)

$ErrorActionPreference = "Stop"

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$fullReportPath = Join-Path $BasePath $ReportPath
$outputPath = Join-Path $BasePath "reports\BROKEN_LINKS_CLASSIFICATION.md"

# ----------------------------------------------------------------------------
# АНАЛИЗ
# ----------------------------------------------------------------------------

Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         КЛАССИФИКАЦИЯ БИТЫХ ССЫЛОК $(Get-Date -Format 'HH:mm:ss')          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$content = Get-Content $fullReportPath -Raw

# Извлечение битых ссылок
$pattern = '(?ms)### 📄 ([^\n]+).*?\| Строка \| Текст \| Ссылка \|(.*?)(?=### 📄|$)'
$matches = [regex]::Matches($content, $pattern)

$files = @{}
$totalBroken = 0

foreach ($match in $matches) {
    $fileName = $match.Groups[1].Value.Trim()
    $linksText = $match.Groups[2].Value.Trim()
    
    if (-not $linksText) { continue }
    
    $links = @()
    $linkLines = $linksText -split "`n" | Where-Object { $_ -match '\|.*\|.*\|.*\|' -and $_ -notmatch '\|--------\|' }
    
    foreach ($line in $linkLines) {
        $parts = $line -split '\|' | Where-Object { $_.Trim() }
        if ($parts.Count -ge 3) {
            $lineNum = $parts[0].Trim()
            $text = $parts[1].Trim()
            $url = $parts[2].Trim()
            
            $links += @{
                Line = $lineNum
                Text = $text
                Url = $url
            }
        }
    }
    
    if ($links.Count -gt 0) {
        $files[$fileName] = $links
        $totalBroken += $links.Count
    }
}

Write-Host "📊 Найдено файлов с битыми ссылками: $($files.Count)" -ForegroundColor Cyan
Write-Host "📊 Всего битых ссылок: $totalBroken" -ForegroundColor Cyan
Write-Host ""

# ----------------------------------------------------------------------------
# КЛАССИФИКАЦИЯ
# ----------------------------------------------------------------------------

$categories = @{
    Critical = @{ Files = @(); Count = 0; Description = "Критичная документация (Base/, .qwen/)" }
    Documentation = @{ Files = @(); Count = 0; Description = "Документация (02-Areas/, scripts/)" }
    Sessions = @{ Files = @(); Count = 0; Description = "История сессий (sessions/chat.md)" }
    Knowledge = @{ Files = @(); Count = 0; Description = "База знаний (KNOWLEDGE_BASE/)" }
    Templates = @{ Files = @(); Count = 0; Description = "Шаблоны (_drafts/, _templates/)" }
    Other = @{ Files = @(); Count = 0; Description = "Остальное" }
}

foreach ($fileName in $files.Keys) {
    $category = "Other"
    
    if ($fileName -match '^\.qwen\\') {
        $category = "Critical"
    } elseif ($fileName -match '^(01-core|02-workflow|03-git|04-safety|05-commands|06-resume|07-session|08-mcp)\.md$') {
        $category = "Critical"
    } elseif ($fileName -match '^AGENTS\.md$' -or $fileName -match '^AI_START_HERE\.md$' -or $fileName -match '^QWEN\.md$') {
        $category = "Critical"
    } elseif ($fileName -match '^02-Areas\\' -or $fileName -match '^scripts\\') {
        $category = "Documentation"
    } elseif ($fileName -match '^sessions\\' -or $fileName -match '^chat\.md$') {
        $category = "Sessions"
    } elseif ($fileName -match '^KNOWLEDGE_BASE\\') {
        $category = "Knowledge"
    } elseif ($fileName -match '^_drafts\\' -or $fileName -match '^_templates\\') {
        $category = "Templates"
    }
    
    $categories[$category].Files += $fileName
    $categories[$category].Count += $files[$fileName].Count
}

# ----------------------------------------------------------------------------
# ОТЧЁТ
# ----------------------------------------------------------------------------

$report = @"
# 📊 КЛАССИФИКАЦИЯ БИТЫХ ССЫЛОК

**Дата:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Источник:** LINK_CHECK_REPORT.md

---

## 📈 ОБЩАЯ СТАТИСТИКА

| Категория | Файлов | Ссылок | % | Описание |
|-----------|--------|--------|---|----------|
"@

foreach ($catName in $categories.Keys) {
    $cat = $categories[$catName]
    $percent = [Math]::Round($cat.Count / $totalBroken * 100, 2)
    $icon = switch ($catName) {
        "Critical" { "🔴" }
        "Documentation" { "🟡" }
        "Sessions" { "🔵" }
        "Knowledge" { "🟢" }
        "Templates" { "🟣" }
        "Other" { "⚪" }
    }
    
    $report += "| $icon **$catName** | $($cat.Files.Count) | $($cat.Count) | $percent% | $($cat.Description) |`n"
}

$report += @"

---

## 🔴 КРИТИЧНЫЕ (исправить в первую очередь)

"@

if ($categories.Critical.Files.Count -gt 0) {
    foreach ($fileName in $categories.Critical.Files) {
        $report += "### 📄 $fileName`n`n"
        $report += "| Строка | Текст | Ссылка |`n"
        $report += "|--------|-------|--------|`n"
        
        foreach ($link in $files[$fileName]) {
            $report += "| $($link.Line) | $($link.Text) | ``$($link.Url)`` |`n"
        }
        
        $report += "`n"
    }
} else {
    $report += "**Нет критичных файлов!** ✅`n"
}

$report += @"

---

## 🟡 ДОКУМЕНТАЦИЯ (исправить во вторую очередь)

"@

if ($categories.Documentation.Files.Count -gt 0) {
    foreach ($fileName in $categories.Documentation.Files) {
        $report += "### 📄 $fileName`n`n"
        $report += "| Строка | Текст | Ссылка |`n"
        $report += "|--------|-------|--------|`n"
        
        foreach ($link in $files[$fileName]) {
            $report += "| $($link.Line) | $($link.Text) | ``$($link.Url)`` |`n"
        }
        
        $report += "`n"
    }
}

$report += @"

---

## 🔵 ИСТОРИЯ СЕССИЙ (не трогать / архив)

**Файлы:** $($categories.Sessions.Files.Count)
**Ссылок:** $($categories.Sessions.Count)

"@

if ($categories.Sessions.Files.Count -gt 0) {
    $report += "**Рекомендация:** Не исправлять, это история диалогов.`n`n"
    
    foreach ($fileName in $categories.Sessions.Files | Select-Object -First 10) {
        $report += "- $fileName`n"
    }
    
    if ($categories.Sessions.Files.Count -gt 10) {
        $report += "`n_... и ещё $($categories.Sessions.Files.Count - 10) файлов_`n"
    }
}

$report += @"

---

## 🟢 БАЗА ЗНАНИЙ (исправить потом)

**Файлов:** $($categories.Knowledge.Files.Count)
**Ссылок:** $($categories.Knowledge.Count)

---

## 🟣 ШАБЛОНЫ (исправить потом)

**Файлов:** $($categories.Templates.Files.Count)
**Ссылок:** $($categories.Templates.Count)

---

## ⚪ ОСТАЛЬНОЕ

**Файлов:** $($categories.Other.Files.Count)
**Ссылок:** $($categories.Other.Count)

---

## 🎯 РЕКОМЕНДАЦИИ

### Приоритет 1 (🔴 Критичные):

**Файлов:** $($categories.Critical.Files.Count)
**Ссылок:** $($categories.Critical.Count)

**План:**
1. Исправить ссылки на существующие файлы
2. Удалить ссылки на несуществующие
3. Закоммитить

---

### Приоритет 2 (🟡 Документация):

**Файлов:** $($categories.Documentation.Files.Count)
**Ссылок:** $($categories.Documentation.Count)

**План:**
1. Проверить актуальность ссылок
2. Исправить или удалить
3. Закоммитить

---

### Приоритет 3 (🔵 Сессии):

**Файлов:** $($categories.Sessions.Files.Count)
**Ссылок:** $($categories.Sessions.Count)

**Рекомендация:** **НЕ ТРОГАТЬ**

Это история диалогов. Ссылки битые, потому что:
- Файлы перемещались
- Контекст сессии устарел

**Если нужно:** Архивировать сессии в _LOCAL_ARCHIVE/

---

### Приоритет 4 (🟢🟣🟡 Остальное):

**Файлов:** $($($categories.Knowledge.Files.Count + $categories.Templates.Files.Count + $categories.Other.Files.Count))
**Ссылок:** $($($categories.Knowledge.Count + $categories.Templates.Count + $categories.Other.Count))

**План:** Исправлять по мере необходимости

---

## 📊 ИТОГИ

| Действие | Файлов | Ссылок | Время |
|----------|--------|--------|-------|
| **Приоритет 1** | $($categories.Critical.Files.Count) | $($categories.Critical.Count) | ~30 мин |
| **Приоритет 2** | $($categories.Documentation.Files.Count) | $($categories.Documentation.Count) | ~45 мин |
| **Приоритет 3** | $($categories.Sessions.Files.Count) | $($categories.Sessions.Count) | 0 мин (не трогать) |
| **Приоритет 4** | $($($categories.Knowledge.Files.Count + $categories.Templates.Files.Count + $categories.Other.Files.Count)) | $($($categories.Knowledge.Count + $categories.Templates.Count + $categories.Other.Count)) | ~1 час |
| **ВСЕГО** | $($files.Count) | $totalBroken | ~2.5 часа |

---

**Отчёт сгенерирован:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** classify-broken-links.ps1
"@

$report | Out-File -FilePath $outputPath -Encoding UTF8

Write-Host "✅ Отчёт сохранён: $outputPath" -ForegroundColor Green
Write-Host ""

# Вывод статистики
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    СТАТИСТИКА                            ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

foreach ($catName in $categories.Keys) {
    $cat = $categories[$catName]
    $icon = switch ($catName) {
        "Critical" { "🔴" }
        "Documentation" { "🟡" }
        "Sessions" { "🔵" }
        "Knowledge" { "🟢" }
        "Templates" { "🟣" }
        "Other" { "⚪" }
    }
    
    Write-Host "$icon $catName`: $($cat.Count) ссылок в $($cat.Files.Count) файлах" -ForegroundColor $(switch ($catName) {
        "Critical" { "Red" }
        "Documentation" { "Yellow" }
        "Sessions" { "Blue" }
        "Knowledge" { "Green" }
        "Templates" { "Magenta" }
        "Other" { "Gray" }
    })
}

Write-Host ""
Write-Host "📌 Подробный отчёт: $outputPath" -ForegroundColor Cyan
