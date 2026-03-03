# ============================================
# Очистка логов и временных файлов
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ОЧИСТКА ЛОГОВ И ВРЕМЕННЫХ ФАЙЛОВ" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Очистка корня
Write-Host "🗑️ Очистка корня проекта..." -ForegroundColor Yellow
$rootLogs = @(
    "D:\QwenPoekt\build.log",
    "D:\QwenPoekt\compile.log",
    "D:\QwenPoekt\autofix.log"
)

foreach ($log in $rootLogs) {
    if (Test-Path $log) {
        Remove-Item $log -Force
        Write-Host "  ✅ Удалено: $log" -ForegroundColor Green
    }
}

# Очистка проекта
Write-Host ""
Write-Host "🗑️ Очистка проекта DragRaceUnity..." -ForegroundColor Yellow
$projectPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity"

$logsToDelete = @(
    "$projectPath\build_exe.log",
    "$projectPath\autofix.log",
    "$projectPath\compile_attempt_*.log"
)

foreach ($log in $logsToDelete) {
    $files = Get-Item $log -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        Remove-Item $file.FullName -Force
        Write-Host "  ✅ Удалено: $($file.FullName)" -ForegroundColor Green
    }
}

# Очистка временных папок Unity
Write-Host ""
Write-Host "🗑️ Очистка временных папок Unity..." -ForegroundColor Yellow
$unityTempFolders = @(
    "$projectPath\Library",
    "$projectPath\Temp",
    "$projectPath\obj",
    "$projectPath\Logs"
)

foreach ($folder in $unityTempFolders) {
    if (Test-Path $folder) {
        # Не удаляем полностью, только содержимое
        $items = Get-ChildItem $folder -Recurse -File -ErrorAction SilentlyContinue
        $count = $items.Count
        foreach ($item in $items) {
            Remove-Item $item.FullName -Force -ErrorAction SilentlyContinue
        }
        Write-Host "  ✅ Очищено: $folder ($count файлов)" -ForegroundColor Green
    }
}

# Очистка .vs
Write-Host ""
Write-Host "🗑️ Очистка .vs..." -ForegroundColor Yellow
$vsFolder = "$projectPath\.vs"
if (Test-Path $vsFolder) {
    $vsFiles = Get-ChildItem $vsFolder -Recurse -File -ErrorAction SilentlyContinue
    $count = $vsFiles.Count
    foreach ($file in $vsFiles) {
        if ($file.Extension -notin @('.suo', '.user')) {
            Remove-Item $file.FullName -Force -ErrorAction SilentlyContinue
        }
    }
    Write-Host "  ✅ Очищено: $vsFolder ($count файлов)" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ОЧИСТКА ЗАВЕРШЕНА" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Совет: Запускайте этот скрипт перед каждой сборкой!" -ForegroundColor Yellow
Write-Host ""
