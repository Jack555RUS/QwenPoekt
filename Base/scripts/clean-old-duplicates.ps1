# ============================================================================
# CLEAN OLD DUPLICATES
# ============================================================================
# Назначение: Очистка OLD/ от дублей (бэкапы, копии, служебные папки)
# Использование: .\scripts\clean-old-duplicates.ps1 [-WhatIf] [-Confirm]
# ============================================================================

param(
    [string]$OldPath = "D:\QwenPoekt\Base\OLD",
    
    [string]$BackupRoot = "D:\QwenPoekt\_BACKUP",
    
    [switch]$WhatIf,
    
    [switch]$Confirm
)

$ErrorActionPreference = "Continue"

# ============================================================================
# СПИСКИ НА УДАЛЕНИЕ
# ============================================================================

# Папки-дубли (бэкапы проектов)
$DuplicateFolders = @(
    "DragRaceUnity_Backup",
    "DragRace1\DragRace_BACKUP_2026-02-25",
    "DragRace1\DragRace_BACKUP_2026-02-25",
    "ProbMenuOld"
)

# Служебные папки (не нужны в архиве)
$ServiceFolders = @(
    ".vs",
    ".vscode",
    "Logs",
    "Packages",
    "obj",
    "bin",
    "Builds",
    "publish",
    "echo",
    "move",
    "-p",
    "Папки созданы",
    "Готово"
)

# ============================================================================
# ФУНКЦИИ
# ============================================================================

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Write-Error-Log {
    param([string]$Message)
    Write-Log "❌ $Message" -Color "Red"
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

function Backup-And-Delete {
    param(
        [string]$FolderPath,
        [string]$Reason
    )
    
    try {
        if (!(Test-Path-Safe -Path $FolderPath)) {
            Write-Log "  Пропущено: не существует" -Color "Gray"
            return 0
        }
        
        $size = Get-Folder-Size-MB -Path $FolderPath
        
        if ($WhatIf) {
            Write-Log "  [WhatIf] Удалить: $FolderPath ($size MB)" -Color "Gray"
            return $size
        }
        
        # Бэкап перед удалением
        $backupPath = Join-Path $BackupRoot "old_cleanup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        $folderName = Split-Path $FolderPath -Leaf
        
        Write-Log "  Бэкап: $folderName → $backupPath" -Color "Gray"
        Copy-Item -Path $FolderPath -Destination $backupPath -Recurse -Force
        
        # Удаление
        Remove-Item -Path $FolderPath -Recurse -Force
        Write-Log "  ✅ Удалено: $FolderPath ($size MB)" -Color "Green"
        
        return $size
    } catch {
        Write-Error-Log "Ошибка: $FolderPath - $($_.Exception.Message)"
        return 0
    }
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ОЧИСТКА OLD/ ОТ ДУБЛЕЙ ===" -Color "Yellow"
    Write-Log "Путь: $OldPath"
    
    $Stats = @{
        DeletedCount = 0
        TotalSize = 0
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Удаление папок-дублей
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Удаление папок-дублей..."
    
    foreach ($folder in $DuplicateFolders) {
        $fullPath = Join-Path $OldPath $folder
        
        Write-Log "  Проверка: $folder"
        $size = Backup-And-Delete -FolderPath $fullPath -Reason "Дубль"
        
        if ($size -gt 0) {
            $Stats.DeletedCount++
            $Stats.TotalSize += $size
        }
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Удаление служебных папок
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Удаление служебных папок..."
    
    $serviceCount = 0
    
    foreach ($serviceFolder in $ServiceFolders) {
        $folders = Get-ChildItem -Path $OldPath -Recurse -Directory -Filter $serviceFolder -ErrorAction SilentlyContinue
        
        foreach ($folder in $folders) {
            # Пропускаем папки в _ANALYZED, _CODE_SNIPPETS, _IDEAS
            if ($folder.FullName -match "_ANALYZED|_CODE_SNIPPETS|_IDEAS") {
                continue
            }
            
            Write-Log "  Проверка: $($folder.FullName.Replace($OldPath, ''))"
            $size = Backup-And-Delete -FolderPath $folder.FullName -Reason "Служебная"
            
            if ($size -gt 0) {
                $Stats.DeletedCount++
                $Stats.TotalSize += $size
                $serviceCount++
            }
        }
    }
    
    Write-Log "  Удалено служебных папок: $serviceCount"
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Финальный отчёт
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Финальный отчёт..."
    
    Write-Host ""
    Write-Success-Log "ОЧИСТКА ЗАВЕРШЕНА!" -Color "Green"
    Write-Host ""
    Write-Host "Результаты:" -ForegroundColor "White"
    Write-Host "  Удалено папок: $($Stats.DeletedCount)" -ForegroundColor "White"
    Write-Host "  Освобождено места: $([math]::Round($Stats.TotalSize / 1MB, 2)) MB" -ForegroundColor "White"
    Write-Host ""
    
    if ($WhatIf) {
        Write-Warning-Log "РЕЖИМ WhatIf: Файлы не удалялись"
        Write-Host ""
        Write-Host "Для реальной очистки запустите без -WhatIf:" -ForegroundColor "Cyan"
        Write-Host "  .\scripts\clean-old-duplicates.ps1 -Confirm" -ForegroundColor "Gray"
        Write-Host ""
    }
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
