# 🧹 СКРИПТ ОЧИСТКИ КОРНЯ

# Папки на удаление
$messFolders = @(
    "--name-only",
    "-r",
    "echo",
    "git",
    "ls-tree",
    "move",
    "⚠ Папка уже существует или ошибки",
    "✓ Папка reports создана",
    "54e32ed1d",
    "Папка создана или уже существует",
    "Перемещение завершено",
    "Структура папок создана",
    "Тестовый проект создан"
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ОЧИСТКА КОРНЯ ОТ МУСОРА" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$deletedCount = 0
$errorCount = 0

foreach ($folder in $messFolders) {
    $path = Join-Path $PSScriptRoot $folder
    
    if (Test-Path $path) {
        try {
            # Проверка, что папка не пустая (для отчёта)
            $itemCount = (Get-ChildItem $path -Recurse -File -ErrorAction SilentlyContinue).Count
            
            # Удаление
            Remove-Item $path -Recurse -Force -ErrorAction Stop
            
            Write-Host "✅ Удалено: $folder" -ForegroundColor Green
            if ($itemCount -gt 0) {
                Write-Host "   (файлов внутри: $itemCount)" -ForegroundColor Yellow
            }
            $deletedCount++
        }
        catch {
            Write-Host "❌ Ошибка удаления: $folder" -ForegroundColor Red
            Write-Host "   $($_.Exception.Message)" -ForegroundColor Red
            $errorCount++
        }
    }
    else {
        Write-Host "⏭️ Пропущено: $folder (не найдено)" -ForegroundColor Gray
    }
}

# Файл $null
Write-Host ""
Write-Host "Проверка `$null файла..." -ForegroundColor Cyan

$nullFile = Join-Path $PSScriptRoot '$null'
if (Test-Path $nullFile) {
    try {
        Remove-Item $nullFile -Force -ErrorAction Stop
        Write-Host "✅ Удалено: `$null" -ForegroundColor Green
        $deletedCount++
    }
    catch {
        Write-Host "❌ Ошибка удаления: `$null" -ForegroundColor Red
        $errorCount++
    }
}
else {
    Write-Host "⏭️ Пропущено: `$null (не найдено)" -ForegroundColor Gray
}

# Итоги
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ИТОГИ:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Удалено объектов: $deletedCount" -ForegroundColor $(if ($deletedCount -gt 0) { "Green" } else { "Yellow" })
Write-Host "Ошибок: $errorCount" -ForegroundColor $(if ($errorCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($errorCount -eq 0) {
    Write-Host "✅ ОЧИСТКА ЗАВЕРШЕНА УСПЕШНО!" -ForegroundColor Green
}
else {
    Write-Host "⚠️ ОЧИСТКА ЗАВЕРШЕНА С ОШИБКАМИ" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Нажмите любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
