# check-kernel-integrity.ps1 — Проверка целостности Ядра
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Проверка критичных файлов Ядра перед запуском

param(
    [switch]$Verbose,
    [switch]$AutoFix
)

$ErrorActionPreference = "Stop"

# Цвета вывода
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║         ПРОВЕРКА ЦЕЛОСТНОСТИ ЯДРА $(Get-Date -Format 'HH:mm:ss')          ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

# ----------------------------------------------------------------------------
# КРИТИЧНЫЕ ФАЙЛЫ (должны быть всегда)
# ----------------------------------------------------------------------------

$criticalFiles = @(
    @{Path = "AI_START_HERE.md"; Name = "Главная инструкция"; Critical = $true},
    @{Path = "AGENTS.md"; Name = "Точка входа"; Critical = $true},
    @{Path = "ТЕКУЩАЯ_ЗАДАЧА.md"; Name = "Текущая задача"; Critical = $true},
    @{Path = ".resume_marker.json"; Name = "Маркер сессии"; Critical = $true},
    @{Path = "SEAMLESS_START.md"; Name = "Автономный запуск"; Critical = $true}
)

# ----------------------------------------------------------------------------
# ВАЖНЫЕ ПАПКИ (должны существовать)
# ----------------------------------------------------------------------------

$criticalDirs = @(
    @{Path = "scripts"; Name = "Скрипты"; Critical = $true},
    @{Path = "sessions"; Name = "Сессии"; Critical = $true},
    @{Path = "03-Resources"; Name = "Ресурсы"; Critical = $true},
    @{Path = ".qwen"; Name = "Конфиг ИИ"; Critical = $false}
)

# ----------------------------------------------------------------------------
# ПРОВЕРКА ФАЙЛОВ
# ----------------------------------------------------------------------------

Write-Info "[1/3] Проверка критичных файлов..."
Write-Host ""

$missingFiles = @()
$presentCount = 0

foreach ($file in $criticalFiles) {
    $exists = Test-Path $file.Path
    
    if ($exists) {
        Write-Success "  ✅ $($file.Name)"
        $presentCount++
        
        if ($Verbose) {
            $size = (Get-Item $file.Path).Length / 1KB
            Write-Host "     Размер: $([Math]::Round($size, 2)) KB" -ForegroundColor Gray
        }
    } else {
        if ($file.Critical) {
            Write-Error "  ❌ $($file.Name) — КРИТИЧНО!"
            $missingFiles += $file.Path
        } else {
            Write-Warning "  ⚠️ $($file.Name) — можно восстановить"
        }
    }
}

Write-Host ""
Write-Info "Файлов: $presentCount из $($criticalFiles.Count)"
Write-Host ""

# ----------------------------------------------------------------------------
# ПРОВЕРКА ПАПОК
# ----------------------------------------------------------------------------

Write-Info "[2/3] Проверка критичных папок..."
Write-Host ""

$missingDirs = @()

foreach ($dir in $criticalDirs) {
    $exists = Test-Path $dir.Path -PathType Container
    
    if ($exists) {
        Write-Success "  ✅ $($dir.Name)"
        
        if ($Verbose) {
            $fileCount = (Get-ChildItem $dir.Path -Recurse -File).Count
            Write-Host "     Файлов: $fileCount" -ForegroundColor Gray
        }
    } else {
        if ($dir.Critical) {
            Write-Error "  ❌ $($dir.Name) — КРИТИЧНО!"
            $missingDirs += $dir.Path
        } else {
            Write-Warning "  ⚠️ $($dir.Name) — можно восстановить"
        }
    }
}

Write-Host ""
Write-Info "Папок: $(($criticalDirs | Where-Object { Test-Path $_.Path }).Count) из $($criticalDirs.Count)"
Write-Host ""

# ----------------------------------------------------------------------------
# ПРОВЕРКА .qwen/ (особая проверка)
# ----------------------------------------------------------------------------

