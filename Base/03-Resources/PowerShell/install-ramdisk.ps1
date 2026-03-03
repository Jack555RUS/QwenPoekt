# install-ramdisk.ps1 — Установка и настройка RAM диска
# Версия: 1.0
# Дата: 2 марта 2026 г.
# Назначение: Создание RAM диска 16 GB для временных файлов

param(
    [int]$SizeMB = 16384,  # Размер RAM диска (16 GB по умолчанию)
    [string]$DriveLetter = "R",  # Буква диска
    [switch]$AutoConfirm
)

$ErrorActionPreference = "Stop"
$ConfirmPreference = "None"

Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         УСТАНОВКА RAM ДИСКА (16 GB)                      ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 1. ПРОВЕРКА ДОСТУПНОЙ ПАМЯТИ
# ============================================

Write-Host "[1/6] Проверка доступной памяти..." -ForegroundColor Cyan

$TotalRAM = (Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB
$FreeRAM = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB

Write-Host "  Всего RAM: $([Math]::Round($TotalRAM, 2)) GB" -ForegroundColor Gray
Write-Host "  Свободно RAM: $([Math]::Round($FreeRAM, 2)) GB" -ForegroundColor Gray

if ($FreeRAM -lt ($SizeMB / 1024)) {
    Write-Host "  ⚠️  Недостаточно свободной памяти!" -ForegroundColor Yellow
    Write-Host "  Требуется: $([Math]::Round($SizeMB / 1024, 2)) GB" -ForegroundColor Yellow
    Write-Host "  Продолжить? (Y/N)" -ForegroundColor Yellow
    if (-not $AutoConfirm) {
        $response = Read-Host
        if ($response -ne 'Y' -and $response -ne 'y') {
            Write-Host "  ❌ Отменено пользователем" -ForegroundColor Red
            exit 0
        }
    }
} else {
    Write-Host "  ✅ Достаточно памяти" -ForegroundColor Green
}

# ============================================
# 2. ПРОВЕРКА IMDISK
# ============================================

Write-Host ""
Write-Host "[2/6] Проверка ImDisk Toolkit..." -ForegroundColor Cyan

$ImDiskPath = "C:\Program Files\ImDisk\DiscUtils\ImDiskNet.dll"
$ImDiskExe = "C:\Program Files\ImDisk\imdisk.exe"

if (Test-Path $ImDiskPath) {
    Write-Host "  ✅ ImDisk установлен" -ForegroundColor Green
} else {
    Write-Host "  ❌ ImDisk не найден" -ForegroundColor Red
    Write-Host ""
    Write-Host "  📥 Установка ImDisk:" -ForegroundColor Yellow
    Write-Host "  1. Скачайте с: https://sourceforge.net/projects/imdisk-toolkit/" -ForegroundColor Gray
    Write-Host "  2. Установите ImDisk Virtual Disk Driver" -ForegroundColor Gray
    Write-Host "  3. Запустите этот скрипт снова" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Или установить через winget:" -ForegroundColor Yellow
    Write-Host "  winget install ImDiskToolkit" -ForegroundColor Gray
    Write-Host ""
    
    # Предложить установку
    if (-not $AutoConfirm) {
        Write-Host "  Установить через winget? (Y/N)" -ForegroundColor Yellow
        $response = Read-Host
        if ($response -eq 'Y' -or $response -eq 'y') {
            Write-Host "  📥 Установка..." -ForegroundColor Cyan
            winget install ImDiskToolkit --silent
            Write-Host "  ✅ Установка завершена" -ForegroundColor Green
            Write-Host "  ⚠️  Требуется перезагрузка!" -ForegroundColor Yellow
            exit 0
        } else {
            exit 0
        }
    }
}

# ============================================
# 3. СОЗДАНИЕ RAM ДИСКА
# ============================================

Write-Host ""
Write-Host "[3/6] Создание RAM диска..." -ForegroundColor Cyan

# Проверка существующего диска
$ExistingDisk = Get-Volume | Where-Object { $_.DriveLetter -eq $DriveLetter }
if ($ExistingDisk) {
    Write-Host "  ⚠️  Диск $DriveLetter уже существует" -ForegroundColor Yellow
    Write-Host "  Удаляем старый? (Y/N)" -ForegroundColor Yellow
    if ($AutoConfirm -or (Read-Host) -eq 'Y') {
        Remove-Volume -DriveLetter $DriveLetter -Confirm:$false -ErrorAction SilentlyContinue
        Write-Host "  ✅ Старый диск удалён" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Отменено" -ForegroundColor Red
        exit 0
    }
}

# Создание команды ImDisk
$CreateCommand = "& `"$ImDiskExe`" -a -s ${SizeMB}M -m ${DriveLetter}: -p `"/fs:ntfs /q /y`""

Write-Host "  Размер: ${SizeMB} MB ($([Math]::Round($SizeMB / 1024, 2)) GB)" -ForegroundColor Gray
Write-Host "  Буква: ${DriveLetter}:" -ForegroundColor Gray
Write-Host "  Файловая система: NTFS" -ForegroundColor Gray

try {
    Invoke-Expression $CreateCommand
    Start-Sleep -Seconds 2
    Write-Host "  ✅ RAM диск создан" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Ошибка создания: $_" -ForegroundColor Red
    exit 1
}

# ============================================
# 4. НАСТРОЙКА ПЕРЕМЕННЫХ СРЕДЫ
# ============================================

Write-Host ""
Write-Host "[4/6] Настройка переменных среды..." -ForegroundColor Cyan

$TempPath = "${DriveLetter}:\Temp"
$NpmCachePath = "${DriveLetter}:\npm-cache"
$VSCodePath = "${DriveLetter}:\VSCode"

# Создание папок
New-Item -ItemType Directory -Path $TempPath -Force | Out-Null
New-Item -ItemType Directory -Path $NpmCachePath -Force | Out-Null
New-Item -ItemType Directory -Path $VSCodePath -Force | Out-Null

Write-Host "  ✅ Созданы папки:" -ForegroundColor Green
Write-Host "     $TempPath" -ForegroundColor Gray
Write-Host "     $NpmCachePath" -ForegroundColor Gray
Write-Host "     $VSCodePath" -ForegroundColor Gray

# Настройка переменных среды (текущая сессия)
$env:TEMP = $TempPath
$env:TMP = $TempPath
$env:NODE_OPTIONS = "--max-old-space-size=32768"

# Настройка переменных среды (постоянно)
[Environment]::SetEnvironmentVariable("TEMP", $TempPath, "User")
[Environment]::SetEnvironmentVariable("TMP", $TempPath, "User")

Write-Host "  ✅ Переменные среды настроены" -ForegroundColor Green
Write-Host "     TEMP = $TempPath" -ForegroundColor Gray
Write-Host "     TMP = $TempPath" -ForegroundColor Gray

# ============================================
# 5. НАСТРОЙКА NPM
# ============================================

Write-Host ""
Write-Host "[5/6] Настройка NPM..." -ForegroundColor Cyan

try {
    npm config set cache $NpmCachePath
    npm config set prefix "${DriveLetter}:\npm-global"
    Write-Host "  ✅ NPM кэш перемещён на RAM диск" -ForegroundColor Green
    Write-Host "     cache = $NpmCachePath" -ForegroundColor Gray
} catch {
    Write-Host "  ⚠️  Ошибка настройки NPM: $_" -ForegroundColor Yellow
}

# ============================================
# 6. СОЗДАНИЕ СКРИПТА ОЧИСТКИ
# ============================================

Write-Host ""
Write-Host "[6/6] Создание скрипта очистки..." -ForegroundColor Cyan

$CleanupScript = @"
# cleanup-ramdisk.ps1 — Очистка RAM диска при завершении работы
# Запускается автоматически при выключении компьютера

`$TempPath = "${DriveLetter}:\Temp"
if (Test-Path `$TempPath) {
    Get-ChildItem `$TempPath -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "RAM диск очищен" -ForegroundColor Green
}
"@

$CleanupScriptPath = "D:\QwenPoekt\Base\scripts\cleanup-ramdisk.ps1"
$CleanupScript | Out-File -FilePath $CleanupScriptPath -Encoding UTF8

Write-Host "  ✅ Скрипт очистки создан: $CleanupScriptPath" -ForegroundColor Green

# ============================================
# ИТОГ
# ============================================

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          ✅ RAM ДИСК УСТАНОВЛЕН УСПЕШНО!                 ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 Результаты:" -ForegroundColor Yellow
Write-Host "  ✅ RAM диск: ${DriveLetter}: ($([Math]::Round($SizeMB / 1024, 2)) GB)" -ForegroundColor Gray
Write-Host "  ✅ TEMP перемещён на RAM диск" -ForegroundColor Gray
Write-Host "  ✅ NPM кэш на RAM диске" -ForegroundColor Gray
Write-Host "  ✅ Скрипт очистки создан" -ForegroundColor Gray

Write-Host ""
Write-Host "🔄 Следующие шаги:" -ForegroundColor Yellow
Write-Host "  1. Перезапустите PowerShell (для применения TEMP)" -ForegroundColor Gray
Write-Host "  2. Перезапустите VS Code (для применения настроек)" -ForegroundColor Gray
Write-Host "  3. Проверьте: echo `$env:TEMP" -ForegroundColor Gray

Write-Host ""
Write-Host "📁 Проверка:" -ForegroundColor Cyan
Write-Host "  Get-Volume | Where-Object DriveLetter -EQ '$DriveLetter'" -ForegroundColor Gray
Write-Host "  echo `$env:TEMP" -ForegroundColor Gray

Write-Host ""
Write-Host "⚠️  Важно:" -ForegroundColor Yellow
Write-Host "  - Данные на RAM диске удаляются при выключении!" -ForegroundColor Gray
Write-Host "  - Не сохраняйте важные файлы на ${DriveLetter}:" -ForegroundColor Gray
Write-Host ""
