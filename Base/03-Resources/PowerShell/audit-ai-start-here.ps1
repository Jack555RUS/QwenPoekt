# ============================================================================
# AUDIT AI_START_HERE.MD
# Полный аудит главного файла с проверкой всех связей
# ============================================================================
# Использование: .\scripts\audit-ai-start-here.ps1 [-Path "путь"] [-WhatIf]
# ============================================================================

param(
    [string]$Path = "D:\QwenPoekt\Base",
    [switch]$WhatIf
)

$ErrorActionPreference = "Continue"
$AiStartHerePath = Join-Path $Path "AI_START_HERE.md"
$ReportPath = Join-Path $Path "reports\AI_START_HERE_AUDIT.md"

# ============================================================================
# ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
# ============================================================================

$AuditDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$Stats = @{
    TotalLinks = 0
    ValidLinks = 0
    BrokenLinks = 0
    MissingFiles = @()
    Sections = @()
    Version = ""
    LastUpdated = ""
}

$CriticalFiles = @(
    ".qwen\QWEN.md",
    "RULES_AND_TASKS.md",
    "NOTES.md",
    "ТЕКУЩАЯ_ЗАДАЧА.md",
    "README.md",
    "_docs\VS_CODE_SETUP_FOR_AI.md",
    "_docs\MCP_FILESYSTEM_SETUP.md",
    "_docs\BRIDGE_SETUP.md"
)

$ScriptFiles = @(
    "scripts\AUDIT_ALL.ps1",
    "scripts\organize-root.ps1",
    "scripts\safe-delete.ps1",
    "scripts\cleanup-root-mess.ps1"
)

# ============================================================================
# ФУНКЦИИ
# ============================================================================

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Extract-Links {
    param([string]$Content)
    
    $links = @()
    $pattern = '\[([^\]]+)\]\(([^\)]+)\)'
    
    $matches = [regex]::Matches($Content, $pattern)
    foreach ($match in $matches) {
        $links += @{
            Text = $match.Groups[1].Value
            Url = $match.Groups[2].Value
        }
    }
    
    return $links
}

function Extract-Sections {
    param([string]$Content)
    
    $sections = @()
    $pattern = '^##\s+(.+)$'
    
    $lines = $Content -split "`n"
    foreach ($line in $lines) {
        if ($line -match $pattern) {
            $sections += $matches[1].Trim()
        }
    }
    
    return $sections
}

