# ============================================================================
# TEST PRE-OPERATION BACKUP
# ============================================================================
# Назначение: Тестирование pre-operation-backup.ps1 в изолированной среде
# Использование: .\scripts\test-pre-operation-backup.ps1 -OperationType "Test"
# ВАЖНО: Работает ТОЛЬКО в _TEST_ENV (вне не выходит)
# ============================================================================

param(
    [Parameter(Mandatory = $true)]
    [string]$OperationType,
    
    [string]$BackupRoot = "D:\QwenPoekt\_TEST_ENV\_BACKUP",
    
    [string]$SourceRoot = "D:\QwenPoekt\_TEST_ENV\Base",
    
    [switch]$WhatIf
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

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ТЕСТОВЫЙ ПРЕДОПЕРАЦИОННЫЙ БЭКАП ===" -Color "Yellow"
    Write-Log "Операция: $OperationType" -Color "Yellow"
    Write-Log "РЕЖИМ: Тестирование (в _TEST_ENV)" -Color "Yellow"
    
    # ------------------------------------------------------------------------
    # ШАГ 0: Проверка источника
    # ------------------------------------------------------------------------
    Write-Log "Шаг 0: Проверка источника..."
    
    if (!(Test-Path-Safe -Path $SourceRoot)) {
        Write-Error-Log "Источник не существует: $SourceRoot"
        Write-Error-Log "Запустите: .\create-test-env.ps1"
        exit 1
    }
    
    $fileCount = Get-File-Count -Path $SourceRoot
    $folderSize = Get-Folder-Size-MB -Path $SourceRoot
    
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
    
    Ensure-Directory-Exists -Path $BackupRoot
    
    Write-Log "  Путь: $backupPath"
    Write-Log "  Копирование файлов..."
    
    Copy-Item -Path $SourceRoot -Destination $backupPath -Recurse -Force
    
    Write-Success-Log "Бэкап создан: $backupPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Проверка целостности
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Проверка целостности..."
    
    $integrityOk = Test-Backup-Integrity -SourcePath $SourceRoot -BackupPath $backupPath
    
    if (!$integrityOk) {
        Write-Error-Log "Бэкап повреждён или неполон!"
        exit 1
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Запись в журнал тестов
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Запись в журнал тестов..."
    
    $logEntry = @"

## $timestamp $OperationType

**Тип:** Тестовый предоперационный бэкап

**Источник:** $SourceRoot
**Бэкап:** $backupPath

**Параметры:**
- Файлов: $fileCount
- Размер: $folderSize MB
- Операция: $OperationType

**Статус:** ✅ Успешно (ТЕСТ)

---
"@
    
    Add-Content -Path $LogPath -Value $logEntry -Encoding UTF8
    Write-Success-Log "Запись в журнал: $LogPath"
    
    # ------------------------------------------------------------------------
    # ЗАВЕРШЕНИЕ
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Success-Log "ТЕСТОВЫЙ БЭКАП ГОТОВ!" -Color "Green"
    Write-Host ""
    Write-Host "Путь к бэкапу:" -ForegroundColor "White"
    Write-Host "  $backupPath" -ForegroundColor "Gray"
    Write-Host ""
    Write-Host "⚠️  ЭТО ТЕСТОВЫЙ БЭКАП (в _TEST_ENV)" -ForegroundColor "Yellow"
    Write-Host ""
    Write-Host "Для очистки тестовой среды:" -ForegroundColor "Cyan"
    Write-Host "  .\cleanup-test-env.ps1" -ForegroundColor "Gray"
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
