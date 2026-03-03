# ============================================================================
# TEST OLD BACKUP ANALYSIS
# ============================================================================
# Назначение: Тестирование old-backup-analysis.ps1 в изолированной среде
# Использование: .\scripts\test-old-backup-analysis.ps1
# ВАЖНО: Работает ТОЛЬКО в _TEST_ENV (вне не выходит)
# ============================================================================

param(
    [string]$BackupRoot = "D:\QwenPoekt\_TEST_ENV\_BACKUP",
    
    [string]$SourceRoot = "D:\QwenPoekt\_TEST_ENV\Base",
    
    [int]$DaysThreshold = 45,
    
    [int]$AnalysisDaysThreshold = 60,
    
    [switch]$AutoConfirm,
    
    [string]$ReportPath = "D:\QwenPoekt\_TEST_ENV\reports\BACKUP_ANALYSIS_REPORT.md"
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

function Write-Info-Log {
    param([string]$Message)
    Write-Log "  $Message" -Color "Gray"
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

# ============================================================================
# ОСНОВНАЯ ЛОГИКА (УПРОЩЕННАЯ ДЛЯ ТЕСТОВ)
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ТЕСТОВЫЙ АНАЛИЗ СТАРЫХ БЭКАПОВ ===" -Color "Yellow"
    Write-Log "РЕЖИМ: Тестирование (в _TEST_ENV)" -Color "Yellow"
    Write-Log "Порог анализа: $DaysThreshold дней" -Color "Yellow"
    Write-Log "Порог удаления: $AnalysisDaysThreshold дней" -Color "Yellow"
    
    # ------------------------------------------------------------------------
    # ШАГ 0: Проверка папки _BACKUP
    # ------------------------------------------------------------------------
    Write-Log "Шаг 0: Проверка папки _BACKUP..."
    
    if (!(Test-Path-Safe -Path $BackupRoot)) {
        Write-Error-Log "Папка _BACKUP не существует: $BackupRoot"
        Write-Error-Log "Запустите: .\create-test-env.ps1"
        exit 1
    }
    
    Write-Success-Log "Папка найдена: $BackupRoot"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Поиск бэкапов >45 дней
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Поиск бэкапов старше $DaysThreshold дней..."
    
    $now = Get-Date
    $backupFolders = Get-ChildItem -Path $BackupRoot -Directory -ErrorAction SilentlyContinue
    
    $oldBackups = @()
    foreach ($folder in $backupFolders) {
        $age = ($now - $folder.CreationTime).Days
        if ($age -ge $DaysThreshold) {
            $oldBackups += @{
                Path = $folder.FullName
                Name = $folder.Name
                Age = $age
                CreationTime = $folder.CreationTime
            }
        }
    }
    
    if ($oldBackups.Count -eq 0) {
        Write-Success-Log "Старых бэкапов не найдено!"
        Write-Log "Все бэкапы моложе $DaysThreshold дней." -Color "Gray"
        Write-Log ""
        Write-Log "💡 Подсказка: Для тестирования создайте бэкап:" -ForegroundColor "Cyan"
        Write-Log "   .\test-pre-operation-backup.ps1 -OperationType `"Test`"" -ForegroundColor "Gray"
        Write-Host ""
        exit 0
    }
    
    Write-Log "Найдено бэкапов: $($oldBackups.Count)" -Color "Green"
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Анализ (упрощённый для тестов)
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Анализ бэкапов..."
    
    $deleteCount = 0
    $keepCount = 0
    $reviewCount = 0
    
    foreach ($backup in $oldBackups) {
        Write-Host ""
        Write-Log "Анализ: $($backup.Name)" -Color "White"
        Write-Info-Log "  Возраст: $($backup.Age) дней"
        
        $fileCount = Get-File-Count -Path $backup.Path
        $folderSize = Get-Folder-Size-MB -Path $backup.Path
        
        Write-Info-Log "  Файлов: $fileCount"
        Write-Info-Log "  Размер: $folderSize MB"
        
        # Простая эвристика для тестов
        if ($folderSize -lt 1 -and $fileCount -lt 10) {
            $deleteCount++
            Write-Info-Log "  Рекомендация: DELETE (малый размер)"
        } elseif ($folderSize -gt 100 -or $fileCount -gt 100) {
            $keepCount++
            Write-Info-Log "  Рекомендация: KEEP (большой размер/много файлов)"
        } else {
            $reviewCount++
            Write-Info-Log "  Рекомендация: REVIEW (средние показатели)"
        }
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Запись в журнал тестов
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Запись в журнал тестов..."
    
    $logEntry = @"

## $(Get-Date -Format 'yyyy-MM-dd HH:mm') Тестовый анализ бэкапов

**Тип:** Тестовый анализ старых бэкапов

**Параметры:**
- Бэкапов найдено: $($oldBackups.Count)
- К удалению: $deleteCount
- Сохранить: $keepCount
- На проверку: $reviewCount

**Статус:** ✅ Завершено (ТЕСТ)

---
"@
    
    Add-Content -Path $LogPath -Value $logEntry -Encoding UTF8
    Write-Success-Log "Запись в журнал: $LogPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Вывод сводки
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Log "=== СВОДКА ===" -Color "Yellow"
    Write-Host ""
    Write-Host "Всего бэкапов: $($oldBackups.Count)" -ForegroundColor "White"
    Write-Host "  🔴 К удалению: $deleteCount" -ForegroundColor "Red"
    Write-Host "  🟢 Сохранить: $keepCount" -ForegroundColor "Green"
    Write-Host "  🟡 На проверку: $reviewCount" -ForegroundColor "Yellow"
    Write-Host ""
    
    if ($AutoConfirm -and $deleteCount -gt 0) {
        Write-Warning-Log "AutoConfirm: Удаление бэкапов с рекомендацией DELETE..."
        
        foreach ($backup in $oldBackups) {
            $age = $backup.Age
            $fileCount = Get-File-Count -Path $backup.Path
            $folderSize = Get-Folder-Size-MB -Path $backup.Path
            
            # Простая эвристика
            if ($folderSize -lt 1 -and $fileCount -lt 10) {
                Write-Log "Удаление: $($backup.Path)" -Color "Gray"
                Remove-Item -Path $backup.Path -Recurse -Force
            }
        }
        
        Write-Success-Log "Удаление завершено!"
    } else {
        Write-Host "Для удаления выполните:" -ForegroundColor "Cyan"
        Write-Host "  .\test-old-backup-analysis.ps1 -AutoConfirm" -ForegroundColor "Gray"
        Write-Host ""
    }
    
    Write-Host "⚠️  ЭТО ТЕСТОВЫЙ АНАЛИЗ (в _TEST_ENV)" -ForegroundColor "Yellow"
    Write-Host ""
    Write-Host "Для очистки тестовой среды:" -ForegroundColor "Cyan"
    Write-Host "  .\cleanup-test-env.ps1" -ForegroundColor "Gray"
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
