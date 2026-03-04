# full-kb-audit.ps1 — Полный аудит Базы Знаний
# Версия: 1.0
# Дата: 4 марта 2026 г.

param(
    [string]$BasePath = "D:\QwenPoekt\Base",
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           ПОЛНЫЙ АУДИТ БАЗЫ ЗНАНИЙ                       ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# ============================================
# 1. ОБЩАЯ СТАТИСТИКА
# ============================================

Write-Host "[1/6] Общая статистика..." -ForegroundColor Cyan

$totalFiles = 0
$totalSize = 0
$mdFiles = 0
$ps1Files = 0
$jsonFiles = 0

$folders = @{
    "03-Resources/Knowledge" = 0
    "03-Resources/PowerShell" = 0
    "03-Resources/AI" = 0
    "03-Resources/Unity" = 0
    "03-Resources/CSharp" = 0
    "03-Resources/BOOKS" = 0
    "reports" = 0
    "scripts" = 0
    "sessions" = 0
    ".qwen" = 0
    "_drafts" = 0
    "_templates" = 0
}

foreach ($folder in $folders.Clone().Keys) {
    $fullPath = Join-Path $BasePath $folder
    if (Test-Path $fullPath) {
        $files = Get-ChildItem $fullPath -File -Recurse -ErrorAction SilentlyContinue
        $folders[$folder] = $files.Count
        $totalFiles += $files.Count
        foreach ($file in $files) {
            $totalSize += $file.Length
            if ($file.Extension -eq ".md") { $mdFiles++ }
            elseif ($file.Extension -eq ".ps1") { $ps1Files++ }
            elseif ($file.Extension -eq ".json") { $jsonFiles++ }
        }
    }
}

Write-Host "  📊 Всего файлов: $totalFiles" -ForegroundColor Cyan
Write-Host "  📄 Markdown (.md): $mdFiles" -ForegroundColor Green
Write-Host "  🔧 PowerShell (.ps1): $ps1Files" -ForegroundColor Yellow
Write-Host "  ⚙️ JSON (.json): $jsonFiles" -ForegroundColor Gray
Write-Host "  💾 Общий размер: $([math]::Round($totalSize / 1MB, 2)) MB" -ForegroundColor Cyan

Write-Host "`n  По папкам:" -ForegroundColor Cyan
foreach ($folder in $folders.GetEnumerator()) {
    Write-Host "    $($folder.Key): $($folder.Value) файлов" -ForegroundColor Gray
}

# ============================================
# 2. ПРОВЕРКА БИТЫХ ССЫЛОК
# ============================================

Write-Host "`n[2/6] Проверка битых ссылок..." -ForegroundColor Cyan

$brokenLinks = 0
$checkedFiles = 0

$mdFilesList = Get-ChildItem $BasePath -Recurse -Filter "*.md" -ErrorAction SilentlyContinue | Select-Object -First 100

foreach ($file in $mdFilesList) {
    $checkedFiles++
    $content = Get-Content $file.FullName -Raw
    $matches = [regex]::Matches($content, '\[([^\]]+)\]\(([^\)]+)\)')
    
    foreach ($match in $matches) {
        $link = $match.Groups[2].Value
        if ($link -like "*.md" -and $link -notlike "http*") {
            $linkPath = $link.Split('#')[0]
            $fullLinkPath = Join-Path $file.DirectoryName $linkPath
            if (-not (Test-Path $fullLinkPath)) {
                $brokenLinks++
                if ($Verbose) {
                    Write-Host "  ❌ Битая ссылка в $($file.Name): $link" -ForegroundColor Red
                }
            }
        }
    }
}

Write-Host "  ✅ Проверено файлов: $checkedFiles" -ForegroundColor Green
Write-Host "  ⚠️ Битых ссылок: $brokenLinks" -ForegroundColor $(if ($brokenLinks -gt 0) { "Red" } else { "Green" })

# ============================================
# 3. ПРОВЕРКА ДУБЛИКАТОВ
# ============================================

Write-Host "`n[3/6] Проверка дубликатов..." -ForegroundColor Cyan

$hashes = @{}
$duplicates = 0

$files = Get-ChildItem $BasePath -Recurse -Filter "*.md" -ErrorAction SilentlyContinue | Select-Object -First 500

foreach ($file in $files) {
    try {
        $hash = Get-FileHash $file.FullName -Algorithm MD5
        if ($hashes.ContainsKey($hash.Hash)) {
            $duplicates++
            if ($Verbose) {
                Write-Host "  🔄 Дубликат: $($file.Name) = $($hashes[$hash.Hash])" -ForegroundColor Yellow
            }
        } else {
            $hashes[$hash.Hash] = $file.Name
        }
    } catch {
        # Игнорировать ошибки
    }
}

Write-Host "  ✅ Проверено файлов: $($files.Count)" -ForegroundColor Green
Write-Host "  🔄 Дубликатов: $duplicates" -ForegroundColor $(if ($duplicates -gt 0) { "Yellow" } else { "Green" })

# ============================================
# 4. ПРОВЕРКА.encoding
# ============================================

Write-Host "`n[4/6] Проверка кодировки..." -ForegroundColor Cyan

$bomFiles = 0
$utf8Files = 0

$files = Get-ChildItem $BasePath -Recurse -Include "*.ps1","*.bat","*.cmd","*.json" -ErrorAction SilentlyContinue | Select-Object -First 200

foreach ($file in $files) {
    try {
        $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
        if ($bytes.Count -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            $bomFiles++
        } else {
            $utf8Files++
        }
    } catch {
        # Игнорировать ошибки
    }
}

Write-Host "  ✅ UTF-8 без BOM: $utf8Files" -ForegroundColor Green
Write-Host "  ❌ С BOM: $bomFiles" -ForegroundColor $(if ($bomFiles -gt 0) { "Red" } else { "Green" })

# ============================================
# 5. ПРОВЕРКА ПРАВИЛ
# ============================================

Write-Host "`n[5/6] Проверка правил (.qwen/rules/)..." -ForegroundColor Cyan

$rulesPath = Join-Path $BasePath ".qwen\rules"
$rulesCount = 0

if (Test-Path $rulesPath) {
    $rules = Get-ChildItem $rulesPath -Filter "*.md"
    $rulesCount = $rules.Count
    
    Write-Host "  ✅ Правил найдено: $rulesCount" -ForegroundColor Green
    
    foreach ($rule in $rules) {
        Write-Host "    • $($rule.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "  ❌ Папка rules не найдена!" -ForegroundColor Red
}

# ============================================
# 6. ОТЧЁТ
# ============================================

Write-Host "`n[6/6] Итоговый отчёт..." -ForegroundColor Cyan

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "АУДИТ БАЗЫ ЗНАНИЙ — ИТОГИ" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

$issues = 0

if ($brokenLinks -gt 0) {
    Write-Host "⚠️ ПРОБЛЕМЫ:" -ForegroundColor Red
    Write-Host "  • Битые ссылки: $brokenLinks" -ForegroundColor Yellow
    $issues++
}

if ($duplicates -gt 0) {
    Write-Host "  • Дубликаты файлов: $duplicates" -ForegroundColor Yellow
    $issues++
}

if ($bomFiles -gt 0) {
    Write-Host "  • Файлы с BOM: $bomFiles" -ForegroundColor Yellow
    $issues++
}

if ($issues -eq 0) {
    Write-Host "✅ ПРОБЛЕМ НЕ ОБНАРУЖЕНО" -ForegroundColor Green
}

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "АУДИТ ЗАВЕРШЁН" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
