# ============================================================================
# TEST SAFE DELETE
# ============================================================================
# Назначение: Тестирование safe-delete.ps1 в изолированной среде
# Использование: .\scripts\test-safe-delete.ps1 -Path "_drafts"
# ВАЖНО: Работает ТОЛЬКО в _TEST_ENV (вне не выходит)
# ============================================================================

param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    
    [string]$BackupRoot = "D:\QwenPoekt\_TEST_ENV\_BACKUP",
    
    [string]$SourceRoot = "D:\QwenPoekt\_TEST_ENV\Base",
    
    [switch]$WhatIf,
    
    [switch]$NoBackup,
    
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$LogPath = "D:\QwenPoekt\_TEST_ENV\reports\TEST_LOG.md"

# ============================================================================
# ПРОВЕРКА БЕЗОПАСНОСТИ (НЕ ВЫХОДИТЬ ЗА _TEST_ENV!)
# ============================================================================

function Test-Path-Safe {
    param([string]$Path)
    try {
        return Test-Path $Path
    } catch {
        return $false
    }
}

# Проверка: пути должны быть в _TEST_ENV
if ($SourceRoot -notlike "*_TEST_ENV*") {
    Write-Error "❌ ОШИБКА БЕЗОПАСНОСТИ: SourceRoot должен быть в _TEST_ENV!"
    Write-Error "  Текущий: $SourceRoot"
    Write-Error "  Ожидаемый: D:\QwenPoekt\_TEST_ENV\Base"
    exit 1
}

if ($BackupRoot -notlike "*_TEST_ENV*") {
    Write-Error "❌ ОШИБКА БЕЗОПАСНОСТИ: BackupRoot должен быть в _TEST_ENV!"
    Write-Error "  Текущий: $BackupRoot"
    Write-Error "  Ожидаемый: D:\QwenPoekt\_TEST_ENV\_BACKUP"
    exit 1
}

# Проверка: тестовая среда существует
if (!(Test-Path-Safe -Path $SourceRoot)) {
    Write-Error "❌ Тестовая среда не существует!"
    Write-Error "  Запустите: .\create-test-env.ps1"
    exit 1
}

# ============================================================================
# ФУНКЦИИ
# ============================================================================

