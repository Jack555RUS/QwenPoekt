# ============================================================================
# CHECK RULE LINKS
# ============================================================================
# Назначение: Проверка перекрёстных ссылок в правилах
# Использование: .\scripts\check-rule-links.ps1
# ============================================================================

param(
    [string]$RulesPath = "D:\QwenPoekt\_TEST_ENV\Base\KNOWLEDGE_BASE",
    
    [string]$ReportPath = "D:\QwenPoekt\_TEST_ENV\reports\rule_links_report.md"
)

$ErrorActionPreference = "Continue"

$Stats = @{
    TotalFiles = 0
    TotalLinks = 0
    ValidLinks = 0
    BrokenLinks = 0
}

$BrokenLinks = @()

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

function Check-File-Links {
    param(
        [System.IO.FileInfo]$File,
        [ref]$BrokenLinksRef
    )
    
    $content = Get-Content $File.FullName -Raw
    $links = [regex]::Matches($content, '\[`[^\]]+`\]\(([^\)]+)\)')
    
    foreach ($link in $links) {
        $path = $link.Groups[1].Value
        
        # Пропускаем внешние ссылки
        if ($path -match '^https?://') {
            continue
        }
        
        $script:Stats.TotalLinks++
        
        # Проверяем путь
        $fullPath = Join-Path $File.DirectoryName $path
        
        # Нормализуем путь (убираем якоря)
        $fullPath = $fullPath.Split('#')[0]
        
        if (!(Test-Path-Safe -Path $fullPath)) {
            $script:Stats.BrokenLinks++
            $BrokenLinksRef.Value += "$($File.Name) → $path"
            Write-Warning-Log "  $($File.Name) → $path (не существует)"
        } else {
            $script:Stats.ValidLinks++
        }
    }
}

function Generate-Report {
    param(
        [hashtable]$Stats,
        [array]$BrokenLinks,
        [string]$ReportPath
    )
    
    $report = @"
# 📊 ОТЧЁТ ПРОВЕРКИ ССЫЛОК В ПРАВИЛАХ

**Дата проверки:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

---

## 📊 СТАТИСТИКА

| Метрика | Значение |
|---------|----------|
| **Всего файлов** | $($Stats.TotalFiles) |
| **Всего ссылок** | $($Stats.TotalLinks) |
| **Рабочие ссылки** | $($Stats.ValidLinks) |
| **Битые ссылки** | $($Stats.BrokenLinks) |
| **% рабочих** | $([math]::Round(($Stats.ValidLinks / $Stats.TotalLinks) * 100, 1))% |

---

## 🔍 НАЙДЕННЫЕ ПРОБЛЕМЫ

"@
    
    if ($BrokenLinks.Count -gt 0) {
        $report += @"

### Битые ссылки ($($BrokenLinks.Count))

"@
        foreach ($link in $BrokenLinks) {
            $report += "- ``````$link```````n"
        }
    } else {
        $report += "``````text`nБитых ссылок не найдено`n``````"
    }
    
    $report += @"

## 🎯 РЕКОМЕНДАЦИИ

"@
    
    if ($BrokenLinks.Count -gt 0) {
        $report += @"

### Приоритет 1 (Критично):

1. ⚠️ **Исправить $($BrokenLinks.Count) битых ссылок**
   - Проверить пути к файлам
   - Обновить относительные пути

"@
    } else {
        $report += @"

### Приоритет 1 (Критично):

``````text`nКритичных проблем не найдено`n``````

### Приоритет 2 (Важно):

``````text`nПредупреждений не найдено`n``````

### Приоритет 3 (Желательно):

``````text`nРекомендаций не найдено`n``````

"@
    }
    
    $report += @"

---

**Проверка завершена:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** check-rule-links.ps1
"@
    
    $report | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Success-Log "Отчёт сохранён: $ReportPath"
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ПРОВЕРКА ССЫЛОК В ПРАВИЛАХ ===" -Color "Yellow"
    Write-Log "Путь: $RulesPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Поиск файлов правил
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Поиск файлов правил..."
    
    $files = Get-ChildItem -Path $RulesPath -Recurse -Filter "*.md" -ErrorAction SilentlyContinue |
             Where-Object { $_.FullName -match "00_CORE|05_METHODOLOGY" }
    
    $Stats.TotalFiles = $files.Count
    
    Write-Log "  Найдено файлов: $($Stats.TotalFiles)"
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Проверка ссылок в каждом файле
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Проверка ссылок..."
    
    foreach ($file in $files) {
        Write-Log "  $($file.Name)..."
        Check-File-Links -File $file -BrokenLinksRef ([ref]$BrokenLinks)
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Генерация отчёта
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Генерация отчёта..."
    
    Generate-Report -Stats $Stats -BrokenLinks $BrokenLinks -ReportPath $ReportPath
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Финальный вывод
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Финальный вывод..."
    
    Write-Host ""
    Write-Success-Log "ПРОВЕРКА ЗАВЕРШЕНА!" -Color "Green"
    Write-Host ""
    Write-Host "Результаты:" -ForegroundColor "White"
    Write-Host "  Всего файлов: $($Stats.TotalFiles)" -ForegroundColor "White"
    Write-Host "  Всего ссылок: $($Stats.TotalLinks)" -ForegroundColor "White"
    Write-Host "  Рабочие ссылки: $($Stats.ValidLinks) ✅" -ForegroundColor "Green"
    Write-Host "  Битые ссылки: $($Stats.BrokenLinks) ❌" -ForegroundColor "Red"
    Write-Host "  % рабочих: $([math]::Round(($Stats.ValidLinks / $Stats.TotalLinks) * 100, 1))%" -ForegroundColor $(if ($Stats.BrokenLinks -eq 0) { "Green" } else { "Yellow" })
    Write-Host ""
    Write-Host "Отчёт: $ReportPath" -ForegroundColor "Cyan"
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
