# pre-change-backup.ps1 — Бэкап перед изменением файлов
# Версия: 1.0
# Дата: 2 марта 2026 г.
# Назначение: Автоматический бэкап файлов перед изменением

param(
    [string]$FilePath,           # Путь к файлу
    [string]$Operation = "Edit", # Тип операции
    [switch]$NoConfirm
)

$ErrorActionPreference = "SilentlyContinue"

# Пути
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$BackupRoot = Join-Path $BasePath "_BACKUP\Pre_Change"

# Создание папки бэкапа
if (-not (Test-Path $BackupRoot)) {
    New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
}

# Бэкап файла
if (Test-Path $FilePath) {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $fileName = Split-Path $FilePath -Leaf
    $backupPath = Join-Path $BackupRoot "${fileName}_${timestamp}"
    
    Copy-Item $FilePath $backupPath -Force
    
    # Лог
    $logEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Operation: $FilePath → $backupPath"
    Add-Content -Path "$BackupRoot\backup.log" -Value $logEntry
}
