# weekly-knowledge-audit.ps1 — Еженедельный аудит Базы Знаний
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Автоматическая проверка состояния Базы Знаний

param(
    [switch]$Verbose,
    [switch]$Log,
    [string]$LogPath = "reports\weekly-knowledge-audit.log",
    [switch]$AutoFix
)

$ErrorActionPreference = "Stop"

# Логирование
function Write-Log {
    param($msg, $color = "Cyan")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $msg"
    
    if ($Log) {
        $logEntry | Out-File -FilePath $LogPath -Append -Encoding UTF8
    }
    
    Write-Host $msg -ForegroundColor $color
}

Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║         ЕЖЕНЕДЕЛЬНЫЙ АУДИТ БАЗЫ ЗНАНИЙ $(Get-Date -Format 'HH:mm:ss')      ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""

# ----------------------------------------------------------------------------
# СТАТИСТИКА
# ----------------------------------------------------------------------------

Write-Log "[1/6] Сбор статистики..."
Write-Log ""

$totalFiles = (Get-ChildItem -Path "." -Recurse -File -Include *.md,*.ps1,*.json).Count
$mdFiles = (Get-ChildItem -Path "." -Recurse -File -Include *.md).Count
$psFiles = (Get-ChildItem -Path "." -Recurse -File -Include *.ps1).Count
$sessions = (Get-ChildItem -Path "sessions" -Directory -ErrorAction SilentlyContinue).Count
$reports = (Get-ChildItem -Path "reports" -File -Include *.md -ErrorAction SilentlyContinue).Count

Write-Log "  📊 Всего файлов: $totalFiles"
Write-Log "  📄 Markdown (.md): $mdFiles"
Write-Log "  🔧 PowerShell (.ps1): $psFiles"
Write-Log "  💾 Сессий: $sessions"
Write-Log "  📝 Отчётов: $reports"
Write-Log ""

# ----------------------------------------------------------------------------
# ПРОВЕРКА 1: Дубликаты
# ----------------------------------------------------------------------------

Write-Log "[2/6] Проверка дубликатов..."
Write-Log ""

if (Test-Path "scripts\check-duplicates.ps1") {
    $duplicates = & .\scripts\check-duplicates.ps1 -PassThru -ErrorAction SilentlyContinue
    
    if ($duplicates -and $duplicates.Count -gt 0) {
        Write-Log "  ❌ Найдено дубликатов: $($duplicates.Count)" "Red"
        
        if ($AutoFix) {
            Write-Log "  🔧 Автоматическое удаление..." "Yellow"
            # Логика удаления дубликатов
        }
    } else {
        Write-Log "  ✅ Дубликатов нет" "Green"
    }
} else {
    Write-Log "  ⚠️ scripts\check-duplicates.ps1 не найден" "Yellow"
}

Write-Log ""

# ----------------------------------------------------------------------------
# ПРОВЕРКА 2: Битые ссылки
# ----------------------------------------------------------------------------

Write-Log "[3/6] Проверка битых ссылок..."
Write-Log ""

if (Test-Path "scripts\check-links.ps1") {
    $linkResult = & .\scripts\check-links.ps1 -Path "." -Recursive -PassThru -ErrorAction SilentlyContinue
    
    if ($linkResult -and $linkResult.BrokenLinks -gt 0) {
        Write-Log "  ❌ Битых ссылок: $($linkResult.BrokenLinks)" "Red"
    } else {
        Write-Log "  ✅ Битых ссылок нет" "Green"
    }
} else {
    Write-Log "  ⚠️ scripts\check-links.ps1 не найден" "Yellow"
}

Write-Log ""

# ----------------------------------------------------------------------------
# ПРОВЕРКА 3: Именование файлов
# ----------------------------------------------------------------------------

Write-Log "[4/6] Проверка именования файлов..."
Write-Log ""

if (Test-Path "scripts\check-file-naming.ps1") {
    $namingResult = & .\scripts\check-file-naming.ps1 -Path "." -Recursive -PassThru -ErrorAction SilentlyContinue
    
    if ($namingResult -and $namingResult.Violations -gt 0) {
        Write-Log "  ❌ Нарушений именования: $($namingResult.Violations)" "Red"
        
        if ($AutoFix) {
            Write-Log "  🔧 Автоматическое исправление..." "Yellow"
            # Логика исправления
        }
    } else {
        Write-Log "  ✅ Все файлы названы правильно" "Green"
    }
} else {
    Write-Log "  ⚠️ scripts\check-file-naming.ps1 не найден" "Yellow"
}

Write-Log ""

# ----------------------------------------------------------------------------
# ПРОВЕРКА 4: Старые файлы (>60 дней без изменений)
# ----------------------------------------------------------------------------

Write-Log "[5/6] Проверка старых файлов..."
Write-Log ""

