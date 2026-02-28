# ============================================
# Review Knowledge — Авто-ревью библиотеки знаний
# ============================================

param(
    [int]$reviewDays = 30,        # Через сколько дней требуется ревью
    [string]$path = "KNOWLEDGE_BASE"  # Путь к базе знаний
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "📋 REVIEW KNOWLEDGE — АВТО-РЕВЬЮ БИБЛИОТЕКИ" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "🕐 Период ревью: $reviewDays дн." -ForegroundColor Yellow
Write-Host "📁 Путь: $path" -ForegroundColor Yellow
Write-Host ""

# Получение всех файлов
$allFiles = Get-ChildItem -Path $path -Recurse -Filter "*.md" -ErrorAction SilentlyContinue

Write-Host "1️⃣ Поиск устаревших файлов (не рецензировались > $reviewDays дн.)..." -ForegroundColor Yellow
Write-Host ""

$oldFiles = $allFiles | 
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$reviewDays) } |
    Sort-Object LastWriteTime |
    Select-Object -First 20

if ($oldFiles.Count -gt 0) {
    Write-Host "⚠️  Найдено файлов: $($oldFiles.Count)" -ForegroundColor Red
    Write-Host ""
    
    $i = 1
    $oldFiles | ForEach-Object {
        $days = [math]::Round(((Get-Date) - $_.LastWriteTime).TotalDays)
        Write-Host "  $i. $($_.Name)" -ForegroundColor White
        Write-Host "     Путь: $($_.FullName)" -ForegroundColor Gray
        Write-Host "     Последнее изменение: $days дн. назад" -ForegroundColor $(if ($days -gt 60) { 'Red' } else { 'Yellow' })
        Write-Host ""
        $i++
    }
} else {
    Write-Host "✅ Устаревших файлов не найдено" -ForegroundColor Green
}

Write-Host ""
Write-Host "2️⃣ Поиск файлов без статуса..." -ForegroundColor Yellow
Write-Host ""

$noStatus = $allFiles | Where-Object {
    try {
        $content = Get-Content $_.FullName -TotalCount 10 -ErrorAction SilentlyContinue
        ($content | Out-String) -notmatch 'status:\s*(draft|review|stable|deprecated)'
    } catch {
        $false
    }
} | Select-Object -First 20

if ($noStatus.Count -gt 0) {
    Write-Host "⚠️  Найдено файлов без статуса: $($noStatus.Count)" -ForegroundColor Red
    Write-Host ""
    
    $i = 1
    $noStatus | ForEach-Object {
        Write-Host "  $i. $($_.Name)" -ForegroundColor White
        Write-Host "     Путь: $($_.FullName)" -ForegroundColor Gray
        Write-Host ""
        $i++
    }
} else {
    Write-Host "✅ Все файлы имеют статус" -ForegroundColor Green
}

Write-Host ""
Write-Host "3️⃣ Поиск файлов без даты ревью..." -ForegroundColor Yellow
Write-Host ""

$noReviewDate = $allFiles | Where-Object {
    try {
        $content = Get-Content $_.FullName -TotalCount 10 -ErrorAction SilentlyContinue
        ($content | Out-String) -notmatch 'last_reviewed:\s*\d{4}-\d{2}-\d{2}'
    } catch {
        $false
    }
} | Select-Object -First 20

if ($noReviewDate.Count -gt 0) {
    Write-Host "⚠️  Найдено файлов без даты ревью: $($noReviewDate.Count)" -ForegroundColor Red
    Write-Host ""
    
    $i = 1
    $noReviewDate | ForEach-Object {
        Write-Host "  $i. $($_.Name)" -ForegroundColor White
        Write-Host "     Путь: $($_.FullName)" -ForegroundColor Gray
        Write-Host ""
        $i++
    }
} else {
    Write-Host "✅ Все файлы имеют дату ревью" -ForegroundColor Green
}

Write-Host ""
Write-Host "4️⃣ Поиск черновиков старше 30 дней..." -ForegroundColor Yellow
Write-Host ""

$oldDrafts = $allFiles | Where-Object {
    try {
        $content = Get-Content $_.FullName -TotalCount 10 -ErrorAction SilentlyContinue
        ($content | Out-String) -match 'status:\s*draft' -and $_.LastWriteTime -lt (Get-Date).AddDays(-30)
    } catch {
        $false
    }
} | Select-Object -First 20

if ($oldDrafts.Count -gt 0) {
    Write-Host "⚠️  Найдено старых черновиков: $($oldDrafts.Count)" -ForegroundColor Red
    Write-Host ""
    
    $i = 1
    $oldDrafts | ForEach-Object {
        $days = [math]::Round(((Get-Date) - $_.LastWriteTime).TotalDays)
        Write-Host "  $i. $($_.Name) ($days дн.)" -ForegroundColor White
        Write-Host "     Путь: $($_.FullName)" -ForegroundColor Gray
        Write-Host ""
        $i++
    }
    
    Write-Host "💡 Рекомендация: Завершите черновики или переместите в архив" -ForegroundColor Yellow
} else {
    Write-Host "✅ Старых черновиков не найдено" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "РЕВЬЮ ЗАВЕРШЕНО" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Сводка
Write-Host "📊 СВОДКА:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  📄 Всего файлов: $($allFiles.Count)" -ForegroundColor White
Write-Host "  ⚠️  Устаревших: $($oldFiles.Count)" -ForegroundColor $(if ($oldFiles.Count -gt 0) { 'Red' } else { 'Green' })
Write-Host "  ⚠️  Без статуса: $($noStatus.Count)" -ForegroundColor $(if ($noStatus.Count -gt 0) { 'Red' } else { 'Green' })
Write-Host "  ⚠️  Без даты ревью: $($noReviewDate.Count)" -ForegroundColor $(if ($noReviewDate.Count -gt 0) { 'Red' } else { 'Green' })
Write-Host "  ⚠️  Старых черновиков: $($oldDrafts.Count)" -ForegroundColor $(if ($oldDrafts.Count -gt 0) { 'Red' } else { 'Green' })
Write-Host ""

# Рекомендации
Write-Host "💡 РЕКОМЕНДАЦИИ:" -ForegroundColor Yellow
Write-Host ""

if ($oldFiles.Count -gt 0) {
    Write-Host "  1. Прорецензируйте устаревшие файлы" -ForegroundColor White
    Write-Host "     Обновите last_reviewed или переместите в архив" -ForegroundColor Gray
}

if ($noStatus.Count -gt 0) {
    Write-Host "  2. Добавьте статус в файлы без статуса" -ForegroundColor White
    Write-Host "     status: draft | review | stable | deprecated" -ForegroundColor Gray
}

if ($oldDrafts.Count -gt 0) {
    Write-Host "  3. Завершите старые черновики или удалите их" -ForegroundColor White
}

Write-Host ""

# Возвращаем результат
return @{
    TotalFiles = $allFiles.Count
    OldFiles = $oldFiles.Count
    NoStatus = $noStatus.Count
    NoReviewDate = $noReviewDate.Count
    OldDrafts = $oldDrafts.Count
    NeedsAttention = ($oldFiles.Count + $noStatus.Count + $noReviewDate.Count + $oldDrafts.Count)
}
