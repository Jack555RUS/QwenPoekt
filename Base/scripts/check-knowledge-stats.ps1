# 📊 ПРОВЕРКА СТАТИСТИКИ KNOWLEDGE_BASE
# Сверка фактического количества файлов с документацией

# ============================================
# НАСТРОЙКИ
# ============================================

$BasePath = $PSScriptRoot
$KnowledgeBasePath = Join-Path $BasePath "KNOWLEDGE_BASE"
$ReadmeFile = Join-Path $KnowledgeBasePath "00_README.md"

# Ожидаемая статистика (из 00_README.md)
$ExpectedStats = @{
    "00_CORE" = 9
    "01_RULES" = 3
    "02_TOOLS" = 2
    "02_UNITY" = 4
    "03_CSHARP" = 2
    "03_PATTERNS" = 3
    "04_ARCHIVES" = 1
    "05_METHODOLOGY" = 5
}

# ============================================
# ФУНКЦИИ
# ============================================

function Get-ActualCount {
    param([string]$FolderName)
    $path = Join-Path $KnowledgeBasePath $FolderName
    $count = (Get-ChildItem -Path $path -Recurse -File -Include *.md -ErrorAction SilentlyContinue).Count
    return $count
}

# ============================================
# ПРОВЕРКА
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ПРОВЕРКА СТАТИСТИКИ KNOWLEDGE_BASE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Чтение актуальной статистики
Write-Host "📊 ФАКТИЧЕСКАЯ СТАТИСТИКА:" -ForegroundColor Yellow

$ActualStats = @{}
$TotalActual = 0

foreach ($folder in $ExpectedStats.Keys) {
    $count = Get-ActualCount -FolderName $folder
    $ActualStats[$folder] = $count
    $TotalActual += $count
    
    $expected = $ExpectedStats[$folder]
    $status = if ($count -eq $expected) { "✅" } else { "⚠️" }
    $color = if ($count -eq $expected) { "Green" } else { "Yellow" }
    
    Write-Host "  $status $folder`: $count файлов (ожидалось: $expected)" -ForegroundColor $color
}

Write-Host ""
Write-Host "  ВСЕГО: $TotalActual файлов" -ForegroundColor Cyan
Write-Host ""

# Сравнение с документацией
Write-Host "🔍 СВЕРКА С ДОКУМЕНТАЦИЕЙ:" -ForegroundColor Yellow

$mismatches = @()
foreach ($folder in $ExpectedStats.Keys) {
    $expected = $ExpectedStats[$folder]
    $actual = $ActualStats[$folder]
    
    if ($expected -ne $actual) {
        $diff = $actual - $expected
        $sign = if ($diff -gt 0) { "+" } else { "" }
        $mismatches += "$folder: $expected → $actual ($sign$diff)"
    }
}

if ($mismatches.Count -gt 0) {
    Write-Host "  ⚠️ Несоответствий: $($mismatches.Count)" -ForegroundColor Red
    foreach ($mismatch in $mismatches) {
        Write-Host "    - $mismatch" -ForegroundColor Red
    }
} else {
    Write-Host "  ✅ Все данные совпадают!" -ForegroundColor Green
}
Write-Host ""

# Проверка 00_README.md
Write-Host "🔍 ПРОВЕРКА 00_README.md:" -ForegroundColor Yellow

if (Test-Path $ReadmeFile) {
    $readmeContent = Get-Content $ReadmeFile -Raw
    
    # Проверка версии
    if ($readmeContent -match '\*\*Версия:\*\*\s*([\d.]+)') {
        $version = $matches[1]
        Write-Host "  Версия: $version" -ForegroundColor Cyan
    }
    
    # Проверка даты
    if ($readmeContent -match '\*\*Дата:\*\*\s*([\d-]+)') {
        $date = $matches[1]
        Write-Host "  Дата: $date" -ForegroundColor Cyan
    }
} else {
    Write-Host "  ❌ Файл не найден!" -ForegroundColor Red
}
Write-Host ""

# Рекомендации
Write-Host "✅ РЕКОМЕНДАЦИИ:" -ForegroundColor Yellow

if ($mismatches.Count -gt 0) {
    Write-Host "  1. Обновить таблицу в KNOWLEDGE_BASE/00_README.md" -ForegroundColor Yellow
    Write-Host "  2. Увеличить версию (v1.1 → v1.2)" -ForegroundColor Yellow
    Write-Host "  3. Закоммитить изменения" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ Документация актуальна!" -ForegroundColor Green
}
Write-Host ""

# Генерация отчёта
$ReportDate = Get-Date -Format "yyyy-MM-dd_HH-mm"
$ReportFile = Join-Path (Join-Path $BasePath "reports") "STATS_CHECK_$ReportDate.md"

$reportContent = @"
# 📊 ПРОВЕРКА СТАТИСТИКИ — $(Get-Date -Format "yyyy-MM-dd")

**Дата:** $(Get-Date -Format "dd.MM.yyyy HH:mm")  
**Скрипт:** check-knowledge-stats.ps1

---

## 📊 ФАКТИЧЕСКАЯ СТАТИСТИКА

| Категория | Файлов | Ожидалось | Статус |
|-----------|--------|-----------|--------|
$(foreach ($folder in $ExpectedStats.Keys) {
    $actual = $ActualStats[$folder]
    $expected = $ExpectedStats[$folder]
    $status = if ($actual -eq $expected) { "✅" } else { "⚠️" }
    "| **$folder** | $actual | $expected | $status |"
})
| **ИТОГО** | **$TotalActual** | **($($ExpectedStats.Values | Measure-Object -Sum).Sum)** | $(if ($mismatches.Count -eq 0) { "✅" } else { "⚠️" }) |

---

## 🔍 СВЕРКА

$($mismatches.Count -gt 0 ? "### ⚠️ Несоответствия:" : "### ✅ Все данные совпадают!")

$($mismatches | ForEach-Object { "- $_" })

---

## ✅ РЕКОМЕНДАЦИИ

$($mismatches.Count -gt 0 ? "
1. Обновить KNOWLEDGE_BASE/00_README.md
2. Увеличить версию
3. Закоммитить изменения
" : "
- Документация актуальна
- Продолжать мониторинг
")
---

**Статус:** $($mismatches.Count -eq 0 ? "✅ ВСЁ В ПОРЯДКЕ" : "⚠️ ТРЕБУЕТСЯ ВНИМАНИЕ")
"@

$reportContent | Out-File -FilePath $ReportFile -Encoding UTF8

Write-Host "📝 Отчёт сохранён: $ReportFile" -ForegroundColor Cyan
Write-Host ""

# Итоги
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ИТОГИ:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$status = if ($mismatches.Count -eq 0) { "✅ ВСЁ В ПОРЯДКЕ" } else { "⚠️ ТРЕБУЕТСЯ ВНИМАНИЕ" }
Write-Host "Статус: $status" -ForegroundColor $(if ($mismatches.Count -eq 0) { "Green" } else { "Yellow" })
Write-Host ""
Write-Host "Нажмите любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
