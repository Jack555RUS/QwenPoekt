# test-assertions.ps1 — Функции проверок для тестирования
# Версия: 1.0
# Дата: 4 марта 2026 г.
# Назначение: Assertions для тестирования Базы Знаний

$ErrorActionPreference = "Stop"

# Цвета
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"

# ============================================
# ФУНКЦИЯ 1: Test-FileDeleted
# ============================================

function Test-FileDeleted {
    param(
        [string]$Path,
        [switch]$Verbose
    )
    
    Write-Host "`n🔍 Тест: Файл удалён" -ForegroundColor Cyan
    Write-Host "  Путь: $Path" -ForegroundColor Gray
    
    $exists = Test-Path $Path
    
    if ($exists) {
        Write-Host "  ❌ FAIL: Файл должен быть удалён" -ForegroundColor Red
        if ($Verbose) {
            Write-Host "  Ожидаемо: Файл не существует" -ForegroundColor Yellow
            Write-Host "  Фактически: Файл существует" -ForegroundColor Yellow
        }
        return $false
    } else {
        Write-Host "  ✅ PASS: Файл удалён" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "  Ожидаемо: Файл не существует" -ForegroundColor Gray
            Write-Host "  Фактически: Файл не существует" -ForegroundColor Gray
        }
        return $true
    }
}

# ============================================
# ФУНКЦИЯ 2: Test-FileExists
# ============================================

function Test-FileExists {
    param(
        [string]$Path,
        [switch]$Verbose
    )
    
    Write-Host "`n🔍 Тест: Файл существует" -ForegroundColor Cyan
    Write-Host "  Путь: $Path" -ForegroundColor Gray
    
    $exists = Test-Path $Path
    
    if (-not $exists) {
        Write-Host "  ❌ FAIL: Файл должен существовать" -ForegroundColor Red
        if ($Verbose) {
            Write-Host "  Ожидаемо: Файл существует" -ForegroundColor Yellow
            Write-Host "  Фактически: Файл не существует" -ForegroundColor Yellow
        }
        return $false
    } else {
        Write-Host "  ✅ PASS: Файл существует" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "  Ожидаемо: Файл существует" -ForegroundColor Gray
            Write-Host "  Фактически: Файл существует" -ForegroundColor Gray
        }
        return $true
    }
}

# ============================================
# ФУНКЦИЯ 3: Test-DependenciesFound
# ============================================

function Test-DependenciesFound {
    param(
        [int]$Expected,
        [int]$Actual,
        [switch]$Verbose
    )
    
    Write-Host "`n🔍 Тест: Зависимости найдены" -ForegroundColor Cyan
    Write-Host "  Ожидаемо: $Expected" -ForegroundColor Gray
    Write-Host "  Фактически: $Actual" -ForegroundColor Gray
    
    if ($Expected -ne $Actual) {
        Write-Host "  ❌ FAIL: Несоответствие количества зависимостей" -ForegroundColor Red
        if ($Verbose) {
            Write-Host "  Ожидаемо: $Expected зависимостей" -ForegroundColor Yellow
            Write-Host "  Фактически: $Actual зависимостей" -ForegroundColor Yellow
        }
        return $false
    } else {
        Write-Host "  ✅ PASS: Количество зависимостей совпадает" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "  Ожидаемо: $Expected зависимостей" -ForegroundColor Gray
            Write-Host "  Фактически: $Actual зависимостей" -ForegroundColor Gray
        }
        return $true
    }
}

# ============================================
# ФУНКЦИЯ 4: Test-NoDuplicates
# ============================================

