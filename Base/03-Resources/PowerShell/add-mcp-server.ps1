# add-mcp-server.ps1 — Добавление MCP Session Saver в VS Code
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Автоматическое добавление MCP сервера в конфигурацию VS Code

$ErrorActionPreference = "Stop"

# Цвета вывода
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║         НАСТРОЙКА MCP SESSION SAVER $(Get-Date -Format 'HH:mm:ss')         ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

# ============================================
# 1. ПРОВЕРКА СУЩЕСТВОВАНИЯ ФАЙЛОВ
# ============================================

Write-Info "[1/5] Проверка файлов..."

$scriptPath = "D:\QwenPoekt\Base\mcp-session-saver.js"
$packagePath = "D:\QwenPoekt\Base\package.json"
$nodeModulesPath = "D:\QwenPoekt\Base\node_modules"

if (-not (Test-Path $scriptPath)) {
    Write-Error "  ❌ mcp-session-saver.js не найден"
    exit 1
}

if (-not (Test-Path $packagePath)) {
    Write-Error "  ❌ package.json не найден"
    exit 1
}

if (-not (Test-Path $nodeModulesPath)) {
    Write-Warning "  ⚠️ node_modules не найден, запускаю npm install..."
    npm install --prefix "D:\QwenPoekt\Base"
}

Write-Success "  ✅ Файлы найдены"
Write-Host ""

# ============================================
# 2. ОПРЕДЕЛЕНИЕ ПУТИ VS CODE SETTINGS
# ============================================

Write-Info "[2/5] Поиск конфигурации VS Code..."

$vsCodePaths = @(
    "$env:APPDATA\Code\User\settings.json",
    "$env:USERPROFILE\.vscode\settings.json"
)

$vsCodeSettingsPath = $null

foreach ($path in $vsCodePaths) {
    if (Test-Path $path) {
        $vsCodeSettingsPath = $path
        break
    }
}

if (-not $vsCodeSettingsPath) {
    # Создаём новую конфигурацию
    $vsCodeSettingsPath = "$env:APPDATA\Code\User\settings.json"
    $dir = Split-Path $vsCodeSettingsPath -Parent
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Write-Info "  📝 Создаю новую конфигурацию..."
} else {
    Write-Success "  ✅ Конфигурация найдена: $vsCodeSettingsPath"
}

Write-Host ""

# ============================================
# 3. ЧТЕНИЕ ТЕКУЩЕЙ КОНФИГУРАЦИИ
# ============================================

Write-Info "[3/5] Чтение текущей конфигурации..."

try {
    if (Test-Path $vsCodeSettingsPath) {
        $currentConfig = Get-Content $vsCodeSettingsPath -Raw | ConvertFrom-Json
    } else {
        $currentConfig = @{}
    }
    Write-Success "  ✅ Конфигурация прочитана"
} catch {
    Write-Error "  ❌ Ошибка чтения: $_"
    exit 1
}

Write-Host ""

# ============================================
# 4. ДОБАВЛЕНИЕ MCP СЕРВЕРА
# ============================================

Write-Info "[4/5] Добавление MCP Session Saver..."

# Инициализация mcpServers если нет
if (-not $currentConfig.mcpServers) {
    $currentConfig | Add-Member -MemberType NoteProperty -Name "mcpServers" -Value @{}
    Write-Info "  📝 Создан раздел mcpServers"
}

# Добавление session-saver
$sessionSaverConfig = @{
    command = "node"
    args = @("D:\QwenPoekt\Base\mcp-session-saver.js")
}

$currentConfig.mcpServers | Add-Member -MemberType NoteProperty -Name "session-saver" -Value $sessionSaverConfig -Force

Write-Success "  ✅ MCP Session Saver добавлен"
Write-Host ""

# ============================================
# 5. СОХРАНЕНИЕ КОНФИГУРАЦИИ
# ============================================

Write-Info "[5/5] Сохранение конфигурации..."

try {
    $currentConfig | ConvertTo-Json -Depth 10 | Out-File -FilePath $vsCodeSettingsPath -Encoding utf8
    Write-Success "  ✅ Конфигурация сохранена"
} catch {
    Write-Error "  ❌ Ошибка сохранения: $_"
    exit 1
}

Write-Host ""

# ============================================
# ИТОГ
# ============================================

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Success "║           НАСТРОЙКА ЗАВЕРШЕНА ✅                       ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

Write-Info "📊 Результаты:"
Write-Host "  📁 Конфигурация: $vsCodeSettingsPath" -ForegroundColor Gray
Write-Host "  🔧 MCP сервер: session-saver" -ForegroundColor Gray
Write-Host "  📍 Путь скрипта: D:\QwenPoekt\Base\mcp-session-saver.js" -ForegroundColor Gray
Write-Host ""

Write-Info "📌 Следующие шаги:"
Write-Host "  1. Перезапустите VS Code" -ForegroundColor Cyan
Write-Host "  2. В чате введите: 'Список сессий'" -ForegroundColor Cyan
Write-Host "  3. Проверьте, что MCP сервер подключён" -ForegroundColor Cyan
Write-Host ""

Write-Info "💡 Для ручного добавления откройте:"
Write-Host "  $vsCodeSettingsPath" -ForegroundColor Gray
Write-Host ""
