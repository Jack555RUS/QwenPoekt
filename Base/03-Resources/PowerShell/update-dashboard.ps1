# ============================================================================
# UPDATE DASHBOARD
# Генерация JSON данных для Dashboard
# ============================================================================
# Использование: .\scripts\update-dashboard.ps1 [-Path "путь"]
# ============================================================================

param(
    [string]$Path = "D:\QwenPoekt\Base"
)

$ErrorActionPreference = "Continue"
$ReportsPath = Join-Path $Path "reports"

# ============================================================================
# ФУНКЦИИ
# ============================================================================

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Test-FileExists {
    param([string]$FileName)
    $filePath = Join-Path $ReportsPath $FileName
    return Test-Path $filePath
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

Write-Host ""
Write-Log "=== ОБНОВЛЕНИЕ DASHBOARD ===" -Color "Yellow"
Write-Log "Путь: $ReportsPath" -Color "Yellow"
Write-Host ""

# Проверка наличия JSON файлов
Write-Log "Проверка JSON файлов..." -Color "Cyan"

$metricsExists = Test-FileExists -FileName "kb_metrics.json"
$graphExists = Test-FileExists -FileName "knowledge_graph.json"

if (!$metricsExists) {
    Write-Log "⚠️  kb_metrics.json не найден" -Color "Yellow"
    Write-Log "   Запустите: .\scripts\calculate-kb-metrics.ps1" -Color "Gray"
} else {
    Write-Log "  ✅ kb_metrics.json" -Color "Green"
}

if (!$graphExists) {
    Write-Log "⚠️  knowledge_graph.json не найден" -Color "Yellow"
    Write-Log "   Запустите: .\scripts\build-knowledge-graph.ps1" -Color "Gray"
} else {
    Write-Log "  ✅ knowledge_graph.json" -Color "Green"
}

Write-Host ""

# Проверка HTML
$htmlPath = Join-Path $ReportsPath "KB_DASHBOARD.html"
if (Test-Path $htmlPath) {
    Write-Log "  ✅ KB_DASHBOARD.html" -Color "Green"
} else {
    Write-Log "  ❌ KB_DASHBOARD.html (не найден)" -Color "Red"
}

Write-Host ""

# Итоги
Write-Log "═══════════════════════════════════════════════════════════" -Color "Cyan"
Write-Log "  СТАТУС" -Color "Yellow"
Write-Log "═══════════════════════════════════════════════════════════" -Color "Cyan"
Write-Host ""

if ($metricsExists -and $graphExists) {
    Write-Host "✅ Dashboard готов к использованию!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 Откройте в браузере:" -ForegroundColor Cyan
    Write-Host "   $htmlPath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 Совет:" -ForegroundColor Yellow
    Write-Host "   Для автообновления данных запустите:" -ForegroundColor Gray
    Write-Host "   .\scripts\AUDIT_ALL.ps1" -ForegroundColor White
} else {
    Write-Host "⚠️  Недостаточно данных для Dashboard" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 Запустите аудит:" -ForegroundColor Cyan
    Write-Host "   .\scripts\AUDIT_ALL.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Или отдельные скрипты:" -ForegroundColor Cyan
    Write-Host "   .\scripts\calculate-kb-metrics.ps1" -ForegroundColor White
    Write-Host "   .\scripts\build-knowledge-graph.ps1" -ForegroundColor White
}

Write-Host ""
Write-Host "Нажмите любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
