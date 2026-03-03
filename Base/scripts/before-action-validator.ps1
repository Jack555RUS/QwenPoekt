# before-action-validator.ps1 — Валидатор действий перед выполнением
# Версия: 1.0
# Дата: 2026-03-04
# Назначение: Проверка соответствия правилам ПЕРЕД действием

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("delete", "move", "rename", "create", "modify")]
    [string]$Action,

    [Parameter(Mandatory=$true)]
    [string]$Target,

    [switch]$DryRun,
    [switch]$ShowDetails
)

$ErrorActionPreference = "Stop"

# ----------------------------------------------------------------------------
# ЦВЕТА ВЫВОДА
# ----------------------------------------------------------------------------

function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

# ----------------------------------------------------------------------------
# ФУНКЦИИ
# ----------------------------------------------------------------------------

function Find-FilesWithLinks {
    param($targetPath)
    
    $targetName = Split-Path $targetPath -Leaf
    $files = Get-ChildItem -Path "Base" -Recurse -Filter "*.md" -File
    
    $dependents = @()
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw
        if ($content -match [regex]::Escape($targetName)) {
            $dependents += $file.FullName
        }
    }
    
    return $dependents
}

function Get-GitCreator {
    param($targetPath)
    
    if (Test-Path $targetPath) {
        $creator = git log --reverse --format="%an <%ae> on %ad" -- $targetPath | Select-Object -First 1
        return $creator
    }
    return "Неизвестно (файл не существует)"
}

function Get-LastAccessTime {
    param($targetPath)
    
    if (Test-Path $targetPath) {
        $item = Get-Item $targetPath
        return $item.LastAccessTime
    }
    return "Н/Д"
}

function Calculate-Risk {
    param($dependents, $lastUsed)
    
    $risk = "Low"
    
    if ($dependents.Count -gt 5) {
        $risk = "High"
    } elseif ($dependents.Count -gt 0) {
        $risk = "Medium"
    }
    
    if ($lastUsed -lt (Get-Date).AddDays(-30)) {
        if ($risk -eq "Low") { $risk = "Medium" }
    }
    
    return $risk
}

function Check-Rules {
    param($action, $target, $impact)
    
    $violations = @()
    
    # Правило A-003: Не удалять без проверки
    if ($action -eq "delete" -and $impact.Dependents.Count -gt 0) {
        $violations += "A-003: Удаление файла с зависимостями ($($impact.Dependents.Count) ссылок)"
    }
    
    # Правило A-002: Не создавать напрямую в Base/
    if ($action -eq "create" -and $target -match "Base/[^/]+$" -and $target -notmatch "_drafts|_TEST_ENV") {
        $violations += "A-002: Создание файла напрямую в Base/ (должно быть _drafts/ → _TEST_ENV/ → Base/)"
    }
    
    # Правило: Не перемещать без анализа
    if ($action -eq "move" -and $impact.Dependents.Count -gt 0) {
        $violations += "PRE-MOVE: Перемещение файла с зависимостями (требуется update-links-after-move.ps1)"
    }
    
    # Правило: Encoding
    if ($action -eq "create" -and $target -match "\.(ps1|bat|cmd|json|yaml|yml)$") {
        Write-Warning "⚠️  Проверьте encoding: UTF-8 без BOM"
    }
    
    return $violations
}

function Log-Action {
    param($action, $target, $result, $violations)
    
    $logDir = "logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    $logFile = Join-Path $logDir "actions.log"
    
    $logEntry = [PSCustomObject]@{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Action = $action
        Target = $target
        Result = $result
        Violations = $violations -join ", "
        SessionId = $env:SESSION_ID -or "unknown"
        User = $env:USERNAME
    }
    
    $logEntry | ConvertTo-Json -Compress | Add-Content $logFile -Encoding UTF8
}

# ----------------------------------------------------------------------------
# ОСНОВНАЯ ЛОГИКА
# ----------------------------------------------------------------------------

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║      ВАЛИДАТОР ДЕЙСТВИЙ $(Get-Date -Format 'HH:mm:ss')                   ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