Write-Info "[3/3] Проверка .qwen/ конфигурации..."
Write-Host ""

$qwenExists = Test-Path ".qwen"
$qwenRulesExists = Test-Path ".qwen\rules"
$qwenQwenExists = Test-Path ".qwen\QWEN.md"

if ($qwenExists) {
    Write-Success "  ✅ .qwen/ папка"
} else {
    Write-Warning "  ⚠️ .qwen/ папка отсутствует"
    Write-Host "  💡 Используйте SEAMLESS_START.md для автономного запуска" -ForegroundColor Cyan
}

if ($qwenRulesExists) {
    $rulesCount = (Get-ChildItem ".qwen\rules" -File -Filter "*.md").Count
    Write-Success "  ✅ .qwen/rules/ ($rulesCount правил)"
} else {
    Write-Warning "  ⚠️ .qwen/rules/ отсутствует"
    Write-Host "  💡 Можно восстановить из git: git checkout HEAD -- .qwen/" -ForegroundColor Cyan
}

if ($qwenQwenExists) {
    Write-Success "  ✅ .qwen/QWEN.md"
} else {
    Write-Warning "  ⚠️ .qwen/QWEN.md отсутствует"
}

Write-Host ""

# ----------------------------------------------------------------------------
# АВТОМАТИЧЕСКОЕ ИСПРАВЛЕНИЕ
# ----------------------------------------------------------------------------

if ($AutoFix -and ($missingDirs.Count -gt 0 -or $missingFiles.Count -gt 0)) {
    Write-Info "Автоматическое исправление..."
    Write-Host ""
    
    # Восстановление .qwen/ из git
    if (-not $qwenExists) {
        Write-Info "Восстановление .qwen/ из git..."
        git checkout HEAD -- .qwen/ 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "  ✅ .qwen/ восстановлен"
        } else {
            Write-Warning "  ⚠️ Не удалось восстановить .qwen/ из git"
        }
    }
    
    # Восстановление правил из 03-Resources
    if (-not $qwenRulesExists -and (Test-Path "03-Resources/Knowledge/01_RULES")) {
        Write-Info "Копирование правил из 03-Resources..."
        New-Item -ItemType Directory -Path ".qwen\rules" -Force | Out-Null
        Copy-Item "03-Resources/Knowledge/01_RULES/*.md" ".qwen\rules/" -Force
        Write-Success "  ✅ Правила скопированы"
    }
}

# ----------------------------------------------------------------------------
# ИТОГ
# ----------------------------------------------------------------------------

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║                    ИТОГИ ПРОВЕРКИ                        ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

if ($missingFiles.Count -eq 0 -and $missingDirs.Count -eq 0) {
    Write-Success "✅ Все критичные файлы на месте!"
    Write-Host ""
    Write-Host "Ядро готово к работе." -ForegroundColor Green
    
    if (-not $qwenExists) {
        Write-Host ""
        Write-Host "💡 .qwen/ отсутствует — используйте SEAMLESS_START.md" -ForegroundColor Cyan
        Write-Host "   или восстановите: git checkout HEAD -- .qwen/" -ForegroundColor Cyan
    }
    
    exit 0
} else {
    Write-Error "❌ Найдены проблемы!"
    Write-Host ""
    
    if ($missingFiles.Count -gt 0) {
        Write-Host "Отсутствуют файлы:" -ForegroundColor Red
        foreach ($file in $missingFiles) {
            Write-Host "  • $file" -ForegroundColor Red
        }
        Write-Host ""
    }
    
    Write-Host "Рекомендации:" -ForegroundColor Yellow
    Write-Host "  1. Проверьте git status" -ForegroundColor Yellow
    Write-Host "  2. Восстановите файлы: git checkout HEAD -- <файл>" -ForegroundColor Yellow
    Write-Host "  3. Или используйте SEAMLESS_START.md" -ForegroundColor Yellow
    Write-Host ""
    
    exit 1
}
