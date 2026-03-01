# ============================================
# Auto Commit Daily — Ежедневный авто-коммит
# ============================================
# Запуск: .\scripts\auto-commit-daily.ps1
# Планировщик: 18:00 ежедневно

param(
    [switch]$AutoConfirm
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "📅 AUTO COMMIT DAILY (18:00)" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Проверка Git
try {
    $gitStatus = git status --porcelain
} catch {
    Write-Host "❌ Git не найден!" -ForegroundColor Red
    exit 1
}

# Проверка изменений
if ([string]::IsNullOrWhiteSpace($gitStatus)) {
    Write-Host "✅ Изменений нет — коммит не нужен" -ForegroundColor Green
    exit 0
}

# Показать изменения
Write-Host "📝 Найдены изменения:" -ForegroundColor Cyan
git status --short
Write-Host ""

# Подтверждение
if (!$AutoConfirm) {
    $response = Read-Host "Создать коммит? (y/n)"
    if ($response -ne 'y' -and $response -ne 'Y' -and $response -ne 'д' -and $response -ne 'Д') {
        Write-Host "❌ Отменено" -ForegroundColor Yellow
        exit 0
    }
}

# Добавить все файлы
Write-Host "📦 Добавление файлов..." -ForegroundColor Cyan
git add .

# Создать коммит
$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HH:mm"
$message = "Daily commit $date $time"

Write-Host "💾 Создание коммита..." -ForegroundColor Cyan
git commit -m "$message"

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Коммит создан!" -ForegroundColor Green
    Write-Host "   Сообщение: $message" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ Ошибка при коммите!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ЗАВЕРШЕНО" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
