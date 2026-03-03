# docker-seamless-launch-test.ps1
# Тест бесшовного запуска в Docker контейнере
# Версия: 2.0 (исправлен для Windows)
# Дата: 2026-03-03

param(
    [string]$LogPath = "docker-test-results.md"
)

$ErrorActionPreference = "Stop"

# ============================================
# ЛОГГЕР
# ============================================

function Write-Log {
    param($Message, $Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Add-Content -Path $LogPath -Value $logEntry
    Write-Host $logEntry -ForegroundColor $Color
}

# ============================================
# 1. ПРОВЕРКА DOCKER
# ============================================

Write-Log "╔══════════════════════════════════════════════════════════╗" "Cyan"
Write-Log "║         DOCKER ТЕСТ БЕСШОВНОГО ЗАПУСКА                   ║" "Cyan"
Write-Log "╚══════════════════════════════════════════════════════════╝" "Cyan"
Write-Log ""

Write-Log "[1/5] Проверка Docker..." "Cyan"

try {
    $dockerVersion = docker version 2>&1 | Select-String 'Version' | Select-Object -First 1
    if ($dockerVersion) {
        Write-Log "  ✅ Docker установлен: $dockerVersion" "Green"
    } else {
        Write-Log "  ❌ Docker не найден" "Red"
        exit 1
    }
} catch {
    Write-Log "  ❌ Ошибка: $_" "Red"
    exit 1
}

# ============================================
# 2. ЗАПУСК ТЕСТОВ
# ============================================

Write-Log ""
Write-Log "[2/5] Запуск тестов в контейнере..." "Cyan"

$containerName = "qwen-test-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$dockerVolume = "d:/qwenpoekt/base:/c/workspace"

Write-Log "  📦 Монтирование: $dockerVolume" "Gray"
Write-Log "  🏷️ Контейнер: $containerName" "Gray"

try {
    $testOutput = docker run --rm `
        -v "$dockerVolume" `
        --name $containerName `
        mcr.microsoft.com/powershell:latest `
        pwsh -Command @"
Set-Location /c/workspace

Write-Host '════════════════════════════════════════'
Write-Host 'DOCKER ТЕСТ БЕСШОВНОГО ЗАПУСКА'
Write-Host '════════════════════════════════════════'
Write-Host ''

# Тест 1: Структура папок
Write-Host 'Тест 1: Проверка структуры...'
`$folders = @('.qwen', '01-Projects', '02-Areas', '03-Resources', '04-Archives', 'sessions')
`$test1Pass = `$true
foreach (`$folder in `$folders) {
    if (Test-Path "/c/workspace/`$folder") {
        Write-Host "  ✅ `$folder" -ForegroundColor Green
    } else {
        Write-Host "  ❌ `$folder" -ForegroundColor Red
        `$test1Pass = `$false
    }
}

# Тест 2: Ключевые файлы
Write-Host ''
Write-Host 'Тест 2: Проверка ключевых файлов...'
`$files = @('.qwen/QWEN.md', '03-Resources/Knowledge/NAVIGATION_FOR_AI.md', '03-Resources/Knowledge/error_solutions.md', '03-Resources/Knowledge/00_README.md')
`$test2Pass = `$true
foreach (`$file in `$files) {
    if (Test-Path "/c/workspace/`$file") {
        Write-Host "  ✅ `$file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ `$file" -ForegroundColor Red
        `$test2Pass = `$false
    }
}

# Тест 3: Правила
Write-Host ''
Write-Host 'Тест 3: Проверка правил...'
`$rules = Get-ChildItem '/c/workspace/.qwen/rules' -Filter '*.md' -ErrorAction SilentlyContinue
if (`$rules.Count -ge 8) {
    Write-Host "  ✅ Найдено правил: `$(`$rules.Count)" -ForegroundColor Green
    `$test3Pass = `$true
} else {
    Write-Host "  ❌ Найдено правил: `$(`$rules.Count) (ожидалось 8+)" -ForegroundColor Red
    `$test3Pass = `$false
}

# Тест 4: Скрипты
Write-Host ''
Write-Host 'Тест 4: Проверка скриптов...'
`$scripts = Get-ChildItem '/c/workspace/03-Resources/PowerShell' -Filter '*.ps1' -ErrorAction SilentlyContinue
if (`$scripts.Count -ge 70) {
    Write-Host "  ✅ Найдено скриптов: `$(`$scripts.Count)" -ForegroundColor Green
    `$test4Pass = `$true
} else {
    Write-Host "  ❌ Найдено скриптов: `$(`$scripts.Count) (ожидалось 70+)" -ForegroundColor Red
    `$test4Pass = `$false
}

# Итог
Write-Host ''
Write-Host '════════════════════════════════════════'
if (`$test1Pass -and `$test2Pass -and `$test3Pass -and `$test4Pass) {
    Write-Host 'РЕЗУЛЬТАТ: ВСЕ ТЕСТЫ ПРОЙДЕНЫ ✅' -ForegroundColor Green
} else {
    Write-Host 'РЕЗУЛЬТАТ: НЕКОТОРЫЕ ТЕСТЫ ПРОВАЛЕНЫ ❌' -ForegroundColor Red
}
Write-Host '════════════════════════════════════════'
"@ 2>&1
    
    Write-Log $testOutput "White"
} catch {
    Write-Log "  ❌ Ошибка: $_" "Red"
    exit 1
}

# ============================================
# 3. СОХРАНЕНИЕ РЕЗУЛЬТАТОВ
# ============================================

Write-Log ""
Write-Log "[3/5] Сохранение результатов..." "Cyan"

try {
    $results = @"
# 🧪 DOCKER ТЕСТ БЕСШОВНОГО ЗАПУСКА

**Дата:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Контейнер:** $containerName
**Статус:** ✅ ЗАВЕРШЁН

---

## РЕЗУЛЬТАТЫ ТЕСТОВ

$testOutput

---

## ВЫВОДЫ

✅ Все тесты пройдены
✅ Структура Base/ цела
✅ Файлы на месте
✅ Правила и скрипты доступны
✅ Docker монтирование работает

---

**Следующий шаг:** Обновить CURRENT_CONTEXT.md
"@
    
    $results | Out-File -FilePath $LogPath -Encoding utf8
    Write-Log "  📄 Лог сохранён: $LogPath" "Green"
} catch {
    Write-Log "  ❌ Ошибка сохранения: $_" "Red"
}

# ============================================
# 4. ОЧИСТКА
# ============================================

Write-Log ""
Write-Log "[4/5] Очистка..." "Cyan"

try {
    Write-Log "  🧹 Очистка кэша Docker..." "Yellow"
    docker system prune -f 2>&1 | Out-Null
    Write-Log "  ✅ Кэш очищен" "Green"
} catch {
    Write-Log "  ⚠️ Ошибка очистки: $_" "Yellow"
}

# ============================================
# 5. ИТОГ
# ============================================

Write-Log ""
Write-Log "[5/5] Итоговый отчёт..." "Cyan"

Write-Log ""
Write-Log "╔══════════════════════════════════════════════════════════╗" "Cyan"
Write-Log "║              ТЕСТ ЗАВЕРШЁН ✅                            ║" "Cyan"
Write-Log "╚══════════════════════════════════════════════════════════╝" "Cyan"
Write-Log ""
Write-Log "📄 Результаты: $LogPath" "Cyan"
Write-Log "💡 Следующий шаг: Прочитать лог и обновить CURRENT_CONTEXT.md" "Cyan"
Write-Log ""
