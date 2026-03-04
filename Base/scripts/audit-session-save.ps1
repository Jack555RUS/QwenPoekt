# audit-session-save.ps1 — Аудит системы сохранения сессий
# Версия: 1.0
# Дата: 4 марта 2026 г.

param(
    [switch]$Verbose,
    [switch]$Detailed
)

$ErrorActionPreference = "Stop"

# Цвета
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"

function Write-Status {
    param($status, $msg, $color)
    $symbol = switch ($status) {
        "OK" { "✅" }
        "WARN" { "⚠️" }
        "FAIL" { "❌" }
        "INFO" { "ℹ️" }
    }
    Write-Host "$symbol $msg" -ForegroundColor $color
}

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      АУДИТ СИСТЕМЫ СОХРАНЕНИЯ СЕССИЙ                   ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$BasePath = Split-Path -Parent $PSScriptRoot
$SessionsPath = Join-Path $BasePath "sessions"
$RulesPath = Join-Path $BasePath ".qwen\session-rules.json"
$MarkerPath = Join-Path $BasePath ".resume_marker.json"
$McpPath = Join-Path $BasePath "mcp-session-saver.js"
$McpJsonPath = Join-Path $BasePath "mcp.json"

# ============================================
# 1. ПРОВЕРКА КОНФИГУРАЦИИ
# ============================================

Write-Host "[1/8] Конфигурация сессий" -ForegroundColor Cyan

if (Test-Path $RulesPath) {
    $rules = Get-Content $RulesPath -Raw | ConvertFrom-Json
    Write-Status "OK" "session-rules.json найден" $Green
    
    if ($rules.session.auto_save.enabled) {
        Write-Status "OK" "Автосохранение: ВКЛЮЧЕНО (интервал: $($rules.session.auto_save.interval_minutes) мин)" $Green
    } else {
        Write-Status "WARN" "Автосохранение: ВЫКЛЮЧЕНО" $Yellow
    }
} else {
    Write-Status "FAIL" "session-rules.json НЕ НАЙДЕН" $Red
}

# ============================================
# 2. ПРОВЕРКА MCP СЕРВЕРА
# ============================================

Write-Host "`n[2/8] MCP сервер" -ForegroundColor Cyan

if (Test-Path $McpPath) {
    Write-Status "OK" "mcp-session-saver.js найден" $Green
    $lines = (Get-Content $McpPath | Measure-Object -Line).Lines
    Write-Status "INFO" "Строк кода: $lines" $Cyan
} else {
    Write-Status "FAIL" "mcp-session-saver.js НЕ НАЙДЕН" $Red
}

if (Test-Path $McpJsonPath) {
    $mcpJson = Get-Content $McpJsonPath -Raw | ConvertFrom-Json
    Write-Status "OK" "mcp.json найден" $Green
    
    if ($mcpJson.servers.session_saver) {
        Write-Status "OK" "session-saver сервер настроен" $Green
    } else {
        Write-Status "WARN" "session-saver сервер НЕ НАСТРОЕН" $Yellow
    }
} else {
    Write-Status "FAIL" "mcp.json НЕ НАЙДЕН" $Red
}

# ============================================
# 3. ПРОВЕРКА МАРКЕРА ВОССТАНОВЛЕНИЯ
# ============================================

Write-Host "`n[3/8] Маркер восстановления" -ForegroundColor Cyan

if (Test-Path $MarkerPath) {
    $marker = Get-Content $MarkerPath -Raw | ConvertFrom-Json
    Write-Status "OK" ".resume_marker.json найден" $Green
    Write-Status "INFO" "Последняя сессия: $($marker.SessionFile)" $Cyan
    Write-Status "INFO" "Задача: $($marker.CurrentTask)" $Cyan
} else {
    Write-Status "FAIL" ".resume_marker.json НЕ НАЙДЕН" $Red
}

# ============================================
# 4. АНАЛИЗ СЕССИЙ
# ============================================

Write-Host "`n[4/8] Анализ сессий" -ForegroundColor Cyan

$totalSessions = 0
$emptySessions = 0
$smallSessions = 0
$largeSessions = 0
$totalLines = 0

$sessions = Get-ChildItem $SessionsPath -Directory | Where-Object { $_.Name -notlike "_*" }

