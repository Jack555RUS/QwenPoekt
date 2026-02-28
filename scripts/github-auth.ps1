# ============================================
# GitHub Auth — Авторизация на GitHub
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🔐 АВТОРИЗАЦИЯ НА GITHUB" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Обновление PATH
$env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
$ghPath = "gh"

# Проверка gh
try {
    & $ghPath --version | Out-Null
    Write-Host "✅ GitHub CLI найден" -ForegroundColor Green
} catch {
    Write-Host "❌ GitHub CLI не найден!" -ForegroundColor Red
    Write-Host "  Установите: winget install GitHub.cli" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "📝 Для авторизации выполните команду:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  gh auth login" -ForegroundColor White
Write-Host ""
Write-Host "📝 Процесс:" -ForegroundColor Cyan
Write-Host "  1. Выберите GitHub.com" -ForegroundColor White
Write-Host "  2. Выберите HTTPS" -ForegroundColor White
Write-Host "  3. Нажмите 'Login with a web browser'" -ForegroundColor White
Write-Host "  4. Скопируйте код" -ForegroundColor White
Write-Host "  5. Откройте ссылку в браузере" -ForegroundColor White
Write-Host "  6. Введите код" -ForegroundColor White
Write-Host "  7. Подтвердите авторизацию" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Готовы начать авторизацию? (y/n)"
if ($continue -ne "y") {
    Write-Host "❌ Отменено" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🔄 Запуск авторизации..." -ForegroundColor Yellow
Write-Host ""

# Запуск авторизации
& $ghPath auth login

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ПРОВЕРКА РЕЗУЛЬТАТА" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Проверка
Write-Host "🔄 Проверка статуса..." -ForegroundColor Yellow
& $ghPath auth status

Write-Host ""
Write-Host "✅ Авторизация завершена!" -ForegroundColor Green
Write-Host ""
