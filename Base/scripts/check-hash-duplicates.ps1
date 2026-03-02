# ============================================================================
# CHECK HASH DUPLICATES
# ============================================================================
# Назначение: Проверка файлов на дубликаты по индексу хэшей
# Использование: .\scripts\check-hash-duplicates.ps1
# ============================================================================

param(
    [string]$IndexPath = "D:\QwenPoekt\Base\meta\file_hashes.json",
    
    [string]$SourceRoot = "D:\QwenPoekt\Base",
    
    [string]$ReportPath = "D:\QwenPoekt\Base\reports\DEDUP_AUDIT_REPORT.md",
    
    [switch]$AutoFix,
    
    [switch]$Verbose
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

function Get-File-Hash-Safe {
    param([string]$Path)
    try {
        return (Get-FileHash -Path $Path -Algorithm SHA256 -ErrorAction SilentlyContinue).Hash
    } catch {
        return $null
    }
}

function Find-Duplicates {
    param(
        [array]$Files
    )
    
    $hashGroups = @{}
    foreach ($file in $Files) {
        $hash = $file.hash
        if (!$hashGroups.ContainsKey($hash)) {
            $hashGroups[$hash] = @()
        }
        $hashGroups[$hash] += $file
    }
    
    $duplicates = @()
    foreach ($hash in $hashGroups.Keys) {
        if ($hashGroups[$hash].Count -gt 1) {
            $duplicates += @{
                Hash = $hash
                Files = $hashGroups[$hash]
            }
        }
    }
    
    return $duplicates
}

function Generate-Report {
    param(
        [array]$Duplicates,
        [string]$ReportPath
    )
    
    $report = @"
# Отчёт аудита дубликатов

**Дата генерации:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Индекс:** $IndexPath
**Всего групп дубликатов:** $($Duplicates.Count)

---

## Сводка

| Метрика | Значение |
|---------|----------|
| Групп дубликатов | $($Duplicates.Count) |
| Файлов в дубликатах | $(($Duplicates | ForEach-Object { $_.Files.Count }) | Measure-Object -Sum).Sum |
| Потенциальная экономия | TBD MB |

---

## Найденные дубликаты

"@
    
    $groupNum = 0
    foreach ($dupGroup in $Duplicates) {
        $groupNum++
        $report += @"

### Группа #$groupNum

**Хэш:** ``````$($dupGroup.Hash.Substring(0, 16))...``````
**Количество файлов:** $($dupGroup.Files.Count)

**Файлы:**
$($dupGroup.Files | ForEach-Object { "- ``````$($_.path)``````" })

**Рекомендация:**
$($dupGroup.Files.Count -eq 2 ? "Удалить один из файлов" : "Оставить один, удалить остальные")

---
"@
    }
    
    $report += @"

## Приложения

### A. Команды для удаления

``````powershell
# Просмотреть дубликаты
.\scripts\check-hash-duplicates.ps1 -Verbose

# Автоматическое удаление (ОПАСНО!)
.\scripts\check-hash-duplicates.ps1 -AutoFix
``````

### B. Матрица решений

| Тип дубликата | Пример | Действие |
|---------------|--------|----------|
| **Точный файл-копия** | file.md и file_copy.md | Удалить копию |
| **Разные форматы** | file.md и file.pdf | ✅ Оставить оба |
| **Новая версия** | file_v1.md и file_v2.md | ✅ Оставить обе, указать связь |
| **Перефразированное** | Два файла об одном | ⚠️ Объединить или связать |

---

**Отчёт сгенерирован:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** check-hash-duplicates.ps1
"@
    
    $report | Out-File -FilePath $ReportPath -Encoding UTF8
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ПРОВЕРКА ДУБЛИКАТОВ ПО ХЭШАМ ===" -Color "Yellow"
    
    # ------------------------------------------------------------------------
    # ШАГ 0: Проверка индекса
    # ------------------------------------------------------------------------
    Write-Log "Шаг 0: Проверка индекса..."
    
    if (!(Test-Path-Safe -Path $IndexPath)) {
        Write-Error-Log "Индекс не найден: $IndexPath"
        Write-Log "Сначала создайте индекс:" -Color "Gray"
        Write-Log "  .\scripts\generate-file-hashes.ps1" -Color "Gray"
        exit 1
    }
    
    Write-Success-Log "Индекс найден: $IndexPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Загрузка индекса
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Загрузка индекса..."
    
    $index = Get-Content $IndexPath -Raw | ConvertFrom-Json
    
    Write-Info-Log "Создан: $($index.generated)"
    Write-Info-Log "Файлов в индексе: $($index.totalFiles)"
    
    if ($index.totalFiles -eq 0) {
        Write-Error-Log "Индекс пуст!"
        exit 1
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Поиск дубликатов
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Поиск дубликатов..."
    
    $duplicates = Find-Duplicates -Files $index.files
    
    if ($duplicates.Count -eq 0) {
        Write-Success-Log "Дубликатов не найдено!"
        Write-Host ""
        Write-Host "Все файлы уникальны." -ForegroundColor "Green"
        Write-Host ""
        exit 0
    }
    
    Write-Warning-Log "Найдено групп дубликатов: $($duplicates.Count)"
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Вывод дубликатов
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Вывод дубликатов..."
    
    $groupNum = 0
    foreach ($dupGroup in $duplicates) {
        $groupNum++
        Write-Host ""
        Write-Log "Группа #$groupNum" -Color "White"
        Write-Info-Log "Хэш: $($dupGroup.Hash.Substring(0, 16))..."
        
        $fileNum = 0
        foreach ($file in $dupGroup.Files) {
            $fileNum++
            $fullPath = Join-Path $SourceRoot $file.path
            
            # Проверка существования файла
            $exists = Test-Path-Safe -Path $fullPath
            $existsMark = if ($exists) { "✅" } else { "❌" }
            
            Write-Info-Log "  $fileNum. $existsMark $($file.path)"
            Write-Info-Log "     Размер: $([math]::Round($file.size / 1KB, 2)) KB"
            Write-Info-Log "     Изменён: $($file.modified)"
        }
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Статистика
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Статистика..."
    
    $totalDuplicateFiles = ($duplicates | ForEach-Object { $_.Files.Count }) | Measure-Object -Sum
    $potentialSavings = 0
    
    foreach ($dupGroup in $duplicates) {
        # Экономия = (количество - 1) * размер файла
        $fileSize = $dupGroup.Files[0].size
        $savings = ($dupGroup.Files.Count - 1) * $fileSize
        $potentialSavings += $savings
    }
    
    Write-Info-Log "Всего файлов в дубликатах: $($totalDuplicateFiles.Sum)"
    Write-Info-Log "Потенциальная экономия: $([math]::Round($potentialSavings / 1KB, 2)) KB"
    
    # ------------------------------------------------------------------------
    # ШАГ 5: Генерация отчёта
    # ------------------------------------------------------------------------
    Write-Log "Шаг 5: Генерация отчёта..."
    
    Generate-Report -Duplicates $duplicates -ReportPath $ReportPath
    
    Write-Success-Log "Отчёт сохранён: $ReportPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 6: AutoFix (если запрошено)
    # ------------------------------------------------------------------------
    if ($AutoFix) {
        Write-Host ""
        Write-Warning-Log "AutoFix: Автоматическое удаление дубликатов..."
        Write-Host ""
        Write-Host "⚠️  ВНИМАНИЕ: Будут удалены все дубликаты, кроме первого в группе!" -ForegroundColor "Red"
        Write-Host "Для продолжения введите Y:" -ForegroundColor "Yellow" -NoNewline
        
        $response = Read-Host
        
        if ($response -eq "Y" -or $response -eq "y") {
            $deletedCount = 0
            
            foreach ($dupGroup in $duplicates) {
                # Оставить первый файл, удалить остальные
                for ($i = 1; $i -lt $dupGroup.Files.Count; $i++) {
                    $file = $dupGroup.Files[$i]
                    $fullPath = Join-Path $SourceRoot $file.path
                    
                    if (Test-Path-Safe -Path $fullPath) {
                        Write-Info-Log "Удаление: $($file.path)"
                        Remove-Item -Path $fullPath -Force
                        $deletedCount++
                    }
                }
            }
            
            Write-Success-Log "Удалено файлов: $deletedCount"
            
            # Перегенерировать индекс
            Write-Log "Перегенерация индекса..."
            & "$SourceRoot\scripts\generate-file-hashes.ps1" -Force
        } else {
            Write-Log "AutoFix отменён пользователем" -Color "Gray"
        }
    }
    
    # ------------------------------------------------------------------------
    # ЗАВЕРШЕНИЕ
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Success-Log "ПРОВЕРКА ЗАВЕРШЕНА!" -Color "Green"
    Write-Host ""
    Write-Host "Групп дубликатов: $($duplicates.Count)" -ForegroundColor $(if ($duplicates.Count -gt 0) { "Yellow" } else { "Green" })
    Write-Host "Файлов в дубликатах: $($totalDuplicateFiles.Sum)" -ForegroundColor "White"
    Write-Host "Потенциальная экономия: $([math]::Round($potentialSavings / 1KB, 2)) KB" -ForegroundColor "White"
    Write-Host ""
    Write-Host "Отчёт: $ReportPath" -ForegroundColor "Cyan"
    Write-Host ""
    
    if (!$AutoFix) {
        Write-Host "Для автоматического удаления:" -ForegroundColor "Cyan"
        Write-Host "  .\scripts\check-hash-duplicates.ps1 -AutoFix" -ForegroundColor "Gray"
        Write-Host ""
        Write-Host "Для ручного удаления:" -ForegroundColor "Cyan"
        Write-Host "  1. Откройте отчёт" -ForegroundColor "Gray"
        Write-Host "  2. Проверьте каждый дубликат" -ForegroundColor "Gray"
        Write-Host "  3. Удалите лишние файлы" -ForegroundColor "Gray"
        Write-Host ""
    }
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
