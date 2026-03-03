# test-seamless-launch.ps1 — Тест бесшовного запуска
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Тестирование автономного запуска Ядра

param(
    [switch]$Verbose,
    [switch]$Log,
    [string]$LogPath = "reports\seamless-launch-test.log"
)

$ErrorActionPreference = "Stop"

# Логирование
function Write-Log {
    param($msg, $color = "Cyan")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $msg"
    
    if ($Log) {
        $logEntry | Out-File -FilePath $LogPath -Append -Encoding UTF8
    }
    
    Write-Host $msg -ForegroundColor $color
}

Write-Log "╔══════════════════════════════════════════════════════════╗" "Yellow"
Write-Log "║         ТЕСТ БЕСШОВНОГО ЗАПУСКА $(Get-Date -Format 'HH:mm:ss')          ║" "Yellow"
Write-Log "╚══════════════════════════════════════════════════════════╝" "Yellow"
Write-Host ""

# ----------------------------------------------------------------------------
# ТЕСТ 1: Проверка критичных файлов
# ----------------------------------------------------------------------------

Write-Log "[Тест 1/5] Проверка критичных файлов..." "Cyan"

$criticalFiles = @(
    "AI_START_HERE.md",
    "AGENTS.md",
    "SEAMLESS_START.md",
    "ТЕКУЩАЯ_ЗАДАЧА.md",
    ".resume_marker.json"
)

$test1Pass = $true
foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        Write-Log "  ✅ $file" "Green"
    } else {
        Write-Log "  ❌ $file — НЕ НАЙДЕН!" "Red"
        $test1Pass = $false
    }
}

Write-Host ""
if ($test1Pass) {
    Write-Log "✅ Тест 1 пройден" "Green"
} else {
    Write-Log "❌ Тест 1 провален" "Red"
}
Write-Host ""

# ----------------------------------------------------------------------------
# ТЕСТ 2: Проверка скриптов
# ----------------------------------------------------------------------------

Write-Log "[Тест 2/5] Проверка скриптов..." "Cyan"

$requiredScripts = @(
    "scripts/check-kernel-integrity.ps1",
    "03-Resources/PowerShell/start-session.ps1",
    "03-Resources/PowerShell/end-session.ps1"
)

$test2Pass = $true
foreach ($script in $requiredScripts) {
    if (Test-Path $script) {
        Write-Log "  ✅ $script" "Green"
    } else {
        Write-Log "  ❌ $script — НЕ НАЙДЕН!" "Red"
        $test2Pass = $false
    }
}

Write-Host ""
if ($test2Pass) {
    Write-Log "✅ Тест 2 пройден" "Green"
} else {
    Write-Log "❌ Тест 2 провален" "Red"
}
Write-Host ""

# ----------------------------------------------------------------------------
# ТЕСТ 3: Проверка .qwen/ (опционально)
# ----------------------------------------------------------------------------

Write-Log "[Тест 3/5] Проверка .qwen/ конфигурации..." "Cyan"

$qwenExists = Test-Path ".qwen"
$qwenRulesExists = Test-Path ".qwen\rules"

if ($qwenExists) {
    Write-Log "  ✅ .qwen/ папка" "Green"
} else {
    Write-Log "  ⚠️ .qwen/ отсутствует (автономный режим)" "Yellow"
}

if ($qwenRulesExists) {
    $rulesCount = (Get-ChildItem ".qwen\rules" -File -Filter "*.md").Count
    Write-Log "  ✅ .qwen/rules/ ($rulesCount правил)" "Green"
} else {
    Write-Log "  ⚠️ .qwen/rules/ отсутствует" "Yellow"
}

$test3Pass = $true
Write-Host ""
Write-Log "✅ Тест 3 пройден (опционально)" "Green"
Write-Host ""

# ----------------------------------------------------------------------------
# ТЕСТ 4: Проверка сессий
# ----------------------------------------------------------------------------

Write-Log "[Тест 4/5] Проверка сессий..." "Cyan"