function Test-NoDuplicates {
    param(
        [int]$Found,
        [int]$MaxAllowed = 0,
        [switch]$Verbose
    )
    
    Write-Host "`n🔍 Тест: Дубликаты" -ForegroundColor Cyan
    Write-Host "  Найдено: $Found" -ForegroundColor Gray
    Write-Host "  Допустимо: $MaxAllowed" -ForegroundColor Gray
    
    if ($Found -gt $MaxAllowed) {
        Write-Host "  ❌ FAIL: Найдены дубликаты" -ForegroundColor Red
        if ($Verbose) {
            Write-Host "  Ожидаемо: ≤ $MaxAllowed дубликатов" -ForegroundColor Yellow
            Write-Host "  Фактически: $Found дубликатов" -ForegroundColor Yellow
        }
        return $false
    } else {
        Write-Host "  ✅ PASS: Дубликатов нет (или в допустимых пределах)" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "  Ожидаемо: ≤ $MaxAllowed дубликатов" -ForegroundColor Gray
            Write-Host "  Фактически: $Found дубликатов" -ForegroundColor Gray
        }
        return $true
    }
}

# ============================================
# ФУНКЦИЯ 5: Test-ContentContains
# ============================================

function Test-ContentContains {
    param(
        [string]$Path,
        [string[]]$ExpectedPhrases,
        [switch]$Verbose
    )
    
    Write-Host "`n🔍 Тест: Содержимое файла" -ForegroundColor Cyan
    Write-Host "  Путь: $Path" -ForegroundColor Gray
    
    if (-not (Test-Path $Path)) {
        Write-Host "  ❌ FAIL: Файл не существует" -ForegroundColor Red
        return $false
    }
    
    $content = Get-Content $Path -Raw
    $allFound = $true
    
    foreach ($phrase in $ExpectedPhrases) {
        $found = $content -match [regex]::Escape($phrase)
        
        if (-not $found) {
            Write-Host "  ❌ Не найдено: `$phrase`" -ForegroundColor Yellow
            $allFound = $false
        } elseif ($Verbose) {
            Write-Host "  ✅ Найдено: `$phrase`" -ForegroundColor Gray
        }
    }
    
    if ($allFound) {
        Write-Host "  ✅ PASS: Все фразы найдены" -ForegroundColor Green
        return $true
    } else {
        Write-Host "  ❌ FAIL: Не все фразы найдены" -ForegroundColor Red
        return $false
    }
}

# ============================================
# ФУНКЦИЯ 6: Test-RiskScore
# ============================================

function Test-RiskScore {
    param(
        [int]$Expected,
        [int]$Actual,
        [int]$Tolerance = 2,
        [switch]$Verbose
    )
    
    Write-Host "`n🔍 Тест: Оценка риска" -ForegroundColor Cyan
    Write-Host "  Ожидаемо: $Expected (±$Tolerance)" -ForegroundColor Gray
    Write-Host "  Фактически: $Actual" -ForegroundColor Gray
    
    $diff = [Math]::Abs($Expected - $Actual)
    
    if ($diff -gt $Tolerance) {
        Write-Host "  ❌ FAIL: Оценка риска вне допустимого диапазона" -ForegroundColor Red
        if ($Verbose) {
            Write-Host "  Ожидаемо: $($Expected - $Tolerance) - $($Expected + $Tolerance)" -ForegroundColor Yellow
            Write-Host "  Фактически: $Actual" -ForegroundColor Yellow
        }
        return $false
    } else {
        Write-Host "  ✅ PASS: Оценка риска в допустимом диапазоне" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "  Ожидаемо: $($Expected - $Tolerance) - $($Expected + $Tolerance)" -ForegroundColor Gray
            Write-Host "  Фактически: $Actual" -ForegroundColor Gray
        }
        return $true
    }
}

# ============================================
# ФУНКЦИЯ 7: Test-LogCreated
# ============================================

