# generate-file-pid.ps1 — Генерация PID для файлов
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Уникальные идентификаторы для файлов проекта

param(
    [string]$Path = ".",           # Путь для сканирования
    [string]$OutputPath = "reports\FILE_PID_REGISTRY.md",  # Выходной файл
    [switch]$Recursive,            # Рекурсивно
    [switch]$UpdateRegistry,       # Обновить реестр
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# ----------------------------------------------------------------------------
# ФУНКЦИИ
# ----------------------------------------------------------------------------

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host $Message -ForegroundColor $Color
}

function Get-FilePID {
    param([string]$FilePath)
    
    # Формат: PID_YYYYMMDDHHMMSS_HASH8
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $hash = [System.Security.Cryptography.SHA256]::Create()
    $bytes = $hash.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($FilePath + $timestamp))
    $shortHash = [System.BitConverter]::ToString($bytes[0..3]).Replace("-", "").ToLower()
    $hash.Dispose()
    
    return "PID_${timestamp}_${shortHash}"
}

function Get-RelativePath {
    param([string]$FullPath)
    $basePath = (Get-Item ".").FullName
    return $FullPath.Replace($basePath + "\", "")
}

# ----------------------------------------------------------------------------
# ОСНОВНАЯ ЛОГИКА
# ----------------------------------------------------------------------------

Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║         ГЕНЕРАЦИЯ PID ДЛЯ ФАЙЛОВ $(Get-Date -Format 'HH:mm:ss')           ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""

# Параметры
$getParams = @{
    Path = $Path
    ErrorAction = "SilentlyContinue"
}

if ($Recursive) {
    $getParams.Recurse = $true
}

Write-Log "Путь: $Path"
$recursiveText = if ($Recursive) { "Да" } else { "Нет" }
Write-Log "Рекурсивно: $recursiveText"
Write-Log "Выходной файл: $OutputPath"
Write-Log ""

# Сбор файлов
Write-Log "[1/3] Сбор файлов..."
$files = Get-ChildItem @getParams -File | Where-Object { $_.Extension -in @('.md', '.ps1', '.json', '.cs', '.unity') }
Write-Log "  Найдено файлов: $($files.Count)"
Write-Log ""

# Генерация PID
Write-Log "[2/3] Генерация PID..."
$registry = @()

foreach ($file in $files) {
    $filePid = Get-FilePID -FilePath $file.FullName
    $relativePath = Get-RelativePath -FullPath $file.FullName
    
    $registry += @{
        PID = $filePid
        Path = $relativePath
        Type = $file.Extension.TrimStart('.')
        Size = $file.Length
        Modified = $file.LastWriteTime
    }
    
    if ($Verbose) {
        Write-Log "  ✅ $($relativePath) → $filePid" -Color "Green"
    }
}

Write-Log "  Сгенерировано PID: $($registry.Count)"
Write-Log ""

# Запись в реестр
if ($UpdateRegistry) {
    Write-Log "[3/3] Запись в реестр..."
    
    $report = @"
# 📁 FILE PID REGISTRY — РЕЕСТР ИДЕНТИФИКАТОРОВ ФАЙЛОВ

**Дата создания:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Всего файлов:** $($registry.Count)

---

## 📋 ФАЙЛЫ

| PID | Путь | Тип | Размер (KB) | Изменён |
|-----|------|-----|-------------|---------|
"@
    
    foreach ($entry in $registry | Sort-Object Path) {
        $sizeKB = [Math]::Round($entry.Size / 1KB, 2)
        $modified = $entry.Modified.ToString("yyyy-MM-dd")
        $report += "| $($entry.PID) | $($entry.Path) | $($entry.Type) | $sizeKB | $modified |`n"
    }
    
    $report += @"

---

## 🔍 ПОИСК

### По PID:
```powershell
Get-Content reports\FILE_PID_REGISTRY.md | Select-String "PID_20260303"
```

### По пути:
```powershell
Get-Content reports\FILE_PID_REGISTRY.md | Select-String "scripts/"
```

---

## 📊 СТАТИСТИКА

| Тип файлов | Количество |
|------------|------------|
"@
    
    $byType = $registry | Group-Object Type | Sort-Object Count -Descending
    foreach ($group in $byType) {
        $report += "| **$($group.Name)** | $($group.Count) |`n"
    }
    
    $report += @"

---

**Сгенерировано:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** generate-file-pid.ps1
"@
    
    $report | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Log "  ✅ Реестр сохранён: $OutputPath" -Color "Green"
} else {
    Write-Log "[Пропущено] Запись в реестр (используйте -UpdateRegistry)"
}

Write-Log ""

# ----------------------------------------------------------------------------
# ИТОГ
# ----------------------------------------------------------------------------

Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║                    ИТОГИ                                 ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""
Write-Log "Сгенерировано PID: $($registry.Count)" -Color "Cyan"

if ($UpdateRegistry) {
    Write-Log "Реестр: $OutputPath" -Color "Cyan"
}

Write-Log ""
Write-Log "Пример использования:" -Color "Yellow"
Write-Log "  .\scripts\generate-file-pid.ps1 -Path `"Base/`" -Recursive -UpdateRegistry" -Color "Gray"
Write-Log ""
