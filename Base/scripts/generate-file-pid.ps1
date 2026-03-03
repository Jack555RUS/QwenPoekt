# generate-file-pid.ps1 — Генерация PID для файлов
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Уникальные идентификаторы для файлов

param(
    [string]$Path,           # Путь к файлу/папке
    [string]$Type = "FILE",  # Тип: FILE, DIR, DOC, SCRIPT
    [switch]$Recursive,      # Рекурсивно для папок
    [switch]$UpdateRegistry, # Обновить реестр
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Пути
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$RegistryPath = Join-Path $BasePath "reports\FILE_PID_REGISTRY.md"

# ----------------------------------------------------------------------------
# ФУНКЦИИ
# ----------------------------------------------------------------------------

function Get-ShortHash {
    param([string]$Input)
    $hash = [System.Security.Cryptography.SHA256]::Create()
    $bytes = $hash.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Input))
    $shortHash = [System.BitConverter]::ToString($bytes[0..3]).Replace("-", "").ToLower()
    $hash.Dispose()
    return $shortHash
}

function Generate-PID {
    param(
        [string]$Path,
        [string]$Type
    )
    
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $hash = Get-ShortHash -Input ($Path + $timestamp)
    
    return "${Type}_${hash}_${timestamp}"
}

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host $Message -ForegroundColor $Color
}

# ----------------------------------------------------------------------------
# ОСНОВНАЯ ЛОГИКА
# ----------------------------------------------------------------------------

try {
    Write-Log "╔══════════════════════════════════════════════════════════╗"
    Write-Log "║         ГЕНЕРАЦИЯ PID ДЛЯ ФАЙЛОВ $(Get-Date -Format 'HH:mm:ss')        ║"
    Write-Log "╚══════════════════════════════════════════════════════════╝"
    
    # Проверка пути
    if (-not $Path) {
        throw "Путь не указан"
    }
    
    if (-not (Test-Path $Path)) {
        throw "Путь не найден: $Path"
    }
    
    $results = @()
    
    # Обработка папки (рекурсивно)
    if ((Get-Item $Path) -is [System.IO.DirectoryInfo] -and $Recursive) {
        Write-Log "[1/3] Рекурсивная обработка папки..."
        
        $files = Get-ChildItem -Path $Path -Recurse -File
        Write-Log "  📊 Найдено файлов: $($files.Count)"
        
        foreach ($file in $files) {
            $filePid = Generate-PID -Path $file.FullName -Type "FILE"
            $results += @{
                PID = $filePid
                Path = $file.FullName
                Type = "FILE"
                Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            }
            
            if ($Verbose) {
                Write-Log "  ✅ $($file.Name) → $filePid" -Color "Gray"
            }
        }
    }
    # Обработка одного файла/папки
    else {
        Write-Log "[1/3] Генерация PID..."
        
        $item = Get-Item $Path
        $itemType = if ($item -is [System.IO.DirectoryInfo]) { "DIR" } else { "FILE" }
        
        $filePid = Generate-PID -Path $item.FullName -Type $Type
        
        $results += @{
            PID = $filePid
            Path = $item.FullName
            Type = $itemType
            Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
        
        Write-Log "  ✅ PID: $filePid"
    }
    
    # Обновление реестра
    if ($UpdateRegistry) {
        Write-Log "[2/3] Обновление реестра..."
        
        $registryHeader = @"
# 📁 FILE PID REGISTRY

**Дата создания:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Последнее обновление:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

---

## ФАЙЛЫ

| PID | Путь | Тип | Дата |
|-----|------|-----|------|

"@
        
        if (Test-Path $RegistryPath) {
            # Чтение существующего реестра
            $existing = Get-Content $RegistryPath -Raw
            
            # Добавление новых записей
            foreach ($result in $results) {
                $line = "| $($result.PID) | $($result.Path) | $($result.Type) | $($result.Date) |`n"
                $existing += $line
            }
            
            $existing | Out-File -FilePath $RegistryPath -Encoding UTF8
        } else {
            # Создание нового реестра
            $registryContent = $registryHeader
            foreach ($result in $results) {
                $registryContent += "| $($result.PID) | $($result.Path) | $($result.Type) | $($result.Date) |`n"
            }
            $registryContent | Out-File -FilePath $RegistryPath -Encoding UTF8
        }
        
        Write-Log "  ✅ Реестр обновлён: $RegistryPath"
    }
    
    # Создание .pid файлов (для важных)
    Write-Log "[3/3] Создание .pid файлов..."
    
    foreach ($result in $results) {
        $pidFilePath = $result.Path + ".pid"
        $pidContent = @{
            PID = $result.PID
            OriginalPath = $result.Path
            Type = $result.Type
            GeneratedAt = $result.Date
        } | ConvertTo-Json
        
        $pidContent | Out-File -FilePath $pidFilePath -Encoding UTF8
        
        if ($Verbose) {
            Write-Log "  ✅ Создан: $pidFilePath" -Color "Gray"
        }
    }
    
    Write-Log "  ✅ .pid файлы созданы"
    
    # ----------------------------------------------------------------------------
    # ИТОГ
    # ----------------------------------------------------------------------------
    
    Write-Log "╔══════════════════════════════════════════════════════════╗"
    Write-Log "║              ГЕНЕРАЦИЯ PID ЗАВЕРШЕНА ✅                  ║"
    Write-Log "╚══════════════════════════════════════════════════════════╝"
    Write-Log ""
    Write-Log "📊 Результаты:"
    Write-Log "  • Сгенерировано PID: $($results.Count)"
    Write-Log "  • Реестр: $RegistryPath"
    Write-Log "  • .pid файлов: $($results.Count)"
    Write-Log ""
    
    if (-not $Verbose) {
        Write-Log "📌 Используйте -Verbose для подробностей"
    }
    
} catch {
    Write-Log "❌ ОШИБКА: $($_.Exception.Message)" -Color "Red"
    exit 1
}
