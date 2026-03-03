# ============================================================================
# KNOWLEDGE BASE AUDIT
# ============================================================================
# Назначение: Полный аудит Базы Знаний (дубликаты, битые файлы, мусор)
# Использование: .\scripts\kb-audit.ps1 [-Path "путь"] [-OutputPath "путь"]
# ============================================================================

param(
    [string]$Path = "D:\QwenPoekt\Base\KNOWLEDGE_BASE",
    
    [string]$OutputPath = "D:\QwenPoekt\Base\reports\KB_AUDIT_REPORT.md",
    
    [string]$LogPath = "D:\QwenPoekt\Base\reports\OPERATION_LOG.md",
    
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"

# ============================================================================
# ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
# ============================================================================

$AuditDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$AuditId = Get-Date -Format "yyyyMMdd_HHmmss"

$Stats = @{
    TotalFiles = 0
    TotalSize = 0
    ZeroSizeFiles = @()
    TempFiles = @()
    Duplicates = @{}
    BrokenFiles = @()
    NamingViolations = @()
    OldVersions = @()
    StructureViolations = @()
}

$Hashes = @{}

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

function Get-File-Hash-Safe {
    param([string]$FilePath)
    try {
        return (Get-FileHash -Path $FilePath -Algorithm SHA256 -ErrorAction Stop).Hash
    } catch {
        return $null
    }
}

function Test-File-Readable {
    param([string]$FilePath)
    try {
        $ext = [System.IO.Path]::GetExtension($FilePath).ToLower()
        
        if ($ext -eq ".md" -or $ext -eq ".txt" -or $ext -eq ".ps1") {
            $content = Get-Content $FilePath -Raw -ErrorAction Stop
            return $true
        }
        elseif ($ext -eq ".json") {
            $content = Get-Content $FilePath -Raw -ErrorAction Stop
            $null = $content | ConvertFrom-Json -ErrorAction Stop
            return $true
        }
        elseif ($ext -eq ".yaml" -or $ext -eq ".yml") {
            $content = Get-Content $FilePath -Raw -ErrorAction Stop
            return $true
        }
        else {
            # Для остальных файлов проверяем только чтение
            $null = [System.IO.File]::OpenRead($FilePath)
            return $true
        }
    } catch {
        return $false
    }
}

function Test-Naming-Compliance {
    param([string]$FileName)
    
    $violations = @()
    
    # Проверка на пробелы
    if ($FileName -match " ") {
        $violations += "Пробелы в имени"
    }
    
    # Проверка на кириллицу
    if ($FileName -match "[а-яА-ЯёЁ]") {
        $violations += "Кириллица в имени"
    }
    
    # Проверка на спецсимволы
    if ($FileName -match '[!"№;%:?*()\[\]{}$&|<>\\]') {
        $violations += "Спецсимволы в имени"
    }
    
    # Проверка на начало с дефиса
    if ($FileName -match "^-") {
        $violations += "Начинается с дефиса"
    }
    
    # Проверка на верхний регистр (рекомендация)
    if ($FileName -match "[A-Z]" -and $FileName -notmatch "^[A-Z0-9_-]+\.[A-Z0-9]+$") {
        # Не считаем нарушением, если это не полное CAPS
        # $violations += "Верхний регистр (рекомендуется lower case)"
    }
    
    return $violations
}

function Find-Duplicates {
    param([string]$RootPath)
    
    Write-Log "Поиск дубликатов..."
    
    $files = Get-ChildItem -Path $RootPath -Recurse -File -ErrorAction SilentlyContinue
    
    $progress = 0
    $total = $files.Count
    
    foreach ($file in $files) {
        $progress++
        if ($progress % 100 -eq 0) {
            Write-Log "  Обработано $progress из $total файлов..." -Color "Gray"
        }
        
        try {
            $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
            
            if ($hash) {
                if ($Hashes.ContainsKey($hash)) {
                    $Hashes[$hash] += $file.FullName
                } else {
                    $Hashes[$hash] = @($file.FullName)
                }
            }
        } catch {
            # Не удалось вычислить хэш
        }
    }
    
    # Фильтруем только дубликаты
    $duplicates = @{}
    foreach ($hash in $Hashes.Keys) {
        if ($Hashes[$hash].Count -gt 1) {
            $duplicates[$hash] = $Hashes[$hash]
        }
    }
    
    return $duplicates
}

function Find-Zero-Size-Files {
    param([string]$RootPath)
    
    Write-Log "Поиск файлов нулевого размера..."
    
    return Get-ChildItem -Path $RootPath -Recurse -File -ErrorAction SilentlyContinue |
           Where-Object { $_.Length -eq 0 } |
           Select-Object -ExpandProperty FullName
}

function Find-Temp-Files {
    param([string]$RootPath)
    
    Write-Log "Поиск временных файлов..."
    
    $extensions = @(".tmp", ".bak", ".DS_Store", ".swp", ".swo", "~*", "*.log")
    $tempFiles = @()
    
    foreach ($ext in $extensions) {
        $tempFiles += Get-ChildItem -Path $RootPath -Recurse -File -Filter $ext -ErrorAction SilentlyContinue |
                      Select-Object -ExpandProperty FullName
    }
    
    return $tempFiles
}

function Find-Broken-Files {
    param([string]$RootPath)
    
    Write-Log "Поиск битых файлов..."
    
    $files = Get-ChildItem -Path $RootPath -Recurse -File -ErrorAction SilentlyContinue
    $broken = @()
    
    $progress = 0
    $total = $files.Count
    
    foreach ($file in $files) {
        $progress++
        if ($progress % 100 -eq 0) {
            Write-Log "  Проверено $progress из $total файлов..." -Color "Gray"
        }
        
        if (!(Test-File-Readable -FilePath $file.FullName)) {
            $broken += $file.FullName
        }
    }
    
    return $broken
}

function Find-Naming-Violations {
    param([string]$RootPath)
    
    Write-Log "Проверка именования файлов..."
    
    $files = Get-ChildItem -Path $RootPath -Recurse -File -ErrorAction SilentlyContinue
    $violations = @()
    
    foreach ($file in $files) {
        $fileName = $file.Name
        $fileViolations = Test-Naming-Compliance -FileName $fileName
        
        if ($fileViolations.Count -gt 0) {
            $violations += @{
                Path = $file.FullName
                Violations = $fileViolations
            }
        }
    }
    
    return $violations
}

function Find-Old-Versions {
    param([string]$RootPath)
    
    Write-Log "Поиск устаревших версий..."
    
    # Паттерны для версий: v1, v2, _old, _backup, даты
    $patterns = @(
        ".*_v\d+\..*",
        ".*_old\..*",
        ".*_backup\..*",
        ".*_\d{4}-\d{2}-\d{2}.*",
        ".*\.bak\..*"
    )
    
    $oldVersions = @()
    
    foreach ($pattern in $patterns) {
        $oldVersions += Get-ChildItem -Path $RootPath -Recurse -File -ErrorAction SilentlyContinue |
                        Where-Object { $_.Name -match $pattern } |
                        Select-Object -ExpandProperty FullName
    }
    
    return $oldVersions | Select-Object -Unique
}

function Generate-Report {
    param(
        [hashtable]$Stats,
        [string]$OutputPath
    )
    
    Write-Log "Генерация отчёта..."
    
    $report = @"
# Отчёт аудита Базы Знаний

**Дата аудита:** $AuditDate
**ID аудита:** $AuditId
**Путь к базе:** $Path

---

## 📊 Статистика

| Метрика | Значение |
|---------|----------|
| **Всего файлов** | $($Stats.TotalFiles) |
| **Общий размер** | $([math]::Round($Stats.TotalSize / 1MB, 2)) MB |
| **Файлов нулевого размера** | $($Stats.ZeroSizeFiles.Count) |
| **Временных файлов** | $($Stats.TempFiles.Count) |
| **Групп дубликатов** | $($Stats.Duplicates.Count) |
| **Битых файлов** | $($Stats.BrokenFiles.Count) |
| **Нарушений именования** | $($Stats.NamingViolations.Count) |
| **Устаревших версий** | $($Stats.OldVersions.Count) |

---

## 🔍 Найденные проблемы

"@
    
    # Дубликаты
    if ($Stats.Duplicates.Count -gt 0) {
        $report += @"

### 1. Дубликаты ($($Stats.Duplicates.Count) групп)

"@
        $groupNum = 0
        foreach ($hash in $Stats.Duplicates.Keys) {
            $groupNum++
            $report += @"

**Группа #$groupNum** (Хэш: $($hash.Substring(0, 16))...):
$($Stats.Duplicates[$hash] | ForEach-Object { "- ``````$_``````" })

"@
        }
    }
    
    # Битые файлы
    if ($Stats.BrokenFiles.Count -gt 0) {
        $report += @"

### 2. Битые файлы ($($Stats.BrokenFiles.Count))

$($Stats.BrokenFiles | Select-Object -First 20 | ForEach-Object { "- ``````$_``````" })
"@
        if ($Stats.BrokenFiles.Count -gt 20) {
            $report += "`n... и ещё $($Stats.BrokenFiles.Count - 20) файлов"
        }
        $report += "`n`n"
    }

    # Нарушения именования
    if ($Stats.NamingViolations.Count -gt 0) {
        $report += @"

### 3. Нарушения именования ($($Stats.NamingViolations.Count))

"@
        $Stats.NamingViolations | Select-Object -First 20 | ForEach-Object {
            $report += "- ``````$($_.Path)``````  `n  Нарушения: $($_.Violations -join ', ')`n"
        }
        if ($Stats.NamingViolations.Count -gt 20) {
            $report += "`n... и ещё $($Stats.NamingViolations.Count - 20) файлов"
        }
        $report += "`n`n"
    }

    # Файлы нулевого размера
    if ($Stats.ZeroSizeFiles.Count -gt 0) {
        $report += @"

### 4. Файлы нулевого размера ($($Stats.ZeroSizeFiles.Count))

$($Stats.ZeroSizeFiles | Select-Object -First 20 | ForEach-Object { "- ``````$_``````" })
"@
        if ($Stats.ZeroSizeFiles.Count -gt 20) {
            $report += "`n... и ещё $($Stats.ZeroSizeFiles.Count - 20) файлов"
        }
        $report += "`n`n"
    }

    # Временные файлы
    if ($Stats.TempFiles.Count -gt 0) {
        $report += @"

### 5. Временные файлы ($($Stats.TempFiles.Count))

$($Stats.TempFiles | Select-Object -First 20 | ForEach-Object { "- ``````$_``````" })
"@
        if ($Stats.TempFiles.Count -gt 20) {
            $report += "`n... и ещё $($Stats.TempFiles.Count - 20) файлов"
        }
        $report += "`n`n"
    }

    # Устаревшие версии
    if ($Stats.OldVersions.Count -gt 0) {
        $report += @"

### 6. Устаревшие версии ($($Stats.OldVersions.Count))

$($Stats.OldVersions | Select-Object -First 20 | ForEach-Object { "- ``````$_``````" })
"@
        if ($Stats.OldVersions.Count -gt 20) {
            $report += "`n... и ещё $($Stats.OldVersions.Count - 20) файлов"
        }
        $report += "`n`n"
    }
    
    # Рекомендации
    $report += @"

---

## 💡 Рекомендации

1. **Удалить файлы нулевого размера** — не несут полезной информации.
2. **Удалить временные файлы** — остатки от редакторов, системные файлы.
3. **Обработать дубликаты** — оставить по одной копии, остальные удалить или переместить в archive.
4. **Исправить нарушения именования** — переименовать файлы согласно правилам (латиница, lower case, _ вместо пробелов).
5. **Проверить битые файлы** — попытаться восстановить или удалить.
6. **Архивировать устаревшие версии** — переместить в ``````04_ARCHIVES/``````.

---

## 📋 План очистки

```powershell
# 1. Создать бэкап
.\scripts\pre-operation-backup.ps1 -OperationType "KB_Audit_$AuditId"

# 2. Запустить очистку
.\scripts\kb-cleanup.ps1 -AuditId "$AuditId" -Confirm

# 3. Проверить результат
.\scripts\kb-audit.ps1 -Path "$Path"

# 4. Закоммитить изменения
git add .
git commit -m "Cleanup: аудит БЗ $AuditId"
```

---

**Аудит завершён:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** kb-audit.ps1
"@
    
    $report | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Success-Log "Отчёт сохранён: $OutputPath"
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== АУДИТ БАЗЫ ЗНАНИЙ ===" -Color "Yellow"
    Write-Log "Путь: $Path"
    Write-Log "Дата: $AuditDate"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Проверка пути
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Проверка пути..."
    
    if (!(Test-Path $Path)) {
        Write-Error-Log "Путь не существует: $Path"
        exit 1
    }
    
    Write-Success-Log "Путь проверен"
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Сбор статистики
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Сбор статистики..."
    
    $files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
    $Stats.TotalFiles = $files.Count
    $Stats.TotalSize = ($files | Measure-Object -Property Length -Sum).Sum
    
    Write-Log "  Всего файлов: $($Stats.TotalFiles)"
    Write-Log "  Общий размер: $([math]::Round($Stats.TotalSize / 1MB, 2)) MB"
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Поиск проблем
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Поиск проблем..."
    
    # Файлы нулевого размера
    $Stats.ZeroSizeFiles = Find-Zero-Size-Files -RootPath $Path
    Write-Log "  Найдено файлов нулевого размера: $($Stats.ZeroSizeFiles.Count)"
    
    # Временные файлы
    $Stats.TempFiles = Find-Temp-Files -RootPath $Path
    Write-Log "  Найдено временных файлов: $($Stats.TempFiles.Count)"
    
    # Дубликаты
    $Stats.Duplicates = Find-Duplicates -RootPath $Path
    Write-Log "  Найдено групп дубликатов: $($Stats.Duplicates.Count)"
    
    # Битые файлы
    $Stats.BrokenFiles = Find-Broken-Files -RootPath $Path
    Write-Log "  Найдено битых файлов: $($Stats.BrokenFiles.Count)"
    
    # Нарушения именования
    $Stats.NamingViolations = Find-Naming-Violations -RootPath $Path
    Write-Log "  Найдено нарушений именования: $($Stats.NamingViolations.Count)"
    
    # Устаревшие версии
    $Stats.OldVersions = Find-Old-Versions -RootPath $Path
    Write-Log "  Найдено устаревших версий: $($Stats.OldVersions.Count)"
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Генерация отчёта
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Генерация отчёта..."
    
    Generate-Report -Stats $Stats -OutputPath $OutputPath
    
    # ------------------------------------------------------------------------
    # ШАГ 5: Запись в журнал операций
    # ------------------------------------------------------------------------
    Write-Log "Шаг 5: Запись в журнал операций..."
    
    $logEntry = @"

## $AuditDate Аудит Базы Знаний

**Тип:** Аудит

**Путь:** $Path
**Отчёт:** $OutputPath

**Статистика:**
- Файлов: $($Stats.TotalFiles)
- Дубликатов: $($Stats.Duplicates.Count)
- Битых файлов: $($Stats.BrokenFiles.Count)
- Нарушений: $($Stats.NamingViolations.Count)

**Статус:** ✅ Завершено

---
"@
    
    if (Test-Path $LogPath) {
        Add-Content -Path $LogPath -Value $logEntry -Encoding UTF8
        Write-Success-Log "Запись в журнал: $LogPath"
    }
    
    # ------------------------------------------------------------------------
    # ЗАВЕРШЕНИЕ
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Success-Log "АУДИТ ЗАВЕРШЁН!" -Color "Green"
    Write-Host ""
    Write-Host "Отчёт: $OutputPath" -ForegroundColor "Cyan"
    Write-Host ""
    Write-Host "Для очистки выполните:" -ForegroundColor "Cyan"
    Write-Host "  .\scripts\kb-cleanup.ps1 -AuditId `"$AuditId`" -Confirm" -ForegroundColor "Gray"
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
