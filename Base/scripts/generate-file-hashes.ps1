# ============================================================================
# GENERATE FILE HASHES
# ============================================================================
# Назначение: Создание индекса хэшей (SHA-256) для всех файлов Базы Знаний
# Использование: .\scripts\generate-file-hashes.ps1
# ============================================================================

param(
    [string]$SourceRoot = "D:\QwenPoekt\Base",
    
    [string]$OutputPath = "D:\QwenPoekt\Base\meta\file_hashes.json",
    
    [string[]]$ExcludeFolders = @(
        "PROJECTS",
        "OLD",
        "RELEASE",
        "_LOCAL_ARCHIVE",
        "BOOK",
        "_BACKUP",
        "_TEST_ENV",
        ".git",
        "node_modules"
    ),
    
    [switch]$Force
)

$ErrorActionPreference = "Stop"

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

function Ensure-Directory-Exists {
    param([string]$Path)
    if (!(Test-Path-Safe -Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
}

function Get-File-Hash-Safe {
    param([string]$Path)
    try {
        return (Get-FileHash -Path $Path -Algorithm SHA256 -ErrorAction SilentlyContinue).Hash
    } catch {
        return $null
    }
}

function Get-Relative-Path {
    param(
        [string]$FullPath,
        [string]$Root
    )
    return $FullPath.Replace($Root, "").TrimStart("\")
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ГЕНЕРАЦИЯ ИНДЕКСА ХЭШЕЙ ===" -Color "Yellow"
    
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
    # ШАГ 1: Проверка существующего индекса
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Проверка существующего индекса..."
    
    if (Test-Path-Safe -Path $OutputPath) {
        if ($Force) {
            Write-Info-Log "Индекс существует. Пересоздание (-Force)..."
        } else {
            Write-Info-Log "Индекс существует. Используйте -Force для пересоздания."
            Write-Host ""
            Write-Host "Варианты:" -ForegroundColor "Cyan"
            Write-Host "  1. Использовать существующий индекс" -ForegroundColor "Gray"
            Write-Host "  2. Пересоздать: .\generate-file-hashes.ps1 -Force" -ForegroundColor "Gray"
            Write-Host ""
            
            $existingIndex = Get-Content $OutputPath -Raw | ConvertFrom-Json
            Write-Info-Log "Существующий индекс:"
            Write-Info-Log "  Создан: $($existingIndex.generated)"
            Write-Info-Log "  Файлов: $($existingIndex.files.Count)"
            
            exit 0
        }
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Сбор всех файлов
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Сбор всех файлов..."
    Write-Info-Log "Исключения: $($ExcludeFolders -join ', ')"
    
    $allFiles = Get-ChildItem -Path $SourceRoot -Recurse -File -ErrorAction SilentlyContinue
    
    # Отфильтровать исключения
    $filesToHash = @()
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
        
        # Исключить служебные файлы
        if (!$exclude) {
            $excludePatterns = @("*.json", "*.log", "*.tmp")
            foreach ($pattern in $excludePatterns) {
                if ($file.Name -like $pattern -and $file.Name -ne "file_hashes.json") {
                    # Пропускаем только временные файлы, но не json
                }
            }
        }
        
        if (!$exclude) {
            $filesToHash += $file
        }
    }
    
    $totalFiles = $filesToHash.Count
    Write-Info-Log "Файлов для хэширования: $totalFiles"
    
    if ($totalFiles -eq 0) {
        Write-Error-Log "Нет файлов для хэширования!"
        exit 1
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Вычисление хэшей
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Вычисление хэшей SHA-256..."
    
    $hashIndex = @{
        generated = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
        sourceRoot = $SourceRoot
        totalFiles = 0
        files = @()
    }
    
    $processedCount = 0
    $progressCounter = 0
    
    foreach ($file in $filesToHash) {
        $relativePath = Get-Relative-Path -FullPath $file.FullName -Root $SourceRoot
        
        # Вычислить хэш
        $hash = Get-File-Hash-Safe -Path $file.FullName
        
        if ($hash) {
            $hashIndex.files += @{
                path = $relativePath
                hash = $hash
                size = $file.Length
                added = Get-Date -Format "yyyy-MM-dd"
                modified = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
            }
            
            $processedCount++
            $progressCounter++
            
            # Вывод прогресса каждые 50 файлов
            if ($progressCounter -ge 50) {
                Write-Info-Log "Обработано: $processedCount из $totalFiles файлов"
                $progressCounter = 0
            }
        } else {
            Write-Info-Log "⚠️  Пропущен: $relativePath"
        }
    }
    
    $hashIndex.totalFiles = $hashIndex.files.Count
    
    Write-Success-Log "Хэшей вычислено: $($hashIndex.totalFiles)"
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Поиск дубликатов (по хэшу)
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Поиск дубликатов..."
    
    $hashGroups = @{}
    foreach ($fileEntry in $hashIndex.files) {
        $hash = $fileEntry.hash
        if (!$hashGroups.ContainsKey($hash)) {
            $hashGroups[$hash] = @()
        }
        $hashGroups[$hash] += $fileEntry.path
    }
    
    $duplicateCount = 0
    foreach ($hash in $hashGroups.Keys) {
        if ($hashGroups[$hash].Count -gt 1) {
            $duplicateCount++
            Write-Info-Log "Дубликат (хэш: $($hash.Substring(0, 16))...):"
            Write-Info-Log "  $($hashGroups[$hash] -join "`n  ")"
        }
    }
    
    if ($duplicateCount -gt 0) {
        Write-Log "Найдено групп дубликатов: $duplicateCount" -Color "Yellow"
    } else {
        Write-Success-Log "Дубликатов не найдено"
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 5: Сохранение индекса
    # ------------------------------------------------------------------------
    Write-Log "Шаг 5: Сохранение индекса..."
    
    Ensure-Directory-Exists -Path (Split-Path $OutputPath -Parent)
    
    # Конвертация в JSON
    $jsonContent = $hashIndex | ConvertTo-Json -Depth 10
    $jsonContent | Out-File -FilePath $OutputPath -Encoding UTF8
    
    Write-Success-Log "Индекс сохранён: $OutputPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 6: Статистика
    # ------------------------------------------------------------------------
    Write-Log "Шаг 6: Статистика..."
    
    $totalSize = ($hashIndex.files | Measure-Object -Property size -Sum).sum
    $avgSize = if ($hashIndex.totalFiles -gt 0) { [math]::Round($totalSize / $hashIndex.totalFiles / 1KB, 2) } else { 0 }
    
    Write-Info-Log "Всего файлов: $($hashIndex.totalFiles)"
    Write-Info-Log "Общий размер: $([math]::Round($totalSize / 1MB, 2)) MB"
    Write-Info-Log "Средний размер файла: $avgSize KB"
    Write-Info-Log "Групп дубликатов: $duplicateCount"
    
    # ------------------------------------------------------------------------
    # ЗАВЕРШЕНИЕ
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Success-Log "ИНДЕКС ХЭШЕЙ СОЗДАН!" -Color "Green"
    Write-Host ""
    Write-Host "Путь: $OutputPath" -ForegroundColor "White"
    Write-Host "Файлов: $($hashIndex.totalFiles)" -ForegroundColor "White"
    Write-Host "Дубликатов: $duplicateCount групп" -ForegroundColor $(if ($duplicateCount -gt 0) { "Yellow" } else { "Green" })
    Write-Host ""
    Write-Host "Для проверки дубликатов:" -ForegroundColor "Cyan"
    Write-Host "  .\scripts\check-hash-duplicates.ps1" -ForegroundColor "Gray"
    Write-Host ""
    Write-Host "Для еженедельного аудита:" -ForegroundColor "Cyan"
    Write-Host "  .\scripts\weekly-dedup-audit.ps1" -ForegroundColor "Gray"
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
