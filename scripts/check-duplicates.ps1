# ============================================
# Check Duplicates — Проверка дубликатов в базе знаний
# ============================================

param(
    [string]$keyword = "",          # Ключевое слово для поиска
    [string]$path = "KNOWLEDGE_BASE" # Путь к базе знаний
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🔍 ПРОВЕРКА НА ДУБЛИКАТЫ" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Проверка входных данных
if ([string]::IsNullOrEmpty($keyword)) {
    $keyword = Read-Host "Введите ключевое слово для поиска"
}

Write-Host "🔑 Ключевое слово: $keyword" -ForegroundColor Yellow
Write-Host "📁 Путь к базе: $path" -ForegroundColor Yellow
Write-Host ""

# Поиск по файлам
Write-Host "1️⃣ Поиск по файлам..." -ForegroundColor Yellow

$files = Get-ChildItem -Path $path -Recurse -Filter "*.md" -ErrorAction SilentlyContinue
$matches = @()

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -match $keyword) {
            $matches += $file.FullName
        }
    } catch {
        Write-Host "  ⚠️  Ошибка чтения: $($file.Name)" -ForegroundColor Red
    }
}

Write-Host ""

if ($matches.Count -gt 0) {
    Write-Host "✅ Найдено совпадений: $($matches.Count)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Файлы:" -ForegroundColor Cyan
    
    $i = 1
    $matches | ForEach-Object {
        Write-Host "  $i. $_" -ForegroundColor White
        $i++
    }
    
    Write-Host ""
    Write-Host "💡 Рекомендация: Проверьте эти файлы на дублирование информации." -ForegroundColor Yellow
} else {
    Write-Host "❌ Совпадений не найдено" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Информация новая! Можно добавлять в базу." -ForegroundColor Green
}

Write-Host ""

# Поиск по заголовкам
Write-Host "2️⃣ Поиск по заголовкам..." -ForegroundColor Yellow

$headerMatches = @()

foreach ($file in $files) {
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        # Поиск по заголовкам (# Заголовок)
        $headers = [regex]::Matches($content, "^#+\s+(.+)$", [System.Text.RegularExpressions.RegexOptions]::Multiline)
        
        foreach ($header in $headers) {
            if ($header.Groups[1].Value -match $keyword) {
                $headerMatches += "$($file.FullName) :: $($header.Groups[1].Value)"
            }
        }
    } catch {
        # Игнорируем ошибки
    }
}

Write-Host ""

if ($headerMatches.Count -gt 0) {
    Write-Host "✅ Найдено заголовков: $($headerMatches.Count)" -ForegroundColor Green
    Write-Host ""
    
    $i = 1
    $headerMatches | ForEach-Object {
        Write-Host "  $i. $_" -ForegroundColor White
        $i++
    }
} else {
    Write-Host "❌ Заголовков не найдено" -ForegroundColor Red
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ПРОВЕРКА ЗАВЕРШЕНА" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Возвращаем результат
return @{
    Keyword = $keyword
    TotalFiles = $files.Count
    Matches = $matches.Count
    HeaderMatches = $headerMatches.Count
    HasDuplicates = ($matches.Count -gt 0)
}
