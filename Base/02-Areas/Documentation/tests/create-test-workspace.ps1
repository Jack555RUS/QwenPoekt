# create-test-workspace.ps1
# Создание тестового workspace для полного доступа
# Версия: 1.0
# Дата: 2026-03-03

$ErrorActionPreference = "Stop"

Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         СОЗДАНИЕ ТЕСТОВОГО WORKSPACE                     ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Путь к workspace
$workspacePath = "D:\QwenPoekt\QwenPoekt_TEST.code-workspace"

Write-Host "[1/3] Создание workspace файла..." -ForegroundColor Cyan

# Содержимое workspace
$workspaceContent = @"
{
  "folders": [
    {
      "path": "."
    }
  ],
  "settings": {
    "files.exclude": {
      "**/.git": true,
      "**/node_modules": true,
      "**/*.tmp": true,
      "**/*.log": true
    },
    "search.exclude": {
      "**/node_modules": true,
      "**/bower_components": true,
      "**/Library": true,
      "**/obj": true,
      "**/bin": true
    }
  }
}
"@

try {
    $workspaceContent | Out-File -FilePath $workspacePath -Encoding utf8
    Write-Host "  ✅ Workspace создан: $workspacePath" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Ошибка создания: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2/3] Проверка доступа..." -ForegroundColor Cyan

# Проверка доступа ко всем папкам
$folders = @('Base', 'BOOK', 'OLD', 'Projects', '_BACKUP', '_TEST_ENV')
$allAccessible = $true

foreach ($folder in $folders) {
    $path = "D:\QwenPoekt\$folder"
    if (Test-Path $path) {
        Write-Host "  ✅ $folder" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $folder (не найдено)" -ForegroundColor Red
        $allAccessible = $false
    }
}

Write-Host ""
Write-Host "[3/3] Итоги..." -ForegroundColor Cyan

if ($allAccessible) {
    Write-Host "  ✅ Все папки доступны" -ForegroundColor Green
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║         WORKSPACE СОЗДАН ✅                              ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "📄 Workspace: $workspacePath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "💡 Следующие шаги:" -ForegroundColor Yellow
    Write-Host "  1. Откройте QwenPoekt_TEST.code-workspace в VS Code" -ForegroundColor Gray
    Write-Host "  2. Проверьте доступ ко всем папкам" -ForegroundColor Gray
    Write-Host "  3. Если ВСЕ ✅ → Обновите основной workspace" -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "  ❌ Некоторые папки недоступны" -ForegroundColor Red
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║         ТРЕБУЕТСЯ ПРОВЕРКА ⚠️                           ║" -ForegroundColor Yellow
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host ""
}
