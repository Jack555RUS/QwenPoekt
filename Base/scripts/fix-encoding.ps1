# fix-encoding.ps1 — Проверка и исправление encoding файлов
# Версия: 1.0
# Дата: 2026-03-04
# Назначение: Проверка UTF-8 без BOM и исправление

param(
    [string]$Path = ".",
    [string]$Filter = "*.md",
    [switch]$Recursive,
    [switch]$Verbose,
    [switch]$Fix
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host $Message -ForegroundColor $Color
}

Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║         ПРОВЕРКА ENCODING $(Get-Date -Format 'HH:mm:ss')                ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""

# Параметры
$getParams = @{
    Path = $Path
    Filter = $Filter
    ErrorAction = "SilentlyContinue"
}

if ($Recursive) {
    $getParams.Recurse = $true
}

Write-Log "Путь: $Path"
Write-Log "Фильтр: $Filter"
$recursiveText = if ($Recursive) { "Да" } else { "Нет" }
Write-Log "Рекурсивно: $recursiveText"
Write-Log "Исправление: $($Fix ? 'Да' : 'Нет')"
Write-Log ""

# Сбор файлов
Write-Log "[1/3] Сбор файлов..."
$files = Get-ChildItem @getParams -File
Write-Log "  Найдено файлов: $($files.Count)"
Write-Log ""

# Счётчики
$totalFiles = $files.Count
$filesWithBOM = 0
$filesWithoutBOM = 0
$fixedFiles = 0
$errors = @()

# Проверка
Write-Log "[2/3] Проверка encoding..."
Write-Log ""

foreach ($file in $files) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    
    # Проверка BOM (UTF-8 BOM: EF BB BF)
    $hasBOM = $false
    if ($bytes.Length -ge 3) {
        if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            $hasBOM = $true
        }
    }
    
    if ($hasBOM) {
        Write-Log "  ❌ BOM: $($file.Name)" -Color "Red"
        $filesWithBOM++
        $errors += $file.FullName
        
        if ($Fix) {
            # Чтение содержимого
            $content = Get-Content $file.FullName -Raw
            
            # Перезапись без BOM
            $content | Set-Content $file.FullName -Encoding UTF8
            Write-Log "     ✅ BOM удалён" -Color "Green"
            $fixedFiles++
        }
    } else {
        Write-Log "  ✅ UTF-8 без BOM: $($file.Name)" -Color "Green"
        $filesWithoutBOM++
    }
    
    if ($Verbose -and -not $hasBOM) {
        # Проверка наличия кириллицы
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        if ($content -match '[\x{0400}-\x{04FF}]') {
            Write-Log "     Содержит кириллицу" -Color "Gray"
        }
    }
}

Write-Log ""

# Итог
Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║                    ИТОГИ                                 ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""
Write-Log "Всего файлов: $totalFiles" -Color "Cyan"
Write-Log "Без BOM: $filesWithoutBOM" -Color "Green"
Write-Log "С BOM: $filesWithBOM" -Color $(if ($filesWithBOM -gt 0) { "Red" } else { "Cyan" })

if ($Fix) {
    Write-Log "Исправлено: $fixedFiles" -Color "Green"
}

Write-Log ""

if ($errors.Count -gt 0) {
    Write-Log "Файлы с BOM:" -Color "Red"
    foreach ($error in $errors) {
        Write-Log "  • $error" -Color "Red"
    }
    Write-Log ""
    
    if (-not $Fix) {
        Write-Log "Для исправления используйте:" -Color "Yellow"
        Write-Log "  .\scripts\fix-encoding.ps1 -Path `"$Path`" -Filter `"$Filter`" -Fix" -Color "Gray"
        Write-Log ""
    }
}

# Выход
if ($filesWithBOM -gt 0) {
    exit 1
} else {
    Write-Log "✅ ВСЕ ФАЙЛЫ В UTF-8 БЕЗ BOM!" -Color "Green"
    exit 0
}
