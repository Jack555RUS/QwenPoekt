# ============================================================================
# COMPREHENSIVE TEST ALL CHANGES
# ============================================================================
# Назначение: Тестирование всех изменений сессии
# Использование: .\test-all-changes.ps1
# ============================================================================

param(
    [string]$TestEnvBase = "D:\QwenPoekt\_TEST_ENV\Base",
    
    [string]$ReportPath = "D:\QwenPoekt\_TEST_ENV\reports\COMPREHENSIVE_TEST_REPORT.md"
)

$ErrorActionPreference = "Stop"

$TestResults = @{
    Total = 0
    Passed = 0
    Failed = 0
    Tests = @()
}

# ============================================================================
# ФУНКЦИИ
# ============================================================================

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Write-Test-Result {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Details
    )
    
    $TestResults.Total++
    if ($Passed) {
        $TestResults.Passed++
        Write-Host "  ✅ $TestName" -ForegroundColor Green
    } else {
        $TestResults.Failed++
        Write-Host "  ❌ $TestName" -ForegroundColor Red
    }
    
    $TestResults.Tests += @{
        Name = $TestName
        Passed = $Passed
        Details = $Details
    }
}

function Test-File-Exists {
    param([string]$Path)
    return Test-Path $Path
}

function Test-File-Content {
    param(
        [string]$Path,
        [string]$Pattern
    )
    $content = Get-Content $Path -Raw
    return $content -match $Pattern
}

# ============================================================================
# ТЕСТ 1: Проверка правила 3 уровней в QWEN.md
# ============================================================================

function Test-Three-Level-Rule {
    Write-Log "Тест 1: Проверка правила 3 уровней..."
    
    $qwennPath = Join-Path $TestEnvBase ".qwen\QWEN.md"
    
    # Проверка существования файла
    if (!(Test-File-Exists $qwennPath)) {
        Write-Test-Result "QWEN.md существует" $false "Файл не найден"
        return
    }
    Write-Test-Result "QWEN.md существует" $true "Файл найден"
    
    # Проверка правила 3 уровней
    $hasRedLevel = Test-File-Content $qwennPath "🔴 КРАСНЫЙ уровень"
    Write-Test-Result "Красный уровень" $hasRedLevel "Правило красного уровня"
    
    $hasYellowLevel = Test-File-Content $qwennPath "🟡 ЖЁЛТЫЙ уровень"
    Write-Test-Result "Жёлтый уровень" $hasYellowLevel "Правило жёлтого уровня"
    
    $hasGreenLevel = Test-File-Content $qwennPath "🟢 ЗЕЛЁНЫЙ уровень"
    Write-Test-Result "Зелёный уровень" $hasGreenLevel "Правило зелёного уровня"
    
    # Проверка примеров
    $hasExamples = Test-File-Content $qwennPath "Пример 1: Удаление TEMP"
    Write-Test-Result "Примеры применения" $hasExamples "Примеры для уровней"
}

# ============================================================================
# ТЕСТ 2: Проверка скрипта check-rule-profiles.ps1
# ============================================================================

function Test-Check-Rule-Profiles {
    Write-Log "Тест 2: Проверка check-rule-profiles.ps1..."
    
    $scriptPath = Join-Path $TestEnvBase "scripts\check-rule-profiles.ps1"
    
    if (!(Test-File-Exists $scriptPath)) {
        Write-Test-Result "check-rule-profiles.ps1 существует" $false "Скрипт не найден"
        return
    }
    Write-Test-Result "check-rule-profiles.ps1 существует" $true "Скрипт найден"
    
    # Проверка содержания
    $hasMetadata = Test-File-Content $scriptPath "Metadata"
    Write-Test-Result "Проверка мета-полей" $hasMetadata "Код проверки мета-полей"
    
    $hasStructure = Test-File-Content $scriptPath "Structure"
    Write-Test-Result "Проверка структуры" $hasStructure "Код проверки структуры"
}

# ============================================================================
# ТЕСТ 3: Проверка скрипта check-rule-conflicts.ps1
# ============================================================================

function Test-Check-Rule-Conflicts {
    Write-Log "Тест 3: Проверка check-rule-conflicts.ps1..."
    
    $scriptPath = Join-Path $TestEnvBase "scripts\check-rule-conflicts.ps1"
    
    if (!(Test-File-Exists $scriptPath)) {
        Write-Test-Result "check-rule-conflicts.ps1 существует" $false "Скрипт не найден"
        return
    }
    Write-Test-Result "check-rule-conflicts.ps1 существует" $true "Скрипт найден"
    
    # Проверка содержания
    $hasDuplicates = Test-File-Content $scriptPath "Find-Duplicate-Content"
    Write-Test-Result "Поиск дубликатов" $hasDuplicates "Функция поиска дубликатов"
    
    $hasOverlaps = Test-File-Content $scriptPath "Find-Overlapping-Topics"
    Write-Test-Result "Поиск пересечений" $hasOverlaps "Функция поиска пересечений"
}

