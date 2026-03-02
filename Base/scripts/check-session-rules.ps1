# check-session-rules.ps1 — Проверка правил сессии
# Версия: 1.0
# Дата: 2 марта 2026 г.
# Назначение: Проверка конфигурации при старте сессии

param(
    [switch]$Verbose,
    [switch]$NoColor
)

$ErrorActionPreference = "Stop"

# Цвета вывода
function Write-Info { param($msg) if (-not $NoColor) { Write-Host $msg -ForegroundColor Cyan } else { Write-Host $msg } }
function Write-Success { param($msg) if (-not $NoColor) { Write-Host $msg -ForegroundColor Green } else { Write-Host $msg } }
function Write-Warning { param($msg) if (-not $NoColor) { Write-Host $msg -ForegroundColor Yellow } else { Write-Host $msg } }
function Write-Error { param($msg) if (-not $NoColor) { Write-Host $msg -ForegroundColor Red } else { Write-Host $msg } }

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║         ПРОВЕРКА ПРАВИЛ СЕССИИ $(Get-Date -Format 'HH:mm:ss')           ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"

# Пути
$BasePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$RulesPath = Join-Path $BasePath ".qwen\session-rules.json"
$ResumeMarkerPath = Join-Path $BasePath ".resume_marker.json"
$SessionsPath = Join-Path $BasePath "sessions"

# ============================================
# 1. ПРОВЕРКА КОНФИГУРАЦИИ
# ============================================

Write-Info "[1/4] Проверка конфигурации..."

if (Test-Path $RulesPath) {
    Write-Success "  ✅ session-rules.json найден"
    
    try {
        $rules = Get-Content $RulesPath -Raw | ConvertFrom-Json
        
        if ($Verbose) {
            Write-Host ""
            Write-Host "Конфигурация:" -ForegroundColor Cyan
            Write-Host "  Версия: $($rules.version)" -ForegroundColor Gray
            Write-Host "  Автосохранение: $($rules.session.auto_save.enabled)" -ForegroundColor Gray
            Write-Host "  Интервал: $($rules.session.auto_save.interval_minutes) мин" -ForegroundColor Gray
            Write-Host "  Путь: $($rules.session.paths.sessions)" -ForegroundColor Gray
        }
    } catch {
        Write-Warning "  ⚠️ Ошибка чтения конфигурации: $_"
        $rules = $null
    }
} else {
    Write-Warning "  ⚠️ session-rules.json не найден"
    Write-Info "  💡 Создайте конфигурацию:"
    Write-Info "     .qwen/session-rules.json"
    $rules = $null
}

# ============================================
# 2. ПРОВЕРКА АВТОСОХРАНЕНИЯ
# ============================================

Write-Info "[2/4] Проверка автосохранения..."

