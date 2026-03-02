# ============================================================================
# CLEANUP TEST ENVIRONMENT
# ============================================================================
# Назначение: Очистка тестовой среды после тестирования
# Использование: .\scripts\cleanup-test-env.ps1
# ============================================================================

param(
    [string]$TestEnvRoot = "D:\QwenPoekt\_TEST_ENV",
    
    [switch]$WhatIf,
    
    [switch]$Force,
    
    [switch]$SaveLogs
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
        Write-Host ""
        exit 0
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Подтверждение (если не Force)
    # ------------------------------------------------------------------------
    if (!$Force) {
        Write-Host ""
        Write-Host "ВНИМАНИЕ: Будет удалена тестовая среда!" -ForegroundColor "Yellow"
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
    # ШАГ 5: Удаление тестовой среды
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Удаление тестовой среды..."
    
    Write-Info-Log "Удаление: $TestEnvRoot"
    Remove-Item -Path $TestEnvRoot -Recurse -Force
    
    # Проверка удаления
    if (Test-Path-Safe -Path $TestEnvRoot) {
        Write-Error-Log "Не удалось удалить тестовую среду!"
        exit 1
    }
    
    Write-Success-Log "Тестовая среда удалена"
    
    # ------------------------------------------------------------------------
    # ШАГ 6: Запись в лог (если сохранили)
    # ------------------------------------------------------------------------
    if ($SaveLogs) {
        Write-Log "Шаг 4: Запись в лог..."
        
        $logEntry = @"

## $(Get-Date -Format 'yyyy-MM-dd HH:mm') Очистка тестовой среды

**Тип:** Очистка с сохранением логов

**Параметры:**
- Путь: $TestEnvRoot
- Размер: $([math]::Round($testSize, 2)) MB
- Файлов: $testFiles
- Сохранение логов: Да

**Статус:** ✅ Успешно

---
"@
        
        $mainLogPath = "D:\QwenPoekt\Base\reports\OPERATION_LOG.md"
        if (Test-Path $mainLogPath) {
            Add-Content -Path $mainLogPath -Value $logEntry -Encoding UTF8
        }
    }
    
    # ------------------------------------------------------------------------
    # ЗАВЕРШЕНИЕ
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Success-Log "ОЧИСТКА ЗАВЕРШЕНА!" -Color "Green"
    Write-Host ""
    
    if ($SaveLogs) {
        Write-Host "Логи сохранены:" -ForegroundColor "White"
        Write-Host "  D:\QwenPoekt\Base\reports\test-logs\" -ForegroundColor "Gray"
        Write-Host ""
    }
    
    Write-Host "Для создания новой тестовой среды:" -ForegroundColor "Cyan"
    Write-Host "  .\create-test-env.ps1" -ForegroundColor "Gray"
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
