# 🛡️ RAM DISK CLEANUP — АВТОМАТИЧЕСКАЯ ОЧИСТКА

**Версия:** 1.0  
**Дата:** 4 марта 2026 г.  
**Назначение:** Предотвращение переполнения R:\Temp

---

## 📋 ПРОБЛЕМА

**R:\Temp переполняется:**
- VS Code temp files (*.tmp.ico)
- Chrome BITS downloads
- Docker tar extracts
- Installation logs
- Node.js cache

**Решение:** Автоматическая очистка по расписанию

---

## 🔧 СКРИПТ 1: cleanup-ramdisk.ps1

```powershell
# 03-Resources/PowerShell/cleanup-ramdisk.ps1
# Автоматическая очистка R:\Temp

param(
    [switch]$WhatIf,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$TempPath = "R:\Temp"

Write-Host "╔══════════════════════════════════════════════════════════╗"
Write-Host "║         ОЧИСТКА RAM ДИСКА (R:\Temp)                      ║"
Write-Host "╚══════════════════════════════════════════════════════════╝"

# Счётчики
$deletedCount = 0
$deletedSize = 0

# 1. VS Code temp files
Write-Host "`n[1/6] VS Code temp files (*.tmp.ico)..."
$files = Get-ChildItem $TempPath -Filter "*.tmp.ico" -ErrorAction SilentlyContinue
foreach ($file in $files) {
    if ($WhatIf) {
        Write-Host "  [WhatIf] $($file.Name)" -ForegroundColor Yellow
    } else {
        Remove-Item $file.FullName -Force
        $deletedSize += $file.Length
    }
    $deletedCount++
}