if (Test-Path "sessions") {
    $sessionCount = (Get-ChildItem "sessions" -Directory).Count
    Write-Log "  ✅ sessions/ папка ($sessionCount сессий)" "Green"
    
    if ($sessionCount -gt 0) {
        $latestSession = Get-ChildItem "sessions" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1
        Write-Log "  ✅ Последняя сессия: $($latestSession.Name)" "Green"
        
        if ($Verbose) {
            $chatExists = Test-Path "$($latestSession.FullName)\chat.md"
            $metaExists = Test-Path "$($latestSession.FullName)\metadata.json"
            
            if ($chatExists) {
                Write-Log "    ✅ chat.md" "Green"
            }
            if ($metaExists) {
                Write-Log "    ✅ metadata.json" "Green"
            }
        }
    }
} else {
    Write-Log "  ❌ sessions/ папка — НЕ НАЙДЕНА!" "Red"
}

$test4Pass = (Test-Path "sessions")
Write-Host ""
if ($test4Pass) {
    Write-Log "✅ Тест 4 пройден" "Green"
} else {
    Write-Log "❌ Тест 4 провален" "Red"
}
Write-Host ""

# ----------------------------------------------------------------------------
# ТЕСТ 5: Автономный запуск (симуляция)
# ----------------------------------------------------------------------------

Write-Log "[Тест 5/5] Симуляция автономного запуска..." "Cyan"
Write-Log "  (Проверка что SEAMLESS_START.md читается)" "Gray"

if (Test-Path "SEAMLESS_START.md") {
    $content = Get-Content "SEAMLESS_START.md" -Raw
    
    if ($content -match "АВТОНОМНАЯ ИНСТРУКЦИЯ") {
        Write-Log "  ✅ SEAMLESS_START.md содержит автономную инструкцию" "Green"
    } else {
        Write-Log "  ⚠️ SEAMLESS_START.md не содержит автономную инструкцию" "Yellow"
    }
    
    if ($content -match "без .qwen") {
        Write-Log "  ✅ Упоминание работы без .qwen/" "Green"
    }
    
    $test5Pass = $true
} else {
    Write-Log "  ❌ SEAMLESS_START.md — НЕ НАЙДЕН!" "Red"
    $test5Pass = $false
}

Write-Host ""
if ($test5Pass) {
    Write-Log "✅ Тест 5 пройден" "Green"
} else {
    Write-Log "❌ Тест 5 провален" "Red"
}
Write-Host ""

# ----------------------------------------------------------------------------
# ИТОГ
# ----------------------------------------------------------------------------

Write-Log "╔══════════════════════════════════════════════════════════╗" "Yellow"
Write-Log "║                    ИТОГИ ТЕСТОВ                          ║" "Yellow"
Write-Log "╚══════════════════════════════════════════════════════════╝" "Yellow"
Write-Host ""

$testsPassed = 0
$totalTests = 5

if ($test1Pass) { $testsPassed++ }
if ($test2Pass) { $testsPassed++ }
if ($test3Pass) { $testsPassed++ }
if ($test4Pass) { $testsPassed++ }
if ($test5Pass) { $testsPassed++ }

Write-Log "Пройдено тестов: $testsPassed из $totalTests" "Cyan"
Write-Host ""

if ($testsPassed -eq $totalTests) {
    Write-Log "✅ ВСЕ ТЕСТЫ ПРОЙДЕНЫ!" "Green"
    Write-Host ""
    Write-Log "Ядро готово к бесшовному запуску." "Green"
    exit 0
} else {
    Write-Log "❌ НЕКОТОРЫЕ ТЕСТЫ ПРОВАЛЕНЫ!" "Red"
    Write-Host ""
    Write-Log "Рекомендации:" "Yellow"
    
    if (-not $test1Pass) {
        Write-Log "  • Восстановите критичные файлы" "Yellow"
    }
    if (-not $test2Pass) {
        Write-Log "  • Восстановите скрипты" "Yellow"
    }
    if (-not $test4Pass) {
        Write-Log "  • Создайте папку sessions/" "Yellow"
    }
    
    Write-Host ""
    Write-Log "Используйте SEAMLESS_START.md для автономного запуска." "Cyan"
    exit 1
}
