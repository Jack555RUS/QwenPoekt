# check-file-naming.ps1 — Проверка соблюдения правил именования
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Поиск нарушений в именах файлов и отсутствии front matter

param(
    [string]$Path = ".",
    [switch]$Recursive,
    [switch]$CheckFrontMatter,
    [switch]$AutoFix,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Цвета вывода
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║         ПРОВЕРКА ПРАВИЛ ИМЕНОВАНИЯ $(Get-Date -Format 'HH:mm:ss')          ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

# ----------------------------------------------------------------------------
# ПАРАМЕТРЫ ПРОВЕРКИ
# ----------------------------------------------------------------------------

$getParams = @{
    Path = $Path
    Include = "*.md","*.ps1","*.json"
    ErrorAction = "SilentlyContinue"
}

if ($Recursive) {
    $getParams.Recurse = $true
}

Write-Info "Путь: $Path"
Write-Info "Рекурсивно: $($Recursive ? 'Да' : 'Нет')"
Write-Info "Проверка front matter: $($CheckFrontMatter ? 'Да' : 'Нет')"
Write-Host ""

# ----------------------------------------------------------------------------
# СБОР ФАЙЛОВ
# ----------------------------------------------------------------------------

Write-Info "[1/4] Сбор файлов..."
$files = Get-ChildItem @getParams -File
Write-Host "  Найдено файлов: $($files.Count)" -ForegroundColor Gray
Write-Host ""

# ----------------------------------------------------------------------------
# ПРОВЕРКА 1: Кириллица в именах
# ----------------------------------------------------------------------------

Write-Info "[2/4] Проверка кириллицы в именах..."
$cyrillicFiles = @()

foreach ($file in $files) {
    if ($file.Name -match '[\x{0400}-\x{04FF}]') {
        $cyrillicFiles += $file
        Write-Error "  ❌ $($file.FullName)"
    } elseif ($Verbose) {
        Write-Success "  ✅ $($file.Name)"
    }
}

Write-Host ""
Write-Info "Файлов с кириллицей: $($cyrillicFiles.Count)"
Write-Host ""

# ----------------------------------------------------------------------------
# ПРОВЕРКА 2: Пробелы в именах
# ----------------------------------------------------------------------------

Write-Info "[3/4] Проверка пробелов в именах..."
$spaceFiles = @()

foreach ($file in $files) {
    $baseName = $file.BaseName
    if ($baseName -match '\s') {
        $spaceFiles += $file
        Write-Error "  ❌ $($file.FullName)"
    } elseif ($Verbose) {
        Write-Success "  ✅ $($file.Name)"
    }
}

Write-Host ""
Write-Info "Файлов с пробелами: $($spaceFiles.Count)"
Write-Host ""

# ----------------------------------------------------------------------------
# ПРОВЕРКА 3: Front matter (для .md файлов)
# ----------------------------------------------------------------------------

if ($CheckFrontMatter) {
    Write-Info "[4/4] Проверка front matter..."
    $missingFrontMatter = @()
    
    $mdFiles = $files | Where-Object { $_.Extension -eq '.md' }
    
    foreach ($file in $mdFiles) {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        
        # Проверка наличия front matter (--- в начале файла)
        if ($content -notmatch '^---\s*$') {
            $missingFrontMatter += $file
            Write-Warning "  ⚠️ $($file.FullName) — нет front matter"
        } elseif ($Verbose) {
            Write-Success "  ✅ $($file.Name) — front matter есть"
        }
    }
    
    Write-Host ""
    Write-Info "Файлов без front matter: $($missingFrontMatter.Count)"
    Write-Host ""
} else {
    $missingFrontMatter = @()
}

# ----------------------------------------------------------------------------
# АВТОМАТИЧЕСКОЕ ИСПРАВЛЕНИЕ
# ----------------------------------------------------------------------------

if ($AutoFix -and ($cyrillicFiles.Count -gt 0 -or $spaceFiles.Count -gt 0)) {
    Write-Info "Автоматическое исправление..."
    Write-Host ""
    
    # Исправление кириллицы (транслитерация)
    foreach ($file in $cyrillicFiles) {
        $newName = $file.Name -replace 'а', 'a' -replace 'б', 'b' -replace 'в', 'v'
        # Упрощённая транслитерация - в реальности нужна полная таблица
        
        Write-Warning "  Транслитерация: $($file.Name) → $newName"
        # Rename-Item -Path $file.FullName -NewName $newName -Force
    }
    
    # Исправление пробелов (замена на дефисы)
    foreach ($file in $spaceFiles) {
        $newName = $file.Name -replace '\s', '-'
        
        Write-Warning "  Замена пробелов: $($file.Name) → $newName"
        # Rename-Item -Path $file.FullName -NewName $newName -Force
    }
    
    Write-Host ""
}

# ----------------------------------------------------------------------------
# ИТОГ
# ----------------------------------------------------------------------------

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║                    ИТОГИ ПРОВЕРКИ                        ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

$totalViolations = $cyrillicFiles.Count + $spaceFiles.Count + $missingFrontMatter.Count

if ($totalViolations -eq 0) {
    Write-Success "✅ Все файлы соответствуют правилам именования!"
    exit 0
} else {
    Write-Error "❌ Найдено нарушений: $totalViolations"
    Write-Host ""
    
    if ($cyrillicFiles.Count -gt 0) {
        Write-Host "Кириллица в именах:" -ForegroundColor Red
        foreach ($file in $cyrillicFiles) {
            Write-Host "  • $($file.Name)" -ForegroundColor Red
        }
        Write-Host ""
    }
    
    if ($spaceFiles.Count -gt 0) {
        Write-Host "Пробелы в именах:" -ForegroundColor Red
        foreach ($file in $spaceFiles) {
            Write-Host "  • $($file.Name)" -ForegroundColor Red
        }
        Write-Host ""
    }
    
    if ($missingFrontMatter.Count -gt 0) {
        Write-Host "Отсутствует front matter:" -ForegroundColor Yellow
        Write-Host "  $($missingFrontMatter.Count) файлов" -ForegroundColor Yellow
        Write-Host ""
    }
    
    Write-Host "Рекомендации:" -ForegroundColor Yellow
    Write-Host "  1. Переименовать файлы с нарушениями" -ForegroundColor Yellow
    Write-Host "  2. Добавить front matter в документы" -ForegroundColor Yellow
    Write-Host "  3. Использовать: .\scripts\check-file-naming.ps1 -AutoFix" -ForegroundColor Yellow
    Write-Host ""
    
    exit 1
}