# ============================================================================
# ТЕСТ 4: Проверка скрипта check-rule-links.ps1
# ============================================================================

function Test-Check-Rule-Links {
    Write-Log "Тест 4: Проверка check-rule-links.ps1..."
    
    $scriptPath = Join-Path $TestEnvBase "scripts\check-rule-links.ps1"
    
    if (!(Test-File-Exists $scriptPath)) {
        Write-Test-Result "check-rule-links.ps1 существует" $false "Скрипт не найден"
        return
    }
    Write-Test-Result "check-rule-links.ps1 существует" $true "Скрипт найден"
    
    # Проверка содержания
    $hasLinkCheck = Test-File-Content $scriptPath "Check-File-Links"
    Write-Test-Result "Проверка ссылок" $hasLinkCheck "Функция проверки ссылок"
}

# ============================================================================
# ТЕСТ 5: Проверка cleanup-test-env.ps1 (умная очистка)
# ============================================================================

function Test-Cleanup-Test-Env {
    Write-Log "Тест 5: Проверка cleanup-test-env.ps1..."
    
    $scriptPath = Join-Path $TestEnvBase "scripts\cleanup-test-env.ps1"
    
    if (!(Test-File-Exists $scriptPath)) {
        Write-Test-Result "cleanup-test-env.ps1 существует" $false "Скрипт не найден"
        return
    }
    Write-Test-Result "cleanup-test-env.ps1 существует" $true "Скрипт найден"
    
    # Проверка содержания
    $hasArchiveTests = Test-File-Content $scriptPath "ArchiveTests"
    Write-Test-Result "Архивация тестов" $hasArchiveTests "Параметр -ArchiveTests"
    
    $hasSaveLogs = Test-File-Content $scriptPath "SaveLogs"
    Write-Test-Result "Сохранение логов" $hasSaveLogs "Параметр -SaveLogs"
    
    # Проверка что структура сохраняется
    $preservesStructure = Test-File-Content $scriptPath "структура сохранена"
    Write-Test-Result "Сохранение структуры" $preservesStructure "Структура сохраняется"
}

# ============================================================================
# ТЕСТ 6: Проверка перекрёстных ссылок
# ============================================================================

function Test-Cross-Links {
    Write-Log "Тест 6: Проверка перекрёстных ссылок..."
    
    $csharpStandards = Join-Path $TestEnvBase "KNOWLEDGE_BASE\00_CORE\csharp_standards.md"
    
    if (!(Test-File-Exists $csharpStandards)) {
        Write-Test-Result "csharp_standards.md существует" $false "Файл не найден"
        return
    }
    
    # Проверка ссылок
    $hasFastLearning = Test-File-Content $csharpStandards "csharp_fast_learning.md"
    Write-Test-Result "Ссылка на csharp_fast_learning" $hasFastLearning "Связь с fast_learning"
    
    $hasSilentTesting = Test-File-Content $csharpStandards "csharp_silent_testing.md"
    Write-Test-Result "Ссылка на csharp_silent_testing" $hasSilentTesting "Связь с silent_testing"
}

# ============================================================================
# ТЕСТ 7: Проверка RULES_INDEX.md
# ============================================================================

function Test-Rules-Index {
    Write-Log "Тест 7: Проверка RULES_INDEX.md..."
    
    $indexPath = Join-Path $TestEnvBase "_docs\RULES_INDEX.md"
    
    if (!(Test-File-Exists $indexPath)) {
        Write-Test-Result "RULES_INDEX.md существует" $false "Файл не найден"
        return
    }
    Write-Test-Result "RULES_INDEX.md существует" $true "Файл найден"
    
    # Проверка содержания
    $hasMatrix = Test-File-Content $indexPath "МАТРИЦА ПРОФИЛЕЙ"
    Write-Test-Result "Матрица профилей" $hasMatrix "Таблица профилей"
}

# ============================================================================
# ТЕСТ 8: Проверка PROFILES_MATRIX.md
# ============================================================================

function Test-Profiles-Matrix {
    Write-Log "Тест 8: Проверка PROFILES_MATRIX.md..."
    
    $matrixPath = Join-Path $TestEnvBase "_docs\PROFILES_MATRIX.md"
    
    if (!(Test-File-Exists $matrixPath)) {
        Write-Test-Result "PROFILES_MATRIX.md существует" $false "Файл не найден"
        return
    }
    Write-Test-Result "PROFILES_MATRIX.md существует" $true "Файл найден"
    
    # Проверка содержания
    $hasMatrix = Test-File-Content $matrixPath "МАТРИЦА"
    Write-Test-Result "Матрица" $hasMatrix "Матрица профилей"
}

# ============================================================================
# ТЕСТ 9: Запуск check-rule-profiles.ps1 в тестовой среде
# ============================================================================

