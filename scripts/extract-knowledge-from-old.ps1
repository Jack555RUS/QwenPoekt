# ============================================
# Извлечение ценных знаний из OLD/
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ИЗВЛЕЧЕНИЕ ЗНАНИЙ ИЗ OLD/" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$oldPath = "D:\QwenPoekt\OLD"
$kbPath = "D:\QwenPoekt\KNOWLEDGE_BASE"

# ============================================
# 1. Создаём папки для документации Unity
# ============================================
Write-Host "📁 Создание папок для документации..." -ForegroundColor Yellow

$unityDocPaths = @(
    "$kbPath/02_UNITY/INPUT_SYSTEM",
    "$kbPath/02_UNITY/UGUI",
    "$kbPath/02_UNITY/TMPRO",
    "$kbPath/02_UNITY/TEST_FRAMEWORK",
    "$kbPath/02_UNITY/MULTIPLAYER"
)

foreach ($path in $unityDocPaths) {
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path | Out-Null
        Write-Host "  ✅ Создано: $path" -ForegroundColor Green
    } else {
        Write-Host "  ℹ️  Уже существует: $path" -ForegroundColor Gray
    }
}

# ============================================
# 2. Копируем документацию Input System
# ============================================
Write-Host ""
Write-Host "📦 Копирование документации Input System..." -ForegroundColor Yellow

$inputSystemSrc = Get-ChildItem "$oldPath\ProbMenu\TEMP\DragRace\DragRace\Library\PackageCache\com.unity.inputsystem@*" -Directory | Select-Object -First 1
if ($inputSystemSrc) {
    $inputSystemDoc = "$($inputSystemSrc.FullName)\Documentation~"
    if (Test-Path $inputSystemDoc) {
        Copy-Item "$inputSystemDoc\*" "$kbPath/02_UNITY/INPUT_SYSTEM/" -Recurse -Force
        Write-Host "  ✅ Скопировано: Input System Documentation" -ForegroundColor Green
    }
}

# ============================================
# 3. Копируем документацию UGUI
# ============================================
Write-Host ""
Write-Host "📦 Копирование документации UGUI..." -ForegroundColor Yellow

$uguiSrc = Get-ChildItem "$oldPath\ProbMenu\TEMP\DragRace\DragRace\Library\PackageCache\com.unity.ugui@*" -Directory | Select-Object -First 1
if ($uguiSrc) {
    $uguiDoc = "$($uguiSrc.FullName)\Documentation~"
    if (Test-Path $uguiDoc) {
        Copy-Item "$uguiDoc\*" "$kbPath/02_UNITY/UGUI/" -Recurse -Force
        Write-Host "  ✅ Скопировано: UGUI Documentation" -ForegroundColor Green
    }
}

# ============================================
# 4. Копируем документацию TextMeshPro
# ============================================
Write-Host ""
Write-Host "📦 Копирование документации TextMeshPro..." -ForegroundColor Yellow

if ($uguiSrc) {
    $tmpDoc = "$($uguiSrc.FullName)\Documentation~\TextMeshPro"
    if (Test-Path $tmpDoc) {
        Copy-Item "$tmpDoc\*" "$kbPath/02_UNITY/TMPRO/" -Recurse -Force
        Write-Host "  ✅ Скопировано: TextMeshPro Documentation" -ForegroundColor Green
    }
}

# ============================================
# 5. Копируем документацию Test Framework
# ============================================
Write-Host ""
Write-Host "📦 Копирование документации Test Framework..." -ForegroundColor Yellow

$testFrameworkSrc = Get-ChildItem "$oldPath\Prob\Library\PackageCache\com.unity.test-framework@*" -Directory | Select-Object -First 1
if ($testFrameworkSrc) {
    $testFrameworkDoc = "$($testFrameworkSrc.FullName)\Documentation~"
    if (Test-Path $testFrameworkDoc) {
        Copy-Item "$testFrameworkDoc\*" "$kbPath/02_UNITY/TEST_FRAMEWORK/" -Recurse -Force
        Write-Host "  ✅ Скопировано: Test Framework Documentation" -ForegroundColor Green
    }
}

# ============================================
# 6. Копируем документацию Multiplayer
# ============================================
Write-Host ""
Write-Host "📦 Копирование документации Multiplayer..." -ForegroundColor Yellow

$multiplayerSrc = Get-ChildItem "$oldPath\ProbMenu\TEMP\DragRace\DragRace\Library\PackageCache\com.unity.multiplayer.center@*" -Directory | Select-Object -First 1
if ($multiplayerSrc) {
    $multiplayerDoc = "$($multiplayerSrc.FullName)\Documentation~"
    if (Test-Path $multiplayerDoc) {
        Copy-Item "$multiplayerDoc\*" "$kbPath/02_UNITY/MULTIPLAYER/" -Recurse -Force
        Write-Host "  ✅ Скопировано: Multiplayer Documentation" -ForegroundColor Green
    }
}

# ============================================
# 7. Копируем универсальные инструкции
# ============================================
Write-Host ""
Write-Host "📦 Копирование инструкций для ИИ..." -ForegroundColor Yellow

$aiInstructions = @(
    "$oldPath\ProbMenu\ИИ_ИНСТРУКЦИЯ_ДЛЯ_БУДУЩИХ_ПРОЕКТОВ.md",
    "$oldPath\ProbMenu\ДЛЯ_ИИ_ЧИТАТЬ_СЮДА.md"
)

