# rename-to-kebab-case.ps1 — Массовое переименование в kebab-case
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Автоматическое переименование файлов в kebab-case

param(
    [string]$Path = "02-Areas/Documentation",
    [switch]$WhatIf,           # Сухой запуск (без переименования)
    [switch]$Verbose,
    [switch]$Log
)

$ErrorActionPreference = "Stop"

# Логирование
$logPath = "reports\rename-kebab-case.log"
if ($Log) {
    "═══════════════════════════════════════════════════════════" | Out-File -FilePath $logPath -Append -Encoding UTF8
    "Начало переименования: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $logPath -Append -Encoding UTF8
    "═══════════════════════════════════════════════════════════" | Out-File -FilePath $logPath -Append -Encoding UTF8
}

function Write-Log {
    param($msg, $color = "Cyan")
    if ($Log) {
        $msg | Out-File -FilePath $logPath -Append -Encoding UTF8
    }
    Write-Host $msg -ForegroundColor $color
}

# Функция преобразования в kebab-case
function ConvertTo-KebabCase {
    param([string]$Name)
    
    # Удаляем расширение
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($Name)
    $extension = [System.IO.Path]::GetExtension($Name)
    
    # Преобразуем в нижний регистр
    $kebab = $baseName.ToLower()
    
    # Заменяем подчёркивания на дефисы
    $kebab = $kebab -replace '_', '-'
    
    # Заменяем множественные дефисы на одинарные
    $kebab = $kebab -replace '-+', '-'
    
    # Удаляем дефисы в начале и конце
    $kebab = $kebab.Trim('-')
    
    return $kebab + $extension
}

Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║         ПЕРЕИМЕНОВАНИЕ В KEBAB-CASE $(Get-Date -Format 'HH:mm:ss')          ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""

# Получаем файлы
$files = Get-ChildItem -Path $Path -Filter "*.md"

Write-Log "Найдено файлов: $($files.Count)"
Write-Log "Путь: $Path"
$whatIfText = if ($WhatIf) { "Да" } else { "Нет" }
Write-Log "Сухой запуск: $whatIfText"
Write-Log ""

# Счётчики
$renamedCount = 0
$skippedCount = 0
$errorCount = 0

# Переименование
foreach ($file in $files) {
    $oldName = $file.Name
    $newName = ConvertTo-KebabCase -Name $oldName
    
    # Пропускаем если имя не изменилось
    if ($oldName -eq $newName) {
        if ($Verbose) {
            Write-Log "  ✅ $oldName (уже kebab-case)" "Green"
        }
        $skippedCount++
        continue
    }
    
    # Проверка на существующий файл
    $newPath = Join-Path $file.DirectoryName $newName
    if (Test-Path $newPath) {
        Write-Log "  ⚠️  $oldName → ПРОПУЩЕНО (файл $newName уже существует)" "Yellow"
        if ($Log) {
            "  ⚠️  $oldName → ПРОПУЩЕНО (файл $newName уже существует)" | Out-File -FilePath $logPath -Append -Encoding UTF8
        }
        $skippedCount++
        continue
    }
    
    # Переименование
    if ($WhatIf) {
        Write-Log "  [WhatIf] $oldName → $newName" "Yellow"
        if ($Log) {
            "  [WhatIf] $oldName → $newName" | Out-File -FilePath $logPath -Append -Encoding UTF8
        }
    } else {
        try {
            Rename-Item -Path $file.FullName -NewName $newName -Force
            Write-Log "  ✅ $oldName → $newName" "Green"
            if ($Log) {
                "  ✅ $oldName → $newName" | Out-File -FilePath $logPath -Append -Encoding UTF8
            }
            $renamedCount++
        } catch {
            Write-Log "  ❌ $oldName → ОШИБКА: $($_.Exception.Message)" "Red"
            if ($Log) {
                "  ❌ $oldName → ОШИБКА: $($_.Exception.Message)" | Out-File -FilePath $logPath -Append -Encoding UTF8
            }
            $errorCount++
        }
    }
}

# Итоги
Write-Log ""
Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║                    ИТОГИ                                 ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""
Write-Log "Переименовано: $renamedCount" "Cyan"
Write-Log "Пропущено: $skippedCount" "Cyan"
Write-Log "Ошибок: $errorCount" $(if ($errorCount -gt 0) { "Red" } else { "Cyan" })
Write-Log ""

if ($Log) {
    "═══════════════════════════════════════════════════════════" | Out-File -FilePath $logPath -Append -Encoding UTF8
    "Итоги:" | Out-File -FilePath $logPath -Append -Encoding UTF8
    "  Переименовано: $renamedCount" | Out-File -FilePath $logPath -Append -Encoding UTF8
    "  Пропущено: $skippedCount" | Out-File -FilePath $logPath -Append -Encoding UTF8
    "  Ошибок: $errorCount" | Out-File -FilePath $logPath -Append -Encoding UTF8
    "═══════════════════════════════════════════════════════════" | Out-File -FilePath $logPath -Append -Encoding UTF8
}

# Выход
if ($errorCount -gt 0) {
    exit 1
} else {
    exit 0
}
