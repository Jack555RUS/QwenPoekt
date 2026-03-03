# weekly-memory-audit.ps1 — Еженедельный аудит памяти
# Версия: 1.0
# Дата: 2026-03-04
# Назначение: Автоматический анализ состояния базы знаний

param(
    [int]$Days = 7,
    [switch]$Verbose,
    [string]$OutputPath = "reports/weekly-audit.json"
)

$ErrorActionPreference = "Stop"

# ----------------------------------------------------------------------------
# ЦВЕТА ВЫВОДА
# ----------------------------------------------------------------------------

function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

# ----------------------------------------------------------------------------
# ФУНКЦИИ
# ----------------------------------------------------------------------------

function Get-GitChanges {
    param($days)
    
    $since = (Get-Date).AddDays(-$days)
    $changes = @{
        Added = @()
        Modified = @()
        Deleted = @()
        Moved = @()
    }
    
    # Получаем изменения
    $log = git log --since="$($since.ToString('yyyy-MM-dd'))" --pretty=format:"%H" --name-status
    
    $currentCommit = ""
    foreach ($line in $log) {
        if ($line -match "^[a-f0-9]{40}$") {
            $currentCommit = $line
        } elseif ($line -match "^(A|M|D|R)\t(.+)$") {
            $status = $matches[1]
            $file = $matches[2]
            
            switch ($status) {
                "A" { $changes.Added += $file }
                "M" { $changes.Modified += $file }
                "D" { $changes.Deleted += $file }
                "R" { $changes.Moved += $file }
            }
        }
    }
    
    return $changes
}

function Find-Duplicates {
    param($path)
    
    $files = Get-ChildItem -Path $path -Recurse -File -Filter "*.md"
    $hashes = @{}
    $duplicates = @()
    
    foreach ($file in $files) {
        $hash = Get-FileHash $file.FullName -Algorithm MD5
        $hashValue = $hash.Hash
        
        if ($hashes.ContainsKey($hashValue)) {
            $duplicates += @{
                File = $file.FullName
                DuplicateOf = $hashes[$hashValue]
                Size = $file.Length
            }
        } else {
            $hashes[$hashValue] = $file.FullName
        }
    }
    
    return $duplicates
}

function Check-All-Links {
    $broken = @()
    
    $files = Get-ChildItem -Path "Base" -Recurse -Filter "*.md" -File
    $totalLinks = 0
    
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw
        $links = [regex]::Matches($content, '\[([^\]]+)\]\(([^)]+)\)')
        
        foreach ($link in $links) {
            $url = $link.Groups[2].Value
            
            # Пропускаем внешние ссылки
            if ($url -match "^https?://|^#|^mailto:") {
                continue
            }
            
            $linkPath = ($url -split '#')[0]
            if (-not $linkPath) { continue }
            
            $totalLinks++
            
            # Разрешаем путь
            $fullPath = Resolve-Path (Join-Path $file.DirectoryName $linkPath) -ErrorAction SilentlyContinue
            if (-not $fullPath) {
                $broken += @{
                    File = $file.FullName
                    Link = $url
                    Line = $content.Substring(0, $link.Index).Split("`n").Count
                }
            }
        }
    }
    
    return @{
        Total = $totalLinks
        Broken = $broken
    }
}

function Get-Rule-Violations {
    # Проверяем файлы в Base/ без _drafts/ и _TEST_ENV/
    $directCreates = Get-ChildItem -Path "Base" -Filter "*.md" -File |
        Where-Object { $_.CreationTime -gt (Get-Date).AddDays(-7) }
    
    return @{
        DirectCreates = $directCreates.Count
        Files = $directCreates.Name
    }
}

function Generate-Recommendations {
    param($metrics)
    
    $recommendations = @()
    
    if ($metrics.Duplicates -gt 0) {
        $recommendations += "🗑️ Найдено $($metrics.Duplicates) дубликатов — запустите .\scripts\weekly-dedup-audit.ps1"
    }
    
    if ($metrics.BrokenLinks -gt 10) {
        $recommendations += "🔗 Найдено $($metrics.BrokenLinks) битых ссылок — запустите .\scripts\fix-broken-links.ps1"
    }
    
    if ($metrics.DirectCreates -gt 0) {
        $recommendations += "📁 $($metrics.DirectCreates) файлов создано напрямую в Base/ — нарушен 3-уровневый процесс"
    }
    
    if ($metrics.FilesAdded -gt 20) {
        $recommendations += "📈 Большое количество файлов ($($metrics.FilesAdded)) — рассмотрите архивирование"
    }
    
    return $recommendations
}

