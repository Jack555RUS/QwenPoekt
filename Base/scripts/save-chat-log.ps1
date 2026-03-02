# save-chat-log.ps1 — Сохранение переписки сессии
# Версия: 1.0
# Дата: 2 марта 2026 г.
# Назначение: Сохранение полной переписки (чат + команды + метаданные)

param(
    [string]$ChatContent,        # Переписка (Markdown)
    [string]$MetadataJson,       # Метаданные (JSON)
    [string]$CommandsLog,        # Команды (текст)
    [string]$SessionId,          # ID сессии (YYYY-MM-DD_HH-mm)
    [string]$Task = "",          # Задача сессии
    [switch]$NoConfirm
)

$ErrorActionPreference = "Stop"

# Цвета вывода
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║         СОХРАНЕНИЕ СЕССИИ $(Get-Date -Format 'HH:mm:ss')                  ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"

# Пути
$BasePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$RulesPath = Join-Path $BasePath ".qwen\session-rules.json"
$SessionsPath = Join-Path $BasePath "sessions"

# ============================================
# 1. ЗАГРУЗКА КОНФИГУРАЦИИ
# ============================================

Write-Info "[1/5] Загрузка конфигурации..."

if (Test-Path $RulesPath) {
    $rules = Get-Content $RulesPath -Raw | ConvertFrom-Json
    Write-Success "  ✅ Конфигурация загружена"
    
    $sessionPath = Join-Path $SessionsPath $SessionId
    $encoding = $rules.session.chat_log.encoding
} else {
    Write-Warning "  ⚠️ Конфигурация не найдена, использую значения по умолчанию"
    $rules = @{
        session = @{
            paths = @{ sessions = "sessions/" }
            chat_log = @{ encoding = "utf8" }
        }
    }
    $sessionPath = Join-Path $SessionsPath $SessionId
    $encoding = "utf8"
}

# ============================================
# 2. ГЕНЕРАЦИЯ ID СЕССИИ
# ============================================

Write-Info "[2/5] Генерация ID сессии..."

if (-not $SessionId) {
    $SessionId = Get-Date -Format "yyyy-MM-dd_HH-mm"
    Write-Info "  📊 ID сессии: $SessionId"
}

$sessionPath = Join-Path $SessionsPath $SessionId

# ============================================
# 3. СОЗДАНИЕ ПАПКИ СЕССИИ
# ============================================

Write-Info "[3/5] Создание папки сессии..."

try {
    if (-not (Test-Path $sessionPath)) {
        New-Item -ItemType Directory -Path $sessionPath -Force | Out-Null
        Write-Success "  ✅ Папка создана: $sessionPath"
    } else {
        Write-Info "  ℹ️  Папка существует"
    }
} catch {
    Write-Error "  ❌ Ошибка создания папки: $_"
    exit 1
}

# ============================================
# 4. СОХРАНЕНИЕ ПЕРЕПИСКИ (chat.md)
# ============================================

Write-Info "[4/5] Сохранение переписки..."

$chatFilePath = Join-Path $sessionPath "chat.md"

if ($ChatContent) {
    try {
        # Формирование заголовка
        $header = @"
# 📋 СЕССИЯ: $SessionId

**Дата:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Задача:** $Task
**Сохранено:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

---

## 📖 ПЕРЕПИСКА

"@
        
        $fullContent = $header + $ChatContent
        $fullContent | Out-File -FilePath $chatFilePath -Encoding $encoding
        
        $chatSize = (Get-Item $chatFilePath).Length / 1KB
        Write-Success "  ✅ chat.md сохранён ($([Math]::Round($chatSize, 2)) KB)"
    } catch {
        Write-Error "  ❌ Ошибка сохранения chat.md: $_"
        exit 1
    }
} else {
    Write-Warning "  ⚠️ Переписка пуста (ChatContent не передан)"
    
    # Создаём пустой файл с заголовком
    $header = @"
# 📋 СЕССИЯ: $SessionId

**Дата:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Задача:** $Task
**Сохранено:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

---

## 📖 ПЕРЕПИСКА

[Переписка не была предоставлена]
"@
        $header | Out-File -FilePath $chatFilePath -Encoding $encoding
        Write-Info "  ℹ️  Создан пустой chat.md"
}

# ============================================
# 5. СОХРАНЕНИЕ МЕТАДАННЫХ И КОМАНД
# ============================================

Write-Info "[5/5] Сохранение метаданных и команд..."

# Метаданные
$metadataPath = Join-Path $sessionPath "metadata.json"

if ($MetadataJson) {
    try {
        $MetadataJson | Out-File -FilePath $metadataPath -Encoding $encoding
        $metaSize = (Get-Item $metadataPath).Length / 1KB
        Write-Success "  ✅ metadata.json сохранён ($([Math]::Round($metaSize, 2)) KB)"
    } catch {
        Write-Warning "  ⚠️ Ошибка сохранения metadata.json: $_"
    }
} else {
    # Создаём метаданные по умолчанию
    $defaultMetadata = @{
        session_id = $SessionId
        timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
        task = $Task
        auto_save = $false
        version = "1.0"
    } | ConvertTo-Json -Depth 3
    
    $defaultMetadata | Out-File -FilePath $metadataPath -Encoding $encoding
    Write-Info "  ℹ️  Создан metadata.json по умолчанию"
}

# Команды
$commandsPath = Join-Path $sessionPath "commands.log"

if ($CommandsLog) {
    try {
        $CommandsLog | Out-File -FilePath $commandsPath -Encoding $encoding
        $cmdSize = (Get-Item $commandsPath).Length / 1KB
        Write-Success "  ✅ commands.log сохранён ($([Math]::Round($cmdSize, 2)) KB)"
    } catch {
        Write-Warning "  ⚠️ Ошибка сохранения commands.log: $_"
    }
} else {
    Write-Info "  ℹ️  CommandsLog не передан"
}

# ============================================
# ИТОГ
# ============================================

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Success "║           СОХРАНЕНИЕ ЗАВЕРШЕНО ✅                      ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

# Подсчёт размера
$totalSize = (Get-ChildItem $sessionPath -File | Measure-Object -Property Length -Sum).Sum / 1KB

Write-Info "📊 Результаты:"
Write-Host "  📁 Путь: $sessionPath" -ForegroundColor Gray
Write-Host "  📄 Файлов: $((Get-ChildItem $sessionPath -File).Count)" -ForegroundColor Gray
Write-Host "  💾 Размер: $([Math]::Round($totalSize, 2)) KB" -ForegroundColor Gray
Write-Host ""

Write-Info "📌 Следующие шаги:"
Write-Host "  1. Проверьте сохранённые файлы" -ForegroundColor Gray
Write-Host "  2. Используйте /resume для восстановления" -ForegroundColor Gray
Write-Host "  3. Файлы будут сжаты через $($rules.session.auto_save.retention_days) дней" -ForegroundColor Gray
Write-Host ""

# Возврат данных
return @{
    SessionId = $SessionId
    Path = $sessionPath
    SizeKB = [Math]::Round($totalSize, 2)
    Files = (Get-ChildItem $sessionPath -File).Count
}