function Write-Log {
    param(
        [string]$Message,
        [string]$Color = "Cyan"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [TEST] $Message"
    
    # Запись в файл
    if (Test-Path-Safe -Path (Split-Path $LogPath -Parent)) {
        $logEntry | Out-File $LogPath -Append -Encoding UTF8
    }
    
    # Вывод в консоль
    Write-Host $logEntry -ForegroundColor $Color
}

function Write-Error-Log {
    param([string]$Message)
    Write-Log "❌ ОШИБКА: $Message" -Color "Red"
}

function Write-Success-Log {
    param([string]$Message)
    Write-Log "✅ $Message" -Color "Green"
}

function Write-Warning-Log {
    param([string]$Message)
    Write-Log "⚠️  $Message" -Color "Yellow"
}

function Get-File-Count {
    param([string]$Path)
    try {
        $files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
        return $files.Count
    } catch {
        return 0
    }
}

function Get-Folder-Size-MB {
    param([string]$Path)
    try {
        $size = (Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        return [math]::Round($size / 1MB, 2)
    } catch {
        return 0
    }
}

function Test-Backup-Integrity {
    param(
        [string]$SourcePath,
        [string]$BackupPath
    )
    
    Write-Log "Проверка целостности бэкапа..."
    
    $sourceCount = Get-File-Count -Path $SourcePath
    $backupCount = Get-File-Count -Path $BackupPath
    
    Write-Log "  Источник: $sourceCount файлов"
    Write-Log "  Бэкап: $backupCount файлов"
    
    if ($sourceCount -ne $backupCount) {
        $diff = [math]::Abs($sourceCount - $backupCount)
        Write-Error-Log "Несоответствие: разница в $diff файлов!"
        return $false
    }
    
    Write-Success-Log "Целостность подтверждена: $sourceCount файлов"
    return $true
}

function Ensure-Directory-Exists {
    param([string]$Path)
    if (!(Test-Path-Safe -Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
}

function Get-Relative-Path {
    param([string]$FullPath)
    return $FullPath.Replace("$SourceRoot\", "").Replace("$SourceRoot", "")
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ТЕСТОВОЕ БЕЗОПАСНОЕ УДАЛЕНИЕ ===" -Color "Yellow"
    Write-Log "РЕЖИМ: Тестирование (в _TEST_ENV)" -Color "Yellow"
    
    # ------------------------------------------------------------------------
    # ШАГ 0: Проверка пути
    # ------------------------------------------------------------------------
    Write-Log "Шаг 0: Проверка пути..."
    
    # Построить полный путь
    if (Test-Path-Safe -Path $Path) {
        $fullPath = $Path
    } else {
        $fullPath = Join-Path $SourceRoot $Path
    }
    
    if (!(Test-Path-Safe -Path $fullPath)) {
        Write-Error-Log "Путь не существует: $fullPath"
        exit 1
    }
    
    $relativePath = Get-Relative-Path -FullPath $fullPath
    Write-Log "  Путь: $relativePath"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Анализ
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Анализ..."
    
    $fileCount = Get-File-Count -Path $fullPath
    $folderSize = Get-Folder-Size-MB -Path $fullPath
    
    Write-Log "  Файлов: $fileCount"
    Write-Log "  Размер: $folderSize MB"
    
    if ($fileCount -eq 0) {
        Write-Warning-Log "Папка пуста! Удаление не требуется."
        exit 0
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 2: WhatIf режим (только проверка)
    # ------------------------------------------------------------------------
    if ($WhatIf) {
        Write-Log "⚠️  РЕЖИМ ПРОВЕРКИ (WhatIf)" -Color "Yellow"
        Write-Log "Удаление НЕ будет выполнено. Только информация:"
        Write-Log "  Путь: $relativePath"
        Write-Log "  Файлов: $fileCount"
        Write-Log "  Размер: $folderSize MB"
        $backupStatus = if ($NoBackup) { "НЕТ (-NoBackup)" } else { "Будет создан" }
        Write-Log "  Бэкап: $backupStatus"
        Write-Host ""
        Write-Host "Для реального удаления запустите без -WhatIf" -ForegroundColor "Cyan"
        Write-Host "Для удаления без бэкапа добавьте -NoBackup (ОПАСНО!)" -ForegroundColor "Red"
        Write-Host ""
        exit 0
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Бэкап (если не NoBackup)
    # ------------------------------------------------------------------------
    $backupPath = $null
    
    if (!$NoBackup) {
        Write-Log "Шаг 2: Создание бэкапа..."
        
        $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
        $folderName = Split-Path $relativePath -Leaf
        $backupFolderName = "${timestamp}_Delete_$folderName"
        $backupPath = Join-Path $BackupRoot $backupFolderName
        
        Ensure-Directory-Exists -Path $BackupRoot
        
        Write-Log "  Путь бэкапа: $backupPath"
        Write-Log "  Копирование файлов..."
        
        Copy-Item -Path $fullPath -Destination $backupPath -Recurse -Force
        
        Write-Success-Log "Бэкап создан: $backupPath"
        
        # Проверка целостности
        $integrityOk = Test-Backup-Integrity -SourcePath $fullPath -BackupPath $backupPath
        
        if (!$integrityOk) {
            Write-Error-Log "Бэкап повреждён! Удаление отменено."
            exit 1
        }
    } else {
        Write-Warning-Log "Бэкап НЕ создан (-NoBackup)"
        Write-Host ""
        Write-Host "ВНИМАНИЕ: Вы отключили создание бэкапа!" -ForegroundColor "Red"
        Write-Host ""
        
        if (!$Force) {
            Write-Host "Для продолжения добавьте -Force" -ForegroundColor "Yellow"
            exit 1
        }
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Удаление
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Удаление..."
    
    Write-Log "  Удаление: $relativePath"
    Remove-Item -Path $fullPath -Recurse -Force
    
    # Проверка удаления
    if (Test-Path-Safe -Path $fullPath) {
        Write-Error-Log "Не удалось удалить папку!"
        exit 1
    }
    
    Write-Success-Log "Папка удалена: $relativePath"
    
    # ------------------------------------------------------------------------
    # ШАГ 5: Запись в журнал тестов
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Запись в журнал тестов..."
    
    $backupPathText = if ($backupPath) { $backupPath } else { "НЕТ (-NoBackup)" }
    $whatIfText = if ($WhatIf) { "Да" } else { "Нет" }
    $noBackupText = if ($NoBackup) { "Да" } else { "Нет" }
    $forceText = if ($Force) { "Да" } else { "Нет" }
    
    $logEntry = @"

## $(Get-Date -Format 'yyyy-MM-dd HH:mm') Тестовое удаление: $relativePath

**Тип:** Тестовое безопасное удаление

**Путь:** $relativePath
**Бэкап:** $backupPathText

**Параметры:**
- Файлов: $fileCount
- Размер: $folderSize MB
- WhatIf: $whatIfText
- NoBackup: $noBackupText
- Force: $forceText

**Статус:** ✅ Успешно (ТЕСТ)

---
"@
    
    Add-Content -Path $LogPath -Value $logEntry -Encoding UTF8
    Write-Success-Log "Запись в журнал: $LogPath"
    
    # ------------------------------------------------------------------------
    # ЗАВЕРШЕНИЕ
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Success-Log "ТЕСТОВОЕ УДАЛЕНИЕ ЗАВЕРШЕНО!" -Color "Green"
    Write-Host ""
    
    if ($backupPath) {
        Write-Host "Бэкап сохранён (тестовый):" -ForegroundColor "White"
        Write-Host "  $backupPath" -ForegroundColor "Gray"
        Write-Host ""
        Write-Host "⚠️  ЭТО ТЕСТОВЫЙ БЭКАП (в _TEST_ENV)" -ForegroundColor "Yellow"
    } else {
        Write-Warning-Log "Бэкап отсутствует! (тестовый режим)"
    }
    
    Write-Host ""
    Write-Host "Для очистки тестовой среды:" -ForegroundColor "Cyan"
    Write-Host "  .\cleanup-test-env.ps1" -ForegroundColor "Gray"
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
