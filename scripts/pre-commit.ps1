# ============================================================================
# PRE-COMMIT HOOK
# Автоматическая проверка перед коммитом
# ============================================================================
# Использование: .\scripts\pre-commit.ps1
# ============================================================================

param(
    [switch]$SkipDuplicates,
    [switch]$SkipLinks,
    [switch]$Force
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "                    PRE-COMMIT CHECK                                        " -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

$hasErrors = $false

# ============================================================================
# 1. ПРОВЕРКА НА ДУБЛИКАТЫ
# ============================================================================

if (!$SkipDuplicates) {
    Write-Host "1. Проверка на дубликаты..." -ForegroundColor Yellow
    
    $duplicateScript = ".\scripts\check-duplicates.ps1"
    if (Test-Path $duplicateScript) {
        & $duplicateScript -Path "." -Threshold 80
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "   ⚠️  Найдены дубликаты! Исправьте перед коммитом." -ForegroundColor Red
            $hasErrors = $true
        } else {
            Write-Host "   ✅ Дубликатов не найдено" -ForegroundColor Green
        }
    } else {
        Write-Host "   ⚠️  Скрипт check-duplicates.ps1 не найден" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# ============================================================================
# 2. ПРОВЕРКА БИТЫХ ССЫЛОК
# ============================================================================

if (!$SkipLinks) {
    Write-Host "2. Проверка битых ссылок..." -ForegroundColor Yellow
    
    $brokenLinks = @()
    $files = Get-ChildItem -Path "." -Recurse -Filter "*.md" -File
    
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw
        $links = [regex]::Matches($content, '\[.*?\]\((.*?)\)') | ForEach-Object { $_.Groups[1].Value }
        
        foreach ($link in $links) {
            if ($link -match "^https?://") { continue }  # Пропускаем внешние ссылки
            if ($link -match "^#") { continue }  # Пропускаем якоря
            
            $targetPath = Join-Path (Split-Path $file.DirectoryName) $link
            if (!(Test-Path $targetPath)) {
                $brokenLinks += [PSCustomObject]@{
                    File = $file.FullName
                    Link = $link
                    Target = $targetPath
                }
            }
        }
    }
    
    if ($brokenLinks.Count -gt 0) {
        Write-Host "   ⚠️  Найдены битые ссылки:" -ForegroundColor Red
        foreach ($link in $brokenLinks) {
            Write-Host "   $($link.File) → $($link.Link)" -ForegroundColor Red
        }
        $hasErrors = $true
    } else {
        Write-Host "   ✅ Битых ссылок не найдено" -ForegroundColor Green
    }
    
    Write-Host ""
}

# ============================================================================
# 3. ПРОВЕРКА GIT STATUS
# ============================================================================

Write-Host "3. Проверка Git статуса..." -ForegroundColor Yellow

$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "   Изменения для коммита:" -ForegroundColor Cyan
    Write-Host $gitStatus -ForegroundColor Gray
} else {
    Write-Host "   ⚠️  Нет изменений для коммита" -ForegroundColor Yellow
    $hasErrors = $true
}

Write-Host ""

# ============================================================================
# 4. ПРОВЕРКА .GITIGNORE
# ============================================================================

Write-Host "4. Проверка .gitignore..." -ForegroundColor Yellow

if (Test-Path ".gitignore") {
    Write-Host "   ✅ .gitignore существует" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  .gitignore не найден" -ForegroundColor Yellow
}

Write-Host ""

# ============================================================================
# 5. ИТОГ
# ============================================================================

Write-Host "============================================================================" -ForegroundColor Cyan

if ($hasErrors -and !$Force) {
    Write-Host "❌ PRE-COMMIT FAILED" -ForegroundColor Red
    Write-Host ""
    Write-Host "Исправьте ошибки перед коммитом или используйте -Force для пропуска" -ForegroundColor Yellow
    Write-Host ""
    exit 1
} else {
    if ($hasErrors) {
        Write-Host "⚠️  PRE-COMMIT PASSED (с предупреждениями, -Force)" -ForegroundColor Yellow
    } else {
        Write-Host "✅ PRE-COMMIT PASSED" -ForegroundColor Green
    }
    Write-Host ""
    exit 0
}
