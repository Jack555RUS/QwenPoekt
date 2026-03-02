# Очистка логов и временных файлов Unity

param(
    [switch]$CleanLibrary = $false,
    [switch]$Verbose = $false
)

Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "Очистка логов проекта DragRaceUnity" -ForegroundColor White
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""

$basePath = "D:\QwenPoekt\ProbMenu\DragRaceUnity"

# 1. Очистка папки Logs
Write-Host "1. Очистка Logs/..." -ForegroundColor Green
$logsPath = Join-Path $basePath "Logs"
if (Test-Path $logsPath) {
    Get-ChildItem -Path $logsPath -Filter *.log | Remove-Item -Force -ErrorAction SilentlyContinue
    Write-Host "   ✅ Логи очищены" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  Папка Logs не найдена" -ForegroundColor Yellow
}

# 2. Очистка build.log
Write-Host "2. Очистка build.log..." -ForegroundColor Green
$buildLogPath = Join-Path $basePath "build.log"
if (Test-Path $buildLogPath) {
    Remove-Item $buildLogPath -Force -ErrorAction SilentlyContinue
    Write-Host "   ✅ build.log очищен" -ForegroundColor Green
} else {
    Write-Host "   ℹ️  build.log не найден" -ForegroundColor Yellow
}

# 3. Очистка Editor.log (если есть)
Write-Host "3. Очистка Editor.log..." -ForegroundColor Green
$editorLogPath = "$env:USERPROFILE\AppData\LocalLow\Unity\Editor\Editor.log"
if (Test-Path $editorLogPath) {
    try {
        Clear-Content $editorLogPath -ErrorAction SilentlyContinue
        Write-Host "   ✅ Editor.log очищен" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Не удалось очистить Editor.log (файл занят)" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ℹ️  Editor.log не найден" -ForegroundColor Yellow
}

# 4. Очистка временных файлов
Write-Host "4. Очистка временных файлов..." -ForegroundColor Green
$tempFiles = @(
    (Join-Path $basePath "*.tmp"),
    (Join-Path $basePath "Temp\*.log"),
    (Join-Path $basePath "obj\*.log")
)

foreach ($pattern in $tempFiles) {
    Get-ChildItem -Path $basePath -Include (Split-Path $pattern -Leaf) -Recurse | 
        Where-Object { $_.FullName -like $pattern } |
        Remove-Item -Force -ErrorAction SilentlyContinue
}
Write-Host "   ✅ Временные файлы очищены" -ForegroundColor Green

# 5. Опциональная очистка Library (только если указан флаг)
if ($CleanLibrary) {
    Write-Host "5. Очистка Library/ (это может занять время)..." -ForegroundColor Yellow
    $libraryPath = Join-Path $basePath "Library"
    if (Test-Path $libraryPath) {
        Remove-Item $libraryPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "   ✅ Library/ очищена" -ForegroundColor Green
        Write-Host "   ⚠️  При следующем запуске Unity будет долгий реимпорт!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "Очистка завершена!" -ForegroundColor Green
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Следующие шаги:" -ForegroundColor Yellow
Write-Host "1. Откройте Unity" -ForegroundColor White
Write-Host "2. Дождитесь реимпорта" -ForegroundColor White
Write-Host "3. Проверьте Console на НОВЫЕ ошибки" -ForegroundColor White
Write-Host ""

if ($Verbose) {
    Write-Host "Статистика:" -ForegroundColor Cyan
    Write-Host "  - Логи: очищены" -ForegroundColor White
    Write-Host "  - Build.log: очищен" -ForegroundColor White
    Write-Host "  - Editor.log: очищен" -ForegroundColor White
    Write-Host "  - Temp files: очищены" -ForegroundColor White
    if ($CleanLibrary) {
        Write-Host "  - Library: очищена" -ForegroundColor White
    }
}
