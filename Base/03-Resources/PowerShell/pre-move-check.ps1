# pre-move-check.ps1 — Проверка перед массовым перемещением файлов
# Версия: 1.0
# Дата: 3 марта 2026 г.
# Назначение: Автоматическая проверка перед перемещением >100 файлов

param(
    [string]$SourcePath,         # Исходная папка
    [string]$DestinationPath,    # Папка назначения
    [string]$Filter = "*",       # Фильтр файлов
    [switch]$Verbose,            # Подробный вывод
    [switch]$AutoConfirm         # Автоматическое подтверждение
)

$ErrorActionPreference = "Stop"

# Цвета вывода
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║         ПРОВЕРКА ПЕРЕМЕЩЕНИЯ ФАЙЛОВ                     ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

# ============================================
# 1. ПОДСЧЁТ ФАЙЛОВ
# ============================================

Write-Info "[1/5] Подсчёт файлов..."

$files = Get-ChildItem -Path $SourcePath -Filter $Filter -Recurse -File
$fileCount = $files.Count
$totalSize = ($files | Measure-Object -Property Length -Sum).Sum / 1KB

Write-Host "  📊 Файлов: $fileCount" -ForegroundColor Gray
Write-Host "  💾 Размер: $([Math]::Round($totalSize, 2)) KB" -ForegroundColor Gray

if ($fileCount -gt 100) {
    Write-Warning "  ⚠️ Массовое перемещение (>100 файлов)"
    Write-Info "  💡 Требуется подтверждение пользователя"
    
    if (-not $AutoConfirm) {
        Write-Host ""
        Write-Host "  Продолжить? (Y/N)" -ForegroundColor Yellow
        $response = Read-Host
        if ($response -ne 'Y' -and $response -ne 'y') {
            Write-Host "  ❌ Отменено пользователем" -ForegroundColor Red
            exit 0
        }
    }
} else {
    Write-Success "  ✅ Нормальное количество файлов"
}

# ============================================
# 2. ПРОВЕРКА СУЩЕСТВОВАНИЯ ПУТЕЙ
# ============================================

Write-Info "[2/5] Проверка путей..."

if (-not (Test-Path $SourcePath)) {
    Write-Error "  ❌ Исходная папка не найдена: $SourcePath"
    exit 1
} else {
    Write-Success "  ✅ Исходная папка: $SourcePath"
}

if (-not (Test-Path $DestinationPath)) {
    Write-Warning "  ⚠️ Папка назначения не найдена"
    Write-Info "  💡 Создаю: $DestinationPath"
    New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    Write-Success "  ✅ Папка создана"
} else {
    Write-Success "  ✅ Папка назначения: $DestinationPath"
}

# ============================================
# 3. ПРОВЕРКА ССЫЛОК НА ФАЙЛЫ
# ============================================

Write-Info "[3/5] Проверка ссылок на файлы..."

$baseMarkdownFiles = Get-ChildItem -Path (Split-Path -Parent $SourcePath) -Filter "*.md" -Recurse -File
$brokenLinks = @()

foreach ($mdFile in $baseMarkdownFiles) {
    $content = Get-Content $mdFile -Raw
    foreach ($file in $files) {
        $relativePath = $file.FullName.Replace((Split-Path -Parent $SourcePath), "").TrimStart('\').Replace('\', '/')
        if ($content -match [regex]::Escape($relativePath)) {
            $brokenLinks += @{
                File = $mdFile.FullName
                Link = $relativePath
                Target = $file.FullName
            }
        }
    }
}

if ($brokenLinks.Count -gt 0) {
    Write-Warning "  ⚠️ Найдено ссылок: $($brokenLinks.Count)"
    
    if ($Verbose) {
        Write-Host ""
        Write-Host "  Файлы со ссылками:" -ForegroundColor Yellow
        foreach ($link in $brokenLinks | Select-Object -First 10) {
            Write-Host "    - $($link.File)" -ForegroundColor Gray
            Write-Host "      → $($link.Link)" -ForegroundColor Gray
        }
    }
    
    Write-Info "  💡 Ссылки будут обновлены после перемещения"
} else {
    Write-Success "  ✅ Ссылок не найдено"
}

# ============================================
# 4. DRY-RUN ПЕРЕМЕЩЕНИЕ
# ============================================

Write-Info "[4/5] Dry-run перемещение..."

$testDestination = Join-Path $DestinationPath "_TEST_MOVE"
if (Test-Path $testDestination) {
    Remove-Item -Path $testDestination -Recurse -Force
}

$testFiles = $files | Select-Object -First 5
foreach ($testFile in $testFiles) {
    $relativePath = $testFile.FullName.Replace($SourcePath, "").TrimStart('\')
    $newPath = Join-Path $testDestination $relativePath
    $newDir = Split-Path -Parent $newPath
    if (-not (Test-Path $newDir)) {
        New-Item -ItemType Directory -Path $newDir -Force | Out-Null
    }
    Copy-Item -Path $testFile.FullName -Destination $newPath -Force
}

$testCount = (Get-ChildItem -Path $testDestination -Recurse -File).Count
if ($testCount -eq $testFiles.Count) {
    Write-Success "  ✅ Dry-run успешен ($testCount файлов)"
} else {
    Write-Error "  ❌ Dry-run не удался"
    exit 1
}

# Очистка теста
if (Test-Path $testDestination) {
    Remove-Item -Path $testDestination -Recurse -Force
}

# ============================================
# 5. ОТЧЁТ О ВЛИЯНИИ
# ============================================

Write-Info "[5/5] Отчёт о влиянии..."

Write-Host ""
Write-Host "  📊 Итоги проверки:" -ForegroundColor Cyan
Write-Host "  ────────────────────────────────────────" -ForegroundColor Gray
Write-Host "  Файлов к перемещению: $fileCount" -ForegroundColor Gray
Write-Host "  Размер: $([Math]::Round($totalSize, 2)) KB" -ForegroundColor Gray
Write-Host "  Ссылок найдено: $($brokenLinks.Count)" -ForegroundColor Gray
Write-Host "  Dry-run: ✅ Успешен" -ForegroundColor Gray
Write-Host "  ────────────────────────────────────────" -ForegroundColor Gray
Write-Host ""

# ============================================
# ИТОГ
# ============================================

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Success "║              ПРОВЕРКА ЗАВЕРШЕНА ✅                     ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

Write-Info "📌 Следующие шаги:"
Write-Host "  1. Получить подтверждение пользователя" -ForegroundColor Gray
Write-Host "  2. Выполнить перемещение:" -ForegroundColor Gray
Write-Host "     Move-Item -Path `"$SourcePath`" -Destination `"$DestinationPath`"" -ForegroundColor Gray
Write-Host "  3. Обновить ссылки:" -ForegroundColor Gray
Write-Host "     .\scripts\update-links-after-move.ps1" -ForegroundColor Gray
Write-Host "  4. Закоммитить изменения:" -ForegroundColor Gray
Write-Host "     git add . && git commit -m `"Move: $fileCount файлов`"" -ForegroundColor Gray
Write-Host ""

# Возврат результата
return @{
    FileCount = $fileCount
    TotalSizeKB = [Math]::Round($totalSize, 2)
    BrokenLinksCount = $brokenLinks.Count
    DryRunSuccess = $true
}
