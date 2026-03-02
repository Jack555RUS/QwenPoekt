# end-session.ps1 — Завершение сессии
# Версия: 1.0
# Дата: 2 марта 2026 г.
# Назначение: Автоматическое создание SESSION_HANDOVER.md и архивация

param(
    [string]$Reason = "Session end",
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
Write-Info "║         ЗАВЕРШЕНИЕ СЕССИИ $(Get-Date -Format 'yyyy-MM-dd HH:mm')          ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"

# Пути
$BasePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ReportsPath = Join-Path $BasePath "reports"
$SessionHandoverPath = Join-Path $ReportsPath "SESSION_HANDOVER.md"
$GitPath = Join-Path $BasePath ".git"

# Проверка Git
Write-Info "[1/5] Проверка Git репозитория..."
if (Test-Path $GitPath) {
    Write-Success "  ✅ Git репозиторий найден"
} else {
    Write-Error "  ❌ Git репозиторий не найден"
    exit 1
}

# Получение статуса Git
Write-Info "[2/5] Получение статуса Git..."
$GitStatus = git status --porcelain 2>$null
$UncommittedChanges = $GitStatus | Measure-Object | Select-Object -ExpandProperty Count

if ($UncommittedChanges -gt 0) {
    Write-Warning "  ⚠️ Найдено $UncommittedChanges незакоммиченных изменений"
    Write-Info "  Рекомендуется закоммитить перед завершением сессии"
} else {
    Write-Success "  ✅ Нет незакоммиченных изменений"
}

# Создание SESSION_HANDOVER.md
Write-Info "[3/5] Создание SESSION_HANDOVER.md..."

$SessionData = @{
    Date = Get-Date -Format "yyyy-MM-dd HH:mm"
    EndDate = Get-Date -Format "yyyy-MM-dd HH:mm"
    Reason = $Reason
    UncommittedChanges = $UncommittedChanges
    GitBranch = git branch --show-current 2>$null
    GitLog = (git log -n 3 --oneline 2>$null) -join "`n"
}

$SessionHandoverContent = @"
# 📋 SESSION HANDOVER — Передача Сессии

**Дата создания:** $($SessionData.Date)  
**Причина:** $($SessionData.Reason)  
**Статус:** ⏳ Открыта / ✅ Закрыта

---

## 🎯 ТЕКУЩЕЕ СОСТОЯНИЕ

### Git статус
- **Ветка:** $($SessionData.GitBranch)
- **Незакоммиченные изменения:** $($SessionData.UncommittedChanges)
- **Последние коммиты:**
``````
$($SessionData.GitLog)
``````

---

## 📋 АКТИВНЫЕ ЗАДАЧИ

| Задача | Статус | Приоритет | Комментарий |
|--------|--------|-----------|-------------|
| [Задача 1] | ⏳ В работе | 🟡 Средний | [Описание] |
| [Задача 2] | ⏳ В работе | 🔴 Высокий | [Описание] |

---

## 🔄 ПРОДОЛЖЕНИЕ С НАЧАЛА

### Что нужно сделать при старте следующей сессии:

1. **Прочитать этот файл** → понять текущее состояние
2. **Проверить `ТЕКУЩАЯ_ЗАДАЧА.md`** → активные задачи
3. **Проверить `AGENTS.md`** → точка входа
4. **Восстановить контекст** → продолжить с задачи

---

## 📚 ВАЖНЫЕ ФАЙЛЫ СЕССИИ

### Создано/Изменено:
- [Файл 1] — [Описание изменений]
- [Файл 2] — [Описание изменений]

### Требует внимания:
- [Файл] — [Что нужно сделать]

---

## ⚠️ ПРОБЛЕМЫ/ОШИБКИ

### Зафиксированные ошибки:
| Ошибка | Статус | Решение |
|--------|--------|---------|
| [Описание] | ⏳ Не исправлено | [План] |

### Извлечённые уроки:
- [Урок 1]
- [Урок 2]

---

## 🎯 ПЛАН НА СЛЕДУЮЩУЮ СЕССИЮ

### Приоритетные задачи:
1. [Задача 1]
2. [Задача 2]
3. [Задача 3]

### Отложенные задачи:
- [Задача]

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`AGENTS.md`](./AGENTS.md) — Точка входа
- [`ТЕКУЩАЯ_ЗАДАЧА.md`](./ТЕКУЩАЯ_ЗАДАЧА.md) — Активная задача
- [`ERROR_LOG.md`](./ERROR_LOG.md) — Журнал ошибок
- [`ANTI_PATTERNS.md`](./ANTI_PATTERNS.md) — Анти-паттерны

---

**Следующая сессия:** Начать с чтения этого файла и `AGENTS.md`

---

**Создано:** $($SessionData.Date)  
**Скрипт:** `end-session.ps1`
"@

# Создание файла
try {
    if (-not (Test-Path $ReportsPath)) {
        New-Item -ItemType Directory -Path $ReportsPath -Force | Out-Null
        Write-Success "  ✅ Создана папка reports/"
    }
    
    $SessionHandoverContent | Out-File -FilePath $SessionHandoverPath -Encoding UTF8NoBOM
    Write-Success "  ✅ SESSION_HANDOVER.md создан"
} catch {
    Write-Error "  ❌ Ошибка создания SESSION_HANDOVER.md: $_"
    exit 1
}

# Архивация сессии
Write-Info "[4/5] Архивация сессии..."

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
        "PRE_ACTION_CHECKLIST.md"
    )
    
    $SessionArchivePath = Join-Path $ArchivePath (Get-Date -Format "yyyy-MM-dd_HH-mm")
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

# Коммит (опционально)
if (-not $NoCommit) {
    Write-Info "[5/5] Создание коммита..."
    
    try {
        git add $SessionHandoverPath 2>$null
        git commit -m "Add: SESSION_HANDOVER.md — завершение сессии ($Reason)" 2>$null
        
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

# Итог
Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Success "║                  СЕССИЯ ЗАВЕРШЕНА ✅                     ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""
Write-Info "📄 SESSION_HANDOVER.md создан: $SessionHandoverPath"
Write-Info "📦 Архив сессии: $SessionArchivePath"
Write-Host ""
Write-Info "Для продолжения следующей сессии:"
Write-Info "  1. Прочитать SESSION_HANDOVER.md"
Write-Info "  2. Прочитать AGENTS.md"
Write-Info "  3. Продолжить с задачи"
Write-Host ""
