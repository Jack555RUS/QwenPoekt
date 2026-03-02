# ============================================================================
# SAFE DELETE
# ============================================================================
# Назначение: Безопасное удаление папок с автоматическим бэкапом
# Использование: .\scripts\safe-delete.ps1 -Path "OLD/_INBOX/AbandonedProject"
# ============================================================================

param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    
    [string]$BackupRoot = "D:\QwenPoekt\_BACKUP",
    
    [string]$SourceRoot = "D:\QwenPoekt\Base",
    
    [switch]$WhatIf,
    
    [switch]$NoBackup,
    
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$LogPath = "D:\QwenPoekt\Base\reports\OPERATION_LOG.md"

# ============================================================================
# КОНФИГУРАЦИЯ: КРИТИЧНЫЕ ПАПКИ (ЗАПРЕТ УДАЛЕНИЯ)
# ============================================================================

$CriticalPaths = @(
    "KNOWLEDGE_BASE",
    "scripts",
    "reports",
    ".qwen",
    "_templates",
    "_docs",
    "PROJECTS",
    ".vscode",
    ".github"
)

$CriticalFiles = @(
    "AI_START_HERE.md",
    "QWEN.md",
    "RULES_AND_TASKS.md",
    "NOTES.md",
    "ТЕКУЩАЯ_ЗАДАЧА.md"
)

# ============================================================================
# ФУНКЦИИ
# ============================================================================

function Write-Log {
    param(
        [string]$Message,
        [string]$Color = "Cyan"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    
    # Запись в файл (только если файл существует)
    if (Test-Path $LogPath) {
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

function Test-Path-Safe {
    param([string]$Path)
    try {
        return Test-Path $Path
    } catch {
        return $false
    }
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

function Test-Critical-Path {
    param([string]$Path)
    
    $relativePath = $Path.Replace("$SourceRoot\", "").Replace("$SourceRoot", "")
    
    foreach ($critical in $CriticalPaths) {
        if ($relativePath -like "*$critical*") {
            return $true
        }
    }
    
    foreach ($criticalFile in $CriticalFiles) {
        if ($relativePath -like "*$criticalFile*") {
            return $true
        }
    }
    
    return $false
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
        Write-Log "Создание папки: $Path"
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
    Write-Log "=== БЕЗОПАСНОЕ УДАЛЕНИЕ ===" -Color "Yellow"
    
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
    # ШАГ 0.5: Проверка на критичные папки
    # ------------------------------------------------------------------------
    Write-Log "Шаг 0.5: Проверка на критичность..."
    
    if (Test-Critical-Path -Path $fullPath) {
        Write-Error-Log "КРИТИЧНАЯ ПАПКА! Удаление запрещено!"
        Write-Log "  Критичные папки: $($CriticalPaths -join ', ')" -Color "Gray"
        Write-Log "  Критичные файлы: $($CriticalFiles -join ', ')" -Color "Gray"
        Write-Host ""
        Write-Host "Если вы уверены, используйте -Force (опасно!)" -ForegroundColor "Red"
        exit 1
    }
    
    Write-Success-Log "Папка не критична, удаление разрешено"
    
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
        Write-Host "При сбое данные будут потеряны безвозвратно!" -ForegroundColor "Red"
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
    # ШАГ 5: Запись в журнал
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Запись в журнал..."
    
    $backupPathText = if ($backupPath) { $backupPath } else { "НЕТ (-NoBackup)" }
    $whatIfText = if ($WhatIf) { "Да" } else { "Нет" }
    $noBackupText = if ($NoBackup) { "Да" } else { "Нет" }
    $forceText = if ($Force) { "Да" } else { "Нет" }
    
    $logEntry = @"

## $(Get-Date -Format 'yyyy-MM-dd HH:mm') Удаление: $relativePath

**Тип:** Безопасное удаление

**Путь:** $relativePath
**Бэкап:** $backupPathText

**Параметры:**
- Файлов: $fileCount
- Размер: $folderSize MB
- WhatIf: $whatIfText
- NoBackup: $noBackupText
- Force: $forceText

**Статус:** ✅ Успешно

**Следующие шаги:**
- [ ] Проверить, что удаление корректно отразилось в проекте
- [ ] Через 45 дней: запустить анализ бэкапа

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
    Write-Success-Log "УДАЛЕНИЕ ЗАВЕРШЕНО!" -Color "Green"
    Write-Host ""
    
    if ($backupPath) {
        Write-Host "Бэкап сохранён:" -ForegroundColor "White"
        Write-Host "  $backupPath" -ForegroundColor "Gray"
        Write-Host ""
        Write-Host "Для восстановления:" -ForegroundColor "White"
        Write-Host "  Copy-Item `"$backupPath`" `"$fullPath`" -Recurse -Force" -ForegroundColor "Gray"
    } else {
        Write-Warning-Log "Бэкап отсутствует! Восстановление невозможно."
    }
    
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    
    Write-Host ""
    Write-Host "ВОЗМОЖНЫЕ ПРИЧИНЫ:" -ForegroundColor "Red"
    Write-Host "  1. Файл заблокирован другим процессом" -ForegroundColor "Gray"
    Write-Host "  2. Нет прав на удаление" -ForegroundColor "Gray"
    Write-Host "  3. Слишком длинный путь к файлу (>260 символов)" -ForegroundColor "Gray"
    Write-Host "  4. Недостаточно свободного места для бэкапа" -ForegroundColor "Gray"
    Write-Host ""
    
    exit 1
}
