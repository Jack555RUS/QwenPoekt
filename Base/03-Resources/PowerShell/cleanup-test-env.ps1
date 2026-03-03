# ============================================================================
# CLEANUP TEST ENVIRONMENT
# ============================================================================
# Назначение: Умная очистка тестовой среды с сохранением структуры и истории
# Использование: .\scripts\cleanup-test-env.ps1 [-Archive] [-WhatIf] [-Force]
# ============================================================================

param(
    [string]$TestEnvRoot = "D:\QwenPoekt\_TEST_ENV",
    
    [string]$LocalArchiveRoot = "D:\QwenPoekt\Base\_LOCAL_ARCHIVE",
    
    [switch]$WhatIf,
    
    [switch]$Force,
    
    [switch]$SaveLogs,
    
    [switch]$ArchiveTests
)

$ErrorActionPreference = "Stop"
$LogPath = "D:\QwenPoekt\_TEST_ENV\reports\TEST_LOG.md"

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

function Test-Path-Safe {
    param([string]$Path)
    try {
        return Test-Path $Path
    } catch {
        return $false
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

function Get-File-Count {
    param([string]$Path)
    try {
        $files = Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
        return $files.Count
    } catch {
        return 0
    }
}

function Save-Test-Logs {
    param(
        [string]$SourcePath,
        [string]$DestPath
    )
    
    $logsPath = Join-Path $SourcePath "reports"
    
    if (Test-Path-Safe -Path $logsPath) {
        Ensure-Directory-Exists -Path $DestPath
        
        $logFiles = Get-ChildItem -Path $logsPath -File -Filter "*.md"
        foreach ($logFile in $logFiles) {
            Copy-Item -Path $logFile.FullName -Destination $DestPath -Force
            Write-Info-Log "Сохранён лог: $($logFile.Name)"
        }
    }
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
    Write-Log "=== ОЧИСТКА ТЕСТОВОЙ СРЕДЫ ===" -Color "Yellow"
    
    # ------------------------------------------------------------------------
    # ШАГ 0: Проверка тестовой среды
    # ------------------------------------------------------------------------
    Write-Log "Шаг 0: Проверка тестовой среды..."
    
    if (!(Test-Path-Safe -Path $TestEnvRoot)) {
        Write-Warning-Log "Тестовая среда не существует: $TestEnvRoot"
        Write-Info-Log "Нечего очищать"
        exit 0
    }
    
    Write-Success-Log "Тестовая среда найдена: $TestEnvRoot"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Анализ перед очисткой
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Анализ перед очисткой..."
    
    $testSize = Get-Folder-Size-MB -Path $TestEnvRoot
    $testFiles = Get-File-Count -Path $TestEnvRoot
    
    Write-Info-Log "Размер: $([math]::Round($testSize, 2)) MB"
    Write-Info-Log "Файлов: $testFiles"
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Сохранение логов (если SaveLogs)
    # ------------------------------------------------------------------------
    if ($SaveLogs) {
        Write-Log "Шаг 2: Сохранение логов..."
        
        $logsDestPath = "D:\QwenPoekt\Base\reports\test-logs"
        Ensure-Directory-Exists -Path $logsDestPath
        
        Save-Test-Logs -SourcePath $TestEnvRoot -DestPath $logsDestPath
        
        Write-Success-Log "Логи сохранены: $logsDestPath"
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 3: WhatIf режим (только проверка)
    # ------------------------------------------------------------------------
    if ($WhatIf) {
        Write-Log "⚠️  РЕЖИМ ПРОВЕРКИ (WhatIf)" -Color "Yellow"
        Write-Log "Очистка НЕ будет выполнена. Только информация:"
        Write-Log "  Путь: $TestEnvRoot"
        Write-Log "  Размер: $([math]::Round($testSize, 2)) MB"
        Write-Log "  Файлов: $testFiles"
        $saveLogsText = if ($SaveLogs) { "Да" } else { "Нет" }
        Write-Log "  Сохранение логов: $saveLogsText"
        Write-Host ""
        Write-Host "Для реальной очистки запустите без -WhatIf" -ForegroundColor "Cyan"
        Write-Host "Для сохранения логов добавьте -SaveLogs" -ForegroundColor "Yellow"
        Write-Host "Для архивации тестов добавьте -ArchiveTests" -ForegroundColor "Yellow"
        Write-Host ""
        exit 0
    }

    # ------------------------------------------------------------------------
    # ШАГ 4: Подтверждение (если не Force)
    # ------------------------------------------------------------------------
    if (!$Force) {
        Write-Host ""
        Write-Host "ВНИМАНИЕ: Будет очищена тестовая среда!" -ForegroundColor "Yellow"
        Write-Host "  Путь: $TestEnvRoot" -ForegroundColor "Gray"
        Write-Host "  Размер: $([math]::Round($testSize, 2)) MB" -ForegroundColor "Gray"
        Write-Host ""
        Write-Host "Продолжить? (Y/N) " -ForegroundColor "Yellow" -NoNewline

        $response = Read-Host

        if ($response -notlike "Y*" -and $response -notlike "y*") {
            Write-Log "Очистка отменена пользователем" -Color "Gray"
            exit 0
        }
    }

    # ------------------------------------------------------------------------
    # ШАГ 5: Архивация тестов (если ArchiveTests)
    # ------------------------------------------------------------------------
    if ($ArchiveTests) {
        Write-Log "Шаг 3: Архивация тестов..."
        
        $archivePath = Join-Path $LocalArchiveRoot "TESTS\$(Get-Date -Format 'yyyy-MM-dd_HH-mm')"
        Ensure-Directory-Exists -Path $archivePath
        
        # Копировать отчёты и логи
        $reportsPath = Join-Path $TestEnvRoot "reports"
        if (Test-Path-Safe -Path $reportsPath) {
            Copy-Item -Path $reportsPath -Destination $archivePath -Recurse -Force
            Write-Success-Log "Тесты архивированы: $archivePath"
        }
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 6: Сохранение логов (если SaveLogs)
    # ------------------------------------------------------------------------
    if ($SaveLogs) {
        Write-Log "Шаг 4: Сохранение логов..."

        $logsDestPath = "D:\QwenPoekt\Base\reports\test-logs"
        Ensure-Directory-Exists -Path $logsDestPath

        Save-Test-Logs -SourcePath $TestEnvRoot -DestPath $logsDestPath

        Write-Success-Log "Логи сохранены: $logsDestPath"
    }

    # ------------------------------------------------------------------------
    # ШАГ 7: Очистка содержимого (НЕ структуры!)
    # ------------------------------------------------------------------------
    Write-Log "Шаг 5: Очистка содержимого..."

    # Очистить Base/ (сохранить структуру)
    $basePath = Join-Path $TestEnvRoot "Base"
    if (Test-Path-Safe -Path $basePath) {
        Write-Info-Log "Очистка: $basePath"
        Get-ChildItem -Path $basePath -Recurse -File | Remove-Item -Force
        Get-ChildItem -Path $basePath -Recurse -Directory | Remove-Item -Force -Recurse
        Write-Success-Log "Base/ очищен"
    }
    
    # Очистить _BACKUP/ (сохранить папку)
    $backupPath = Join-Path $TestEnvRoot "_BACKUP"
    if (Test-Path-Safe -Path $backupPath) {
        Write-Info-Log "Очистка: $backupPath"
        Get-ChildItem -Path $backupPath -Recurse -File | Remove-Item -Force
        Get-ChildItem -Path $backupPath -Recurse -Directory | Remove-Item -Force -Recurse
        Write-Success-Log "_BACKUP/ очищен"
    }
    
    # Очистить reports/ (сохранить TEST_LOG.md)
    $reportsPath = Join-Path $TestEnvRoot "reports"
    if (Test-Path-Safe -Path $reportsPath) {
        Write-Info-Log "Очистка: $reportsPath (сохранение TEST_LOG.md)"
        Get-ChildItem -Path $reportsPath -Recurse -File | Where-Object { $_.Name -ne "TEST_LOG.md" } | Remove-Item -Force
        Write-Success-Log "reports/ очищен (TEST_LOG.md сохранён)"
    }

    Write-Success-Log "Тестовая среда очищена (структура сохранена)"
    
    Write-Host ""
    Write-Host "Структура сохранена:" -ForegroundColor "Green"
    Write-Host "  ✅ $TestEnvRoot" -ForegroundColor "Gray"
    Write-Host "  ✅ Base/" -ForegroundColor "Gray"
    Write-Host "  ✅ _BACKUP/" -ForegroundColor "Gray"
    Write-Host "  ✅ reports/ (TEST_LOG.md)" -ForegroundColor "Gray"
    Write-Host ""
    
    Write-Host "Для создания новой тестовой среды:" -ForegroundColor "Cyan"
    Write-Host "  .\create-test-env.ps1 -Force" -ForegroundColor "Gray"
    Write-Host ""
    Write-Host "Для архивации тестов в следующий раз:" -ForegroundColor "Yellow"
    Write-Host "  .\cleanup-test-env.ps1 -ArchiveTests" -ForegroundColor "Gray"
    Write-Host ""

} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
