# add-front-matter.ps1 — Добавление front matter к файлам
# Версия: 1.0
# Дата: 2026-03-04
# Назначение: Автоматическое добавление front matter к Markdown файлам

param(
    [string]$Path = ".",
    [switch]$Recursive,
    [switch]$Verbose,
    [switch]$WhatIf  # Сухой запуск
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host $Message -ForegroundColor $Color
}

Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║         ДОБАВЛЕНИЕ FRONT MATTER $(Get-Date -Format 'HH:mm:ss')          ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""

# Параметры
$getParams = @{
    Path = $Path
    Filter = "*.md"
    ErrorAction = "SilentlyContinue"
}

if ($Recursive) {
    $getParams.Recurse = $true
}

$recursiveText = if ($Recursive) { "Да" } else { "Нет" }
$whatIfText = if ($WhatIf) { "Да (без изменений)" } else { "Нет" }

Write-Log "Путь: $Path"
Write-Log "Рекурсивно: $recursiveText"
Write-Log "Сухой запуск: $whatIfText"
Write-Log ""

# Сбор файлов
Write-Log "[1/3] Сбор файлов..."
$files = Get-ChildItem @getParams -File
Write-Log "  Найдено файлов: $($files.Count)"
Write-Log ""

# Счётчики
$totalFiles = $files.Count
$filesWithFrontMatter = 0
$filesWithoutFrontMatter = 0
$addedFiles = 0

# Обработка
Write-Log "[2/3] Обработка файлов..."
Write-Log ""

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    # Проверка наличия front matter
    if ($content -match '^---\s*$') {
        Write-Log "  ✅ $($file.Name) — front matter есть" -Color "Green"
        $filesWithFrontMatter++
    } else {
        Write-Log "  ❌ $($file.Name) — front matter отсутствует" -Color "Red"
        $filesWithoutFrontMatter++
        
        # Генерация front matter
        $title = $file.BaseName -replace '-', ' ' -replace '_', ' '
        $title = (Get-Culture).TextInfo.ToTitleCase($title)
        
        $frontMatter = @"
---
title: $title
version: 1.0
date: $(Get-Date -Format 'yyyy-MM-dd')
status: draft
---

"@
        
        if ($WhatIf) {
            Write-Log "     [WhatIf] Front matter будет добавлен" -Color "Yellow"
        } else {
            # Добавление front matter
            $newContent = $frontMatter + $content
            $newContent | Set-Content $file.FullName -Encoding UTF8
            Write-Log "     ✅ Front matter добавлен" -Color "Green"
            $addedFiles++
        }
    }
    
    if ($Verbose -and ($content -match '^---\s*$')) {
        # Извлечение заголовка из front matter
        if ($content -match 'title:\s*(.+)') {
            Write-Log "     Title: $($matches[1])" -Color "Gray"
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
Write-Log "С front matter: $filesWithFrontMatter" -Color "Green"
Write-Log "Без front matter: $filesWithoutFrontMatter" -Color $(if ($filesWithoutFrontMatter -gt 0) { "Red" } else { "Cyan" })

if (-not $WhatIf) {
    Write-Log "Добавлено: $addedFiles" -Color "Green"
}

Write-Log ""

$percent = [Math]::Round(($filesWithFrontMatter / $totalFiles) * 100, 2)
Write-Log "Процент с front matter: $percent%" -Color $(if ($percent -ge 80) { "Green" } elseif ($percent -ge 50) { "Yellow" } else { "Red" })
Write-Log ""

if ($WhatIf) {
    Write-Log "Это пробный запуск. Для реального добавления:" -Color "Yellow"
    Write-Log "  .\scripts\add-front-matter.ps1 -Path `"$Path`" -Recursive" -Color "Gray"
    Write-Log ""
}

# Выход
if ($filesWithoutFrontMatter -gt 0 -and -not $WhatIf) {
    Write-Log "✅ Front matter добавлен к $addedFiles файлам!" -Color "Green"
    exit 0
} elseif ($filesWithoutFrontMatter -eq 0) {
    Write-Log "✅ ВСЕ ФАЙЛЫ С FRONT MATTER!" -Color "Green"
    exit 0
} else {
    exit 1
}
