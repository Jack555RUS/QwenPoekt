# ============================================
# Check Duplicates Advanced — Проверка дубликатов с синонимами
# ============================================

param(
    [string]$keyword = "",                    # Ключевое слово для поиска
    [string]$path = "D:\QwenPoekt\KNOWLEDGE_BASE",         # Путь к базе знаний
    [switch]$useSynonyms = $true,             # Использовать ли синонимы
    [string]$synonymsFile = "D:\QwenPoekt\scripts\synonyms.json"  # Файл синонимов
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🔍 ПРОВЕРКА НА ДУБЛИКАТЫ (ADVANCED)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Проверка входных данных
if ([string]::IsNullOrEmpty($keyword)) {
    $keyword = Read-Host "Введите ключевое слово для поиска"
}

Write-Host "🔑 Ключевое слово: $keyword" -ForegroundColor Yellow
Write-Host "📁 Путь к базе: $path" -ForegroundColor Yellow
Write-Host "📖 Синонимы: $(if ($useSynonyms) { 'Включены' } else { 'Выключены' })" -ForegroundColor Yellow
Write-Host ""

# Загрузка синонимов
$allKeywords = @($keyword)

if ($useSynonyms -and (Test-Path $synonymsFile)) {
    try {
        $synonyms = Get-Content $synonymsFile -Raw | ConvertFrom-Json
        
        # Поиск синонимов для ключевого слова
        $synonymProperty = $synonyms.PSObject.Properties | Where-Object { 
            $_.Name -eq $keyword -or $_.Value -contains $keyword 
        }
        
        if ($synonymProperty) {
            $allKeywords = $synonymProperty.Value
            Write-Host "📚 Найдены синонимы: $($allKeywords -join ', ')" -ForegroundColor Green
        }
    } catch {
        Write-Host "⚠️  Ошибка загрузки синонимов: $_" -ForegroundColor Red
        Write-Host "  Поиск будет выполнен без синонимов" -ForegroundColor Yellow
    }
} elseif ($useSynonyms) {
    Write-Host "⚠️  Файл синонимов не найден: $synonymsFile" -ForegroundColor Red
    Write-Host "  Поиск будет выполнен без синонимов" -ForegroundColor Yellow
}

Write-Host ""

# Поиск по файлам
Write-Host "1️⃣ Поиск по файлам..." -ForegroundColor Yellow

$files = Get-ChildItem -Path $path -Recurse -Filter "*.md" -ErrorAction SilentlyContinue
$allMatches = @{}

foreach ($kw in $allKeywords) {
    foreach ($file in $files) {
        try {
            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
            if ($content -match $kw) {
                if (-not $allMatches.ContainsKey($file.FullName)) {
                    $allMatches[$file.FullName] = @{
                        File = $file.FullName
                        Keywords = @()
                        Count = 0
                    }
                }
                $allMatches[$file.FullName].Keywords += $kw
                $allMatches[$file.FullName].Count++
            }
        } catch {
            Write-Host "  ⚠️  Ошибка чтения: $($file.Name)" -ForegroundColor Red
        }
    }
}

Write-Host ""

if ($allMatches.Count -gt 0) {
    Write-Host "✅ Найдено файлов с совпадениями: $($allMatches.Count)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Файлы:" -ForegroundColor Cyan
    
    $i = 1
    $allMatches.Values | ForEach-Object {
        $uniqueKeywords = ($_.Keywords | Select-Object -Unique) -join ', '
        Write-Host "  $i. $($_.File)" -ForegroundColor White
        Write-Host "     Ключевые слова: $uniqueKeywords" -ForegroundColor Gray
        Write-Host "     Совпадений: $($_.Count)" -ForegroundColor Gray
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

foreach ($kw in $allKeywords) {
    foreach ($file in $files) {
        try {
            $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
            # Поиск по заголовкам (# Заголовок)
            $headers = [regex]::Matches($content, "^#+\s+(.+)$", [System.Text.RegularExpressions.RegexOptions]::Multiline)
            
            foreach ($header in $headers) {
                if ($header.Groups[1].Value -match $kw) {
                    $headerMatches += "$($file.FullName) :: $($header.Groups[1].Value) :: $kw"
                }
            }
        } catch {
            # Игнорируем ошибки
        }
    }
}

Write-Host ""

if ($headerMatches.Count -gt 0) {
    Write-Host "✅ Найдено заголовков: $($headerMatches.Count)" -ForegroundColor Green
    Write-Host ""
    
    $headerMatches | Select-Object -Unique | ForEach-Object {
        Write-Host "  📄 $_" -ForegroundColor White
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
    AllKeywords = $allKeywords
    TotalFiles = $files.Count
    Matches = $allMatches.Count
    HeaderMatches = ($headerMatches | Select-Object -Unique).Count
    HasDuplicates = ($allMatches.Count -gt 0)
}
