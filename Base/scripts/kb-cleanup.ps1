# ============================================================================
# KNOWLEDGE BASE CLEANUP
# ============================================================================
# Назначение: Очистка Базы Знаний по результатам аудита
# Использование: .\scripts\kb-cleanup.ps1 -AuditId "ID" [-Confirm]
# ============================================================================

param(
    [string]$AuditId,
    
    [string]$AuditReportPath = "D:\QwenPoekt\Base\reports\KB_AUDIT_REPORT.md",
    
    [string]$Path = "D:\QwenPoekt\Base\KNOWLEDGE_BASE",
    
    [string]$BackupRoot = "D:\QwenPoekt\_BACKUP",
    
    [string]$LogPath = "D:\QwenPoekt\Base\reports\OPERATION_LOG.md",
    
    [switch]$Confirm,
    
    [switch]$WhatIf
)

$ErrorActionPreference = "Continue"

# ============================================================================
# ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
# ============================================================================

$CleanupDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$Stats = @{
    DeletedCount = 0
    DeletedSize = 0
    ArchivedCount = 0
    RenamedCount = 0
    Errors = 0
}

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

function Ensure-Directory-Exists {
    param([string]$Path)
    if (!(Test-Path-Safe -Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
}

function Backup-And-Delete {
    param(
        [string]$FilePath,
        [string]$Reason
    )
    
    try {
        # Копировать в архив перед удалением
        $archivePath = Join-Path $BackupRoot "cleanup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Ensure-Directory-Exists -Path $archivePath
        
        $relativePath = $FilePath.Replace($Path, "").TrimStart("\")
        $destPath = Join-Path $archivePath $relativePath
        
        Ensure-Directory-Exists -Path (Split-Path $destPath -Parent)
        
        Copy-Item -Path $FilePath -Destination $destPath -Force
        
        # Удалить оригинал
        Remove-Item -Path $FilePath -Force
        
        $Stats.DeletedCount++
        $Stats.DeletedSize += (Get-Item $FilePath -ErrorAction SilentlyContinue).Length
        
        Write-Log "  Удалено: $relativePath ($Reason)" -Color "Gray"
        return $true
    } catch {
        $Stats.Errors++
        Write-Error-Log "Ошибка удаления: $FilePath - $($_.Exception.Message)"
        return $false
    }
}

function Archive-File {
    param(
        [string]$FilePath,
        [string]$Reason
    )
    
    try {
        $archivePath = Join-Path $Path "04_ARCHIVES\cleanup_$(Get-Date -Format 'yyyyMMdd')"
        Ensure-Directory-Exists -Path $archivePath
        
        $relativePath = $FilePath.Replace($Path, "").TrimStart("\")
        $destPath = Join-Path $archivePath $relativePath
        
        Ensure-Directory-Exists -Path (Split-Path $destPath -Parent)
        
        Move-Item -Path $FilePath -Destination $destPath -Force
        
        $Stats.ArchivedCount++
        
        Write-Log "  Архивировано: $relativePath ($Reason)" -Color "Gray"
        return $true
    } catch {
        $Stats.Errors++
        Write-Error-Log "Ошибка архивации: $FilePath - $($_.Exception.Message)"
        return $false
    }
}

function Rename-File {
    param(
        [string]$FilePath,
        [string]$NewName
    )
    
    try {
        $dir = Split-Path $FilePath -Parent
        $newPath = Join-Path $dir $NewName
        
        Rename-Item -Path $FilePath -NewName $NewName -Force
        
        $Stats.RenamedCount++
        
        Write-Log "  Переименовано: $(Split-Path $FilePath -Leaf) → $NewName" -Color "Gray"
        return $true
    } catch {
        $Stats.Errors++
        Write-Error-Log "Ошибка переименования: $FilePath - $($_.Exception.Message)"
        return $false
    }
}

function Fix-Naming {
    param([string]$FileName)
    
    # Заменить пробелы на _
    $fixed = $FileName -replace " ", "_"
    
    # Удалить спецсимволы
    $fixed = $fixed -replace '[!"№;%:?*()\[\]{}$&|<>\\]', ""
    
    # Преобразовать в lower case
    $fixed = $fixed.ToLower()
    
    # Убрать кириллицу (транслитерация сложна, оставляем как есть с предупреждением)
    
    return $fixed
}

function Parse-Audit-Report {
    param([string]$ReportPath)
    
    if (!(Test-Path-Safe -Path $ReportPath)) {
        Write-Error-Log "Отчёт аудита не найден: $ReportPath"
        return $null
    }
    
    $content = Get-Content $ReportPath -Raw
    
    # Парсим секции отчёта (упрощённо)
    $result = @{
        ZeroSizeFiles = @()
        TempFiles = @()
        Duplicates = @()
        BrokenFiles = @()
        NamingViolations = @()
        OldVersions = @()
    }
    
    # Извлекаем списки файлов из отчёта (regex)
    # Это упрощённый парсер, в реальности нужно более сложное решение
    
    return $result
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ОЧИСТКА БАЗЫ ЗНАНИЙ ===" -Color "Yellow"
    Write-Log "Дата: $CleanupDate"
    
    # ------------------------------------------------------------------------
    # ШАГ 0: Проверка параметров
    # ------------------------------------------------------------------------
    Write-Log "Шаг 0: Проверка параметров..."
    
    if (!$Confirm -and !$WhatIf) {
        Write-Warning-Log "Требуется -Confirm или -WhatIf для запуска"
        Write-Log "  Используйте -WhatIf для проверки без удаления" -Color "Gray"
        Write-Log "  Используйте -Confirm для выполнения очистки" -Color "Gray"
        exit 1
    }
    
    if (!(Test-Path-Safe -Path $Path)) {
        Write-Error-Log "Путь не существует: $Path"
        exit 1
    }
    
    Write-Success-Log "Параметры проверены"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Создание бэкапа
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Создание бэкапа..."
    
    if (!$WhatIf) {
        & "$PSScriptRoot\pre-operation-backup.ps1" -OperationType "KB_Cleanup_$AuditId" -BackupRoot $BackupRoot
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Log "Не удалось создать бэкап! Очистка отменена."
            exit 1
        }
        
        Write-Success-Log "Бэкап создан"
    } else {
        Write-Log "  WhatIf: бэкап не создаётся" -Color "Gray"
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Очистка файлов нулевого размера
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Очистка файлов нулевого размера..."
    
    $zeroFiles = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
                 Where-Object { $_.Length -eq 0 }
    
    foreach ($file in $zeroFiles) {
        if ($WhatIf) {
            Write-Log "  [WhatIf] Удалить: $($file.FullName)" -Color "Gray"
        } else {
            Backup-And-Delete -FilePath $file.FullName -Reason "Нулевой размер"
        }
    }
    
    Write-Log "  Найдено: $($zeroFiles.Count), Удалено: $($Stats.DeletedCount)"
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Очистка временных файлов
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Очистка временных файлов..."
    
    $tempExtensions = @(".tmp", ".bak", ".DS_Store", ".swp", ".swo", "*.log")
    $tempFiles = @()
    
    foreach ($ext in $tempExtensions) {
        $tempFiles += Get-ChildItem -Path $Path -Recurse -File -Filter $ext -ErrorAction SilentlyContinue
    }
    
    foreach ($file in $tempFiles) {
        if ($WhatIf) {
            Write-Log "  [WhatIf] Удалить: $($file.FullName)" -Color "Gray"
        } else {
            Backup-And-Delete -FilePath $file.FullName -Reason "Временный файл"
        }
    }
    
    Write-Log "  Найдено: $($tempFiles.Count), Удалено: $($Stats.DeletedCount)"
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Обработка дубликатов
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Обработка дубликатов..."
    
    $hashes = @{}
    $files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
    
    foreach ($file in $files) {
        try {
            $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
            
            if ($hashes.ContainsKey($hash)) {
                $hashes[$hash] += $file.FullName
            } else {
                $hashes[$hash] = @($file.FullName)
            }
        } catch {
            # Не удалось вычислить хэш
        }
    }
    
    # Обрабатываем дубликаты
    $dupCount = 0
    foreach ($hash in $hashes.Keys) {
        if ($hashes[$hash].Count -gt 1) {
            # Оставляем первый файл, остальные удаляем
            $keep = $hashes[$hash][0]
            
            for ($i = 1; $i -lt $hashes[$hash].Count; $i++) {
                $dupFile = $hashes[$hash][$i]
                
                if ($WhatIf) {
                    Write-Log "  [WhatIf] Удалить дубликат: $dupFile (оригинал: $keep)" -Color "Gray"
                } else {
                    Backup-And-Delete -FilePath $dupFile -Reason "Дубликат"
                    $dupCount++
                }
            }
        }
    }
    
    Write-Log "  Найдено групп дубликатов: $($hashes.Values.Where({$_.Count -gt 1}).Count), Удалено: $dupCount"
    
    # ------------------------------------------------------------------------
    # ШАГ 5: Исправление именования
    # ------------------------------------------------------------------------
    Write-Log "Шаг 5: Исправление именования..."
    
    $files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
    $renameCount = 0
    
    foreach ($file in $files) {
        $fileName = $file.Name
        $fixedName = Fix-Naming -FileName $fileName
        
        if ($fileName -ne $fixedName) {
            if ($WhatIf) {
                Write-Log "  [WhatIf] Переименовать: $fileName → $fixedName" -Color "Gray"
            } else {
                # Проверяем, нет ли уже файла с таким именем
                $newPath = Join-Path $file.DirectoryName $fixedName
                if (!(Test-Path-Safe -Path $newPath)) {
                    Rename-File -FilePath $file.FullName -NewName $fixedName
                    $renameCount++
                }
            }
        }
    }
    
    Write-Log "  Переименовано: $renameCount"
    
    # ------------------------------------------------------------------------
    # ШАГ 6: Архивация устаревших версий
    # ------------------------------------------------------------------------
    Write-Log "Шаг 6: Архивация устаревших версий..."
    
    $patterns = @("*_v[0-9]*", "*_old.*", "*_backup.*", "*_[0-9][0-9][0-9][0-9]-*")
    $oldFiles = @()
    
    foreach ($pattern in $patterns) {
        $oldFiles += Get-ChildItem -Path $Path -Recurse -File -Filter $pattern -ErrorAction SilentlyContinue
    }
    
    $archiveCount = 0
    foreach ($file in $oldFiles | Select-Object -Unique) {
        # Пропускаем файлы в archive/
        if ($file.FullName -notmatch "04_ARCHIVES") {
            if ($WhatIf) {
                Write-Log "  [WhatIf] Архивировать: $($file.FullName)" -Color "Gray"
            } else {
                Archive-File -FilePath $file.FullName -Reason "Устаревшая версия"
                $archiveCount++
            }
        }
    }
    
    Write-Log "  Архивировано: $archiveCount"
    
    # ------------------------------------------------------------------------
    # ШАГ 7: Финальный отчёт
    # ------------------------------------------------------------------------
    Write-Log "Шаг 7: Финальный отчёт..."
    
    $reportEntry = @"

## $CleanupDate Очистка Базы Знаний

**Тип:** Очистка

**Audit ID:** $AuditId
**Путь:** $Path

**Результаты:**
- Удалено файлов: $($Stats.DeletedCount)
- Архивировано файлов: $($Stats.ArchivedCount)
- Переименовано файлов: $($Stats.RenamedCount)
- Ошибок: $($Stats.Errors)

**Режим:** $(if ($WhatIf) { "WhatIf (проверка)" } else { "Полная очистка" })

**Статус:** ✅ Завершено

---
"@
    
    if (Test-Path $LogPath) {
        Add-Content -Path $LogPath -Value $reportEntry -Encoding UTF8
        Write-Success-Log "Запись в журнал: $LogPath"
    }
    
    # ------------------------------------------------------------------------
    # ЗАВЕРШЕНИЕ
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Success-Log "ОЧИСТКА ЗАВЕРШЕНА!" -Color "Green"
    Write-Host ""
    Write-Host "Результаты:" -ForegroundColor "White"
    Write-Host "  Удалено файлов: $($Stats.DeletedCount)" -ForegroundColor "White"
    Write-Host "  Архивировано: $($Stats.ArchivedCount)" -ForegroundColor "White"
    Write-Host "  Переименовано: $($Stats.RenamedCount)" -ForegroundColor "White"
    Write-Host "  Ошибок: $($Stats.Errors)" -ForegroundColor $(if ($Stats.Errors -gt 0) { "Red" } else { "Green" })
    Write-Host ""
    
    if ($WhatIf) {
        Write-Warning-Log "РЕЖИМ WhatIf: Файлы не удалялись"
        Write-Host ""
        Write-Host "Для реальной очистки запустите без -WhatIf:" -ForegroundColor "Cyan"
        Write-Host "  .\scripts\kb-cleanup.ps1 -AuditId `"$AuditId`" -Confirm" -ForegroundColor "Gray"
        Write-Host ""
    }
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
