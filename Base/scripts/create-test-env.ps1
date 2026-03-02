# ============================================================================
# CREATE TEST ENVIRONMENT
# ============================================================================
# Назначение: Создание изолированной тестовой среды для безопасного тестирования
# Использование: .\scripts\create-test-env.ps1
# ============================================================================

param(
    [string]$SourceRoot = "D:\QwenPoekt\Base",
    
    [string]$TestEnvRoot = "D:\QwenPoekt\_TEST_ENV",
    
    [string[]]$ExcludeFolders = @(
        "PROJECTS",
        "OLD",
        "RELEASE",
        "_LOCAL_ARCHIVE",
        "BOOK",
        "_BACKUP",
        ".git",
        "node_modules",
        "*.pdf",
        "*.zip",
        "*.rar"
    ),
    
    [switch]$Force
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
    
    # Запись в файл (если папка существует)
    if (Test-Path (Split-Path $LogPath -Parent)) {
        $logEntry | Out-File $LogPath -Append -Encoding UTF8
    }
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
    Write-Log "=== СОЗДАНИЕ ТЕСТОВОЙ СРЕДЫ ===" -Color "Yellow"
    
    # ------------------------------------------------------------------------
    # ШАГ 0: Проверка источника
    # ------------------------------------------------------------------------
    Write-Log "Шаг 0: Проверка источника..."
    
    if (!(Test-Path-Safe -Path $SourceRoot)) {
        Write-Error-Log "Источник не существует: $SourceRoot"
        exit 1
    }
    
    Write-Success-Log "Источник найден: $SourceRoot"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Проверка существующей тестовой среды
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Проверка существующей тестовой среды..."
    
    if (Test-Path-Safe -Path $TestEnvRoot) {
        if ($Force) {
            Write-Warning-Log "Тестовая среда существует. Удаление (-Force)..."
            Remove-Item -Path $TestEnvRoot -Recurse -Force
            Write-Success-Log "Старая тестовая среда удалена"
        } else {
            Write-Warning-Log "Тестовая среда уже существует!"
            Write-Host ""
            Write-Host "Варианты:" -ForegroundColor "Cyan"
            Write-Host "  1. Использовать существующую (без создания)" -ForegroundColor "Gray"
            Write-Host "  2. Удалить и создать заново: .\create-test-env.ps1 -Force" -ForegroundColor "Gray"
            Write-Host "  3. Очистить: .\cleanup-test-env.ps1" -ForegroundColor "Gray"
            Write-Host ""
            
            $existingSize = Get-Folder-Size-MB -Path $TestEnvRoot
            $existingFiles = Get-File-Count -Path $TestEnvRoot
            Write-Info-Log "Существующий размер: $existingSize MB"
            Write-Info-Log "Существующих файлов: $existingFiles"
            
            exit 0
        }
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Создание структуры папок
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Создание структуры папок..."
    
    Ensure-Directory-Exists -Path $TestEnvRoot
    Ensure-Directory-Exists -Path "$TestEnvRoot\Base"
    Ensure-Directory-Exists -Path "$TestEnvRoot\_BACKUP"
    Ensure-Directory-Exists -Path "$TestEnvRoot\reports"
    
    Write-Success-Log "Структура создана"
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Копирование файлов (с исключениями)
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Копирование файлов..."
    Write-Info-Log "Исключения: $($ExcludeFolders -join ', ')"
    
    # Получить все файлы из источника
    $allFiles = Get-ChildItem -Path $SourceRoot -Recurse -File -ErrorAction SilentlyContinue
    
    # Отфильтровать исключения
    $filesToCopy = @()
    foreach ($file in $allFiles) {
        $exclude = $false
        
        # Проверка на исключения по папкам
        foreach ($excludeFolder in $ExcludeFolders) {
            if ($file.FullName -like "*\$excludeFolder\*" -or 
                $file.FullName -like "*\$excludeFolder") {
                $exclude = $true
                break
            }
        }
        
        # Проверка на исключения по расширениям
        if (!$exclude) {
            foreach ($excludePattern in $ExcludeFolders) {
                if ($excludePattern -like "*.*" -and $file.Name -like $excludePattern) {
                    $exclude = $true
                    break
                }
            }
        }
        
        if (!$exclude) {
            $filesToCopy += $file
        }
    }
    
    $totalFiles = $filesToCopy.Count
    $totalSize = ($filesToCopy | Measure-Object -Property Length -Sum).Sum / 1MB
    
    Write-Info-Log "Файлов к копированию: $totalFiles"
    Write-Info-Log "Общий размер: $([math]::Round($totalSize, 2)) MB"
    
    # Копирование
    Write-Log "Копирование (это может занять несколько минут)..."
    $copiedCount = 0
    $progressCounter = 0
    
    foreach ($file in $filesToCopy) {
        $relativePath = $file.FullName.Replace($SourceRoot, "").TrimStart("\")
        $destPath = Join-Path "$TestEnvRoot\Base" $relativePath
        
        # Создать папку назначения
        $destDir = Split-Path $destPath -Parent
        Ensure-Directory-Exists -Path $destDir
        
        # Копировать файл
        Copy-Item -Path $file.FullName -Destination $destPath -Force
        
        $copiedCount++
        $progressCounter++
        
        # Вывод прогресса каждые 100 файлов
        if ($progressCounter -ge 100) {
            Write-Info-Log "Скопировано: $copiedCount из $totalFiles файлов"
            $progressCounter = 0
        }
    }
    
    Write-Success-Log "Скопировано файлов: $copiedCount"
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Проверка целостности
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Проверка целостности..."
    
    $sourceCount = Get-File-Count -Path $SourceRoot
    $testCount = Get-File-Count -Path "$TestEnvRoot\Base"
    
    # С учётом исключений
    $expectedCount = $sourceCount - ($allFiles.Count - $filesToCopy.Count)
    
    Write-Info-Log "Файлов в источнике: $sourceCount (с учётом исключений: $expectedCount)"
    Write-Info-Log "Файлов в тестовой среде: $testCount"
    
    if ($testCount -ne $copiedCount) {
        Write-Warning-Log "Несоответствие: ожидалось $copiedCount, скопировано $testCount"
    } else {
        Write-Success-Log "Целостность подтверждена: $testCount файлов"
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 5: Создание тестовых скриптов
    # ------------------------------------------------------------------------
    Write-Log "Шаг 5: Создание тестовых скриптов..."
    
    # Создать папку scripts в тестовой среде
    Ensure-Directory-Exists -Path "$TestEnvRoot\Base\scripts"
    
    # Обновить пути в тестовых скриптах
    $testScripts = @(
        "pre-operation-backup.ps1",
        "safe-delete.ps1",
        "old-backup-analysis.ps1"
    )
    
    foreach ($scriptName in $testScripts) {
        $sourceScript = Join-Path $SourceRoot "scripts\$scriptName"
        $testScript = Join-Path "$TestEnvRoot\Base\scripts" "test-$scriptName"
        
        if (Test-Path-Safe -Path $sourceScript) {
            $content = Get-Content $sourceScript -Raw
            
            # Заменить пути на тестовые
            $content = $content -replace 
                [regex]::Escape('D:\QwenPoekt\Base'), 
                [regex]::Escape('D:\QwenPoekt\_TEST_ENV\Base')
            
            $content = $content -replace 
                [regex]::Escape('D:\QwenPoekt\_BACKUP'), 
                [regex]::Escape('D:\QwenPoekt\_TEST_ENV\_BACKUP')
            
            # Сохранить тестовый скрипт
            $content | Out-File -FilePath $testScript -Encoding UTF8
            Write-Info-Log "Создан тестовый скрипт: test-$scriptName"
        }
    }
    
    Write-Success-Log "Тестовые скрипты созданы"
    
    # ------------------------------------------------------------------------
    # ШАГ 6: Создание отчёта
    # ------------------------------------------------------------------------
    Write-Log "Шаг 6: Создание отчёта..."
    
    $testSize = Get-Folder-Size-MB -Path $TestEnvRoot
    $testFiles = Get-File-Count -Path $TestEnvRoot
    
    $report = @"
# Отчёт о создании тестовой среды

**Дата создания:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Источник:** $SourceRoot
**Назначение:** $TestEnvRoot

## Параметры

| Параметр | Значение |
|----------|----------|
| Файлов скопировано | $copiedCount |
| Общий размер | $([math]::Round($testSize, 2)) MB |
| Исключено папок | $($ExcludeFolders.Count) |
| Исключения | $($ExcludeFolders -join ', ') |

## Структура

``````
$TestEnvRoot/
├── Base/                    # Копия Base (без PROJECTS, OLD, RELEASE)
│   ├── scripts/             # Скрипты (оригинал + test-*)
│   ├── reports/             # Отчёты
│   └── ...                  # Другие папки
├── _BACKUP/                 # Тестовые бэкапы
└── reports/                 # Логи тестов
``````

## Тестовые скрипты

- ``````test-pre-operation-backup.ps1``````
- ``````test-safe-delete.ps1``````
- ``````test-old-backup-analysis.ps1``````

## Использование

``````powershell
# Запустить тесты
.\test-pre-operation-backup.ps1 -OperationType "Test"
.\test-safe-delete.ps1 -Path "_drafts" -WhatIf
.\test-old-backup-analysis.ps1

# Очистить после тестов
.\cleanup-test-env.ps1
``````

## Безопасность

⚠️  **ВСЕ тесты только в _TEST_ENV!**

Скрипты проверяют пути и не выходят за пределы _TEST_ENV.

---

**Создано:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** create-test-env.ps1
"@
    
    $report | Out-File -FilePath "$TestEnvRoot\reports\CREATE_TEST_ENV_REPORT.md" -Encoding UTF8
    Write-Success-Log "Отчёт сохранён: $TestEnvRoot\reports\CREATE_TEST_ENV_REPORT.md"
    
    # ------------------------------------------------------------------------
    # ШАГ 7: Инициализация лога тестов
    # ------------------------------------------------------------------------
    Write-Log "Шаг 7: Инициализация лога тестов..."
    
    $logHeader = @"
# Журнал тестов

**Создано:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Тестовая среда:** $TestEnvRoot

---

"@
    
    $logHeader | Out-File -FilePath $LogPath -Encoding UTF8
    Write-Success-Log "Лог инициализирован: $LogPath"
    
    # ------------------------------------------------------------------------
    # ЗАВЕРШЕНИЕ
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Success-Log "ТЕСТОВАЯ СРЕДА ГОТОВА!" -Color "Green"
    Write-Host ""
    Write-Host "Путь: $TestEnvRoot" -ForegroundColor "White"
    Write-Host "Размер: $([math]::Round($testSize, 2)) MB" -ForegroundColor "White"
    Write-Host "Файлов: $testFiles" -ForegroundColor "White"
    Write-Host ""
    Write-Host "Тестовые скрипты:" -ForegroundColor "Cyan"
    Write-Host "  .\test-pre-operation-backup.ps1" -ForegroundColor "Gray"
    Write-Host "  .\test-safe-delete.ps1" -ForegroundColor "Gray"
    Write-Host "  .\test-old-backup-analysis.ps1" -ForegroundColor "Gray"
    Write-Host ""
    Write-Host "Для очистки после тестов:" -ForegroundColor "Cyan"
    Write-Host "  .\cleanup-test-env.ps1" -ForegroundColor "Gray"
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
