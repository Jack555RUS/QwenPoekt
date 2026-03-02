# analyze-session-crash.ps1 — Анализ сбоя сессии
# Версия: 1.0
# Дата: 2 марта 2026 г.
# Назначение: Анализ последней сессии перед сбоем

param(
    [switch]$Verbose
)

$ErrorActionPreference = "SilentlyContinue"

# Пути
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$SessionsPath = Join-Path $BasePath "sessions"
$MarkerPath = Join-Path $BasePath ".resume_marker.json"

# ============================================
# 1. ПОИСК ПОСЛЕДНЕЙ СЕССИИ
# ============================================

$lastSession = Get-ChildItem $SessionsPath -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if (-not $lastSession) {
    Write-Host "❌ Сессии не найдены" -ForegroundColor Red
    exit 1
}

$timeSinceBackup = New-TimeSpan -Start $lastSession.LastWriteTime -End (Get-Date)

# ============================================
# 2. ЧТЕНИЕ ДАННЫХ
# ============================================

$marker = $null
if (Test-Path $MarkerPath) {
    $marker = Get-Content $MarkerPath | ConvertFrom-Json
}

$chat = $null
$chatPath = Join-Path $lastSession.FullName "chat.jsonl"
if (Test-Path $chatPath) {
    $chat = Get-Content $chatPath | ConvertFrom-Json
}

# ============================================
# 3. АНАЛИЗ
# ============================================

$result = @{
    LastSessionTime = $lastSession.LastWriteTime
    TimeSinceBackup = $timeSinceBackup
    Task = if ($marker) { $marker.CurrentTask } else { "Неизвестно" }
    HasChat = ($chat -ne $null)
    MessageCount = if ($chat) { $chat.messages.Count } else { 0 }
    LastCommands = @()
    CriticalOperation = $false
    TaskCompleted = $false
}

# Анализ последних команд
if ($chat -and $chat.commands) {
    $result.LastCommands = $chat.commands | Select-Object -Last 5
}

# Проверка критических операций
if ($chat -and $chat.last_operation) {
    $criticalOps = @("git rebase", "git reset", "Remove-Item", "Move-Item", "Format-Volume")
    foreach ($op in $criticalOps) {
        if ($chat.last_operation -like "*$op*") {
            $result.CriticalOperation = $true
        }
    }
}

# Проверка завершённости задачи
if ($chat -and $chat.messages) {
    $lastMessage = $chat.messages | Select-Object -Last 1
    if ($lastMessage.content -match "(завершено|готово|finished|done|коммит создан)") {
        $result.TaskCompleted = $true
    }
}

# ============================================
# 4. ВЫВОД
# ============================================

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         АНАЛИЗ ПОСЛЕДНЕЙ СЕССИИ ПЕРЕД СБОЕМ              ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 Информация:" -ForegroundColor Yellow
Write-Host "  Последнее сохранение: $($result.LastSessionTime)" -ForegroundColor Gray
Write-Host "  Прошло времени: $([Math]::Round($result.TimeSinceBackup.TotalMinutes, 1)) мин" -ForegroundColor Gray
Write-Host "  Задача: $($result.Task)" -ForegroundColor Gray
Write-Host ""

Write-Host "📋 Статус:" -ForegroundColor Yellow
Write-Host "  Завершена ли задача: $(if ($result.TaskCompleted) { '✅ Да' } else { '⏳ Нет' })" -ForegroundColor $(if ($result.TaskCompleted) { 'Green' } else { 'Yellow' })
Write-Host "  Критическая операция: $(if ($result.CriticalOperation) { '⚠️ Да' } else { '✅ Нет' })" -ForegroundColor $(if ($result.CriticalOperation) { 'Red' } else { 'Green' })
Write-Host ""

if ($result.LastCommands.Count -gt 0) {
    Write-Host "📋 Последние команды:" -ForegroundColor Yellow
    foreach ($cmd in $result.LastCommands) {
        Write-Host "  - $cmd" -ForegroundColor Gray
    }
    Write-Host ""
}

Write-Host "💡 Рекомендация:" -ForegroundColor Yellow

if ($result.TaskCompleted) {
    Write-Host "  ✅ Задача завершена — можно начать новую сессию" -ForegroundColor Green
} elseif ($result.CriticalOperation) {
    Write-Host "  ⚠️ Критическая операция прервана — сначала проверить состояние" -ForegroundColor Red
} else {
    Write-Host "  ⏳ Задача не завершена — восстановить контекст" -ForegroundColor Cyan
}

Write-Host ""

# ============================================
# 5. ВОПРОСЫ К ПОЛЬЗОВАТЕЛЮ
# ============================================

Write-Host "🗣️ Вопросы к тебе:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Что произошло с твоей стороны?" -ForegroundColor Gray
Write-Host "     - Закрытие терминала?" -ForegroundColor Gray
Write-Host "     - Сбой питания?" -ForegroundColor Gray
Write-Host "     - Что-то ещё?" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Что делаем?" -ForegroundColor Gray
Write-Host "     - 1️⃣ Восстановить контекст" -ForegroundColor Gray
Write-Host "     - 2️⃣ Начать новую сессию" -ForegroundColor Gray
Write-Host "     - 3️⃣ Сначала проверить состояние" -ForegroundColor Gray
Write-Host ""

# Возврат результата
return $result