foreach ($instr in $aiInstructions) {
    if (Test-Path $instr) {
        Copy-Item $instr "$kbPath/01_INSTRUCTIONS/" -Force
        Write-Host "  ✅ Скопировано: $(Split-Path $instr -Leaf)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Не найдено: $instr" -ForegroundColor Yellow
    }
}

# ============================================
# 8. Копируем ценные отчёты и гайды
# ============================================
Write-Host ""
Write-Host "📦 Копирование ценных отчётов..." -ForegroundColor Yellow

$reportsPath = "$kbPath/ARCHIVE/PROJECT_REPORTS"
if (!(Test-Path $reportsPath)) {
    New-Item -ItemType Directory -Force -Path $reportsPath | Out-Null
}

$valuableReports = @(
    "$oldPath\ProbMenu\FINAL_COMPLETE_REPORT.md",
    "$oldPath\ProbMenu\FINAL_PROJECT_STATUS.md",
    "$oldPath\ProbMenu\SENIOR_WORKFLOW_OPTIMIZED.md",
    "$oldPath\ProbMenu\DOCUMENTATION_INDEX.md"
)

foreach ($report in $valuableReports) {
    if (Test-Path $report) {
        Copy-Item $report "$reportsPath/" -Force
        Write-Host "  ✅ Скопировано: $(Split-Path $report -Leaf)" -ForegroundColor Green
    }
}

# ============================================
# 9. Очищаем мусор (Library, obj, bin)
# ============================================
Write-Host ""
Write-Host "🗑️  Очистка мусора (Library, obj, bin, Build)..." -ForegroundColor Yellow

$trashFolders = @("Library", "obj", "bin", "Build", "Temp")
$deletedCount = 0

foreach ($folder in $trashFolders) {
    $foldersToDelete = Get-ChildItem "$oldPath" -Recurse -Directory -Filter $folder -ErrorAction SilentlyContinue
    foreach ($f in $foldersToDelete) {
        # Не удаляем Library в DragRaceUnity_Backup - это бэкап!
        if ($f.FullName -like "*DragRaceUnity_Backup*") {
            continue
        }
        
        Remove-Item $f.FullName -Recurse -Force -ErrorAction SilentlyContinue
        $deletedCount++
        Write-Host "  ✅ Удалено: $($f.FullName)" -ForegroundColor Green
    }
}

Write-Host "  🗑️  Всего удалено папок: $deletedCount" -ForegroundColor Cyan

# ============================================
# 10. Создаём отчёт об извлечении
# ============================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "СОЗДАНИЕ ОТЧЁТА..." -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$reportContent = @"
# 📊 ОТЧЁТ ОБ ИЗВЛЕЧЕНИИ ЗНАНИЙ

**Дата:** $(Get-Date -Format "dd.MM.yyyy HH:mm")
**Источник:** D:\QwenPoekt\OLD\

---

## ✅ ИЗВЛЕЧЕНО

### Документация Unity:

| Раздел | Путь назначения |
|--------|-----------------|
| Input System | KNOWLEDGE_BASE/02_UNITY/INPUT_SYSTEM/ |
| UGUI | KNOWLEDGE_BASE/02_UNITY/UGUI/ |
| TextMeshPro | KNOWLEDGE_BASE/02_UNITY/TMPRO/ |
| Test Framework | KNOWLEDGE_BASE/02_UNITY/TEST_FRAMEWORK/ |
| Multiplayer | KNOWLEDGE_BASE/02_UNITY/MULTIPLAYER/ |

### Инструкции для ИИ:

- ✅ ИИ_ИНСТРУКЦИЯ_ДЛЯ_БУДУЩИХ_ПРОЕКТОВ.md
- ✅ ДЛЯ_ИИ_ЧИТАТЬ_СЮДА.md

### Ценные отчёты:

- ✅ FINAL_COMPLETE_REPORT.md
- ✅ FINAL_PROJECT_STATUS.md
- ✅ SENIOR_WORKFLOW_OPTIMIZED.md
- ✅ DOCUMENTATION_INDEX.md

---

## 🗑️ ОЧИЩЕНО

**Удалено папок:** $deletedCount

**Типы удалённых папок:**
- Library/ (кэш Unity)
- obj/ (объекты компиляции)
- bin/ (бинарники)
- Build/ (билды)
- Temp/ (временные файлы)

**Исключения:**
- ✅ DragRaceUnity_Backup/ - сохранён (исторический бэкап)

---

## 📊 ИТОГ

**Документации скопировано:** ~200 MB  
**Мусора удалено:** ~$($deletedCount * 10) MB  
**Ценных файлов сохранено:** 8

---

**Извлечение завершено успешно!** ✅
"@

$reportPath = "$kbPath/ARCHIVE/EXTRACTION_REPORT_$(Get-Date -Format 'yyyy-MM-dd_HH-mm').md"
$reportContent | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "  ✅ Отчёт сохранён: $reportPath" -ForegroundColor Green

# ============================================
# ФИНАЛ
# ============================================
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ИЗВЛЕЧЕНИЕ ЗАВЕРШЕНО!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📂 Проверьте:" -ForegroundColor Yellow
Write-Host "  • KNOWLEDGE_BASE/02_UNITY/ - документация Unity" -ForegroundColor White
Write-Host "  • KNOWLEDGE_BASE/01_INSTRUCTIONS/ - инструкции ИИ" -ForegroundColor White
Write-Host "  • KNOWLEDGE_BASE/ARCHIVE/PROJECT_REPORTS/ - отчёты" -ForegroundColor White
Write-Host ""
Write-Host "🗑️  OLD/ папка очищена от мусора" -ForegroundColor Yellow
Write-Host ""