Write-Info "Действие: $Action"
Write-Info "Цель: $Target"
Write-Host ""

# 1. АНАЛИЗ ПОСЛЕДСТВИЙ
Write-Info "[1/3] Анализ последствий..."

$impact = @{
    Dependents = @()
    Creator = ""
    LastUsed = ""
    RiskLevel = "Unknown"
}

if (Test-Path $Target) {
    $impact.Dependents = Find-FilesWithLinks -targetPath $Target
    $impact.Creator = Get-GitCreator -targetPath $Target
    $impact.LastUsed = Get-LastAccessTime -targetPath $Target
    $impact.RiskLevel = Calculate-Risk -dependents $impact.Dependents -lastUsed $impact.LastUsed
    
    Write-Success "  ✅ Файл существует"
    Write-Host "  Создатель: $($impact.Creator)" -ForegroundColor Gray
    Write-Host "  Последнее использование: $($impact.LastUsed)" -ForegroundColor Gray
    Write-Host "  Зависимости: $($impact.Dependents.Count) файлов" -ForegroundColor Gray
    Write-Host "  Уровень риска: $($impact.RiskLevel)" -ForegroundColor $(if($impact.RiskLevel -eq "High"){"Red"}elseif($impact.RiskLevel -eq "Medium"){"Yellow"}else{"Green"})
} else {
    Write-Warning "  ⚠️  Файл не существует"
    
    if ($action -eq "delete" -or $action -eq "modify") {
        Write-Error "❌ Невозможно: файл не найден"
        exit 1
    }
}

Write-Host ""

# 2. ПРОВЕРКА ПРАВИЛ
Write-Info "[2/3] Проверка соблюдения правил..."

$violations = Check-Rules -action $Action -target $Target -impact $impact

if ($violations.Count -gt 0) {
    Write-Error "❌ Нарушения правил:"
    foreach ($violation in $violations) {
        Write-Host "  • $violation" -ForegroundColor Red
    }
    Write-Host ""
    
    Log-Action -action $Action -target $Target -result "BLOCKED" -violations $violations
    
    if (-not $DryRun) {
        exit 1
    }
} else {
    Write-Success "  ✅ Нарушений нет"
}

Write-Host ""

# 3. РЕКОМЕНДАЦИИ
Write-Info "[3/3] Рекомендации..."

if ($impact.RiskLevel -eq "High") {
    Write-Warning "  ⚠️  ВЫСОКИЙ РИСК:"
    Write-Host "    • Создайте бэкап: git add . && git commit -m 'Backup: ...'" -ForegroundColor Yellow
    Write-Host "    • Проверьте зависимости вручную" -ForegroundColor Yellow
    Write-Host "    • Рассмотрите возможность архивирования вместо удаления" -ForegroundColor Yellow
}

if ($action -eq "delete" -and $impact.Dependents.Count -eq 0) {
    Write-Success "  ✅ Безопасно для удаления (нет зависимостей)"
}

if ($action -eq "move") {
    Write-Info "  ℹ️  После перемещения запустите:"
    Write-Host "    .\scripts\update-links-after-move.ps1 -OldPath '$Target' -NewPath '<новый путь>'" -ForegroundColor Cyan
}

Write-Host ""

# 4. ЛОГИРОВАНИЕ
Log-Action -action $Action -target $Target -result "APPROVED" -violations @()

if ($DryRun) {
    Write-Success "╔══════════════════════════════════════════════════════════╗"
    Write-Success "║              DRY-RUN: НАРУШЕНИЙ НЕТ ✅                   ║"
    Write-Success "╚══════════════════════════════════════════════════════════╝"
} else {
    Write-Success "╔══════════════════════════════════════════════════════════╗"
    Write-Success "║              ВАЛИДАЦИЯ ПРОЙДЕНА ✅                       ║"
    Write-Success "╚══════════════════════════════════════════════════════════╝"
}

Write-Host ""
Write-Info "Действие может быть выполнено."

exit 0
