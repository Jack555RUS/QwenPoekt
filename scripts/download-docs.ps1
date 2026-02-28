# ============================================
# Download Documentation — Скачивание документации
# ============================================

param(
    [string]$url = "",              # URL страницы
    [string]$outputPath = ""        # Путь для сохранения
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "📥 СКАЧИВАНИЕ ДОКУМЕНТАЦИИ" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Проверка входных данных
if ([string]::IsNullOrEmpty($url)) {
    $url = Read-Host "Введите URL страницы"
}

if ([string]::IsNullOrEmpty($outputPath)) {
    $outputPath = Read-Host "Введите путь для сохранения (без расширения)"
}

Write-Host ""
Write-Host "🔗 URL: $url" -ForegroundColor Yellow
Write-Host "📁 Путь: $outputPath" -ForegroundColor Yellow
Write-Host ""

# Создание папки для загрузок
$downloadDir = "downloads"
if (!(Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null
    Write-Host "📁 Создана папка: $downloadDir" -ForegroundColor Green
}

# Скачивание страницы
Write-Host ""
Write-Host "1️⃣ Скачивание страницы..." -ForegroundColor Yellow

try {
    $htmlPath = "$downloadDir\$((Split-Path $outputPath -Leaf)).html"
    Invoke-WebRequest -Uri $url -OutFile $htmlPath -UseBasicParsing -ErrorAction Stop
    Write-Host "  ✅ Страница сохранена: $htmlPath" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Ошибка скачивания: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "2️⃣ Конвертация в Markdown..." -ForegroundColor Yellow

# Проверка наличия pandoc
$pandocPath = Get-Command pandoc -ErrorAction SilentlyContinue

if ($pandocPath) {
    Write-Host "  ✅ Pandoc найден: $($pandocPath.Source)" -ForegroundColor Green
    
    $mdPath = "$downloadDir\$((Split-Path $outputPath -Leaf)).md"
    
    try {
        & pandoc $htmlPath -o $mdPath --from html --to markdown
        Write-Host "  ✅ Конвертация завершена: $mdPath" -ForegroundColor Green
        Write-Host ""
        Write-Host "📄 Файл готов к обработке!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Следующий шаг:" -ForegroundColor Yellow
        Write-Host "  1. Откройте $mdPath" -ForegroundColor White
        Write-Host "  2. Отредактируйте содержимое" -ForegroundColor White
        Write-Host "  3. Создайте отчёт об интеграции" -ForegroundColor White
    } catch {
        Write-Host "  ❌ Ошибка конвертации: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 Откройте HTML файл вручную и скопируйте текст" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠️  Pandoc не найден!" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Установите Pandoc: https://pandoc.org/installing.html" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Или используйте ручной метод:" -ForegroundColor Yellow
    Write-Host "  1. Откройте $htmlPath в браузере" -ForegroundColor White
    Write-Host "  2. Скопируйте текст" -ForegroundColor White
    Write-Host "  3. Вставьте в Markdown файл" -ForegroundColor White
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "СКАЧИВАНИЕ ЗАВЕРШЕНО" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Возвращаем результат
return @{
    Url = $url
    HtmlPath = "$downloadDir\$((Split-Path $outputPath -Leaf)).html"
    MdPath = "$downloadDir\$((Split-Path $outputPath -Leaf)).md"
    PandocInstalled = ($pandocPath -ne $null)
}
