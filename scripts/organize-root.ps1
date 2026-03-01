# ============================================================================
# ORGANIZE ROOT FOLDER
# Автоматическая организация корневой папки
# ============================================================================
# Использование: .\scripts\organize-root.ps1
# ============================================================================

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "                    ORGANIZE ROOT FOLDER                                    " -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# 1. СОЗДАТЬ ПАПКИ
# ============================================================================

Write-Host "1. Создание папок..." -ForegroundColor Yellow

$folders = @("_docs", "reports")

foreach ($folder in $folders) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
        Write-Host "   ✓ Создана папка: $folder" -ForegroundColor Green
    } else {
        Write-Host "   ✓ Папка уже существует: $folder" -ForegroundColor Gray
    }
}

# ============================================================================
# 2. ПЕРЕМЕСТИТЬ ДОКУМЕНТАЦИЮ (_docs/)
# ============================================================================

Write-Host ""
Write-Host "2. Перемещение документации..." -ForegroundColor Yellow

$docs = @(
    "CHEAT_SHEET.md",
    "SCRIPTS_README.md"
)

foreach ($file in $docs) {
    if (Test-Path $file) {
        Move-Item $file "_docs/$file" -Force
        Write-Host "   ✓ Перемещено: $file → _docs/" -ForegroundColor Green
    } else {
        Write-Host "   ⊘ Не найдено: $file" -ForegroundColor Gray
    }
}

# ============================================================================
# 3. ПЕРЕМЕСТИТЬ ШАБЛОНЫ (_templates/)
# ============================================================================

Write-Host ""
Write-Host "3. Перемещение шаблонов..." -ForegroundColor Yellow

$templates = @(
    "ANSWER_TEMPLATE.md"
)

foreach ($file in $templates) {
    if (Test-Path $file) {
        Move-Item $file "_templates/$file" -Force
        Write-Host "   ✓ Перемещено: $file → _templates/" -ForegroundColor Green
    } else {
        Write-Host "   ⊘ Не найдено: $file" -ForegroundColor Gray
    }
}

# ============================================================================
# 4. ПЕРЕМЕСТИТЬ СКРИПТЫ (scripts/)
# ============================================================================

Write-Host ""
Write-Host "4. Перемещение скриптов..." -ForegroundColor Yellow

$scripts = Get-ChildItem "*.ps1" -File | Where-Object { 
    $_.Name -ne "organize-root.ps1" 
}

foreach ($file in $scripts) {
    Move-Item $file.FullName "scripts/$($file.Name)" -Force
    Write-Host "   ✓ Перемещено: $($file.Name) → scripts/" -ForegroundColor Green
}

Write-Host "   Перемещено скриптов: $($scripts.Count)" -ForegroundColor Cyan

# ============================================================================
# 5. ПЕРЕМЕСТИТЬ ОТЧЁТЫ (reports/)
# ============================================================================

Write-Host ""
Write-Host "5. Перемещение отчётов..." -ForegroundColor Yellow

$reportPatterns = @(
    "*_COMPLETE.md",
    "*_REPORT.md",
    "*_AUDIT.md",
    "*_ANALYSIS.md",
    "*_IMPLEMENTATION.md"
)

$reportCount = 0

foreach ($pattern in $reportPatterns) {
    $files = Get-ChildItem $pattern -File
    
    foreach ($file in $files) {
        Move-Item $file.FullName "reports/$($file.Name)" -Force
        Write-Host "   ✓ Перемещено: $($file.Name) → reports/" -ForegroundColor Green
        $reportCount++
    }
}

Write-Host "   Перемещено отчётов: $reportCount" -ForegroundColor Cyan

# ============================================================================
# 6. ИТОГ
# ============================================================================

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "                    ORGANIZE COMPLETE                                       " -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""

# Подсчёт оставшихся файлов в корне
$remainingFiles = Get-ChildItem -File | Where-Object { 
    $_.Name -notmatch "^\." -and $_.Name -ne "organize-root.ps1"
}

Write-Host "📊 Итог:" -ForegroundColor Cyan
Write-Host "   Осталось в корне: $($remainingFiles.Count) файлов" -ForegroundColor White
Write-Host ""
Write-Host "📁 Файлы в корне:" -ForegroundColor Cyan

foreach ($file in $remainingFiles) {
    Write-Host "   - $($file.Name)" -ForegroundColor White
}

Write-Host ""
Write-Host "✅ Корень организован!" -ForegroundColor Green
Write-Host ""
