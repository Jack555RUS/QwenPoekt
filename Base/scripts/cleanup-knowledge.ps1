# cleanup-knowledge.ps1 — Очистка БИБЛИОТЕКИ от дубликатов и устаревших файлов
# Версия: 1.0
# Дата: 2026-03-04
# Назначение: Анализ и удаление дубликатов/устаревших файлов

param(
    [string]$Path = "03-Resources/Knowledge",
    [switch]$DryRun,     # Сухой запуск (без удаления)
    [switch]$Verbose,
    [int]$DaysOld = 60   # Файлы старше этого возраста
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host $Message -ForegroundColor $Color
}

Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║         ОЧИСТКА БИБЛИОТЕКИ $(Get-Date -Format 'HH:mm:ss')               ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""

Write-Log "Путь: $Path"
$dryRunText = if ($DryRun) { "Да (без удаления)" } else { "Нет" }
Write-Log "Сухой запуск: $dryRunText"
Write-Log "Дней для устаревших: $DaysOld"
Write-Log ""

# Сбор файлов
Write-Log "[1/4] Сбор файлов..."
$files = Get-ChildItem -Path $Path -Filter "*.md" -Recurse -File
Write-Log "  Найдено файлов: $($files.Count)"
Write-Log ""

# Анализ по категориям
Write-Log "[2/4] Анализ категорий..."
Write-Log ""

$categories = @{
    "SESSION" = @()
    "ANALYSIS" = @()
    "REPORT" = @()
    "AUDIT" = @()
    "INVESTIGATION" = @()
    "OTHER" = @()
}

foreach ($file in $files) {
    $name = $file.Name.ToUpper()
    
    if ($name -match "SESSION") {
        $categories["SESSION"] += $file
    } elseif ($name -match "ANALYSIS") {
        $categories["ANALYSIS"] += $file
    } elseif ($name -match "REPORT") {
        $categories["REPORT"] += $file
    } elseif ($name -match "AUDIT") {
        $categories["AUDIT"] += $file
    } elseif ($name -match "INVESTIGATION|MISSING") {
        $categories["INVESTIGATION"] += $file
    } else {
        $categories["OTHER"] += $file
    }
}

Write-Log "  SESSION файлы: $($categories["SESSION"].Count)"
Write-Log "  ANALYSIS файлы: $($categories["ANALYSIS"].Count)"
Write-Log "  REPORT файлы: $($categories["REPORT"].Count)"
Write-Log "  AUDIT файлы: $($categories["AUDIT"].Count)"
Write-Log "  INVESTIGATION файлы: $($categories["INVESTIGATION"].Count)"
Write-Log "  OTHER файлы: $($categories["OTHER"].Count)"
Write-Log ""

# Устаревшие файлы
Write-Log "[3/4] Поиск устаревших файлов (> $DaysOld дней)..."
Write-Log ""

$cutoffDate = (Get-Date).AddDays(-$DaysOld)
$oldFiles = $files | Where-Object { $_.LastWriteTime -lt $cutoffDate }

Write-Log "  Найдено устаревших: $($oldFiles.Count)"

if ($Verbose -and $oldFiles.Count -gt 0) {
    Write-Log ""
    Write-Log "  Устаревшие файлы:" -ForegroundColor "Yellow"
    foreach ($file in $oldFiles | Sort-Object LastWriteTime) {
        $days = [Math]::Round((Get-Date) - $file.LastWriteTime).Days
        Write-Log "    • $($file.Name) ($days дней)" -ForegroundColor "Gray"
    }
}
Write-Log ""

# Потенциальные дубликаты
Write-Log "[4/4] Поиск потенциальных дубликатов..."
Write-Log ""

# Группировка по ключевым словам
$duplicates = @()

# SESSION файлы
if ($categories["SESSION"].Count -gt 3) {
    $duplicates += @{
        Category = "SESSION"
        Files = $categories["SESSION"]
        Reason = "Много файлов сессий"
    }
}

# ANALYSIS файлы
if ($categories["ANALYSIS"].Count -gt 3) {
    $duplicates += @{
        Category = "ANALYSIS"
        Files = $categories["ANALYSIS"]
        Reason = "Много файлов анализа"
    }
}

# REPORT файлы
if ($categories["REPORT"].Count -gt 5) {
    $duplicates += @{
        Category = "REPORT"
        Files = $categories["REPORT"]
        Reason = "Много отчётов"
    }
}

if ($duplicates.Count -gt 0) {
    Write-Log "  Найдено групп дубликатов: $($duplicates.Count)" -ForegroundColor "Yellow"
    Write-Log ""
    
    foreach ($dup in $duplicates) {
        Write-Log "  $($dup.Category) ($($dup.Reason)):" -ForegroundColor "Yellow"
        foreach ($file in $dup.Files | Select-Object -First 5) {
            Write-Log "    • $($file.Name)" -ForegroundColor "Gray"
        }
        if ($dup.Files.Count -gt 5) {
            Write-Log "    ... и ещё $($dup.Files.Count - 5)" -ForegroundColor "Gray"
        }
        Write-Log ""
    }
} else {
    Write-Log "  Дубликаты не найдены" -ForegroundColor "Green"
}
Write-Log ""

# Итог
Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║                    ИТОГИ                                 ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""
Write-Log "Всего файлов: $($files.Count)" -Color "Cyan"
Write-Log "Устаревших: $($oldFiles.Count)" -Color $(if ($oldFiles.Count -gt 0) { "Yellow" } else { "Green" })
Write-Log "Групп дубликатов: $($duplicates.Count)" -Color $(if ($duplicates.Count -gt 0) { "Yellow" } else { "Green" })
Write-Log ""

if ($DryRun) {
    Write-Log "Это пробный запуск. Для реального удаления:" -Color "Yellow"
    Write-Log "  .\scripts\cleanup-knowledge.ps1 -Path `"$Path`"" -Color "Gray"
    Write-Log ""
} else {
    Write-Log "Для удаления используйте:" -Color "Yellow"
    Write-Log "  .\scripts\cleanup-knowledge.ps1 -Path `"$Path`" -RemoveOld -RemoveDuplicates" -Color "Gray"
    Write-Log ""
}
