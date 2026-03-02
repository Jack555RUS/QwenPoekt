# auto-full-backup.ps1 — Автоматическая полная копия Base
# Версия: 1.0
# Дата: 3 марта 2026 г.
# Назначение: Копирование Base/ в _BACKUP/ каждые 10 минут

param(
    [switch]$Verbose
)

$ErrorActionPreference = "SilentlyContinue"

# Пути
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$BackupRoot = Join-Path $BasePath "_BACKUP\Auto_Full"

# Создание папки бэкапа
if (-not (Test-Path $BackupRoot)) {
    New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
}

# Формирование имени папки бэкапа
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$BackupPath = Join-Path $BackupRoot "Base_$timestamp"

# Исключаемые папки
$ExcludeDirs = @("_TEMP", "sessions", "_LOCAL_ARCHIVE", "_BACKUP", "PROJECTS", "OLD", "RELEASE", "KNOWLEDGE_BASE")

# Формирование команды robocopy
$RobocopyArgs = @(
    $BasePath,
    $BackupPath,
    "/MIR",           # Зеркалирование
    "/Z",             # Режим перезапуска
    "/R:2",           # 2 попытки при ошибке
    "/W:5",           # 5 секунд между попытками
    "/MT:8",          # 8 потоков
    "/NP",            # Без прогресса
    "/NFL",           # Без имён файлов
    "/NDL",           # Без имён каталогов
    "/NS",            # Без размеров
    "/NC",            # Без классов
    "/NJS",           # Без сводки
    "/NJH",           # Без заголовка
    "/XD",            # Исключить папки
    ($ExcludeDirs -join " "),
    "/XF",            # Исключить файлы
    "*.tmp", "*.log", "*.cache"
)

# Запуск robocopy
$job = Start-Job -ScriptBlock {
    param($args)
    & robocopy.exe $args
} -ArgumentList $RobocopyArgs

# Ожидание завершения
$job | Wait-Job | Out-Null
$job | Remove-Job

# Логирование
$logEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Бэкап: $BasePath → $BackupPath"
Add-Content -Path "$BackupRoot\backup.log" -Value $logEntry

if ($Verbose) {
    Write-Host "✅ Бэкап создан: $BackupPath" -ForegroundColor Green
}