# ----------------------------------------------------------------------------
# ОСНОВНАЯ ЛОГИКА
# ----------------------------------------------------------------------------

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║      ЕЖЕНЕДЕЛЬНЫЙ АУДИТ ПАМЯТИ $(Get-Date -Format 'yyyy-MM-dd HH:mm')          ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

# 1. АНАЛИЗ ИЗМЕНЕНИЙ
Write-Info "[1/5] Анализ изменений за последние $Days дней..."

$changes = Get-GitChanges -days $Days

Write-Host "  Добавлено файлов: $($changes.Added.Count)" -ForegroundColor $(if($changes.Added.Count -gt 10){"Yellow"}else{"Green"})
Write-Host "  Изменено файлов: $($changes.Modified.Count)" -ForegroundColor Gray
Write-Host "  Удалено файлов: $($changes.Deleted.Count)" -ForegroundColor $(if($changes.Deleted.Count -gt 5){"Yellow"}else{"Green"})
Write-Host "  Перемещено файлов: $($changes.Moved.Count)" -ForegroundColor Gray

Write-Host ""

# 2. ПОИСК ДУБЛИКАТОВ
Write-Info "[2/5] Поиск дубликатов..."

$duplicates = Find-Duplicates -path "Base"

if ($duplicates.Count -gt 0) {
    Write-Warning "  ⚠️  Найдено $($duplicates.Count) дубликатов"
    if ($Verbose) {
        foreach ($dup in $duplicates | Select-Object -First 5) {
            Write-Host "    • $($dup.File)" -ForegroundColor Yellow
            Write-Host "      Дубликат: $($dup.DuplicateOf)" -ForegroundColor Gray
        }
    }
} else {
    Write-Success "  ✅ Дубликатов не найдено"
}

Write-Host ""

# 3. АНАЛИЗ БИТЫХ ССЫЛОК
Write-Info "[3/5] Проверка ссылок..."

$linkCheck = Check-All-Links

Write-Host "  Всего ссылок: $($linkCheck.Total)" -ForegroundColor Gray
Write-Host "  Битых ссылок: $($linkCheck.Broken.Count)" -ForegroundColor $(if($linkCheck.Broken.Count -gt 50){"Red"}elseif($linkCheck.Broken.Count -gt 10){"Yellow"}else{"Green"})

if ($Verbose -and $linkCheck.Broken.Count -gt 0) {
    Write-Host ""
    Write-Host "  Первые 5 битых ссылок:" -ForegroundColor Yellow
    foreach ($broken in $linkCheck.Broken | Select-Object -First 5) {
        Write-Host "    • $($broken.File):$($broken.Line) → $($broken.Link)" -ForegroundColor Gray
    }
}

Write-Host ""

# 4. ПРОВЕРКА СОБЛЮДЕНИЯ ПРАВИЛ
Write-Info "[4/5] Проверка соблюдения правил..."

$violations = Get-Rule-Violations

if ($violations.DirectCreates -gt 0) {
    Write-Warning "  ⚠️  $($violations.DirectCreates) файлов создано напрямую в Base/"
    if ($Verbose) {
        foreach ($file in $violations.Files) {
            Write-Host "    • $file" -ForegroundColor Yellow
        }
    }
} else {
    Write-Success "  ✅ Нарушений 3-уровневого процесса не найдено"
}

Write-Host ""

# 5. МЕТРИКИ И РЕКОМЕНДАЦИИ
Write-Info "[5/5] Метрики и рекомендации..."

$metrics = @{
    Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    PeriodDays = $Days
    FilesAdded = $changes.Added.Count
    FilesModified = $changes.Modified.Count
    FilesDeleted = $changes.Deleted.Count
    FilesMoved = $changes.Moved.Count
    Duplicates = $duplicates.Count
    BrokenLinks = $linkCheck.Broken.Count
    TotalLinks = $linkCheck.Total
    RuleViolations = $violations.DirectCreates
    Recommendations = @()
}

$metrics.Recommendations = Generate-Recommendations -metrics $metrics

if ($metrics.Recommendations.Count -gt 0) {
    Write-Warning "  Рекомендации:"
    foreach ($rec in $metrics.Recommendations) {
        Write-Host "    $rec" -ForegroundColor Cyan
    }
} else {
    Write-Success "  ✅ Рекомендаций нет (всё в порядке)"
}

Write-Host ""

# СОХРАНЕНИЕ ОТЧЁТА
$metrics | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding UTF8

Write-Success "  ✅ Отчёт сохранён: $OutputPath"

Write-Host ""
Write-Success "╔══════════════════════════════════════════════════════════╗"
Write-Success "║              АУДИТ ЗАВЕРШЁН ✅                           ║"
Write-Success "╚══════════════════════════════════════════════════════════╝"

# Возврат метрик
return $metrics