function Test-LogCreated {
    param(
        [string]$LogPath,
        [switch]$Verbose
    )
    
    Write-Host "`n🔍 Тест: Лог создан" -ForegroundColor Cyan
    Write-Host "  Путь: $LogPath" -ForegroundColor Gray
    
    if (-not (Test-Path $LogPath)) {
        Write-Host "  ❌ FAIL: Лог файл не создан" -ForegroundColor Red
        if ($Verbose) {
            Write-Host "  Ожидаемо: Файл существует" -ForegroundColor Yellow
            Write-Host "  Фактически: Файл не существует" -ForegroundColor Yellow
        }
        return $false
    } else {
        Write-Host "  ✅ PASS: Лог файл создан" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "  Ожидаемо: Файл существует" -ForegroundColor Gray
            Write-Host "  Фактически: Файл существует" -ForegroundColor Gray
        }
        return $true
    }
}

# ============================================
# ФУНКЦИЯ 8: Test-ReportGenerated
# ============================================

function Test-ReportGenerated {
    param(
        [string]$ReportPath,
        [switch]$Verbose
    )
    
    Write-Host "`n🔍 Тест: Отчёт создан" -ForegroundColor Cyan
    Write-Host "  Путь: $ReportPath" -ForegroundColor Gray
    
    if (-not (Test-Path $ReportPath)) {
        Write-Host "  ❌ FAIL: Отчёт не создан" -ForegroundColor Red
        if ($Verbose) {
            Write-Host "  Ожидаемо: Файл существует" -ForegroundColor Yellow
            Write-Host "  Фактически: Файл не существует" -ForegroundColor Yellow
        }
        return $false
    } else {
        $size = (Get-Item $ReportPath).Length
        Write-Host "  ✅ PASS: Отчёт создан ($([math]::Round($size / 1KB, 2)) KB)" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "  Ожидаемо: Файл существует" -ForegroundColor Gray
            Write-Host "  Фактически: Файл существует ($([math]::Round($size / 1KB, 2)) KB)" -ForegroundColor Gray
        }
        return $true
    }
}

# ============================================
# ФУНКЦИЯ 9: Write-TestSummary
# ============================================

function Write-TestSummary {
    param(
        [array]$TestResults,
        [string]$TestName
    )
    
    $total = $TestResults.Count
    $passed = ($TestResults | Where-Object { $_ -eq $true }).Count
    $failed = $total - $passed
    $passRate = if ($total -gt 0) { [math]::Round(($passed / $total) * 100, 2) } else { 0 }
    
    Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                    ИТОГИ ТЕСТИРОВАНИЯ                    ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    
    Write-Host "`n📊 Тест: $TestName" -ForegroundColor Cyan
    Write-Host "  Всего тестов: $total" -ForegroundColor Gray
    Write-Host "  ✅ Прошло: $passed" -ForegroundColor Green
    Write-Host "  ❌ Провалилось: $failed" -ForegroundColor Red
    Write-Host "  📈 Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 95) { $Green } elseif ($passRate -ge 80) { $Yellow } else { $Red })
    
    if ($failed -eq 0) {
        Write-Host "`n🎉 ВСЕ ТЕСТЫ ПРОЙДЕНЫ!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "`n⚠️ НЕКОТОРЫЕ ТЕСТЫ НЕ ПРОЙДЕНЫ" -ForegroundColor Yellow
        return $false
    }
}

# ============================================
# ПРИМЕР ИСПОЛЬЗОВАНИЯ
# ============================================

<#
.SYNOPSIS
    Пример использования функций тестирования

.EXAMPLE
    # Тест 1: Удаление файла
    $results = @()
    
    # Arrange
    New-Item "test-file.md" -Value "TEST" -Force
    New-Item "dep1.md" -Value "[link](test-file.md)" -Force
    
    # Act
    .\before-action-checklist-v2.ps1 -Action delete -Target "test-file.md" -Force
    
    # Assert
    $results += Test-FileDeleted -Path "test-file.md" -Verbose
    $results += Test-DependenciesFound -Expected 1 -Actual 1 -Verbose
    
    # Cleanup
    Remove-Item "dep1.md" -Force
    
    # Summary
    Write-TestSummary -TestResults $results -TestName "Удаление файла"

#>
