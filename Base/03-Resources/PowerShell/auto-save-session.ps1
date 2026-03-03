# auto-save-session.ps1 — Автосохранение контекста сессии
# Версия: 1.0
# Дата: 2 марта 2026 г.
# Назначение: Автоматическое сохранение контекста при выходе/перезагрузке

param(
    [string]$Reason = "User exit",
    [string]$CurrentTask = "",
    [string]$NextStep = "",
    [switch]$NoCommit,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Цвета вывода
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║         АВТОСОХРАНЕНИЕ СЕССИИ $(Get-Date -Format 'yyyy-MM-dd HH:mm')        ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"

# Пути
$BasePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ReportsPath = Join-Path $BasePath "reports"
$SessionHandoverPath = Join-Path $ReportsPath "SESSION_HANDOVER.md"
$GitPath = Join-Path $BasePath ".git"
$CurrentTaskPath = Join-Path $BasePath "ТЕКУЩАЯ_ЗАДАЧА.md"
$ErrorLogPath = Join-Path $BasePath "ERROR_LOG.md"

# ============================================
# 1. СБОР ИНФОРМАЦИИ О СЕССИИ
# ============================================

Write-Info "[1/5] Сбор информации о сессии..."

# Git статус (с подавлением предупреждений)
try {
    $GitBranch = git branch --show-current 2>&1 | Out-String
    $GitBranch = ($GitBranch -split "`n" | Where-Object { $_ -notmatch "^warning:" }) -join "`n"
    $GitLog = (git log -n 5 --oneline 2>&1 | Where-Object { $_ -notmatch "^warning:" }) -join "`n"
    $GitStatusOutput = git status --porcelain 2>&1 | Where-Object { $_ -notmatch "^warning:" }
    $UncommittedChanges = ($GitStatusOutput | Measure-Object).Count
    $RecentFiles = (git diff HEAD --name-only 2>&1 | Where-Object { $_ -notmatch "^warning:" } | Select-Object -First 10) -join "`n"
} catch {
    $GitBranch = "unknown"
    $GitLog = "Git error"
    $UncommittedChanges = 0
    $RecentFiles = ""
}

# Активные задачи из ТЕКУЩАЯ_ЗАДАЧА.md
$ActiveTasks = @()
if (Test-Path $CurrentTaskPath) {
    $Content = Get-Content $CurrentTaskPath -Raw
    if ($Content -match '(?s)## 🎯 АКТИВНЫЕ ЗАДАЧИ.*?(?=##|\Z)') {
        $ActiveTasksSection = $matches[0]
        $ActiveTasks = ($ActiveTasksSection -split '\n' | Where-Object { $_ -match '^\|.*\|$' -and $_ -notmatch '\|--------\|' }) | Select-Object -First 5
    }
}

Write-Success "  ✅ Информация собрана"
if ($Verbose) {
    Write-Info "  📊 Ветка: $GitBranch"
    Write-Info "  📝 Изменений: $UncommittedChanges"
    Write-Info "  📋 Задач: $($ActiveTasks.Count)"
}

# ============================================
# 2. СОЗДАНИЕ SESSION_HANDOVER.md v2
# ============================================

Write-Info "[2/5] Создание SESSION_HANDOVER.md v2..."

$SessionData = @{
    Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Reason = $Reason
    CurrentTask = $CurrentTask
    NextStep = $NextStep
    GitBranch = $GitBranch
    UncommittedChanges = $UncommittedChanges
    GitLog = $GitLog
    RecentFiles = ($RecentFiles -join "`n")
    ActiveTasks = ($ActiveTasks -join "`n")
}

$SessionHandoverContent = @"
# 📋 SESSION HANDOVER — Передача Сессии

**Дата создания:** $($SessionData.Date)
**Причина:** $($SessionData.Reason)
**Статус:** ⏳ Требует продолжения

---

## 🔄 ТОЧКА ВОЗОБОВЛЕНИЯ

**Последняя задача:** $($SessionData.CurrentTask)
**Текущий шаг:** $($SessionData.NextStep)
**Следующее действие:** [Определяется при восстановлении]

---

## 🎯 ТЕКУЩЕЕ СОСТОЯНИЕ

### Git статус
- **Ветка:** $($SessionData.GitBranch)
- **Незакоммиченные изменения:** $($SessionData.UncommittedChanges)
- **Последние коммиты:**
``````
$($SessionData.GitLog)
``````

### Последние изменённые файлы:
``````
$($SessionData.RecentFiles)
``````

---

## 📋 АКТИВНЫЕ ЗАДАЧИ

$($SessionData.ActiveTasks)

---

## 🔄 ПРОДОЛЖЕНИЕ С НАЧАЛА

### Что нужно сделать при старте следующей сессии:

1. **Прочитать этот файл** → понять текущее состояние
2. **Запустить команду** `/resume` → автоматическое восстановление
3. **Или прочитать вручную:**
   - \`ТЕКУЩАЯ_ЗАДАЧА.md\` → активные задачи
   - \`ERROR_LOG.md\` → проблемы сессии
   - \`AGENTS.md\` → точка входа

### Команды восстановления:

| Команда | Описание |
|---------|----------|
| **`/resume`** | Автоматическое восстановление контекста |
| **`/status`** | Показать статус сессии |
| **`/continue`** | Продолжить с последней задачи |

---

## 📚 ВАЖНЫЕ ФАЙЛЫ СЕССИИ

### Создано/Изменено:
- [Автоматически заполняется при восстановлении]

### Требует внимания:
- [Автоматически заполняется при восстановлении]

---

## ⚠️ ПРОБЛЕМЫ/ОШИБКИ

### Зафиксированные ошибки:
| Ошибка | Статус | Решение |
|--------|--------|---------|
| [Заполняется при восстановлении из ERROR_LOG.md] |

### Извлечённые уроки:
- [Заполняется при восстановлении]

---

## 🎯 ПЛАН НА СЛЕДУЮЩУЮ СЕССИЮ

### Приоритетные задачи:
1. [Автоматически из ТЕКУЩАЯ_ЗАДАЧА.md]
2. [Автоматически из ТЕКУЩАЯ_ЗАДАЧА.md]
3. [Автоматически из ТЕКУЩАЯ_ЗАДАЧА.md]

### Отложенные задачи:
- [Автоматически из ТЕКУЩАЯ_ЗАДАЧА.md]

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [\`AGENTS.md\`](./AGENTS.md) — Точка входа
- [\`ТЕКУЩАЯ_ЗАДАЧА.md\`](./ТЕКУЩАЯ_ЗАДАЧА.md) — Активная задача
- [\`ERROR_LOG.md\`](./ERROR_LOG.md) — Журнал ошибок
- [\`ANTI_PATTERNS.md\`](./ANTI_PATTERNS.md) — Анти-паттерны
- [\`PRE_ACTION_CHECKLIST.md\`](./PRE_ACTION_CHECKLIST.md) — Чек-лист

---

## 📊 МЕТАДАННЫЕ

**Создано:** $($SessionData.Date)
**Скрипт:** \`auto-save-session.ps1\`
**Версия формата:** 2.0 (Hybrid)
**Путь к файлу:** \`$SessionHandoverPath\`

---

**Следующая сессия:** Начать с команды `/resume` или чтения этого файла
"@

# Создание файла
try {
    if (-not (Test-Path $ReportsPath)) {
        New-Item -ItemType Directory -Path $ReportsPath -Force | Out-Null
        Write-Success "  ✅ Создана папка reports/"
    }

    $SessionHandoverContent | Out-File -FilePath $SessionHandoverPath -Encoding utf8
    Write-Success "  ✅ SESSION_HANDOVER.md v2 создан"
} catch {
    Write-Error "  ❌ Ошибка создания SESSION_HANDOVER.md: $_"
    exit 1
}

# ============================================
# 3. АРХИВАЦИЯ СЕССИИ
# ============================================

Write-Info "[3/5] Архивация сессии..."

$ArchivePath = Join-Path $BasePath "_LOCAL_ARCHIVE"
$SessionArchivePath = Join-Path $ArchivePath (Get-Date -Format "yyyy-MM-dd_HH-mm")

try {
    if (-not (Test-Path $ArchivePath)) {
        New-Item -ItemType Directory -Path $ArchivePath -Force | Out-Null
    }

    # Копирование важных файлов
    $FilesToArchive = @(
        "AGENTS.md",
        "ERROR_LOG.md",
        "ANTI_PATTERNS.md",
        "PRE_ACTION_CHECKLIST.md",
        "ТЕКУЩАЯ_ЗАДАЧА.md"
    )

    if (-not (Test-Path $SessionArchivePath)) {
        New-Item -ItemType Directory -Path $SessionArchivePath -Force | Out-Null
    }

    foreach ($File in $FilesToArchive) {
        $SourcePath = Join-Path $BasePath $File
        if (Test-Path $SourcePath) {
            Copy-Item -Path $SourcePath -Destination $SessionArchivePath -Force
            if ($Verbose) {
                Write-Info "  📄 Скопировано: $File"
            }
        }
    }

    Write-Success "  ✅ Сессия заархивирована в $SessionArchivePath"
} catch {
    Write-Warning "  ⚠️ Ошибка архивации: $_"
}

# ============================================
# 4. СОЗДАНИЕ МАРКЕРА ВОССТАНОВЛЕНИЯ
# ============================================

Write-Info "[4/5] Создание маркера восстановления..."

$ResumeMarkerPath = Join-Path $BasePath ".resume_marker.json"
$ResumeMarker = @{
    Date = $SessionData.Date
    Reason = $SessionData.Reason
    CurrentTask = $SessionData.CurrentTask
    NextStep = $SessionData.NextStep
    SessionFile = $SessionHandoverPath
    GitCommit = (git rev-parse HEAD 2>$null)
} | ConvertTo-Json -Depth 3

try {
    $ResumeMarker | Out-File -FilePath $ResumeMarkerPath -Encoding utf8
    Write-Success "  ✅ Маркер восстановления создан"
    if ($Verbose) {
        Write-Info "  📄 Путь: $ResumeMarkerPath"
    }
} catch {
    Write-Warning "  ⚠️ Ошибка создания маркера: $_"
}

# ============================================
# 5. КОММИТ (ОПЦИОНАЛЬНО)
# ============================================

if (-not $NoCommit) {
    Write-Info "[5/5] Создание коммита..."

    try {
        git add $SessionHandoverPath $ResumeMarkerPath 2>$null
        $CommitMessage = "Add: SESSION_HANDOVER.md — автосохранение сессии ($Reason)"
        git commit -m $CommitMessage 2>$null

        if ($LASTEXITCODE -eq 0) {
            Write-Success "  ✅ Коммит создан"
        } else {
            Write-Warning "  ⚠️ Нет изменений для коммита"
        }
    } catch {
        Write-Warning "  ⚠️ Ошибка коммита: $_"
    }
} else {
    Write-Info "[5/5] Пропуск коммита (флаг -NoCommit)"
}

# ============================================
# ИТОГ
# ============================================

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Success "║           АВТОСОХРАНЕНИЕ ЗАВЕРШЕНО ✅                  ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""
Write-Info "📄 SESSION_HANDOVER.md: $SessionHandoverPath"
Write-Info "📦 Архив сессии: $SessionArchivePath"
Write-Info "🔖 Маркер: $ResumeMarkerPath"
Write-Host ""
Write-Info "Для продолжения следующей сессии:"
Write-Info "  1. Открыть AI_START_HERE.md или AGENTS.md"
Write-Info "  2. Использовать команду /resume"
Write-Info "  3. Или прочитать SESSION_HANDOVER.md вручную"
Write-Host ""
