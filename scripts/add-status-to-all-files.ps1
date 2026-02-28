# ============================================
# Add Status to All Files — Массовое добавление статусов
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "📝 ADD STATUS TO ALL FILES" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$basePath = "D:\QwenPoekt\KNOWLEDGE_BASE"
$today = Get-Date -Format 'yyyy-MM-dd'

Write-Host "📁 Путь: $basePath" -ForegroundColor Yellow
Write-Host "📅 Дата ревью: $today" -ForegroundColor Yellow
Write-Host ""

# Категории файлов
$categories = @{
    "00_CORE" = @{ status = "stable"; source = "Project Core" }
    "01_INSTRUCTIONS" = @{ status = "stable"; source = "AI Instructions" }
    "01_RULES" = @{ status = "stable"; source = "Project Rules" }
    "02_TOOLS" = @{ status = "stable"; source = "Tools Documentation" }
    "02_UNITY" = @{ status = "stable"; source = "Unity Documentation" }
    "03_CSHARP" = @{ status = "stable"; source = "C# Standards" }
    "04_TOOLS" = @{ status = "stable"; source = "Tools Guide" }
    "05_METHODOLOGY" = @{ status = "stable"; source = "Methodology" }
    "06_AI" = @{ status = "stable"; source = "AI Constitution" }
}

$totalFiles = 0
$updated = 0
$skipped = 0
$archived = 0

# Обход по папкам
foreach ($category in $categories.Keys) {
    $categoryPath = Join-Path $basePath $category
    
    if (Test-Path $categoryPath) {
        Write-Host ""
        Write-Host "📂 Категория: $category" -ForegroundColor Cyan
        
        $files = Get-ChildItem -Path $categoryPath -Filter "*.md" -Recurse
        
        foreach ($file in $files) {
            $totalFiles++
            $content = Get-Content $file.FullName -Raw
            
            # Проверка наличия статуса
            if ($content -match 'status:\s*(stable|draft|review|deprecated)') {
                # Статус уже есть — обновляем last_reviewed
                $newContent = $content -replace 'last_reviewed: \d{4}-\d{2}-\d{2}', "last_reviewed: $today"
                
                if ($newContent -ne $content) {
                    Set-Content -Path $file.FullName -Value $newContent -NoNewline
                    Write-Host "  🔄 Обновлена дата: $($file.Name)" -ForegroundColor Gray
                    $updated++
                } else {
                    $skipped++
                }
            } else {
                # Статуса нет — добавляем
                $statusInfo = $categories[$category]
                $createdDate = $file.CreationTime.ToString('yyyy-MM-dd')
                
                # Проверка на устаревшие файлы (UGUI, TMPRO — документация пакетов)
                if ($file.DirectoryName -match 'UGUI|TMPRO') {
                    # Это документация из пакетов Unity
                    $frontMatter = @"
---
status: stable
created: $createdDate
last_reviewed: $today
source: Unity Package Documentation
tags: unity, package, documentation
---

"@
                } else {
                    $frontMatter = @"
---
status: $($statusInfo.status)
created: $createdDate
last_reviewed: $today
source: $($statusInfo.source)
---

"@
                }
                
                $newContent = $frontMatter + $content
                Set-Content -Path $file.FullName -Value $newContent -NoNewline
                Write-Host "  ✅ Добавлен статус: $($file.Name)" -ForegroundColor Green
                $updated++
            }
        }
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ОБНОВЛЕНИЕ ЗАВЕРШЕНО" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 СТАТИСТИКА:" -ForegroundColor Cyan
Write-Host "  📄 Всего файлов: $totalFiles" -ForegroundColor White
Write-Host "  ✅ Обновлено: $updated" -ForegroundColor Green
Write-Host "  ⏭️  Пропущено (была дата): $skipped" -ForegroundColor Gray
Write-Host ""