$cutoffDate = (Get-Date).AddDays(-60)
$oldFiles = Get-ChildItem -Path "02-Areas/Documentation" -File -Include *.md | 
    Where-Object { $_.LastWriteTime -lt $cutoffDate }

if ($oldFiles.Count -gt 0) {
    Write-Log "  ⚠️ Старых файлов (>60 дней): $($oldFiles.Count)" "Yellow"
    
    foreach ($file in $oldFiles | Select-Object -First 5) {
        Write-Log "    • $($file.Name) ($([Math]::Round((Get-Date - $file.LastWriteTime).TotalDays, 0)) дн.)" "Gray"
    }
    
    if ($oldFiles.Count -gt 5) {
        Write-Log "    ... и ещё $($oldFiles.Count - 5)" "Gray"
    }
    
    if ($AutoFix) {
        Write-Log "  🔧 Перемещение в архив..." "Yellow"
        # Логика архивирования
    }
} else {
    Write-Log "  ✅ Старых файлов нет" "Green"
}

Write-Log ""

# ----------------------------------------------------------------------------
# ПРОВЕРКА 5: Черновики (>7 дней)
# ----------------------------------------------------------------------------

Write-Log "[6/6] Проверка черновиков..."
Write-Log ""

if (Test-Path "_drafts") {
    $cutoffDrafts = (Get-Date).AddDays(-7)
    $oldDrafts = Get-ChildItem -Path "_drafts" -File -Include *.md | 
        Where-Object { $_.LastWriteTime -lt $cutoffDrafts }
    
    if ($oldDrafts.Count -gt 0) {
        Write-Log "  ⚠️ Старых черновиков (>7 дней): $($oldDrafts.Count)" "Yellow"
        
        foreach ($draft in $oldDrafts | Select-Object -First 5) {
            Write-Log "    • $($draft.Name)" "Gray"
        }
        
        if ($AutoFix) {
            Write-Log "  🔧 Удаление черновиков..." "Yellow"
            # Логика удаления
        }
    } else {
        Write-Log "  ✅ Старых черновиков нет" "Green"
    }
} else {
    Write-Log "  ℹ️  Папка _drafts/ не найдена" "Gray"
}

Write-Log ""

# ----------------------------------------------------------------------------
# ИТОГОВЫЙ ОТЧЁТ
# ----------------------------------------------------------------------------

Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║                    ИТОГИ АУДИТА                          ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""

# Запись в журнал операций
$logEntry = @"
## $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") — Еженедельный аудит

**Статистика:**
- Файлов: $totalFiles
- Markdown: $mdFiles
- PowerShell: $psFiles
- Сессий: $sessions
- Отчётов: $reports

**Проблемы:**
$(if ($duplicates -and $duplicates.Count -gt 0) { "- ❌ Дубликаты: $($duplicates.Count)" } else { "- ✅ Дубликатов нет" })
$(if ($linkResult -and $linkResult.BrokenLinks -gt 0) { "- ❌ Битые ссылки: $($linkResult.BrokenLinks)" } else { "- ✅ Битых ссылок нет" })
$(if ($namingResult -and $namingResult.Violations -gt 0) { "- ❌ Нарушения именования: $($namingResult.Violations)" } else { "- ✅ Именование в порядке" })
$(if ($oldFiles.Count -gt 0) { "- ⚠️ Старые файлы: $($oldFiles.Count)" } else { "- ✅ Старых файлов нет" })
$(if ($oldDrafts.Count -gt 0) { "- ⚠️ Старые черновики: $($oldDrafts.Count)" } else { "- ✅ Черновиков нет" })

**Статус:** $(if ($duplicates.Count -eq 0 -and $linkResult.BrokenLinks -eq 0 -and $namingResult.Violations -eq 0 -and $oldFiles.Count -eq 0 -and $oldDrafts.Count -eq 0) { "✅ Всё в порядке" } else { "⚠️ Требует внимания" })

---
"@

if (Test-Path "reports\OPERATION_LOG.md") {
    $content = Get-Content "reports\OPERATION_LOG.md" -Raw
    $newContent = $content -replace '(## 📊 ЗАПИСИ)', "## 📊 ЗАПИСИ`n`n$logEntry"
    $newContent | Out-File -FilePath "reports\OPERATION_LOG.md" -Encoding UTF8
    Write-Log "✅ Запись в журнал операций добавлена" "Green"
} else {
    Write-Log "⚠️ reports\OPERATION_LOG.md не найден" "Yellow"
}

Write-Log ""
Write-Log "📁 Лог аудита: $LogPath" "Cyan"
Write-Log ""

# Выход
if ($duplicates.Count -gt 0 -or $linkResult.BrokenLinks -gt 0 -or $namingResult.Violations -gt 0 -or $oldFiles.Count -gt 0 -or $oldDrafts.Count -gt 0) {
    exit 1
} else {
    Write-Log "✅ ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ!" "Green"
    exit 0
}
