# test-all-docs.ps1 — Полное тестирование документации
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Автоматическая валидация документации (Markdown, JSON, ссылки)

param(
    [switch]$Fix,          # Автоматическое исправление
    [switch]$Verbose,      # Подробный вывод
    [string]$Path = "."    # Путь для проверки
)

$ErrorActionPreference = "Stop"

# Цвета вывода
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║         ТЕСТИРОВАНИЕ ДОКУМЕНТАЦИИ $(Get-Date -Format 'HH:mm:ss')        ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

$results = @{
    Markdownlint = $null
    LinkCheck = $null
    SpellCheck = $null
    JSON = $null
    MetaFields = $null
    Total = 0
    Passed = 0
    Failed = 0
}

# ============================================
# 1. MARKDOWNLINT
# ============================================

Write-Info "[1/5] Markdownlint — проверка синтаксиса..."

try {
    $mdFiles = Get-ChildItem -Recurse -Filter *.md -Exclude node_modules,_BACKUP,OLD
    $results.Markdownlint = @()
    
    foreach ($file in $mdFiles) {
        $result = markdownlint $file.FullName 2>&1
        if ($result -and $result -notmatch "^OK$") {
            $results.Markdownlint += $result
        }
    }
    
    if ($results.Markdownlint.Count -eq 0) {
        Write-Success "  ✅ Markdownlint: ошибок нет"
        $results.Passed++
    } else {
        Write-Warning "  ⚠️ Markdownlint: $($results.Markdownlint.Count) ошибок"
        if ($Verbose) {
            $results.Markdownlint | ForEach-Object { Write-Warning "    $_" }
        }
        $results.Failed++
    }
} catch {
    Write-Error "  ❌ Markdownlint: $_"
    $results.Failed++
}

Write-Host ""

# ============================================
# 2. ПРОВЕРКА ССЫЛОК
# ============================================

Write-Info "[2/5] Проверка ссылок..."

try {
    $mdFiles = Get-ChildItem -Recurse -Filter *.md -Exclude node_modules,_BACKUP,OLD -ErrorAction SilentlyContinue
    $results.LinkCheck = @()
    
    foreach ($file in $mdFiles) {
        $result = markdown-link-check $file.FullName 2>&1
        if ($result -match "ERROR|✖") {
            $results.LinkCheck += $result
        }
    }
    
    if ($results.LinkCheck.Count -eq 0) {
        Write-Success "  ✅ Ссылки: все работают"
        $results.Passed++
    } else {
        Write-Warning "  ⚠️ Ссылки: $($results.LinkCheck.Count) проблем"
        if ($Verbose) {
            $results.LinkCheck | ForEach-Object { Write-Warning "    $_" }
        }
        $results.Failed++
    }
} catch {
    Write-Error "  ❌ Ссылки: $_"
    $results.Failed++
}

Write-Host ""

# ============================================
# 3. ПРОВЕРКА ОРФОГРАФИИ
# ============================================

Write-Info "[3/5] cspell — проверка орфографии..."

try {
    $result = cspell "**/*.md" --no-progress 2>&1
    if ($result -match "Issues found") {
        Write-Warning "  ⚠️ cspell: найдены ошибки"
        if ($Verbose) {
            Write-Warning "    $result"
        }
        $results.Failed++
    } else {
        Write-Success "  ✅ cspell: ошибок нет"
        $results.Passed++
    }
} catch {
    Write-Error "  ❌ cspell: $_"
    $results.Failed++
}

Write-Host ""

# ============================================
# 4. JSON ВАЛИДАЦИЯ
# ============================================

Write-Info "[4/5] JSON валидация..."

try {
    $jsonFiles = Get-ChildItem -Recurse -Filter *.json -Exclude node_modules,_BACKUP,OLD -ErrorAction SilentlyContinue
    $results.JSON = @()
    
    foreach ($file in $jsonFiles) {
        try {
            $content = Get-Content $file.FullName -Raw | ConvertFrom-Json
            # Проверка структуры
            if ($file.Name -eq "metadata.json") {
                if (-not $content.session_id -or -not $content.timestamp) {
                    $results.JSON += "$($file.FullName): missing required fields"
                }
            }
        } catch {
            $results.JSON += "$($file.FullName): $($_.Exception.Message)"
        }
    }
    
    if ($results.JSON.Count -eq 0) {
        Write-Success "  ✅ JSON: все файлы валидны"
        $results.Passed++
    } else {
        Write-Warning "  ⚠️ JSON: $($results.JSON.Count) ошибок"
        if ($Verbose) {
            $results.JSON | ForEach-Object { Write-Warning "    $_" }
        }
        $results.Failed++
    }
} catch {
    Write-Error "  ❌ JSON: $_"
    $results.Failed++
}

Write-Host ""

# ============================================
# 5. ПРОВЕРКА МЕТА-ПОЛЕЙ
# ============================================

Write-Info "[5/5] Проверка мета-полей (версия, дата, статус)..."

$metaErrors = @()
$mdFiles = Get-ChildItem -Recurse -Filter *.md -Exclude node_modules,_BACKUP,OLD -ErrorAction SilentlyContinue

foreach ($file in $mdFiles) {
    $content = Get-Content $file.FullName -First 30
    $hasVersion = $content -match '\*\*Версия\*\*:'
    $hasDate = $content -match '\*\*Дата\*\*:'
    $hasStatus = $content -match '\*\*Статус\*\*:'
    
    # Только для файлов в определённых папках
    if ($file.DirectoryName -match "KNOWLEDGE_BASE|\.qwen|_drafts") {
        if (-not $hasVersion -or -not $hasDate -or -not $hasStatus) {
            $metaErrors += "$($file.FullName): missing metadata"
        }
    }
}

$results.MetaFields = $metaErrors

if ($metaErrors.Count -eq 0) {
    Write-Success "  ✅ Мета-поля: все заполнены"
    $results.Passed++
} else {
    Write-Warning "  ⚠️ Мета-поля: $($metaErrors.Count) файлов без метаданных"
    if ($Verbose) {
        $metaErrors | ForEach-Object { Write-Warning "    $_" }
    }
    $results.Failed++
}

Write-Host ""

# ============================================
# ИТОГ
# ============================================

$results.Total = $results.Passed + $results.Failed

Write-Info "╔══════════════════════════════════════════════════════════╗"
if ($results.Failed -eq 0) {
    Write-Success "║           ВСЕ ТЕСТЫ ПРОЙДЕНЫ ✅                      ║"
} else {
    Write-Error "║           ЕСТЬ ОШИБКИ ❌                              ║"
}
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

Write-Info "📊 Результаты:"
Write-Host "  ✅ Пройдено: $($results.Passed) из $($results.Total)" -ForegroundColor $(if ($results.Failed -eq 0) { "Green" } else { "Yellow" })
Write-Host "  ❌ Провалено: $($results.Failed)" -ForegroundColor $(if ($results.Failed -eq 0) { "Green" } else { "Red" })
Write-Host ""

# Возврат кода выхода
if ($results.Failed -eq 0) {
    Write-Success "Готово к коммиту! ✅"
    exit 0
} else {
    Write-Error "Исправьте ошибки перед коммитом ❌"
    exit 1
}
