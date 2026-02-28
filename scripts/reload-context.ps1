# ============================================
# Reload Context — Перезагрузка контекста знаний
# ============================================

param(
    [int]$hours = 1,              # За какой период искать изменения
    [string]$path = "KNOWLEDGE_BASE"  # Путь к базе знаний
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🔄 RELOAD CONTEXT — ОБНОВЛЕНИЕ КОНТЕКСТА" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🕐 Период: последние $hours ч.(ов)" -ForegroundColor Yellow
Write-Host "📁 Путь: $path" -ForegroundColor Yellow
Write-Host ""

# Поиск последних изменений
$recentFiles = Get-ChildItem -Path $path -Recurse -Filter "*.md" | 
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-$hours) } |
    Sort-Object LastWriteTime -Descending

Write-Host "1️⃣ Обновлённые файлы за последние $hours ч.:" -ForegroundColor Yellow
Write-Host ""

if ($recentFiles.Count -eq 0) {
    Write-Host "  ℹ️  Нет изменений за указанный период" -ForegroundColor Gray
} else {
    $i = 1
    $recentFiles | ForEach-Object {
        $minutesAgo = [math]::Round(((Get-Date) - $_.LastWriteTime).TotalMinutes)
        Write-Host "  $i. $($_.Name)" -ForegroundColor White
        Write-Host "     Путь: $($_.FullName)" -ForegroundColor Gray
        Write-Host "     Обновлено: $minutesAgo мин. назад" -ForegroundColor Gray
        
        # Краткое содержимое (первые 15 строк)
        Write-Host "     Содержимое (первые 15 строк):" -ForegroundColor Gray
        Get-Content $_.FullName -TotalCount 15 | ForEach-Object {
            Write-Host "       $_" -ForegroundColor DarkGray
        }
        Write-Host ""
        
        $i++
    }
}

Write-Host ""

# Статистика
Write-Host "2️⃣ Статистика:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  📄 Всего файлов обновлено: $($recentFiles.Count)" -ForegroundColor Cyan

if ($recentFiles.Count -gt 0) {
    $totalLines = ($recentFiles | ForEach-Object { (Get-Content $_.FullName).Count } | Measure-Object -Sum).Sum
    Write-Host "  📝 Всего строк: $totalLines" -ForegroundColor Cyan
    
    $newestFile = $recentFiles | Select-Object -First 1
    $oldestFile = $recentFiles | Select-Object -Last 1
    Write-Host "  🕐 Самый новый: $($newestFile.Name) ($([math]::Round(((Get-Date) - $newestFile.LastWriteTime).TotalMinutes)) мин. назад)" -ForegroundColor Cyan
    Write-Host "  🕐 Самый старый: $($oldestFile.Name) ($([math]::Round(((Get-Date) - $oldestFile.LastWriteTime).TotalMinutes)) мин. назад)" -ForegroundColor Cyan
}

Write-Host ""

# Рекомендации
Write-Host "3️⃣ Рекомендации:" -ForegroundColor Yellow
Write-Host ""

if ($recentFiles.Count -gt 0) {
    Write-Host "  ✅ Загрузите эти файлы в контекст сессии" -ForegroundColor Green
    Write-Host "  ✅ Проверьте, нет ли противоречий с существующими знаниями" -ForegroundColor Green
    Write-Host "  ✅ Обновите индекс ссылок, если добавлены новые файлы" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Команда для загрузки:" -ForegroundColor Cyan
    Write-Host "    Get-Content $($recentFiles[0].FullName) -Raw" -ForegroundColor White
} else {
    Write-Host "  ℹ️  Изменений нет. Контекст актуален." -ForegroundColor Gray
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "RELOAD CONTEXT ЗАВЕРШЁН" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Возвращаем результат
return @{
    PeriodHours = $hours
    TotalFiles = $recentFiles.Count
    TotalLines = (if ($recentFiles.Count -gt 0) { ($recentFiles | ForEach-Object { (Get-Content $_.FullName).Count } | Measure-Object -Sum).Sum } else { 0 })
    Files = $recentFiles
    NewestFile = (if ($recentFiles.Count -gt 0) { $recentFiles | Select-Object -First 1 } else { $null })
    OldestFile = (if ($recentFiles.Count -gt 0) { $recentFiles | Select-Object -Last 1 } else { $null })
}
