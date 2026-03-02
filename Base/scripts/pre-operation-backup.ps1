# ============================================================================
# PRE-OPERATION BACKUP
# ============================================================================
# Назначение: Автоматическое создание резервной копии ПЕРЕД удалением/перемещением
# Использование: .\scripts\pre-operation-backup.ps1 -OperationType "Delete_OldProject"
# ============================================================================

param(
    [Parameter(Mandatory = $true)]
    [string]$OperationType,
    
    [string]$BackupRoot = "D:\QwenPoekt\_BACKUP",
    
    [string]$SourcePath = "D:\QwenPoekt\Base",
    
    [switch]$WhatIf
)

$ErrorActionPreference = "Stop"
$LogPath = "D:\QwenPoekt\Base\reports\OPERATION_LOG.md"

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
    
    # Запись в файл
    $logEntry | Out-File $LogPath -Append -Encoding UTF8
    
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

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ПРЕДОПЕРАЦИОННЫЙ БЭКАП ===" -Color "Yellow"
    Write-Log "Операция: $OperationType" -Color "Yellow"
    
    # ------------------------------------------------------------------------
    # ШАГ 0: Проверка источника
    # ------------------------------------------------------------------------
    Write-Log "Шаг 0: Проверка источника..."
    
    if (!(Test-Path-Safe -Path $SourcePath)) {
        Write-Error-Log "Источник не существует: $SourcePath"
        exit 1
    }
    
    $fileCount = Get-File-Count -Path $SourcePath
    $folderSize = Get-Folder-Size-MB -Path $SourcePath
    
    Write-Log "  Файлов: $fileCount"
    Write-Log "  Размер: $folderSize MB"
    
    if ($fileCount -eq 0) {
        Write-Error-Log "Источник пуст! Бэкап не создан."
        exit 1
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 1: WhatIf режим (только проверка)
    # ------------------------------------------------------------------------
    if ($WhatIf) {
        Write-Log "⚠️  РЕЖИМ ПРОВЕРКИ (WhatIf)" -Color "Yellow"
        Write-Log "Бэкап НЕ будет создан. Только информация:"
        Write-Log "  Путь бэкапа: $BackupRoot\$((Get-Date -Format 'yyyy-MM-dd_HH-mm'))_$OperationType"
        Write-Log "  Требуемое место: ~$folderSize MB"
        Write-Host ""
        Write-Success-Log "Проверка завершена. Запустите без -WhatIf для создания бэкапа."
        exit 0
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Создание бэкапа
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Создание бэкапа..."
    
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $backupFolderName = "${timestamp}_$OperationType"
    $backupPath = Join-Path $BackupRoot $backupFolderName
    
    # Убедиться, что папка _BACKUP существует
    Ensure-Directory-Exists -Path $BackupRoot
    
    Write-Log "  Путь: $backupPath"
    
    # Копирование
    Write-Log "  Копирование файлов (это может занять несколько минут)..."
    Copy-Item -Path $SourcePath -Destination $backupPath -Recurse -Force
    
    Write-Success-Log "Бэкап создан: $backupPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Проверка целостности
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Проверка целостности..."
    
    $integrityOk = Test-Backup-Integrity -SourcePath $SourcePath -BackupPath $backupPath
    
    if (!$integrityOk) {
        Write-Error-Log "Бэкап повреждён или неполон! Требуется повторное копирование."
        Write-Log "  Рекомендуется:"
        Write-Log "  1. Проверить свободное место на диске"
        Write-Log "  2. Запустить скрипт заново"
        Write-Log "  3. Проверить логи ошибок PowerShell"
        exit 1
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Запись в журнал операций
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Запись в журнал операций..."
    
    $logEntry = @"

## $timestamp $OperationType

**Тип:** Предоперационный бэкап

**Источник:** $SourcePath
**Бэкап:** $backupPath

**Параметры:**
- Файлов: $fileCount
- Размер: $folderSize MB
- Операция: $OperationType

**Статус:** ✅ Успешно

**Следующие шаги:**
- [ ] Выполнить планируемую операцию (удаление/перемещение)
- [ ] Записать результат в OPERATION_LOG.md
- [ ] Через 45 дней: запустить анализ бэкапа

---
"@
    
    Add-Content -Path $LogPath -Value $logEntry -Encoding UTF8
    Write-Success-Log "Запись в журнал: $LogPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 5: Проверка свободного места (предупреждение)
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Проверка свободного места..."
    
    try {
        $drive = Split-Path $BackupRoot -Qualifier
        $diskSpace = Get-PSDrive -Name $drive.Replace(':', '')
        $freeSpaceGB = [math]::Round($diskSpace.Free / 1GB, 2)
        
        Write-Log "  Свободно на диске $drive : $freeSpaceGB GB"
        
        if ($freeSpaceGB -lt 1) {
            Write-Log "⚠️  ПРЕДУПРЕЖДЕНИЕ: Мало свободного места!" -Color "Yellow"
            Write-Log "  Рекомендуется освободить место перед следующими бэкапами."
        }
    } catch {
        Write-Log "  Не удалось проверить свободное место" -Color "Gray"
    }
    
    # ------------------------------------------------------------------------
    # ЗАВЕРШЕНИЕ
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Success-Log "БЭКАП ГОТОВ!" -Color "Green"
    Write-Host ""
    Write-Host "Путь к бэкапу:" -ForegroundColor "White"
    Write-Host "  $backupPath" -ForegroundColor "Gray"
    Write-Host ""
    Write-Host "Теперь можно безопасно выполнить операцию: $OperationType" -ForegroundColor "Cyan"
    Write-Host ""
    Write-Host "Для восстановления из бэкапа:" -ForegroundColor "White"
    Write-Host "  Copy-Item `"$backupPath`" `"$SourcePath`" -Recurse -Force" -ForegroundColor "Gray"
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    
    Write-Host ""
    Write-Host "ВОЗМОЖНЫЕ ПРИЧИНЫ:" -ForegroundColor "Red"
    Write-Host "  1. Недостаточно свободного места на диске" -ForegroundColor "Gray"
    Write-Host "  2. Нет доступа к папке _BACKUP" -ForegroundColor "Gray"
    Write-Host "  3. Файл заблокирован другим процессом" -ForegroundColor "Gray"
    Write-Host "  4. Слишком длинный путь к файлу (>260 символов)" -ForegroundColor "Gray"
    Write-Host ""
    
    exit 1
}
