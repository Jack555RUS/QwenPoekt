# ============================================================================
# OLD FOLDER CLEANUP
# Очистка OLD/_ARCHIVE_60D/ (старше 60 дней) с глубоким анализом
# ============================================================================
# Использование: .\scripts\old-cleanup.ps1 [-AutoConfirm]
# ============================================================================

param(
    [int]$DaysToKeep = 60,
    [switch]$AutoConfirm
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "                    OLD FOLDER CLEANUP (>60 days)                           " -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

$archivePath = "OLD/_ARCHIVE_60D"
$cutoffDate = (Get-Date).AddDays(-$DaysToKeep)

if (!(Test-Path $archivePath)) {
    Write-Host "ℹ️  Папка _ARCHIVE_60D не найдена" -ForegroundColor Yellow
    Write-Host "   Нет папок для очистки" -ForegroundColor Gray
    return
}

$oldFolders = Get-ChildItem $archivePath -Directory | 
    Where-Object { $_.CreationTime -lt $cutoffDate }

if ($oldFolders.Count -eq 0) {
    Write-Host "✓ Нет папок старше $DaysToKeep дней" -ForegroundColor Green
    return
}

Write-Host "Найдено $($oldFolders.Count) папок для удаления:`n" -ForegroundColor Yellow

# Отчёт перед удалением
$report = @()
$report += "# OLD FOLDER DELETION REPORT`n"
$report += "**Дата:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n"
$report += "**Cutoff:** $cutoffDate`n"
$report += "**Срок хранения:** $DaysToKeep дней`n`n"
$report += "## ⚠️ Папки на удаление`n`n"

$deletionList = @()

foreach ($folder in $oldFolders) {
    $age = (Get-Date) - $folder.CreationTime
    $size = (Get-ChildItem $folder.FullName -Recurse -File | 
        Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1KB
    
    $folderInfo = @{
        Name = $folder.Name
        Age = $age.Days
        Size = $size
        Files = (Get-ChildItem $folder.FullName -Recurse -File).Count
        Patterns = @()
    }
    
    $report += "### 📁 $($folder.Name)`n"
    $report += "- **Возраст:** $($age.Days) дней"
    $report += "- **Размер:** $($size.ToString("F2")) KB"
    $report += "- **Файлов:** $($folderInfo.Files)`n"
    
    # Последний анализ содержимого (поиск паттернов)
    $patterns = @("class", "public", "static", "TODO", "IDEA", "HACK", "Singleton", "Manager", "System")
    
    foreach ($pattern in $patterns) {
        $matches = Get-ChildItem $folder.FullName -Recurse -Include *.cs,*.md,*.json |
            Select-String -Pattern $pattern -CaseSensitive:$false |
            Select-Object -First 1
        
        if ($matches) {
            $folderInfo.Patterns += $pattern
        }
    }
    
    if ($folderInfo.Patterns.Count -gt 0) {
        $report += "- **⚠️ Содержит:** $($folderInfo.Patterns -join ', ')`n"
        Write-Host "⚠️  WARNING: $($folder.Name) может содержать ценное!" -ForegroundColor Red
    }
    
    $report += "`n"
    $deletionList += $folderInfo
}

# Сохранить отчёт
$reportPath = "OLD/_DELETION_REPORT_$(Get-Date -Format 'yyyy-MM-dd_HH-mm').md"
$report | Out-File $reportPath -Encoding UTF8

Write-Host "`n📄 Отчёт сохранён: $reportPath`n" -ForegroundColor Cyan

# Статистика
$warningCount = ($deletionList | Where-Object { $_.Patterns.Count -gt 0 }).Count
$safeCount = $deletionList.Count - $warningCount

Write-Host "📊 Статистика:" -ForegroundColor Cyan
Write-Host "   Всего папок: $($deletionList.Count)" -ForegroundColor White
Write-Host "   ⚠️  Возможные ценности: $warningCount" -ForegroundColor $(if ($warningCount -gt 0) { "Red" } else { "Green" })
Write-Host "   ✓ Безопасно: $safeCount" -ForegroundColor Green
Write-Host ""

# Подтверждение
if (!$AutoConfirm) {
    Write-Host "============================================================================" -ForegroundColor Yellow
    Write-Host "                    ТРЕБУЕТСЯ ПОДТВЕРЖДЕНИЕ                                 " -ForegroundColor Yellow
    Write-Host "============================================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Откройте отчёт: $reportPath" -ForegroundColor Cyan
    Write-Host "2. Проверьте папки с ⚠️ на наличие ценного" -ForegroundColor Cyan
    Write-Host "3. Извлеките ценное (если есть)" -ForegroundColor Cyan
    Write-Host "4. Запустите с флагом -AutoConfirm для удаления`n" -ForegroundColor Cyan
    Write-Host "   Команда: .\scripts\old-cleanup.ps1 -AutoConfirm`n" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "============================================================================" -ForegroundColor Yellow
    Write-Host "                    ПОДТВЕРЖДЕНО: УДАЛЕНИЕ                                  " -ForegroundColor Yellow
    Write-Host "============================================================================" -ForegroundColor Yellow
    Write-Host ""
    
    $deletedCount = 0
    $skippedCount = 0
    
    foreach ($folder in $oldFolders) {
        # Если есть паттерны → пропустить (требует ручного анализа)
        $folderInfo = $deletionList | Where-Object { $_.Name -eq $folder.Name }
        
        if ($folderInfo.Patterns.Count -gt 0) {
            Write-Host "⊘ Пропущено (может быть ценное): $($folder.Name)" -ForegroundColor Yellow
            $skippedCount++
        } else {
            Remove-Item $folder.FullName -Recurse -Force
            Write-Host "✓ Удалено: $($folder.Name)" -ForegroundColor Green
            $deletedCount++
        }
    }
    
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Green
    Write-Host "                    CLEANUP COMPLETE                                        " -ForegroundColor Green
    Write-Host "============================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 Результат:" -ForegroundColor Cyan
    Write-Host "   Удалено: $deletedCount" -ForegroundColor Green
    Write-Host "   Пропущено: $skippedCount" -ForegroundColor Yellow
    Write-Host ""
}