# 2. Chrome BITS downloads
Write-Host "`n[2/6] Chrome BITS downloads..."
$folders = Get-ChildItem $TempPath -Filter "chrome_BITS_*" -Directory -ErrorAction SilentlyContinue
foreach ($folder in $folders) {
    if ($WhatIf) {
        Write-Host "  [WhatIf] $($folder.Name)" -ForegroundColor Yellow
    } else {
        $folderSize = (Get-ChildItem $folder.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        $deletedSize += $folderSize
        Remove-Item $folder.FullName -Recurse -Force
    }
    $deletedCount++
}

# 3. Docker tar extracts
Write-Host "`n[3/6] Docker tar extracts..."
$folders = Get-ChildItem $TempPath -Filter "docker-tar-extract*" -Directory -ErrorAction SilentlyContinue
foreach ($folder in $folders) {
    if ($WhatIf) {
        Write-Host "  [WhatIf] $($folder.Name)" -ForegroundColor Yellow
    } else {
        $folderSize = (Get-ChildItem $folder.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        $deletedSize += $folderSize
        Remove-Item $folder.FullName -Recurse -Force
    }
    $deletedCount++
}

# 4. Installation logs (dd_*.log)
Write-Host "`n[4/6] Installation logs (dd_*.log)..."
$files = Get-ChildItem $TempPath -Filter "dd_*.log" -ErrorAction SilentlyContinue
foreach ($file in $files) {
    if ($WhatIf) {
        Write-Host "  [WhatIf] $($file.Name)" -ForegroundColor Yellow
    } else {
        Remove-Item $file.FullName -Force
        $deletedSize += $file.Length
    }
    $deletedCount++
}

# 5. Node.js compile cache
Write-Host "`n[5/6] Node.js compile cache..."
$folders = Get-ChildItem $TempPath -Filter "node-compile-cache" -Directory -ErrorAction SilentlyContinue
foreach ($folder in $folders) {
    if ($WhatIf) {
        Write-Host "  [WhatIf] $($folder.Name)" -ForegroundColor Yellow
    } else {
        $folderSize = (Get-ChildItem $folder.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        $deletedSize += $folderSize
        Remove-Item $folder.FullName -Recurse -Force
    }
    $deletedCount++
}

# 6. Старые файлы (>7 дней)
Write-Host "`n[6/6] Старые файлы (>7 дней)..."
$cutoff = (Get-Date).AddDays(-7)
$files = Get-ChildItem $TempPath -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cutoff }
foreach ($file in $files) {
    if ($WhatIf) {
        Write-Host "  [WhatIf] $($file.Name) ($([math]::Round(($cutoff - $_.LastWriteTime).TotalDays, 0)) дн.)" -ForegroundColor Yellow
    } else {
        Remove-Item $file.FullName -Force
        $deletedSize += $file.Length
    }
    $deletedCount++
}

# Итоги
Write-Host "`n╔══════════════════════════════════════════════════════════╗"
Write-Host "║                    ИТОГИ                                 ║"
Write-Host "╚══════════════════════════════════════════════════════════╝"
Write-Host "Удалено объектов: $deletedCount" -ForegroundColor Cyan
Write-Host "Освобождено места: $([math]::Round($deletedSize / 1MB, 2)) MB" -ForegroundColor Cyan

if ($WhatIf) {
    Write-Host "`nЭто пробный запуск. Для реальной очистки:" -ForegroundColor Yellow
    Write-Host "  .\scripts\cleanup-ramdisk.ps1" -ForegroundColor Gray
}
```

---

## 📋 СКРИПТ 2: set-ramdisk-size.ps1

```powershell
# 03-Resources/PowerShell/set-ramdisk-size.ps1
# Изменение размера RAM диска

param(
    [int]$SizeMB = 24576,  # 24 GB по умолчанию
    [switch]$Restart
)

Write-Host "╔══════════════════════════════════════════════════════════╗"
Write-Host "║         ИЗМЕНЕНИЕ РАЗМЕРА RAM ДИСКА                      ║"
Write-Host "╚══════════════════════════════════════════════════════════╝"

# Проверка ImDisk
try {
    $imdisk = Get-Command imdisk -ErrorAction Stop
} catch {
    Write-Host "❌ ImDisk не найден!" -ForegroundColor Red
    Write-Host "Установите: https://www.ltr-data.se/opencode.html/#ImDisk"
    exit 1
}

# Удаление текущего диска
Write-Host "`n[1/3] Удаление текущего RAM диска..."
imdisk -D -m R:
Write-Host "  ✅ Удалено" -ForegroundColor Green

# Создание нового
Write-Host "`n[2/3] Создание нового RAM диска ($SizeMB MB)..."
imdisk -a -s ${SizeMB}M -m R: -p "/fs:ntfs"
Write-Host "  ✅ Создано" -ForegroundColor Green

# Проверка
Write-Host "`n[3/3] Проверка..."
Start-Sleep -Seconds 2
$disk = Get-PSDrive R -ErrorAction SilentlyContinue
if ($disk) {
    Write-Host "  ✅ RAM диск R: доступен" -ForegroundColor Green
    Write-Host "  Размер: $([math]::Round($disk.Capacity / 1GB, 2)) GB" -ForegroundColor Cyan
    Write-Host "  Свободно: $([math]::Round($disk.Free / 1GB, 2)) GB" -ForegroundColor Cyan
} else {
    Write-Host "  ⚠️ Диск не найден" -ForegroundColor Yellow
}

Write-Host "`n╔══════════════════════════════════════════════════════════╗"
Write-Host "║                    ГОТОВО                                ║"
Write-Host "╚══════════════════════════════════════════════════════════╝"

if ($Restart) {
    Write-Host "`n⚠️ Требуется перезагрузка для применения изменений" -ForegroundColor Yellow
}
```

---

## 📋 СКРИПТ 3: Task Scheduler

```powershell
# 03-Resources/PowerShell/register-ramdisk-cleanup.ps1
# Регистрация задачи в Task Scheduler

$taskName = "RamDiskCleanup"
$scriptPath = "D:\QwenPoekt\Base\03-Resources\PowerShell\cleanup-ramdisk.ps1"

# Действие
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`" -AutoConfirm"

# Триггер (каждый день в 03:00)
$trigger = New-ScheduledTaskTrigger -Daily -At 3am

# Настройки
$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -RunOnlyIfNetworkAvailable:$false `
    -StartWhenAvailable

# Регистрация
Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Description "Автоматическая очистка R:\Temp" `
    -Force

Write-Host "✅ Задача '$taskName' зарегистрирована" -ForegroundColor Green
Write-Host "   Расписание: Ежедневно в 03:00" -ForegroundColor Cyan
```

---

## 🚀 БЫСТРЫЙ СТАРТ

### 1. Увеличить RAM диск до 24 GB

```powershell
# Запустить скрипт
.\03-Resources\PowerShell\set-ramdisk-size.ps1 -SizeMB 24576
```

### 2. Настроить автоматическую очистку

```powershell
# Зарегистрировать задачу
.\03-Resources\PowerShell\register-ramdisk-cleanup.ps1

# Проверить задачу
Get-ScheduledTask RamDiskCleanup
```

### 3. Ручная очистка (по нужде)

```powershell
# Пробный запуск
.\03-Resources\PowerShell\cleanup-ramdisk.ps1 -WhatIf

# Реальная очистка
.\03-Resources\PowerShell\cleanup-ramdisk.ps1
```

---

## 📊 МОНИТОРИНГ

### Проверка статуса

```powershell
# Статус RAM диска
Get-PSDrive R | Select-Object Name, Used, Free, Capacity

# Статус задачи
Get-ScheduledTask RamDiskCleanup | Select-Object TaskName, State, LastRunTime
```

### Логирование

```powershell
# Добавить логирование в cleanup-ramdisk.ps1
.\cleanup-ramdisk.ps1 -Verbose | Out-File R:\cleanup.log
```

---

## 📋 ПРАВИЛА ПРЕДОТВРАЩЕНИЯ

### 1. VS Code

**Настройки (settings.json):**
```json
{
  "temp.cleanup.enabled": true,
  "temp.cleanup.age": 7
}
```

### 2. Chrome

**Очистка кэша:**
- Настройки → Конфиденциальность → Очистить историю
- Включить "Кэшированные изображения и файлы"

### 3. Docker

**Очистка:**
```powershell
docker system prune -a --volumes
```

### 4. Node.js

**Очистка кэша:**
```powershell
npm cache clean --force
```

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- `03-Resources/PowerShell/cleanup-ramdisk.ps1` — Очистка
- `03-Resources/PowerShell/set-ramdisk-size.ps1` — Изменение размера
- `03-Resources/PowerShell/register-ramdisk-cleanup.ps1` — Автозапуск
- `reports/RAMDISK_INCREASE_GUIDE.md` — Инструкция

---

**Создано:** 4 марта 2026 г.  
**Статус:** ✅ Готово к использованию

---

**Автоматическая очистка предотвратит будущее переполнение!** 🛡️
