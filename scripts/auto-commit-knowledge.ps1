# ============================================
# Auto-Commit Knowledge Base — Авто-коммит изменений
# ============================================

param(
    [string]$message = ""  # Сообщение коммита
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "📦 AUTO-COMMIT KNOWLEDGE BASE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Проверка Git (полный путь)
$gitPath = "C:\Program Files\Git\bin\git.exe"

if (!(Test-Path $gitPath)) {
    Write-Host "❌ Git не найден! Установите Git: https://git-scm.com/" -ForegroundColor Red
    exit 1
}

try {
    $gitVersion = & $gitPath --version 2>&1
    Write-Host "✅ Git найден: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git не найден!" -ForegroundColor Red
    exit 1
}

# Проверка репозитория
try {
    $gitStatus = & $gitPath status 2>&1
    Write-Host "✅ Git репозиторий найден" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Git репозиторий не найден. Инициализация..." -ForegroundColor Yellow
    & $gitPath init
    Write-Host "✅ Репозиторий инициализирован" -ForegroundColor Green
}

Write-Host ""

# Добавление изменений
Write-Host "1️⃣ Добавление изменений..." -ForegroundColor Yellow
& $gitPath add KNOWLEDGE_BASE/ -v
Write-Host "  ✅ Изменения добавлены" -ForegroundColor Green

Write-Host ""

# Создание сообщения
if ([string]::IsNullOrEmpty($message)) {
    $message = "Auto-commit: Knowledge Base update $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
}

Write-Host "2️⃣ Создание коммита..." -ForegroundColor Yellow
Write-Host "  📝 Сообщение: $message" -ForegroundColor Gray

try {
    & $gitPath commit -m $message
    Write-Host "  ✅ Коммит создан" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Нет изменений для коммита" -ForegroundColor Yellow
}

Write-Host ""

# Статус
Write-Host "3️⃣ Статус репозитория..." -ForegroundColor Yellow
& $gitPath status --short

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "AUTO-COMMIT ЗАВЕРШЁН" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Возвращаем результат
return @{
    Message = $message
    Status = "Success"
    Timestamp = Get-Date
}
