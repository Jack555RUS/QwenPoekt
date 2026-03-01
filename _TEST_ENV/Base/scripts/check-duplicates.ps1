# ============================================================================
# CHECK DUPLICATES
# Автоматическая проверка дубликатов в базе знаний
# ============================================================================
# Использование: .\scripts\check-duplicates.ps1 [-Path <путь>] [-Threshold <процент>]
# ============================================================================

param(
    [string]$Path = ".",
    [int]$Threshold = 80,  # Порог схожести (80% = высокий риск дубликата)
    [switch]$AutoFix
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "                    CHECK DUPLICATES                                        " -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Параметры:" -ForegroundColor Yellow
Write-Host "   Путь: $Path"
Write-Host "   Порог схожести: $Threshold%"
Write-Host "   Автоисправление: $(if ($AutoFix) { 'Да' } else { 'Нет' })"
Write-Host ""

# ============================================================================
# 1. ПРОВЕРКА НА ДУБЛИКАТЫ ПО ИМЕНИ
# ============================================================================

Write-Host "1. Проверка дубликатов по имени..." -ForegroundColor Yellow

$files = Get-ChildItem -Path $Path -Recurse -Filter "*.md" -File
$fileNameGroups = $files | Group-Object Name | Where-Object { $_.Count -gt 1 }

if ($fileNameGroups.Count -gt 0) {
    Write-Host "   ⚠️  Найдены дубликаты имён файлов:" -ForegroundColor Red
    foreach ($group in $fileNameGroups) {
        Write-Host "   - $($group.Name) ($($group.Count) файлов)" -ForegroundColor Red
        foreach ($file in $group.Group) {
            Write-Host "     • $($file.FullName)" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "   ✅ Дубликатов имён не найдено" -ForegroundColor Green
}

Write-Host ""

# ============================================================================
# 2. ПРОВЕРКА НА ДУБЛИКАТЫ ПО СОДЕРЖИМОМУ (хэши)
# ============================================================================

Write-Host "2. Проверка дубликатов по содержимому (хэши)..." -ForegroundColor Yellow

$fileHashGroups = @{}
foreach ($file in $files) {
    $hash = Get-FileHash $file.FullName -Algorithm SHA256
    if ($fileHashGroups.ContainsKey($hash.Hash)) {
        $fileHashGroups[$hash.Hash] += $file
    } else {
        $fileHashGroups[$hash.Hash] = @($file)
    }
}

$duplicateHashes = $fileHashGroups.GetEnumerator() | Where-Object { $_.Value.Count -gt 1 }

if ($duplicateHashes.Count -gt 0) {
    Write-Host "   ⚠️  Найдены точные дубликаты содержимого:" -ForegroundColor Red
    foreach ($hashGroup in $duplicateHashes) {
        Write-Host "   Хэш: $($hashGroup.Key.Substring(0, 16))..." -ForegroundColor Red
        foreach ($file in $hashGroup.Value) {
            Write-Host "     • $($file.FullName)" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "   ✅ Точных дубликатов содержимого не найдено" -ForegroundColor Green
}

Write-Host ""

# ============================================================================
# 3. ПРОВЕРКА НА ДУБЛИКАТЫ ПРАВИЛ (ключевые фразы)
# ============================================================================

Write-Host "3. Проверка дубликатов правил (ключевые фразы)..." -ForegroundColor Yellow

$rulePatterns = @(
    "Правило:",
    "**Правило:**",
    "### Правило",
    "ПРОВЕРКА ПЕРЕД",
    "перед перемещением",
    "перед внесением",
    "Матрица подтверждений",
    "🟢🟡🔴",
    "TDD",
    "verify-complete",
    "OLD/RELEASE",
    "OLD/_INBOX",
    "OLD/_ANALYZED",
    "OLD/_IDEAS",
    "OLD/_CODE_SNIPPETS",
    "OLD/_ARCHIVE_60D",
    "срок хранения",
    "45 дней",
    "60 дней",
    "7 дней",
    "snake_case",
    "kebab-case",
    "именование файлов"
)

$ruleDuplicates = @{}
foreach ($pattern in $rulePatterns) {
    $matches = Get-ChildItem -Path $Path -Recurse -Filter "*.md" -File |
        Select-String -Pattern $pattern -CaseSensitive:$false |
        Group-Object Path |
        Where-Object { $_.Count -gt 3 }  # Более 3 упоминаний в разных файлах
    
    if ($matches.Count -gt 0) {
        $ruleDuplicates[$pattern] = $matches
    }
}

if ($ruleDuplicates.Count -gt 0) {
    Write-Host "   ⚠️  Возможные дубликаты правил:" -ForegroundColor Yellow
    foreach ($pattern in $ruleDuplicates.Keys) {
        Write-Host "   Паттерн: '$pattern'" -ForegroundColor Yellow
        foreach ($match in $ruleDuplicates[$pattern]) {
            $count = ($match.Group | Measure-Object).Count
            Write-Host "     • $($match.Name) ($count упоминаний)" -ForegroundColor Gray
        }
    }
    Write-Host ""
    Write-Host "   💡 Совет: Проверьте эти файлы на дублирование правил" -ForegroundColor Cyan
    Write-Host "      Возможно, стоит оставить только в QWEN.md и AI_START_HERE.md" -ForegroundColor Cyan
} else {
    Write-Host "   ✅ Подозрительных дубликатов правил не найдено" -ForegroundColor Green
}

Write-Host ""

# ============================================================================
# 4. ПРОВЕРКА ССЫЛОК НА НЕСУЩЕСТВУЮЩИЕ ФАЙЛЫ
# ============================================================================

Write-Host "4. Проверка ссылок на несуществующие файлы..." -ForegroundColor Yellow

$brokenLinks = @()
foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $links = [regex]::Matches($content, '\[.*?\]\((.*?)\)') | ForEach-Object { $_.Groups[1].Value }
    
    foreach ($link in $links) {
        if ($link -match "^https?://") { continue }  # Пропускаем внешние ссылки
        if ($link -match "^#") { continue }  # Пропускаем якоря
        
        $targetPath = Join-Path (Split-Path $file.DirectoryName) $link
        if (!(Test-Path $targetPath)) {
            $brokenLinks += [PSCustomObject]@{
                File = $file.FullName
                Link = $link
                Target = $targetPath
            }
        }
    }
}

if ($brokenLinks.Count -gt 0) {
    Write-Host "   ⚠️  Найдены битые ссылки:" -ForegroundColor Red
    $brokenLinks | Group-Object File | ForEach-Object {
        Write-Host "   Файл: $($_.Name)" -ForegroundColor Red
        foreach ($link in $_.Group) {
            Write-Host "     • $($link.Link) → $($link.Target)" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "   ✅ Битых ссылок не найдено" -ForegroundColor Green
}

Write-Host ""

# ============================================================================
# 5. СТАТИСТИКА
# ============================================================================

Write-Host "5. Статистика:" -ForegroundColor Cyan

$totalFiles = $files.Count
$totalSize = ($files | Measure-Object -Property Length -Sum).Sum / 1KB
$duplicateFiles = ($fileNameGroups | Measure-Object -Property Count -Sum).Sum
$exactDuplicates = 0
foreach ($hashGroup in $duplicateHashes) {
    $exactDuplicates += $hashGroup.Value.Count
}

Write-Host "   Всего файлов: $totalFiles" -ForegroundColor White
Write-Host "   Общий размер: $([math]::Round($totalSize, 2)) KB" -ForegroundColor White
Write-Host "   Дубликаты имён: $duplicateFiles" -ForegroundColor $(if ($duplicateFiles -gt 0) { "Red" } else { "Green" })
Write-Host "   Точные дубликаты: $exactDuplicates" -ForegroundColor $(if ($exactDuplicates -gt 0) { "Red" } else { "Green" })
Write-Host "   Битые ссылки: $($brokenLinks.Count)" -ForegroundColor $(if ($brokenLinks.Count -gt 0) { "Red" } else { "Green" })

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan

# ============================================================================
# 6. ОТЧЁТ
# ============================================================================

$reportPath = "reports\DUPLICATE_CHECK_$(Get-Date -Format 'yyyy-MM-dd_HH-mm').md"
$report = @()
$report += "# 📊 CHECK DUPLICATES REPORT"
$report += ""
$report += "**Дата:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
$report += "**Путь:** $Path"
$report += "**Порог:** $Threshold%"
$report += ""
$report += "## Статистика"
$report += ""
$report += "- Всего файлов: $totalFiles"
$report += "- Общий размер: $([math]::Round($totalSize, 2)) KB"
$report += "- Дубликаты имён: $duplicateFiles"
$report += "- Точные дубликаты: $exactDuplicates"
$report += "- Битые ссылки: $($brokenLinks.Count)"
$report += ""

if ($fileNameGroups.Count -gt 0) {
    $report += "## Дубликаты имён"
    $report += ""
    foreach ($group in $fileNameGroups) {
        $report += "### $($group.Name)"
        $report += ""
        foreach ($file in $group.Group) {
            $report += "- $($file.FullName)"
        }
        $report += ""
    }
}

if ($duplicateHashes.Count -gt 0) {
    $report += "## Точные дубликаты содержимого"
    $report += ""
    foreach ($hashGroup in $duplicateHashes) {
        foreach ($file in $hashGroup.Value) {
            $report += "- $($file.FullName)"
        }
    }
    $report += ""
}

if ($brokenLinks.Count -gt 0) {
    $report += "## Битые ссылки"
    $report += ""
    foreach ($link in $brokenLinks) {
        $report += "- $($link.File) → $($link.Link)"
    }
    $report += ""
}

$report | Out-File $reportPath -Encoding UTF8
Write-Host "📄 Отчёт сохранён: $reportPath" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# 7. РЕКОМЕНДАЦИИ
# ============================================================================

Write-Host "💡 РЕКОМЕНДАЦИИ:" -ForegroundColor Cyan
Write-Host ""

if ($duplicateFiles -gt 0 -or $exactDuplicates -gt 0) {
    Write-Host "   1. Удалите или объедините дубликаты файлов" -ForegroundColor Yellow
}

if ($ruleDuplicates.Count -gt 0) {
    Write-Host "   2. Проверьте файлы с дубликатами правил" -ForegroundColor Yellow
    Write-Host "      Оставьте только в QWEN.md и AI_START_HERE.md" -ForegroundColor Yellow
}

if ($brokenLinks.Count -gt 0) {
    Write-Host "   3. Исправьте битые ссылки" -ForegroundColor Yellow
}

if ($duplicateFiles -eq 0 -and $exactDuplicates -eq 0 -and $ruleDuplicates.Count -eq 0 -and $brokenLinks.Count -eq 0) {
    Write-Host "   ✅ Всё чисто! Дубликатов не найдено" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ CHECK DUPLICATES COMPLETE" -ForegroundColor Green
Write-Host ""
