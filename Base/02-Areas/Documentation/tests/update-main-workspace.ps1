# update-main-workspace.ps1
# Обновление основного workspace
# Версия: 1.0
# Дата: 2026-03-03

$ErrorActionPreference = "Stop"

Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         ОБНОВЛЕНИЕ ОСНОВНОГО WORKSPACE                   ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Пути
$testWorkspacePath = "D:\QwenPoekt\QwenPoekt_TEST.code-workspace"
$mainWorkspacePath = "D:\QwenPoekt\QwenPoekt.code-workspace"

Write-Host "[1/3] Чтение тестового workspace..." -ForegroundColor Cyan

try {
    $testContent = Get-Content $testWorkspacePath -Raw
    Write-Host "  ✅ Тестовый workspace прочитан" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Ошибка чтения: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/3] Копирование в основной..." -ForegroundColor Cyan

try {
    $testContent | Out-File -FilePath $mainWorkspacePath -Encoding utf8
    Write-Host "  ✅ Основной workspace обновлён" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Ошибка записи: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[3/3] Проверка..." -ForegroundColor Cyan

try {
    $mainContent = Get-Content $mainWorkspacePath -Raw
    if ($mainContent -eq $testContent) {
        Write-Host "  ✅ Workspace идентичны" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Расхождение (требуется проверка)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ❌ Ошибка проверки: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         WORKSPACE ОБНОВЛЁН ✅                            ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📄 Workspace: $mainWorkspacePath" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Следующие шаги:" -ForegroundColor Yellow
Write-Host "  1. Перезагрузите VS Code" -ForegroundColor Gray
Write-Host "  2. Откройте QwenPoekt.code-workspace" -ForegroundColor Gray
Write-Host "  3. Проверьте доступ ко всем папкам" -ForegroundColor Gray
Write-Host ""
