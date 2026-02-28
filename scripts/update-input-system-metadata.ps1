# ============================================
# Update Input System Metadata — Обновление мета-данных INPUT_SYSTEM
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "📝 UPDATE INPUT SYSTEM METADATA" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$path = "D:\QwenPoekt\KNOWLEDGE_BASE\02_UNITY\INPUT_SYSTEM"
$today = Get-Date -Format 'yyyy-MM-dd'

Write-Host "📁 Путь: $path" -ForegroundColor Yellow
Write-Host "📅 Дата ревью: $today" -ForegroundColor Yellow
Write-Host ""

$files = Get-ChildItem -Path $path -Filter "*.md"
$updated = 0
$skipped = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    
    if ($content -notmatch 'status:') {
        # Добавляем Front Matter
        $frontMatter = @"
---
status: stable
created: 2026-01-14
last_reviewed: $today
source: Unity Input System Documentation
tags: input, input-system, unity, controls
---

"@
        
        $newContent = $frontMatter + $content
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        Write-Host "  ✅ Обновлено: $($file.Name)" -ForegroundColor Green
        $updated++
    } else {
        # Обновляем last_reviewed
        $newContent = $content -replace 'last_reviewed: \d{4}-\d{2}-\d{2}', "last_reviewed: $today"
        if ($newContent -ne $content) {
            Set-Content -Path $file.FullName -Value $newContent -NoNewline
            Write-Host "  🔄 Обновлена дата ревью: $($file.Name)" -ForegroundColor Yellow
            $updated++
        } else {
            Write-Host "  ⏭️  Пропущено: $($file.Name)" -ForegroundColor Gray
            $skipped++
        }
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ОБНОВЛЕНИЕ ЗАВЕРШЕНО" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Статистика:" -ForegroundColor Cyan
Write-Host "  📄 Всего файлов: $($files.Count)" -ForegroundColor White
Write-Host "  ✅ Обновлено: $updated" -ForegroundColor Green
Write-Host "  ⏭️  Пропущено: $skipped" -ForegroundColor Gray
Write-Host ""