function Test-FileExists {
    param([string]$RelativePath, [string]$BasePath)
    
    # Убрать якоря
    $path = $RelativePath.Split('#')[0]
    
    # Пропустить внешние ссылки
    if ($path -match '^https?://') {
        return $true
    }
    
    # Построить полный путь
    $fullPath = Join-Path $BasePath $path
    $fullPath = $fullPath.Replace('/', '\')
    
    return Test-Path $fullPath
}

function Extract-Version {
    param([string]$Content)
    
    if ($Content -match '\*\*Версия:\*\*\s*([\d.]+)') {
        return $matches[1]
    }
    return "Не указана"
}

function Extract-LastUpdated {
    param([string]$Content)
    
    if ($Content -match '\*\*Последнее обновление:\*\*\s*(.+)') {
        return $matches[1].Trim()
    }
    return "Не указано"
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

Write-Host ""
Write-Log "═══════════════════════════════════════════════════════════" -Color "Cyan"
Write-Log "  АУДИТ AI_START_HERE.MD" -Color "Yellow"
Write-Log "═══════════════════════════════════════════════════════════" -Color "Cyan"
Write-Host ""

# Проверка существования файла
Write-Log "1. Проверка файла..." -Color "Cyan"

if (!(Test-Path $AiStartHerePath)) {
    Write-Log "  ❌ AI_START_HERE.md не найден!" -Color "Red"
    exit 1
}

Write-Log "  ✅ AI_START_HERE.md найден" -Color "Green"

# Чтение содержимого
Write-Log "2. Чтение содержимого..." -Color "Cyan"

$content = Get-Content $AiStartHerePath -Raw -ErrorAction Stop
$Stats.Version = Extract-Version -Content $content
$Stats.LastUpdated = Extract-LastUpdated -Content $content
$Stats.Sections = Extract-Sections -Content $content

Write-Log "  Версия: $($Stats.Version)" -Color "White"
Write-Log "  Последнее обновление: $($Stats.LastUpdated)" -Color "White"
Write-Log "  Разделов: $($Stats.Sections.Count)" -Color "White"
Write-Host ""

# Извлечение ссылок
Write-Log "3. Анализ ссылок..." -Color "Cyan"

$links = Extract-Links -Content $content
$Stats.TotalLinks = $links.Count

Write-Log "  Найдено ссылок: $($Stats.TotalLinks)" -Color "White"
Write-Host ""

# Проверка ссылок
Write-Log "4. Проверка ссылок..." -Color "Cyan"

$validLinks = @()
$brokenLinks = @()

foreach ($link in $links) {
    $exists = Test-FileExists -RelativePath $link.Url -BasePath $Path
    
    if ($exists) {
        $validLinks += $link
    } else {
        $brokenLinks += $link
        $Stats.MissingFiles += $link.Url
    }
}

$Stats.ValidLinks = $validLinks.Count
$Stats.BrokenLinks = $brokenLinks.Count

Write-Log "  ✅ Рабочих: $($Stats.ValidLinks)" -Color "Green"
if ($brokenLinks.Count -gt 0) {
    Write-Log "  ❌ Битых: $($Stats.BrokenLinks)" -Color "Red"
}
Write-Host ""

# Проверка критичных файлов
Write-Log "5. Проверка критичных файлов..." -Color "Cyan"

$criticalStatus = @{}
foreach ($file in $CriticalFiles) {
    $fullPath = Join-Path $Path $file
    $exists = Test-Path $fullPath
    $criticalStatus[$file] = $exists
    
    if ($exists) {
        Write-Log "  ✅ $file" -Color "Green"
    } else {
        Write-Log "  ❌ $file (не найден)" -Color "Red"
    }
}
Write-Host ""

# Проверка скриптов
Write-Log "6. Проверка скриптов..." -Color "Cyan"

$scriptStatus = @{}
foreach ($file in $ScriptFiles) {
    $fullPath = Join-Path $Path $file
    $exists = Test-Path $fullPath
    $scriptStatus[$file] = $exists
    
    if ($exists) {
        Write-Log "  ✅ $file" -Color "Green"
    } else {
        Write-Log "  ❌ $file (не найден)" -Color "Red"
    }
}
Write-Host ""

# Генерация отчёта
Write-Log "7. Генерация отчёта..." -Color "Cyan"

$reportContent = @"
# 📊 АУДИТ AI_START_HERE.MD — $AuditDate

**Дата:** $AuditDate  
**Скрипт:** audit-ai-start-here.ps1  
**Путь:** $Path

---

## 📊 ОБЗОР

| Показатель | Значение |
|------------|----------|
| **Версия** | $($Stats.Version) |
| **Последнее обновление** | $($Stats.LastUpdated) |
| **Разделов** | $($Stats.Sections.Count) |
| **Ссылок всего** | $($Stats.TotalLinks) |
| **Рабочих ссылок** | $($Stats.ValidLinks) |
| **Битых ссылок** | $($Stats.BrokenLinks) |

---

## 📋 СТРУКТУРА (РАЗДЕЛЫ)

$($Stats.Sections | ForEach-Object { "### $_`n" })

---

## 🔗 ПРОВЕРКА ССЫЛОК

### ✅ Рабочие ($($validLinks.Count)):

$(foreach ($link in $validLinks | Select-Object -First 20) {
    "- [$($link.Text)]($($link.Url))"
})
$(if ($validLinks.Count -gt 20) { "`n... и ещё $($validLinks.Count - 20)" })

### ❌ Битые ($($brokenLinks.Count)):

$(if ($brokenLinks.Count -gt 0) {
"$(foreach ($link in $brokenLinks) {
    "- [$($link.Text)]($($link.Url)) — **ФАЙЛ НЕ НАЙДЕН**"
})"
} else {
"✅ Битых ссылок нет!"
})

