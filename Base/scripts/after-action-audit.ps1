# after-action-audit.ps1 — Аудит после действия
# Версия: 1.0
# Дата: 4 марта 2026 г.
# Назначение: Сравнение ДО/ПОСЛЕ действий, поиск непредвиденных изменений

param(
    [string]$Action,        # delete, move, rename, create, modify
    [string]$Target,        # Цель действия (файл/папка)
    [string]$SnapshotBefore, # Снимок ДО (JSON файл)
    [switch]$Verbose,
    [switch]$Log
)

$ErrorActionPreference = "Stop"

# Пути
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$AuditLogPath = Join-Path $BasePath "reports\after-action-audit.log"

# Логирование
function Write-Log {
    param($msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $msg"

    if ($Log) {
        Add-Content -Path $AuditLogPath -Value $logEntry
    }

    if ($Verbose) {
        Write-Host $logEntry -ForegroundColor Cyan
    }
}

Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║         POST-ACTION AUDIT — $(Get-Date -Format 'HH:mm:ss')          ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"

# ============================================
# 1. СОЗДАНИЕ СНИМКА СОСТОЯНИЯ
# ============================================

function New-SystemSnapshot {
    param(
        [string]$OutputPath
    )

    Write-Log "[1/4] Создание снимка системы..."

    $snapshot = @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Files = @()
        GitStatus = ""
    }

    # Получение списка файлов (ограничено 1000)
    $files = Get-ChildItem $BasePath -Recurse -File -Exclude "*.log", "*.tmp" | Select-Object -First 1000
    foreach ($file in $files) {
        $snapshot.Files += @{
            Path = $file.FullName.Replace($BasePath, "").TrimStart("\")
            Size = $file.Length
            LastWriteTime = $file.LastWriteTime
        }
    }

    # Git статус
    try {
        $gitStatus = git status --porcelain 2>$null
        $snapshot.GitStatus = $gitStatus
    } catch {
        $snapshot.GitStatus = "Git error: $_"
    }

    # Сохранение снимка
    $snapshot | ConvertTo-Json -Depth 3 | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Log "  ✅ Снимок сохранён: $OutputPath"

    return $snapshot
}

# ============================================
# 2. СРАВНЕНИЕ СНИМКОВ
# ============================================

function Compare-SystemSnapshots {
    param(
        [string]$BeforePath,
        [string]$AfterPath
    )

    Write-Log "[2/4] Сравнение снимков..."

    if (-not (Test-Path $BeforePath)) {
        Write-Log "  ❌ Снимок ДО не найден: $BeforePath"
        return $null
    }

    if (-not (Test-Path $AfterPath)) {
        Write-Log "  ❌ Снимок ПОСЛЕ не найден: $AfterPath"
        return $null
    }

    $before = Get-Content $BeforePath -Raw | ConvertFrom-Json
    $after = Get-Content $AfterPath -Raw | ConvertFrom-Json

    $diff = @{
        NewFiles = @()
        DeletedFiles = @()
        ModifiedFiles = @()
        GitChanges = @()
    }

    # Сравнение файлов
    $beforeFiles = $before.Files | ForEach-Object { $_.Path }
    $afterFiles = $after.Files | ForEach-Object { $_.Path }

    # Новые файлы
    foreach ($file in $afterFiles) {
        if ($file -notin $beforeFiles) {
            $diff.NewFiles += $file
        }
    }

    # Удалённые файлы
    foreach ($file in $beforeFiles) {
        if ($file -notin $afterFiles) {
            $diff.DeletedFiles += $file
        }
    }

    # Изменённые файлы (по размеру или времени)
    foreach ($beforeFile in $before.Files) {
        $afterFile = $after.Files | Where-Object { $_.Path -eq $beforeFile.Path }
        if ($afterFile) {
            if ($afterFile.Size -ne $beforeFile.Size -or $afterFile.LastWriteTime -ne $beforeFile.LastWriteTime) {
                $diff.ModifiedFiles += $beforeFile.Path
            }
        }
    }

    # Git изменения
    if ($before.GitStatus -ne $after.GitStatus) {
        $diff.GitChanges = $after.GitStatus
    }

    return $diff
}

# ============================================
# 3. ПРОВЕРКА НАРУШЕНИЙ ПРАВИЛ
# ============================================

function Test-RuleViolations {
    param(
        [array]$NewFiles,
        [array]$DeletedFiles
    )

    Write-Log "[3/4] Проверка нарушений правил..."

    $violations = @()

    # Проверка 1: Создание файлов напрямую в Base/ (A-002)
    foreach ($file in $NewFiles) {
        if ($file -like "*.md" -and $file -notlike "_drafts\*" -and $file -notlike "_TEST_ENV\*") {
            if ($file -notlike "reports\*" -and $file -notlike "scripts\*" -and $file -notlike "03-Resources\*") {
                $violations += @{
                    Rule = "A-002"
                    Description = "Создание файла напрямую в Base/: $file"
                    Severity = "High"
                }
            }
        }
    }

    # Проверка 2: Удаление без проверки (A-003)
    foreach ($file in $DeletedFiles) {
        $violations += @{
            Rule = "A-003"
            Description = "Удаление файла: $file (проверить pre-action-validator)"
            Severity = "Medium"
        }
    }

    # Проверка 3: Encoding с BOM (A-004)
    foreach ($file in $NewFiles) {
        if ($file -like "*.ps1" -or $file -like "*.bat" -or $file -like "*.cmd") {
            $fullPath = Join-Path $BasePath $file
            if (Test-Path $fullPath) {
                $bytes = [System.IO.File]::ReadAllBytes($fullPath)
                if ($bytes.Count -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
                    $violations += @{
                        Rule = "A-004"
                        Description = "Файл с BOM: $file"
                        Severity = "High"
                    }
                }
            }
        }
    }

    return $violations
}

# ============================================
# 4. ОТЧЁТ
# ============================================

function Write-AuditReport {
    param(
        [pscustomobject]$Diff,
        [array]$Violations
    )

    Write-Log "[4/4] Формирование отчёта..."

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "ОТЧЁТ POST-ACTION AUDIT" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

    # Новые файлы
    if ($Diff.NewFiles.Count -gt 0) {
        Write-Host "`n📄 Новые файлы ($($Diff.NewFiles.Count)):" -ForegroundColor Green
        foreach ($file in $Diff.NewFiles[0..9]) {
            Write-Host "  + $file" -ForegroundColor Green
        }
        if ($Diff.NewFiles.Count -gt 10) {
            Write-Host "  ... и ещё $($Diff.NewFiles.Count - 10) файлов" -ForegroundColor Gray
        }
    }

    # Удалённые файлы
    if ($Diff.DeletedFiles.Count -gt 0) {
        Write-Host "`n🗑️ Удалённые файлы ($($Diff.DeletedFiles.Count)):" -ForegroundColor Yellow
        foreach ($file in $Diff.DeletedFiles[0..9]) {
            Write-Host "  - $file" -ForegroundColor Yellow
        }
        if ($Diff.DeletedFiles.Count -gt 10) {
            Write-Host "  ... и ещё $($Diff.DeletedFiles.Count - 10) файлов" -ForegroundColor Gray
        }
    }

    # Изменённые файлы
    if ($Diff.ModifiedFiles.Count -gt 0) {
        Write-Host "`n✏️ Изменённые файлы ($($Diff.ModifiedFiles.Count)):" -ForegroundColor Cyan
        foreach ($file in $Diff.ModifiedFiles[0..9]) {
            Write-Host "  ~ $file" -ForegroundColor Cyan
        }
        if ($Diff.ModifiedFiles.Count -gt 10) {
            Write-Host "  ... и ещё $($Diff.ModifiedFiles.Count - 10) файлов" -ForegroundColor Gray
        }
    }

    # Нарушения
    if ($Violations.Count -gt 0) {
        Write-Host "`n⚠️ НАРУШЕНИЯ ПРАВИЛ ($($Violations.Count)):" -ForegroundColor Red
        foreach ($v in $Violations) {
            Write-Host "  [$($v.Severity)] $($v.Rule): $($v.Description)" -ForegroundColor Red
        }
    } else {
        Write-Host "`n✅ Нарушений не обнаружено" -ForegroundColor Green
    }

    Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
}

# ============================================
# ГЛАВНАЯ ФУНКЦИЯ
# ============================================

Write-Log "Action: $Action, Target: $Target"

# Создание снимка ПОСЛЕ
$snapshotAfterPath = Join-Path $BasePath "reports\snapshot-after-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
New-SystemSnapshot -OutputPath $snapshotAfterPath

# Если есть снимок ДО — сравниваем
if ($SnapshotBefore) {
    $diff = Compare-SystemSnapshots -BeforePath $SnapshotBefore -AfterPath $snapshotAfterPath
    
    if ($diff) {
        $violations = Test-RuleViolations -NewFiles $diff.NewFiles -DeletedFiles $diff.DeletedFiles
        Write-AuditReport -Diff $diff -Violations $violations
    }
} else {
    Write-Log "  ℹ️  Снимок ДО не указан — создан только снимок ПОСЛЕ"
    Write-Host "`n✅ Снимок системы сохранён: $snapshotAfterPath" -ForegroundColor Green
    Write-Host "   Используйте его для сравнения при следующем запуске" -ForegroundColor Gray
}

Write-Log "Аудит завершён"
