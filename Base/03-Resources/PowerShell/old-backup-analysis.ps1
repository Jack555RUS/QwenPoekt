# ============================================================================
# OLD BACKUP ANALYSIS
# ============================================================================
# Назначение: Глубокий анализ бэкапов старше 45 дней
# Использование: .\scripts\old-backup-analysis.ps1
# ============================================================================

param(
    [string]$BackupRoot = "D:\QwenPoekt\_BACKUP",
    
    [string]$SourceRoot = "D:\QwenPoekt\Base",
    
    [int]$DaysThreshold = 45,
    
    [int]$AnalysisDaysThreshold = 60,
    
    [switch]$AutoConfirm,
    
    [string]$ReportPath = "D:\QwenPoekt\Base\reports\BACKUP_ANALYSIS_REPORT.md"
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

function Get-File-Hash-Safe {
    param([string]$Path)
    try {
        return (Get-FileHash -Path $Path -Algorithm MD5 -ErrorAction SilentlyContinue).Hash
    } catch {
        return $null
    }
}

function Get-All-Files {
    param([string]$Path)
    try {
        return Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | 
               Select-Object FullName, RelativePath, Length, LastWriteTime
    } catch {
        return @()
    }
}

function Compare-Backups {
    param(
        [string]$BackupPath,
        [string]$SourcePath
    )
    
    $result = @{
        Deleted = @()      # Файлы удалены из Base
        Moved = @()        # Файлы перемещены
        Renamed = @()      # Файлы переименованы
        Modified = @()     # Файлы изменены
        Unique = @()       # Файлы только в бэкапе
        Unchanged = @()    # Файлы без изменений
    }
    
    Write-Info-Log "Сравнение файлов..."
    
    # Получить все файлы
    $backupFiles = Get-All-Files -Path $BackupPath
    $sourceFiles = Get-All-Files -Path $SourcePath
    
    # Создать словарь для быстрого поиска
    $sourceDict = @{}
    foreach ($file in $sourceFiles) {
        $relativePath = $file.FullName.Replace($SourcePath, "").TrimStart("\")
        $sourceDict[$relativePath] = $file
    }
    
    # Сравнить каждый файл бэкапа
    foreach ($backupFile in $backupFiles) {
        $relativePath = $backupFile.FullName.Replace($BackupPath, "").TrimStart("\")
        
        if ($sourceDict.ContainsKey($relativePath)) {
            # Файл существует в Base
            $sourceFile = $sourceDict[$relativePath]
            
            # Проверить размер (быстрая проверка)
            if ($backupFile.Length -ne $sourceFile.Length) {
                $result.Modified += @{
                    Path = $relativePath
                    BackupSize = $backupFile.Length
                    SourceSize = $sourceFile.Length
                }
            } else {
                # Проверить хэш (медленная, но точная проверка)
                $backupHash = Get-File-Hash-Safe -Path $backupFile.FullName
                $sourceHash = Get-File-Hash-Safe -Path $sourceFile.FullName
                
                if ($backupHash -ne $sourceHash) {
                    $result.Modified += @{
                        Path = $relativePath
                        BackupHash = $backupHash
                        SourceHash = $sourceHash
                    }
                } else {
                    $result.Unchanged += $relativePath
                }
            }
        } else {
            # Файл не найден в Base → удалён или перемещён
            $result.Deleted += $relativePath
        }
    }
    
    # Найти уникальные файлы (только в бэкапе)
    $backupPaths = $backupFiles | ForEach-Object { $_.FullName.Replace($BackupPath, "").TrimStart("\") }
    $sourcePaths = $sourceFiles | ForEach-Object { $_.FullName.Replace($SourcePath, "").TrimStart("\") }
    
    $uniqueFiles = $backupPaths | Where-Object { $_ -notin $sourcePaths }
    $result.Unique = $uniqueFiles
    
    return $result
}

function Analyze-Value {
    param(
        [hashtable]$ComparisonResult,
        [int]$FileCount,
        [double]$FolderSizeMB
    )
    
    $score = 0
    $reasons = @()
    
    # Фактор 1: Уникальные файлы (только в бэкапе)
    if ($ComparisonResult.Unique.Count -gt 0) {
        $score += 30
        $reasons += "Есть уникальные файлы ( $($ComparisonResult.Unique.Count) )"
    }
    
    # Фактор 2: Удалённые файлы (возможно, ценные)
    if ($ComparisonResult.Deleted.Count -gt 0) {
        $score += 20
        $reasons += "Файлы удалены из Base ( $($ComparisonResult.Deleted.Count) )"
    }
    
    # Фактор 3: Изменённые файлы (история изменений)
    if ($ComparisonResult.Modified.Count -gt 0) {
        $score += 15
        $reasons += "Есть изменённые файлы ( $($ComparisonResult.Modified.Count) )"
    }
    
    # Фактор 4: Большой размер
    if ($FolderSizeMB -gt 100) {
        $score += 10
        $reasons += "Большой размер ( $([math]::Round($FolderSizeMB, 2)) MB )"
    }
    
    # Фактор 5: Много файлов
    if ($FileCount -gt 100) {
        $score += 10
        $reasons += "Много файлов ( $FileCount )"
    }
    
    # Фактор 6: Критичные папки в имени
    $backupName = Split-Path $BackupPath -Leaf
    if ($backupName -like "*KNOWLEDGE*" -or $backupName -like "*scripts*") {
        $score += 25
        $reasons += "Критичные данные в имени"
    }
    
    # Рекомендация
    $recommendation = "DELETE"
    if ($score -ge 50) {
        $recommendation = "KEEP"
    } elseif ($score -ge 30) {
        $recommendation = "REVIEW"
    }
    
    return @{
        Score = $score
        Recommendation = $recommendation
        Reasons = $reasons
    }
}

function Generate-Report {
    param(
        [array]$AnalysisResults
    )
    
    $report = @"
# Отчёт анализа бэкапов

**Дата генерации:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Порог анализа:** $DaysThreshold дней
**Порог удаления:** $AnalysisDaysThreshold дней
**Всего бэкапов проанализировано:** $($AnalysisResults.Count)

---

## Сводка

"@
    
    $deleteCount = ($AnalysisResults | Where-Object { $_.Value.Recommendation -eq "DELETE" }).Count
    $keepCount = ($AnalysisResults | Where-Object { $_.Value.Recommendation -eq "KEEP" }).Count
    $reviewCount = ($AnalysisResults | Where-Object { $_.Value.Recommendation -eq "REVIEW" }).Count
    $totalSize = ($AnalysisResults | Measure-Object -Property { $_.Value.FolderSizeMB } -Sum).Sum
    
    $report += @"
| Категория | Количество | Размер |
|-----------|------------|--------|
| 🔴 К удалению | $deleteCount | $([math]::Round(($AnalysisResults | Where-Object { $_.Value.Recommendation -eq "DELETE" } | Measure-Object -Property { $_.Value.FolderSizeMB } -Sum).Sum, 2)) MB |
| 🟢 Сохранить | $keepCount | $([math]::Round(($AnalysisResults | Where-Object { $_.Value.Recommendation -eq "KEEP" } | Measure-Object -Property { $_.Value.FolderSizeMB } -Sum).Sum, 2)) MB |
| 🟡 На проверку | $reviewCount | $([math]::Round(($AnalysisResults | Where-Object { $_.Value.Recommendation -eq "REVIEW" } | Measure-Object -Property { $_.Value.FolderSizeMB } -Sum).Sum, 2)) MB |
| **ВСЕГО** | $($AnalysisResults.Count) | $([math]::Round($totalSize, 2)) MB |

---

## Детальный анализ

"@
    
    foreach ($result in $AnalysisResults) {
        $backupName = Split-Path $result.Key -Leaf
        $report += @"

### $backupName

**Путь:** ``````$($result.Key)``````
**Дата бэкапа:** $($result.Value.BackupDate)
**Дней с момента бэкапа:** $($result.Value.DaysOld)
**Файлов:** $($result.Value.FileCount)
**Размер:** $([math]::Round($result.Value.FolderSizeMB, 2)) MB

**Рекомендация:** $(
    if ($result.Value.Recommendation -eq "DELETE") { "🔴 УДАЛИТЬ" }
    elseif ($result.Value.Recommendation -eq "KEEP") { "🟢 СОХРАНИТЬ" }
    else { "🟡 ПРОВЕРИТЬ" }
) (Очки: $($result.Value.Score))

**Причины:**
$($result.Value.Reasons | ForEach-Object { "- $_" })

**Изменения:**
- Удалено из Base: $($result.Value.Comparison.Deleted.Count) файлов
- Изменено: $($result.Value.Comparison.Modified.Count) файлов
- Уникальные (только в бэкапе): $($result.Value.Comparison.Unique.Count) файлов
- Без изменений: $($result.Value.Comparison.Unchanged.Count) файлов

---
"@
    }
    
    $report += @"

## Приложения

### A. Список бэкапов к удалению

$($AnalysisResults | Where-Object { $_.Value.Recommendation -eq "DELETE" } | ForEach-Object { "- ``````$($_.Key)``````" })

### B. Список бэкапов на сохранение

$($AnalysisResults | Where-Object { $_.Value.Recommendation -eq "KEEP" } | ForEach-Object { "- ``````$($_.Key)``````" })

### C. Команды для удаления

``````powershell
# Удалить все бэкапы с рекомендацией DELETE
$($AnalysisResults | Where-Object { $_.Value.Recommendation -eq "DELETE" } | ForEach-Object { "Remove-Item `"$($_.Key)`" -Recurse -Force" })
``````

---

**Отчёт сгенерирован:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** old-backup-analysis.ps1
"@
    
    return $report
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== АНАЛИЗ СТАРЫХ БЭКАПОВ ===" -Color "Yellow"
    Write-Log "Порог анализа: $DaysThreshold дней" -Color "Yellow"
    Write-Log "Порог удаления: $AnalysisDaysThreshold дней" -Color "Yellow"
    
    # ------------------------------------------------------------------------
    # ШАГ 0: Проверка папки _BACKUP
    # ------------------------------------------------------------------------
    Write-Log "Шаг 0: Проверка папки _BACKUP..."
    
    if (!(Test-Path-Safe -Path $BackupRoot)) {
        Write-Error-Log "Папка _BACKUP не существует: $BackupRoot"
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
        exit 0
    }
    
    Write-Log "Найдено бэкапов: $($oldBackups.Count)" -Color "Green"
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Глубокий анализ каждого бэкапа
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Глубокий анализ..."
    
    $analysisResults = @{}
    
    foreach ($backup in $oldBackups) {
        Write-Host ""
        Write-Log "Анализ: $($backup.Name)" -Color "White"
        Write-Info-Log "  Возраст: $($backup.Age) дней"
        
        $fileCount = Get-File-Count -Path $backup.Path
        $folderSize = Get-Folder-Size-MB -Path $backup.Path
        
        Write-Info-Log "  Файлов: $fileCount"
        Write-Info-Log "  Размер: $folderSize MB"
        
        # Сравнение с Base
        $comparison = Compare-Backups -BackupPath $backup.Path -SourcePath $SourceRoot
        
        # Оценка ценности
        $valueAnalysis = Analyze-Value -ComparisonResult $comparison -FileCount $fileCount -FolderSizeMB $folderSize
        
        $analysisResults[$backup.Path] = @{
            BackupDate = $backup.CreationTime
            DaysOld = $backup.Age
            FileCount = $fileCount
            FolderSizeMB = $folderSize
            Comparison = $comparison
            Score = $valueAnalysis.Score
            Recommendation = $valueAnalysis.Recommendation
            Reasons = $valueAnalysis.Reasons
        }
        
        Write-Info-Log "  Рекомендация: $($valueAnalysis.Recommendation) (Очки: $($valueAnalysis.Score))"
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Генерация отчёта
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Генерация отчёта..."
    
    $report = Generate-Report -AnalysisResults $analysisResults
    $report | Out-File -FilePath $ReportPath -Encoding UTF8
    
    Write-Success-Log "Отчёт сохранён: $ReportPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Запись в журнал операций
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Запись в журнал..."
    
    $deleteCount = ($analysisResults.Values | Where-Object { $_.Recommendation -eq "DELETE" }).Count
    $keepCount = ($analysisResults.Values | Where-Object { $_.Recommendation -eq "KEEP" }).Count
    $reviewCount = ($analysisResults.Values | Where-Object { $_.Recommendation -eq "REVIEW" }).Count
    
    $logEntry = @"

## $(Get-Date -Format 'yyyy-MM-dd HH:mm') Анализ старых бэкапов

**Тип:** Глубокий анализ бэкапов >$DaysThreshold дней

**Параметры:**
- Бэкапов найдено: $($oldBackups.Count)
- К удалению: $deleteCount
- Сохранить: $keepCount
- На проверку: $reviewCount

**Отчёт:** $ReportPath

**Статус:** ✅ Завершено

---
"@
    
    Add-Content -Path $LogPath -Value $logEntry -Encoding UTF8
    Write-Success-Log "Запись в журнал: $LogPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 5: Вывод сводки
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Log "=== СВОДКА ===" -Color "Yellow"
    Write-Host ""
    Write-Host "Всего бэкапов: $($oldBackups.Count)" -ForegroundColor "White"
    Write-Host "  🔴 К удалению: $deleteCount" -ForegroundColor "Red"
    Write-Host "  🟢 Сохранить: $keepCount" -ForegroundColor "Green"
    Write-Host "  🟡 На проверку: $reviewCount" -ForegroundColor "Yellow"
    Write-Host ""
    Write-Host "Отчёт: $ReportPath" -ForegroundColor "Cyan"
    Write-Host ""
    
    if ($AutoConfirm -and $deleteCount -gt 0) {
        Write-Warning-Log "AutoConfirm: Удаление бэкапов с рекомендацией DELETE..."
        
        foreach ($result in $analysisResults.GetEnumerator()) {
            if ($result.Value.Recommendation -eq "DELETE") {
                Write-Log "Удаление: $($result.Key)" -Color "Gray"
                Remove-Item -Path $result.Key -Recurse -Force
            }
        }
        
        Write-Success-Log "Удаление завершено!"
    } else {
        Write-Host "Для удаления выполните:" -ForegroundColor "Cyan"
        Write-Host "  .\scripts\old-backup-analysis.ps1 -AutoConfirm" -ForegroundColor "Gray"
        Write-Host ""
    }
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