---

## 📁 КРИТИЧНЫЕ ФАЙЛЫ

| Файл | Статус |
|------|--------|
$(foreach ($file in $CriticalFiles) {
    $status = if ($criticalStatus[$file]) { "✅" } else { "❌" }
    "| $file | $status |"
})

---

## 🛠️ СКРИПТЫ

| Скрипт | Статус |
|--------|--------|
$(foreach ($file in $ScriptFiles) {
    $status = if ($scriptStatus[$file]) { "✅" } else { "❌" }
    "| $file | $status |"
})

---

## ✅ РЕКОМЕНДАЦИИ

### Приоритет 1 (Критично):
$(if ($brokenLinks.Count -gt 0) {
"- [ ] Исправить $($brokenLinks.Count) битых ссылок в AI_START_HERE.md"
} else {
"- ✅ Все ссылки рабочие"
})

### Приоритет 2 (Важно):
$(if ($criticalStatus.Values -contains $false) {
"- [ ] Восстановить отсутствующие критичные файлы"
} else {
"- ✅ Все критичные файлы на месте"
})

### Приоритет 3 (Желательно):
"- [ ] Обновить версию в AI_START_HERE.md
- [ ] Актуализировать дату последнего обновления
- [ ] Добавить раздел о новой автоматизации"

---

## 🎯 СТАТУС

**Общая оценка:** $(if ($Stats.BrokenLinks -eq 0 -and $criticalStatus.Values -notcontains $false) { "✅ ОТЛИЧНО" } elseif ($Stats.BrokenLinks -le 5) { "🟡 ХОРОШО" } else { "❌ ТРЕБУЕТ ВНИМАНИЯ" })

---

**Сгенерировано:** $AuditDate
"@

$reportContent | Out-File -FilePath $ReportPath -Encoding UTF8

Write-Log "   Отчёт сохранён: $ReportPath" -Color "Green"
Write-Host ""

# ============================================================================
# ИТОГИ
# ============================================================================

Write-Host ""
Write-Log "═══════════════════════════════════════════════════════════" -Color "Cyan"
Write-Log "  ИТОГИ" -Color "Yellow"
Write-Log "═══════════════════════════════════════════════════════════" -Color "Cyan"
Write-Host ""

Write-Host "  Версия: $($Stats.Version)" -ForegroundColor White
Write-Host "  Разделов: $($Stats.Sections.Count)" -ForegroundColor White
Write-Host "  Ссылок: $($Stats.TotalLinks)" -ForegroundColor White
Write-Host "  ✅ Рабочих: $($Stats.ValidLinks)" -ForegroundColor Green
Write-Host "  ❌ Битых: $($Stats.BrokenLinks)" -ForegroundColor $(if ($Stats.BrokenLinks -gt 0) { "Red" } else { "Green" })
Write-Host ""

$criticalMissing = ($criticalStatus.Values -eq $false).Count
Write-Host "  Критичных файлов отсутствует: $criticalMissing" -ForegroundColor $(if ($criticalMissing -gt 0) { "Red" } else { "Green" })
Write-Host ""

$overallStatus = "✅ ОТЛИЧНО"
if ($Stats.BrokenLinks -gt 0 -or $criticalMissing -gt 0) {
    $overallStatus = "🟡 ТРЕБУЕТ ВНИМАНИЯ"
}
if ($Stats.BrokenLinks -gt 10) {
    $overallStatus = "❌ КРИТИЧНО"
}

Write-Host "  ОБЩАЯ ОЦЕНКА: $overallStatus" -ForegroundColor $(if ($overallStatus -eq "✅ ОТЛИЧНО") { "Green" } elseif ($overallStatus -eq "🟡 ТРЕБУЕТ ВНИМАНИЯ") { "Yellow" } else { "Red" })
Write-Host ""

if ($overallStatus -ne "✅ ОТЛИЧНО") {
    Write-Host "📁 См. отчёт: $ReportPath" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Нажмите любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
