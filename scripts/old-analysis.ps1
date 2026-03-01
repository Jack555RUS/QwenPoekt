# ============================================================================
# OLD FOLDER ANALYSIS
# Глубокий анализ OLD папки на предмет ценных наработок
# ============================================================================
# Использование: .\scripts\old-analysis.ps1
# ============================================================================

param(
    [string]$SourcePath = "OLD/_INBOX",
    [string]$IdeasPath = "OLD/_IDEAS",
    [string]$CodePath = "OLD/_CODE_SNIPPETS",
    [string]$ReleasePath = "RELEASE",
    [string]$ReportPath = "OLD/_ANALYSIS_REPORT.md"
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "                    OLD FOLDER ANALYSIS                                     " -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Проверка существования папок
if (!(Test-Path $SourcePath)) {
    Write-Host "⚠️  Папка $SourcePath не найдена" -ForegroundColor Yellow
    Write-Host "   Возможно, нет новых проектов для анализа" -ForegroundColor Gray
    return
}

# Создать целевые папки
@($IdeasPath, $CodePath, $ReleasePath) | ForEach-Object {
    if (!(Test-Path $_)) {
        New-Item -ItemType Directory -Force -Path $_ | Out-Null
        Write-Host "✓ Создана папка: $_" -ForegroundColor Green
    }
}

# Паттерны для поиска ценного
$patterns = @{
    "Уникальные идеи" = @("TODO", "FIXME", "IDEA", "HACK", "WORKAROUND", "OPTIMIZE", "REFACTOR")
    "Готовые решения" = @("class.*Controller", "public static", "Singleton", "Instance", "Manager")
    "Настройки" = @("config", "settings", "options", "preferences")
    "Утилиты" = @("Helper", "Utility", "Extensions", "Utils", "Helper", "Tools")
    "Интерфейсы" = @("UI", "Menu", "Screen", "View", "Panel", "Dialog")
    "Системы" = @("Manager", "System", "Service", "Factory", "Repository", "Provider")
    "Алгоритмы" = @("algorithm", "calculator", "processor", "analyzer")
    "Шаблоны" = @("template", "pattern", "base", "abstract")
}

$report = @()
$report += "# OLD FOLDER ANALYSIS REPORT`n"
$report += "**Дата:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n"
$report += "**Источник:** $SourcePath`n`n"
$report += "## Содержание`n"
$report += "- Извлечено идей: 0`n"
$report += "- Сохранено кода: 0`n"
$report += "- Перемещено в RELEASE: 0`n`n"
$report += "---`n`n"

$stats = @{
    Ideas = 0
    Code = 0
    Release = 0
    TotalFolders = 0
}

foreach ($folder in Get-ChildItem $SourcePath -Directory) {
    $stats.TotalFolders++
    Write-Host "`n----------------------------------------------------------------------------" -ForegroundColor Gray
    Write-Host "Анализ: $($folder.Name)" -ForegroundColor Yellow
    Write-Host "----------------------------------------------------------------------------" -ForegroundColor Gray
    
    $folderReport = "## 📁 $($folder.Name)`n"
    $folderReport += "**Анализ:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n`n"
    $foundValuable = $false
    
    foreach ($category in $patterns.Keys) {
        $foundFiles = @()
        $foundPatterns = @()
        
        foreach ($pattern in $patterns[$category]) {
            $files = Get-ChildItem $folder.FullName -Recurse -Include *.cs,*.md,*.json,*.uxml,*.uss,*.yaml,*.yml |
                Select-String -Pattern $pattern -CaseSensitive:$false |
                Select-Object -ExpandProperty Path -Unique
            
            if ($files.Count -gt 0) {
                $foundFiles += $files
                $foundPatterns += $pattern
            }
        }
        
        if ($foundFiles.Count -gt 0) {
            $foundValuable = $true
            $folderReport += "### $category`n"
            $folderReport += "**Паттерны:** $($foundPatterns -join ', ')`n`n"
            
            Write-Host "  $category`: $($foundFiles.Count) файлов" -ForegroundColor Cyan
            
            foreach ($file in ($foundFiles | Select-Object -Unique)) {
                $relativePath = $file.Replace($folder.FullName, "").TrimStart('\')
                $folderReport += "- ``$relativePath``$([Environment]::NewLine)"
                
                # Копировать в соответствующую папку
                $destDir = $null
                $destCategory = ""
                
                if ($category -eq "Уникальные идеи") {
                    $destDir = $IdeasPath
                    $destCategory = "ideas"
                    $stats.Ideas++
                } elseif ($category -eq "Готовые решения" -or $category -eq "Утилиты" -or $category -eq "Алгоритмы") {
                    $destDir = $CodePath
                    $destCategory = "code"
                    $stats.Code++
                } elseif ($category -eq "Системы" -or $category -eq "Интерфейсы") {
                    $destDir = $ReleasePath
                    $destCategory = "release"
                    $stats.Release++
                }
                
                if ($destDir) {
                    $destSubDir = "$destDir\$category"
                    if (!(Test-Path $destSubDir)) {
                        New-Item -ItemType Directory -Force -Path $destSubDir | Out-Null
                    }
                    
                    $destFile = "$destSubDir\$($folder.Name)_$relativePath"
                    $destFileDir = Split-Path $destFile -Parent
                    
                    if (!(Test-Path $destFileDir)) {
                        New-Item -ItemType Directory -Force -Path $destFileDir | Out-Null
                    }
                    
                    Copy-Item $file -Destination $destFile -Force
                    Write-Host "    ✓ → $destCategory`: $relativePath" -ForegroundColor Green
                }
            }
            $folderReport += "`n"
        }
    }
    
    if ($foundValuable) {
        $report += $folderReport
        # Переместить в _ANALYZED
        $analyzedPath = "OLD/_ANALYZED"
        if (!(Test-Path $analyzedPath)) {
            New-Item -ItemType Directory -Force -Path $analyzedPath | Out-Null
        }
        Move-Item $folder.FullName "$analyzedPath\$($folder.Name)" -Force
        Write-Host "  → Перемещено в _ANALYZED" -ForegroundColor Cyan
    } else {
        # Нет ценного → сразу в _ARCHIVE_60D
        $archivePath = "OLD/_ARCHIVE_60D"
        if (!(Test-Path $archivePath)) {
            New-Item -ItemType Directory -Force -Path $archivePath | Out-Null
        }
        Move-Item $folder.FullName "$archivePath\$($folder.Name)" -Force
        Write-Host "  → Нет ценного → _ARCHIVE_60D" -ForegroundColor Gray
    }
}

# Обновить статистику в отчёте
$report = $report -replace "- Извлечено идей: 0", "- Извлечено идей: $($stats.Ideas)"
$report = $report -replace "- Сохранено кода: 0", "- Сохранено кода: $($stats.Code)"
$report = $report -replace "- Перемещено в RELEASE: 0", "- Перемещено в RELEASE: $($stats.Release)"

# Добавить итог
$report += "`n## 📊 Итог`n"
$report += "- **Всего папок проанализировано:** $($stats.TotalFolders)`n"
$report += "- **Извлечено идей:** $($stats.Ideas)`n"
$report += "- **Сохранено кода:** $($stats.Code)`n"
$report += "- **Перемещено в RELEASE:** $($stats.Release)`n"

# Сохранить отчёт
$report | Out-File $ReportPath -Encoding UTF8

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "                    ANALYSIS COMPLETE                                       " -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Статистика:" -ForegroundColor Cyan
Write-Host "   Папок проанализировано: $($stats.TotalFolders)" -ForegroundColor White
Write-Host "   Извлечено идей: $($stats.Ideas)" -ForegroundColor White
Write-Host "   Сохранено кода: $($stats.Code)" -ForegroundColor White
Write-Host "   Перемещено в RELEASE: $($stats.Release)" -ForegroundColor White
Write-Host ""
Write-Host "📄 Отчёт: $ReportPath" -ForegroundColor Cyan
Write-Host ""
