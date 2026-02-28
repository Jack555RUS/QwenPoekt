# ============================================
# Find Files Without Table of Contents
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "📑 ПОИСК ФАЙЛОВ БЕЗ ОГЛАВЛЕНИЙ" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$path = "KNOWLEDGE_BASE"
$files = Get-ChildItem -Path $path -Recurse -Filter "*.md" -ErrorAction SilentlyContinue

$withoutToc = @()
$withToc = @()

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        
        # Проверка на наличие оглавления (## Содержание или ## Оглавление или [Содержание](#))
        $hasToc = $content -match '(?i)^(##\s+(Содержание|Оглавление|Table of Contents)|\[Содержание\]\(#)|^\s*-+\s*\[\s*(\d+\.\d+|\d+)\s*\]'
        
        # Проверка на наличие подзаголовков (## )
        $hasHeaders = $content -match '(?i)^##\s+'
        
        if ($hasHeaders -and -not $hasToc) {
            $withoutToc += $file.FullName
        } elseif ($hasToc) {
            $withToc += $file.FullName
        }
    } catch {
        # Игнорируем ошибки
    }
}

Write-Host "📊 СТАТИСТИКА:" -ForegroundColor Yellow
Write-Host "  Всего файлов: $($files.Count)" -ForegroundColor White
Write-Host "  С оглавлениями: $($withToc.Count)" -ForegroundColor Green
Write-Host "  Без оглавлений: $($withoutToc.Count)" -ForegroundColor Red
Write-Host ""

if ($withoutToc.Count -gt 0) {
    Write-Host "📁 ФАЙЛЫ БЕЗ ОГЛАВЛЕНИЙ (первые 20):" -ForegroundColor Cyan
    Write-Host ""
    
    $i = 0
    $withoutToc | Select-Object -First 20 | ForEach-Object {
        $i++
        $relativePath = $_.Replace((Get-Location).Path + "\", "")
        Write-Host "  $i. $relativePath" -ForegroundColor White
    }
    
    if ($withoutToc.Count -gt 20) {
        Write-Host ""
        Write-Host "  ... и ещё $($withoutToc.Count - 20) файлов" -ForegroundColor Gray
    }
    
    # Сохраняем полный список в файл
    $outputFile = "_drafts/files_without_toc.txt"
    $withoutToc | Out-File -FilePath $outputFile -Encoding UTF8
    Write-Host ""
    Write-Host "💡 Полный список сохранён: $outputFile" -ForegroundColor Yellow
} else {
    Write-Host "✅ Все файлы имеют оглавления!" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ПРОВЕРКА ЗАВЕРШЕНА" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
