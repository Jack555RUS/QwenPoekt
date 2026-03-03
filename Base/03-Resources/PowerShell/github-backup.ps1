# ============================================
# GitHub Backup — Резервное копирование на GitHub
# ============================================
# Запуск: .\scripts\github-backup.ps1
# Требует: gh auth login (авторизация)

param(
    [switch]$AutoConfirm
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🔄 GITHUB BACKUP" -ForegroundColor Cyan
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
    Write-Host "✅ Изменений нет" -ForegroundColor Green
} else {
    Write-Host "📝 Найдены изменения:" -ForegroundColor Cyan
    git status --short
    Write-Host ""
    
    # Подтверждение
    if (!$AutoConfirm) {
        $response = Read-Host "Создать коммит? (y/n)"
        if ($response -eq 'y' -or $response -eq 'Y' -or $response -eq 'д' -or $response -eq 'Д') {
            git add .
            $date = Get-Date -Format "yyyy-MM-dd HH:mm"
            git commit -m "Backup $date"
        }
    }
}

# Проверка удалённого репозитория
Write-Host ""
Write-Host "📡 Проверка удалённого репозитория..." -ForegroundColor Cyan

try {
    $remote = git remote get-url origin 2>$null
    if ($remote) {
        Write-Host "✅ Remote origin: $remote" -ForegroundColor Green
    } else {
        Write-Host "❌ Remote origin не настроен!" -ForegroundColor Red
        Write-Host "   Настройте: git remote add origin <url>" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ Remote origin не настроен!" -ForegroundColor Red
    Write-Host "   Настройте: git remote add origin <url>" -ForegroundColor Yellow
    exit 1
}

# Push на GitHub
Write-Host ""
Write-Host "📤 Push на GitHub..." -ForegroundColor Cyan

try {
    git push -u origin master
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Backup завершён!" -ForegroundColor Green
        Write-Host "   Все изменения на GitHub" -ForegroundColor Gray
    } else {
        Write-Host ""
        Write-Host "❌ Ошибка при push!" -ForegroundColor Red
        Write-Host "   Проверьте авторизацию: gh auth status" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "❌ Ошибка при push!" -ForegroundColor Red
    Write-Host "   Проверьте: gh auth login" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ЗАВЕРШЕНО" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
