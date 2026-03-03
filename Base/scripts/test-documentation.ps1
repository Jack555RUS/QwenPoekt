# test-documentation.ps1 — Тестирование документации
# Версия: 1.0
# Дата: 2026-03-04
# Назначение: Валидация Markdown документации перед коммитом

param(
    [string]$Path = ".",
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
Write-Log "║         ТЕСТ ДОКУМЕНТАЦИИ $(Get-Date -Format 'HH:mm:ss')                ║"
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

Write-Log "Путь: $Path"
$recursiveText = if ($Recursive) { "Да" } else { "Нет" }
Write-Log "Рекурсивно: $recursiveText"
Write-Log ""

# Сбор файлов
Write-Log "[1/4] Сбор файлов..."
$files = Get-ChildItem @getParams -File
Write-Log "  Найдено файлов: $($files.Count)"
Write-Log ""

# Счётчики
$totalTests = 0
$passedTests = 0
$failedTests = 0
$errors = @()

# Тесты
foreach ($file in $files) {
    Write-Log "Тест: $($file.Name)" -Color "Gray"
    
    $content = Get-Content $file.FullName -Raw
    
    # Тест 1: Front matter
    $totalTests++
    if ($content -match '^---\s*$') {
        Write-Log "  ✅ Front matter" -Color "Green"
        $passedTests++
    } else {
        Write-Log "  ❌ Front matter отсутствует" -Color "Red"
        $failedTests++
        $errors += "$($file.Name): Нет front matter"
        
        if ($Fix) {
            $frontMatter = @"
---
title: $($file.BaseName -replace '-', ' ')
version: 1.0
date: $(Get-Date -Format 'yyyy-MM-dd')
status: draft
---

"@
            $frontMatter + $content | Set-Content $file.FullName -Encoding UTF8
            Write-Log "  ✅ Front matter добавлен" -Color "Green"
        }
    }
    
    # Тест 2: Заголовок H1
    $totalTests++
    if ($content -match '^#\s+.+') {
        Write-Log "  ✅ Заголовок H1" -Color "Green"
        $passedTests++
    } else {
        Write-Log "  ❌ Заголовок H1 отсутствует" -Color "Red"
        $failedTests++
        $errors += "$($file.Name): Нет заголовка H1"
    }
    
    # Тест 3: Битые ссылки (внутренние)
    $totalTests++
    $links = [regex]::Matches($content, '\[([^\]]+)\]\(([^)]+)\)')
    $brokenLinks = @()
    
    foreach ($link in $links) {
        $url = $link.Groups[2].Value
        if ($url -notmatch '^https?://|^#|^mailto:') {
            $linkPath = ($url -split '#')[0]
            if ($linkPath -and $linkPath -notmatch '\.md$') {
                # Проверка существования файла
                $resolved = Resolve-Path (Join-Path $file.DirectoryName $linkPath) -ErrorAction SilentlyContinue
                if (-not $resolved) {
                    $brokenLinks += $url
                }
            }
        }
    }
    
    if ($brokenLinks.Count -eq 0) {
        Write-Log "  ✅ Ссылки рабочие" -Color "Green"
        $passedTests++
    } else {
        Write-Log "  ⚠️ Битых ссылок: $($brokenLinks.Count)" -Color "Yellow"
        $failedTests++
        $errors += "$($file.Name): $($brokenLinks.Count) битых ссылок"
    }
    
    # Тест 4: Encoding UTF-8
    $totalTests++
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $bom = $bytes[0..2]
    if ($bom[0] -eq 0xEF -and $bom[1] -eq 0xBB -and $bom[2] -eq 0xBF) {
        Write-Log "  ⚠️ BOM обнаружен (требуется UTF-8 без BOM)" -Color "Yellow"
        $failedTests++
        $errors += "$($file.Name): BOM в файле"
        
        if ($Fix) {
            $content | Set-Content $file.FullName -Encoding UTF8
            Write-Log "  ✅ BOM удалён" -Color "Green"
        }
    } else {
        Write-Log "  ✅ UTF-8 без BOM" -Color "Green"
        $passedTests++
    }
    
    Write-Log ""
}

# Итог
Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║                    ИТОГИ ТЕСТОВ                          ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""
Write-Log "Всего тестов: $totalTests" -Color "Cyan"
Write-Log "Пройдено: $passedTests" -Color "Green"
Write-Log "Провалено: $failedTests" -Color $(if ($failedTests -gt 0) { "Red" } else { "Green" })
Write-Log ""

$percent = [Math]::Round(($passedTests / $totalTests) * 100, 2)
Write-Log "Процент прохождения: $percent%" -Color $(if ($percent -ge 80) { "Green" } elseif ($percent -ge 50) { "Yellow" } else { "Red" })
Write-Log ""

if ($errors.Count -gt 0) {
    Write-Log "Ошибки:" -Color "Red"
    foreach ($error in $errors) {
        Write-Log "  • $error" -Color "Red"
    }
    Write-Log ""
}

# Выход
if ($failedTests -gt 0) {
    exit 1
} else {
    Write-Log "✅ ВСЕ ТЕСТЫ ПРОЙДЕНЫ!" -Color "Green"
    exit 0
}
