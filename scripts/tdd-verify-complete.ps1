# ============================================
# TDD Verify Complete — Проверка завершения задачи
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "✅ TDD VERIFY COMPLETE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity"
$allPassed = $true

# ============================================
# 1. Проверка компиляции кода
# ============================================
Write-Host "1️⃣ Проверка компиляции кода..." -ForegroundColor Yellow

try {
    Set-Location $projectPath
    $buildResult = dotnet build -c Release 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Код компилируется без ошибок" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Ошибки компиляции:" -ForegroundColor Red
        Write-Host $buildResult | Select-String "error" | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
        $allPassed = $false
    }
} catch {
    Write-Host "  ❌ Ошибка при компиляции: $_" -ForegroundColor Red
    $allPassed = $false
}

Write-Host ""

# ============================================
# 2. Проверка тестов
# ============================================
Write-Host "2️⃣ Проверка тестов (NUnit)..." -ForegroundColor Yellow

try {
    Set-Location $projectPath
    $testResult = dotnet test -c Release --no-build 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Все тесты проходят" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Тесты не проходят:" -ForegroundColor Red
        Write-Host $testResult | Select-String "Failed" | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
        $allPassed = $false
    }
} catch {
    Write-Host "  ❌ Ошибка при запуске тестов: $_" -ForegroundColor Red
    $allPassed = $false
}

Write-Host ""

# ============================================
# 3. Проверка EXE сборки
# ============================================
Write-Host "3️⃣ Проверка EXE сборки..." -ForegroundColor Yellow

$exePath = "$projectPath\Build\DragRace.exe"
if (Test-Path $exePath) {
    Write-Host "  ✅ EXE существует: $exePath" -ForegroundColor Green
    
    $exeInfo = Get-Item $exePath
    Write-Host "    Размер: $([math]::Round($exeInfo.Length / 1MB, 2)) MB" -ForegroundColor Gray
    Write-Host "    Дата: $($exeInfo.LastWriteTime)" -ForegroundColor Gray
} else {
    Write-Host "  ⚠️  EXE не найден (это нормально для текущей задачи)" -ForegroundColor Yellow
}

Write-Host ""

# ============================================
# 4. Проверка UI кнопок
# ============================================
Write-Host "4️⃣ Проверка UI кнопок..." -ForegroundColor Yellow

$uiScripts = @(
    "$projectPath\Assets\Scripts\UI\MainMenuController.cs",
    "$projectPath\Assets\Scenes\MainMenu.unity"
)

$uiFound = $true
foreach ($script in $uiScripts) {
    if (Test-Path $script) {
        Write-Host "  ✅ Найден: $script" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Не найден: $script" -ForegroundColor Yellow
        $uiFound = $false
    }
}

if ($uiFound) {
    # Проверка подписок на события
    $mainMenuController = Get-Content "$projectPath\Assets\Scripts\UI\MainMenuController.cs" -Raw
    
    if ($mainMenuController -match 'clicked\s*\+=') {
        Write-Host "  ✅ События кнопок подписаны" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  События кнопок могут быть не подписаны" -ForegroundColor Yellow
    }
    
    if ($mainMenuController -match 'clicked\s*-=' -or $mainMenuController -match 'OnDisable') {
        Write-Host "  ✅ События кнопок отписываются (OnDisable)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Проверь отписку событий в OnDisable" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ℹ️  UI не требуется для текущей задачи" -ForegroundColor Gray
}

Write-Host ""

# ============================================
# ФИНАЛ
# ============================================
Write-Host "============================================" -ForegroundColor Cyan

if ($allPassed) {
    Write-Host "✅ ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Задача может быть завершена." -ForegroundColor White
} else {
    Write-Host "❌ ЕСТЬ ПРОБЛЕМЫ!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Нельзя завершить задачу. Исправь ошибки выше." -ForegroundColor White
    Write-Host ""
    Write-Host "Используй команды:" -ForegroundColor Yellow
    Write-Host "  .\auto-build.ps1        — Исправить компиляцию" -ForegroundColor White
    Write-Host "  dotnet test             — Запустить тесты" -ForegroundColor White
    Write-Host "  .\auto-build-exe.ps1    — Собрать EXE" -ForegroundColor White
}

Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Вернуться в исходную директорию
Set-Location "D:\QwenPoekt"