if ($rules -and $rules.session.auto_save.enabled) {
    Write-Success "  ✅ Автосохранение включено"
    
    # Проверка задачи Task Scheduler
    $task = Get-ScheduledTask -TaskName "QwenSessionAutoSave" -ErrorAction SilentlyContinue
    
    if ($task) {
        Write-Success "  ✅ Задача QwenSessionAutoSave активна"
        
        if ($Verbose) {
            $taskInfo = Get-ScheduledTaskInfo -TaskName "QwenSessionAutoSave"
            Write-Host "  Интервал: $($rules.session.auto_save.interval_minutes) мин" -ForegroundColor Gray
            Write-Host "  След. запуск: $($taskInfo.NextRunTime)" -ForegroundColor Gray
        }
    } else {
        Write-Warning "  ⚠️ Задача QwenSessionAutoSave не найдена"
        Write-Info "  💡 Создаю задачу..."
        
        try {
            $action = New-ScheduledTaskAction -Execute "PowerShell" `
              -Argument "-NoProfile -WindowStyle Hidden -File `"$BasePath\scripts\auto-save-chat.ps1`""
            
            $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) `
              -RepetitionInterval (New-TimeSpan -Minutes $rules.session.auto_save.interval_minutes) `
              -RepetitionDuration ([TimeSpan]::MaxValue)
            
            $settings = New-ScheduledTaskSettingsSet `
              -AllowStartIfOnBatteries `
              -DontStopIfGoingOnBatteries `
              -ExecutionTimeLimit (New-TimeSpan -Minutes 5)
            
            Register-ScheduledTask -TaskName "QwenSessionAutoSave" `
              -Action $action `
              -Trigger $trigger `
              -Settings $settings `
              -Force | Out-Null
            
            Write-Success "  ✅ Задача создана"
        } catch {
            Write-Warning "  ⚠️ Ошибка создания задачи: $_"
            Write-Info "  💡 Запустите от имени администратора"
        }
    }
} else {
    Write-Info "  ℹ️  Автосохранение выключено"
    Write-Info "  💡 Используйте /auto-save on для включения"
}

# ============================================
# 3. ПРОВЕРКА ВОССТАНОВЛЕНИЯ
# ============================================

Write-Info "[3/4] Проверка восстановления..."

if (Test-Path $ResumeMarkerPath) {
    Write-Success "  ✅ Маркер восстановления найден"
    
    try {
        $resumeData = Get-Content $ResumeMarkerPath -Raw | ConvertFrom-Json
        
        Write-Host ""
        Write-Info "📊 Информация о сессии:"
        Write-Host "  Дата: $($resumeData.Date)" -ForegroundColor Gray
        Write-Host "  Задача: $($resumeData.CurrentTask)" -ForegroundColor Gray
        Write-Host "  След. шаг: $($resumeData.NextStep)" -ForegroundColor Gray
        
        if ($Verbose) {
            Write-Host "  Причина: $($resumeData.Reason)" -ForegroundColor Gray
            Write-Host "  Git Commit: $($resumeData.GitCommit)" -ForegroundColor Gray
        }
    } catch {
        Write-Warning "  ⚠️ Ошибка чтения маркера: $_"
    }
} else {
    Write-Info "  ℹ️  Маркер восстановления не найден"
    Write-Info "  → Новая сессия"
}

# ============================================
# 4. ПРОВЕРКА СЕССИЙ
# ============================================

Write-Info "[4/4] Проверка сессий..."

if (Test-Path $SessionsPath) {
    $sessionCount = (Get-ChildItem $SessionsPath -Directory).Count
    $totalSize = (Get-ChildItem $SessionsPath -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB
    
    Write-Success "  ✅ Папка sessions/ найдена"
    Write-Host "  Сессий: $sessionCount" -ForegroundColor Gray
    Write-Host "  Размер: $([Math]::Round($totalSize, 2)) MB" -ForegroundColor Gray
    
    if ($Verbose) {
        Write-Host ""
        Write-Host "Последние сессии:" -ForegroundColor Cyan
        Get-ChildItem $SessionsPath -Directory | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | ForEach-Object {
            $size = (Get-ChildItem $_.FullName -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1KB
            Write-Host "  $($_.Name) ($([Math]::Round($size, 2)) KB)" -ForegroundColor Gray
        }
    }
} else {
    Write-Info "  ℹ️  Папка sessions/ не найдена"
    Write-Info "  💡 Будет создана при первом сохранении"
    
    if ($rules) {
        try {
            New-Item -ItemType Directory -Path (Join-Path $BasePath $rules.session.paths.sessions) -Force | Out-Null
            Write-Success "  ✅ Папка создана"
        } catch {
            Write-Warning "  ⚠️ Ошибка создания папки: $_"
        }
    }
}

# ============================================
# ИТОГ
# ============================================

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Success "║              ПРОВЕРКА ЗАВЕРШЕНА ✅                     ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

# Рекомендации
if ($rules -and $rules.session.auto_resume.enabled) {
    if (Test-Path $ResumeMarkerPath) {
        Write-Info "📌 Рекомендации:"
        Write-Host ""
        Write-Info "  Найдена предыдущая сессия!"
        Write-Info "  Используйте /resume для восстановления контекста"
        Write-Host ""
    }
}

# Возврат данных
return @{
    RulesLoaded = ($rules -ne $null)
    AutoSaveEnabled = ($rules -and $rules.session.auto_save.enabled)
    TaskActive = (Get-ScheduledTask -TaskName "QwenSessionAutoSave" -ErrorAction SilentlyContinue) -ne $null
    HasPreviousSession = (Test-Path $ResumeMarkerPath)
    SessionCount = (Get-ChildItem $SessionsPath -Directory -ErrorAction SilentlyContinue).Count
}
