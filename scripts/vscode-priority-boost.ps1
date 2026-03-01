# ============================================================================
# VS CODE PRIORITY BOOST
# Повышение приоритета VS Code для снижения нагрузки на SSD
# ============================================================================
# Использование: .\scripts\vscode-priority-boost.ps1
# ============================================================================

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "                    VS CODE PRIORITY BOOST                                  " -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# 1. ПРОВЕРКА ЗАПУСКА ОТ АДМИНИСТРАТОРА
# ============================================================================

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (!$isAdmin) {
    Write-Host "❌ ОШИБКА: Скрипт должен быть запущен от имени администратора!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Как запустить:" -ForegroundColor Yellow
    Write-Host "1. Закройте этот терминал" -ForegroundColor Gray
    Write-Host "2. Найдите PowerShell в меню Пуск" -ForegroundColor Gray
    Write-Host "3. Правая кнопка → Запуск от имени администратора" -ForegroundColor Gray
    Write-Host "4. Выполните: .\scripts\vscode-priority-boost.ps1" -ForegroundColor Gray
    Write-Host ""
    exit 1
}

Write-Host "✅ Запуск от имени администратора подтверждён" -ForegroundColor Green
Write-Host ""

# ============================================================================
# 2. ПОИСК ПРОЦЕССОВ VS CODE
# ============================================================================

Write-Host "1. Поиск процессов VS Code..." -ForegroundColor Yellow

$processes = Get-Process code -ErrorAction SilentlyContinue

if ($processes.Count -eq 0) {
    Write-Host "   ❌ VS Code не запущен!" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Запустите VS Code и повторите попытку" -ForegroundColor Yellow
    exit 1
}

Write-Host "   ✅ Найдено процессов: $($processes.Count)" -ForegroundColor Green
Write-Host ""

# ============================================================================
# 3. ПОВЫШЕНИЕ ПРИОРИТЕТА
# ============================================================================

Write-Host "2. Повышение приоритета процессов..." -ForegroundColor Yellow
Write-Host ""

$successCount = 0
$failCount = 0

foreach ($process in $processes) {
    try {
        $oldPriority = $process.PriorityClass
        $process.PriorityClass = "High"
        
        Write-Host "   ✅ PID $($process.Id): $oldPriority → High" -ForegroundColor Green
        $successCount++
    }
    catch {
        Write-Host "   ❌ PID $($process.Id): Ошибка - $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "                    РЕЗУЛЬТАТ                                               " -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Успешно: $successCount" -ForegroundColor Green
Write-Host "   Ошибок: $failCount" -ForegroundColor $(if ($failCount -gt 0) { "Red" } else { "Green" })
Write-Host ""

# ============================================================================
# 4. РЕКОМЕНДАЦИИ
# ============================================================================

Write-Host "📋 РЕКОМЕНДАЦИИ:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   1. Приоритет сбрасывается после перезапуска VS Code" -ForegroundColor Gray
Write-Host "   2. Запускайте этот скрипт при каждом запуске VS Code" -ForegroundColor Gray
Write-Host "   3. Альтернатива: закрепите ярлык с повышенным приоритетом" -ForegroundColor Gray
Write-Host ""

Write-Host "💡 АЛЬТЕРНАТИВНЫЙ СПОСОБ (навсегда):" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Создать ярлык для VS Code с параметром:" -ForegroundColor Gray
Write-Host "   " -NoNewline
Write-Host "powershell -Command \"Start-Process 'code' -PriorityClass High\"" -ForegroundColor White
Write-Host ""
Write-Host "   Или использовать Process Lasso для постоянного приоритета" -ForegroundColor Gray
Write-Host ""

Write-Host "✅ VS CODE PRIORITY BOOST COMPLETE" -ForegroundColor Green
Write-Host ""