foreach ($session in $sessions) {
    $totalSessions++
    $chatPath = Join-Path $session.FullName "chat.md"
    
    if (Test-Path $chatPath) {
        $lines = (Get-Content $chatPath | Measure-Object -Line).Lines
        $totalLines += $lines
        
        if ($lines -lt 20) {
            $emptySessions++
            if ($Verbose) {
                Write-Status "WARN" "ПУСТАЯ ($lines строк): $($session.Name)" $Yellow
            }
        } elseif ($lines -lt 50) {
            $smallSessions++
            if ($Verbose) {
                Write-Status "WARN" "МАЛО ДАННЫХ ($lines строк): $($session.Name)" $Yellow
            }
        } else {
            $largeSessions++
        }
    } else {
        $emptySessions++
        if ($Verbose) {
            Write-Status "FAIL" "НЕТ chat.md: $($session.Name)" $Red
        }
    }
}

Write-Status "INFO" "Всего сессий: $totalSessions" $Cyan
Write-Status "INFO" "С данными (>50 строк): $largeSessions" $Green
Write-Status "WARN" "Пустые/мало данных (<50 строк): $emptySessions" $Yellow
Write-Status "INFO" "Всего строк в сессиях: $totalLines" $Cyan

# ============================================
# 5. ПРОВЕРКА ПОСЛЕДНИХ СЕССИЙ
# ============================================

Write-Host "`n[5/8] Последние сессии (Топ-5)" -ForegroundColor Cyan

$lastSessions = $sessions | Sort-Object CreationTime -Descending | Select-Object -First 5

foreach ($session in $lastSessions) {
    $chatPath = Join-Path $session.FullName "chat.md"
    if (Test-Path $chatPath) {
        $lines = (Get-Content $chatPath | Measure-Object -Line).Lines
        $status = if ($lines -gt 50) { "✅" } elseif ($lines -gt 20) { "⚠️" } else { "❌" }
        Write-Host "  $status $($session.Name) — $lines строк"
    }
}

# ============================================
# 6. ПРОВЕРКА СКРИПТОВ АВТОСОХРАНЕНИЯ
# ============================================

Write-Host "`n[6/8] Скрипты автосохранения" -ForegroundColor Cyan

$autoSaveScripts = @(
    "auto-save-chat.ps1",
    "auto-save-session.ps1",
    "save-chat-log.ps1"
)

foreach ($script in $autoSaveScripts) {
    $scriptPath = Join-Path $BasePath "03-Resources\PowerShell\$script"
    if (Test-Path $scriptPath) {
        Write-Status "OK" "$script найден" $Green
    } else {
        Write-Status "FAIL" "$script НЕ НАЙДЕН" $Red
    }
}

# ============================================
# 7. ПРОВЕРКА TASK SCHEDULER
# ============================================

Write-Host "`n[7/8] Task Scheduler" -ForegroundColor Cyan

# Попытка проверить через schtasks
try {
    $task = schtasks /Query /TN "QwenSessionAutoSave" 2>$null
    if ($task) {
        Write-Status "OK" "Задача QwenSessionAutoSave найдена" $Green
        if ($Detailed) {
            Write-Host $task
        }
    } else {
        Write-Status "WARN" "Задача QwenSessionAutoSave НЕ НАЙДЕНА" $Yellow
    }
} catch {
    Write-Status "WARN" "Не удалось проверить Task Scheduler" $Yellow
}

# ============================================
# 8. ВЫВОДЫ И РЕКОМЕНДАЦИИ
# ============================================

Write-Host "`n[8/8] Выводы и рекомендации" -ForegroundColor Cyan

$problems = @()

if (-not (Test-Path $RulesPath)) {
    $problems += "session-rules.json отсутствует"
}

if (-not (Test-Path $McpPath)) {
    $problems += "mcp-session-saver.js отсутствует"
}

if ($emptySessions -gt ($totalSessions / 2)) {
    $problems += "Более 50% сессий пустые или малые"
}

if ($totalLines -lt 1000) {
    $problems += "Общее количество строк в сессиях мало (<1000)"
}

if ($problems.Count -gt 0) {
    Write-Status "FAIL" "ПРОБЛЕМЫ:" $Red
    foreach ($problem in $problems) {
        Write-Host "  • $problem" -ForegroundColor Yellow
    }
} else {
    Write-Status "OK" "Проблем не обнаружено" $Green
}

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Аудит заверён" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