function Test-Run-Check-Profiles {
    Write-Log "Тест 9: Запуск check-rule-profiles.ps1..."
    
    try {
        $output = & "D:\QwenPoekt\_TEST_ENV\Base\scripts\check-rule-profiles.ps1" 2>&1
        $success = $LASTEXITCODE -eq 0
        Write-Test-Result "check-rule-profiles.ps1 выполнился" $success "Код возврата: $LASTEXITCODE"
    } catch {
        Write-Test-Result "check-rule-profiles.ps1 выполнился" $false $_.Exception.Message
    }
}

# ============================================================================
# ТЕСТ 10: Запуск check-rule-links.ps1 в тестовой среде
# ============================================================================

function Test-Run-Check-Links {
    Write-Log "Тест 10: Запуск check-rule-links.ps1..."
    
    try {
        $output = & "D:\QwenPoekt\_TEST_ENV\Base\scripts\check-rule-links.ps1" 2>&1
        $success = $LASTEXITCODE -eq 0
        Write-Test-Result "check-rule-links.ps1 выполнился" $success "Код возврата: $LASTEXITCODE"
    } catch {
        Write-Test-Result "check-rule-links.ps1 выполнился" $false $_.Exception.Message
    }
}

# ============================================================================
# ГЕНЕРАЦИЯ ОТЧЁТА
# ============================================================================

function Generate-Test-Report {
    param(
        [hashtable]$Results,
        [string]$ReportPath
    )
    
    $report = @"
# 🧪 ОТЧЁТ КОМПЛЕКСНОГО ТЕСТИРОВАНИЯ

**Дата:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Среда:** _TEST_ENV

---

## 📊 ОБЩАЯ СТАТИСТИКА

| Метрика | Значение |
|---------|----------|
| **Всего тестов** | $($Results.Total) |
| **Пройдено** | $($Results.Passed) |
| **Провалено** | $($Results.Failed) |
| **% успеха** | $([math]::Round(($Results.Passed / $Results.Total) * 100, 1))% |

---

## 📋 РЕЗУЛЬТАТЫ ПО ТЕСТАМ

"@
    
    foreach ($test in $Results.Tests) {
        $status = if ($test.Passed) { "✅" } else { "❌" }
        $report += "- $status **$($test.Name)** — $($test.Details)`n"
    }
    
    $report += @"

---

## 🎯 ВЫВОДЫ

"@
    
    if ($Results.Failed -eq 0) {
        $report += "``````text`nВСЕ ТЕСТЫ ПРОЙДЕНЫ! ✅`n``````"
    } else {
        $report += "``````text`nТРЕБУЕТСЯ ВНИМАНИЕ: $($Results.Failed) тест(ов) провалено ❌`n``````"
    }
    
    $report += @"

---

**Тестирование завершено:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@
    
    $report | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Log "Отчёт сохранён: $ReportPath" -Color "Green"
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== КОМПЛЕКСНОЕ ТЕСТИРОВАНИЕ ВСЕХ ИЗМЕНЕНИЙ ===" -Color "Yellow"
    Write-Log "Тестовая среда: $TestEnvBase"
    
    # ------------------------------------------------------------------------
    # ЗАПУСК ТЕСТОВ
    # ------------------------------------------------------------------------
    Write-Log "Запуск тестов..."
    Write-Host ""
    
    Test-Three-Level-Rule
    Write-Host ""
    
    Test-Check-Rule-Profiles
    Write-Host ""
    
    Test-Check-Rule-Conflicts
    Write-Host ""
    
    Test-Check-Rule-Links
    Write-Host ""
    
    Test-Cleanup-Test-Env
    Write-Host ""
    
    Test-Cross-Links
    Write-Host ""
    
    Test-Rules-Index
    Write-Host ""
    
    Test-Profiles-Matrix
    Write-Host ""
    
    Test-Run-Check-Profiles
    Write-Host ""
    
    Test-Run-Check-Links
    Write-Host ""
    
    # ------------------------------------------------------------------------
    # ГЕНЕРАЦИЯ ОТЧЁТА
    # ------------------------------------------------------------------------
    Write-Log "Генерация отчёта..."
    
    Generate-Test-Report -Results $TestResults -ReportPath $ReportPath
    
    # ------------------------------------------------------------------------
    # ФИНАЛЬНЫЙ ВЫВОД
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Log "=== РЕЗУЛЬТАТЫ ТЕСТИРОВАНИЯ ===" -Color "Yellow"
    Write-Host ""
    Write-Host "Всего тестов: $($TestResults.Total)" -ForegroundColor White
    Write-Host "Пройдено: $($TestResults.Passed) ✅" -ForegroundColor Green
    Write-Host "Провалено: $($TestResults.Failed) ❌" -ForegroundColor Red
    Write-Host "Успех: $([math]::Round(($TestResults.Passed / $TestResults.Total) * 100, 1))%" -ForegroundColor $(if ($TestResults.Failed -eq 0) { "Green" } else { "Yellow" })
    Write-Host ""
    Write-Host "Отчёт: $ReportPath" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)" -Color "Red"
    exit 1
}
