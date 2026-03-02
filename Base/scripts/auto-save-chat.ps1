# auto-save-chat.ps1 — Автоматическое сохранение сессии
# Версия: 1.0
# Дата: 2 марта 2026 г.
# Назначение: Автосохранение каждые 2 минуты (Task Scheduler)

param(
    [switch]$Verbose,
    [switch]$Log
)

$ErrorActionPreference = "Stop"

# Пути
$BasePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$RulesPath = Join-Path $BasePath ".qwen\session-rules.json"
$SessionsPath = Join-Path $BasePath "sessions"
$LogPath = Join-Path $SessionsPath "auto-save.log"

# Логирование
function Write-Log {
    param($msg)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $msg"
    
    if ($Log) {
        Add-Content -Path $LogPath -Value $logEntry
    }
    
    if ($Verbose) {
        Write-Host $logEntry
    }
}

Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║         АВТОСОХРАНЕНИЕ СЕССИИ $(Get-Date -Format 'HH:mm:ss')          ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"

# ============================================
# 1. ПРОВЕРКА КОНФИГУРАЦИИ
# ============================================

Write-Log "[1/6] Проверка конфигурации..."

if (Test-Path $RulesPath) {
    $rules = Get-Content $RulesPath -Raw | ConvertFrom-Json
    Write-Log "  ✅ Конфигурация загружена"
    
    if (-not $rules.session.auto_save.enabled) {
        Write-Log "  ⚠️ Автосохранение выключено в конфигурации"
        exit 0
    }
} else {
    Write-Log "  ❌ Конфигурация не найдена"
    exit 1
}

# ============================================
# 2. ПОЛУЧЕНИЕ ТЕКУЩЕЙ СЕССИИ
# ============================================

Write-Log "[2/6] Получение текущей сессии..."

$sessionId = Get-Date -Format "yyyy-MM-dd_HH-mm"
$sessionPath = Join-Path $SessionsPath $sessionId

Write-Log "  📊 ID сессии: $sessionId"

# ============================================
# 3. ПРОВЕРКА СУЩЕСТВУЮЩИХ ДАННЫХ
# ============================================

Write-Log "[3/6] Проверка существующих данных..."

# Проверка .resume_marker.json для получения контекста
$markerPath = Join-Path $BasePath ".resume_marker.json"
$task = ""
$lastStep = ""

if (Test-Path $markerPath) {
    try {
        $marker = Get-Content $markerPath -Raw | ConvertFrom-Json
        $task = $marker.CurrentTask
        $lastStep = $marker.NextStep
        Write-Log "  📋 Задача: $task"
        Write-Log "  📍 Шаг: $lastStep"
    } catch {
        Write-Log "  ⚠️ Ошибка чтения маркера: $_"
    }
} else {
    Write-Log "  ℹ️  Маркер не найден (новая сессия)"
}

# ============================================
# 4. ФОРМИРОВАНИЕ ПЕРЕПИСКИ
# ============================================

Write-Log "[4/6] Формирование переписки..."

# Запрос к ИИ через MCP (файловая система)
# ИИ должен предоставить текущую переписку
$chatContent = @"
[Автосохранение: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')]

**Задача:** $task
**Шаг:** $lastStep

---

## [$(Get-Date -Format 'HH:mm:ss')] Автосохранение

Переписка сохраняется автоматически каждые $($rules.session.auto_save.interval_minutes) минуты.

**Примечание:** Для полной переписки обратитесь к ИИ через команду /save-session

"@

Write-Log "  ✅ Переписка сформирована"

# ============================================
# 5. ФОРМИРОВАНИЕ МЕТАДАННЫХ
# ============================================

Write-Log "[5/6] Формирование метаданных..."

$metadata = @{
    session_id = $sessionId
    timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss'
    task = $task
    last_step = $lastStep
    auto_save = $true
    auto_save_interval = $rules.session.auto_save.interval_minutes
    version = "1.0"
}

# Добавление информации о Git
try {
    $gitCommit = git rev-parse HEAD 2>$null
    if ($gitCommit) {
        $metadata.last_commit = $gitCommit
    }
} catch {
    Write-Log "  ⚠️ Git недоступен"
}

$metadataJson = $metadata | ConvertTo-Json -Depth 3

Write-Log "  ✅ Метаданные сформированы"

# ============================================
# 6. СОХРАНЕНИЕ
# ============================================

Write-Log "[6/6] Сохранение..."

try {
    # Создание папки
    if (-not (Test-Path $sessionPath)) {
        New-Item -ItemType Directory -Path $sessionPath -Force | Out-Null
        Write-Log "  ✅ Папка создана"
    }
    
    # Сохранение переписки
    $chatPath = Join-Path $sessionPath "chat.md"
    $chatContent | Out-File -FilePath $chatPath -Encoding utf8
    $chatSize = (Get-Item $chatPath).Length / 1KB
    Write-Log "  ✅ chat.md ($([Math]::Round($chatSize, 2)) KB)"
    
    # Сохранение метаданных
    $metadataPath = Join-Path $sessionPath "metadata.json"
    $metadataJson | Out-File -FilePath $metadataPath -Encoding utf8
    $metaSize = (Get-Item $metadataPath).Length / 1KB
    Write-Log "  ✅ metadata.json ($([Math]::Round($metaSize, 2)) KB)"
    
    # Обновление .resume_marker.json
    $markerData = @{
        Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Reason = "Auto-save"
        CurrentTask = $task
        NextStep = $lastStep
        SessionFile = "sessions/$sessionId/chat.md"
        GitCommit = $gitCommit
        AutoSave = $true
    }
    
    $markerData | ConvertTo-Json -Depth 3 | Out-File -FilePath $markerPath -Encoding utf8
    Write-Log "  ✅ .resume_marker.json обновлён"
    
} catch {
    Write-Log "  ❌ Ошибка сохранения: $_"
    exit 1
}

# ============================================
# 7. ОЧИСТКА СТАРЫХ СЕССИЙ
# ============================================

Write-Log "[7/6] Очистка старых сессий..."

try {
    $retentionDays = $rules.session.auto_save.retention_days
    $cutoffDate = (Get-Date).AddDays(-$retentionDays)
    
    $oldSessions = Get-ChildItem $SessionsPath -Directory | Where-Object {
        $_.LastWriteTime -lt $cutoffDate
    }
    
    if ($oldSessions.Count -gt 0) {
        Write-Log "  📊 Найдено старых сессий: $($oldSessions.Count)"
        
        foreach ($session in $oldSessions) {
            # Сжатие вместо удаления
            if ($rules.session.auto_save.compress_old) {
                $zipPath = "$($session.FullName).zip"
                Compress-Archive -Path $session.FullName -DestinationPath $zipPath -Force
                Remove-Item -Path $session.FullName -Recurse -Force
                Write-Log "  🗜️ Сжато: $($session.Name)"
            } else {
                Remove-Item -Path $session.FullName -Recurse -Force
                Write-Log "  🗑️ Удалено: $($session.Name)"
            }
        }
    } else {
        Write-Log "  ✅ Старых сессий нет"
    }
} catch {
    Write-Log "  ⚠️ Ошибка очистки: $_"
}

# ============================================
# ИТОГ
# ============================================

Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║           АВТОСОХРАНЕНИЕ ЗАВЕРШЕНО ✅                    ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""
Write-Log "📊 Результаты:"
Write-Log "  📁 Сессия: $sessionId"
Write-Log "  📄 Путь: $sessionPath"
Write-Log "  💾 Размер: ~$([Math]::Round(($chatSize + $metaSize), 2)) KB"
Write-Log ""
