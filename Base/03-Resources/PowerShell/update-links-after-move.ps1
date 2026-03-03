# update-links-after-move.ps1 — Обновление ссылок после перемещения файлов
# Версия: 1.0
# Дата: 3 марта 2026 г.
# Назначение: Автоматическое обновление ссылок в .md, .ps1, .json файлах

param(
    [string]$OldPath,          # Старый путь (например, "scripts/")
    [string]$NewPath,          # Новый путь (например, "03-Resources/PowerShell/")
    [string]$SearchPath = ".", # Где искать файлы для обновления
    [switch]$Verbose,          # Подробный вывод
    [switch]$DryRun            # Сухой запуск (без изменений)
)

$ErrorActionPreference = "Stop"

# Цвета вывода
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║         ОБНОВЛЕНИЕ ССЫЛОК ПОСЛЕ ПЕРЕМЕЩЕНИЯ             ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

# ============================================
# 1. ПОДГОТОВКА ПУТЕЙ
# ============================================

Write-Info "[1/5] Подготовка путей..."

# Нормализация путей
$OldPath = $OldPath.TrimEnd('\').Replace('\', '/')
$NewPath = $NewPath.TrimEnd('\').Replace('\', '/')
$SearchPath = $SearchPath.TrimEnd('\').Replace('\', '/')

Write-Host "  Старый путь: $OldPath" -ForegroundColor Gray
Write-Host "  Новый путь: $NewPath" -ForegroundColor Gray
Write-Host "  Поиск в: $SearchPath" -ForegroundColor Gray

# ============================================
# 2. ПОИСК ФАЙЛОВ ДЛЯ ОБНОВЛЕНИЯ
# ============================================

Write-Info "[2/5] Поиск файлов для обновления..."

$extensions = @("*.md", "*.ps1", "*.json", "*.yaml", "*.yml")
$filesToUpdate = @()

foreach ($ext in $extensions) {
    $files = Get-ChildItem -Path $SearchPath -Filter $ext -Recurse -File
    $filesToUpdate += $files
}

Write-Host "  📊 Файлов для проверки: $($filesToUpdate.Count)" -ForegroundColor Gray

# ============================================
# 3. ОБНОВЛЕНИЕ ССЫЛОК
# ============================================

Write-Info "[3/5] Обновление ссылок..."

$updatedCount = 0
$failedFiles = @()

foreach ($file in $filesToUpdate) {
    try {
        $content = Get-Content $file -Raw
        $originalContent = $content
        
        # Замена путей в ссылках
        $content = $content -replace [regex]::Escape($OldPath), $NewPath
        
        # Если контент изменился
        if ($content -ne $originalContent) {
            if (-not $DryRun) {
                # Сохранение с UTF-8 без BOM
                $content | Out-File -FilePath $file.FullName -Encoding utf8 -NoNewline
            }
            $updatedCount++
            
            if ($Verbose) {
                Write-Host "  ✅ $($file.FullName)" -ForegroundColor Green
            }
        }
    } catch {
        $failedFiles += $file.FullName
        Write-Warning "  ❌ $($file.FullName): $_"
    }
}

Write-Host ""
Write-Host "  📊 Обновлено файлов: $updatedCount" -ForegroundColor Cyan
if ($failedFiles.Count -gt 0) {
    Write-Host "  ❌ Ошибок: $($failedFiles.Count)" -ForegroundColor Red
}

# ============================================
# 4. ПРОВЕРКА БИТЫХ ССЫЛОК
# ============================================

Write-Info "[4/5] Проверка битых ссылок..."

$markdownFiles = Get-ChildItem -Path $SearchPath -Filter "*.md" -Recurse -File
$brokenLinks = @()

foreach ($mdFile in $markdownFiles) {
    $content = Get-Content $mdFile -Raw
    
    # Поиск ссылок вида [текст](путь)
    $links = [regex]::Matches($content, '\[([^\]]*)\]\(([^\)]*)\)')
    
    foreach ($link in $links) {
        $linkPath = $link.Groups[2].Value
        
        # Пропуск внешних ссылок
        if ($linkPath -match '^https?://') {
            continue
        }
        
        # Пропуск якорей
        if ($linkPath -match '^#') {
            continue
        }
        
        # Проверка существования файла
        $relativePath = $linkPath.TrimStart('./').Split('#')[0]
        $fullPath = Join-Path (Split-Path -Parent $mdFile.FullName) $relativePath
        
        if (-not (Test-Path $fullPath)) {
            $brokenLinks += @{
                File = $mdFile.FullName
                Link = $linkPath
                Line = $link.Value
            }
        }
    }
}

if ($brokenLinks.Count -gt 0) {
    Write-Warning "  ⚠️ Найдено битых ссылок: $($brokenLinks.Count)"
    
    if ($Verbose) {
        Write-Host ""
        Write-Host "  Битые ссылки:" -ForegroundColor Yellow
        foreach ($link in $brokenLinks | Select-Object -First 10) {
            Write-Host "    - $($link.File)" -ForegroundColor Gray
            Write-Host "      → $($link.Link)" -ForegroundColor Gray
        }
    }
} else {
    Write-Success "  ✅ Битых ссылок не найдено"
}

# ============================================
# 5. ИТОГОВЫЙ ОТЧЁТ
# ============================================

Write-Info "[5/5] Итоговый отчёт..."

Write-Host ""
Write-Host "  📊 Итоги:" -ForegroundColor Cyan
Write-Host "  ────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  Файлов проверено: $($filesToUpdate.Count)" -ForegroundColor Gray
Write-Host "  Файлов обновлено: $updatedCount" -ForegroundColor Gray
Write-Host "  Битых ссылок: $($brokenLinks.Count)" -ForegroundColor Gray
Write-Host "  Ошибок: $($failedFiles.Count)" -ForegroundColor Gray
Write-Host "  ────────────────────────────────────────" -ForegroundColor Gray
Write-Host ""

if ($DryRun) {
    Write-Warning "  ⚠️ DRY-RUN режим (изменения не сохранены)"
}

# ============================================
# ИТОГ
# ============================================

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Success "║              ОБНОВЛЕНИЕ ЗАВЕРШЕНО ✅                   ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

if (-not $DryRun -and $updatedCount -gt 0) {
    Write-Info "📌 Следующие шаги:"
    Write-Host "  1. Проверить изменения:" -ForegroundColor Gray
    Write-Host "     git status" -ForegroundColor Gray
    Write-Host "  2. Закоммитить:" -ForegroundColor Gray
    Write-Host "     git add ." -ForegroundColor Gray
    Write-Host "     git commit -m `"Update: $updatedCount ссылок после перемещения`"" -ForegroundColor Gray
    Write-Host ""
}

# Возврат результата
return @{
    FilesChecked = $filesToUpdate.Count
    FilesUpdated = $updatedCount
    BrokenLinksCount = $brokenLinks.Count
    FailedFiles = $failedFiles.Count
}
