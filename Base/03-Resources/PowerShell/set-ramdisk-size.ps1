# set-ramdisk-size.ps1 — Изменение размера RAM диска
# Версия: 1.0
# Дата: 4 марта 2026 г.

param(
    [int]$SizeMB = 24576,  # 24 GB по умолчанию
    [switch]$NoRestart
)

Write-Host "╔══════════════════════════════════════════════════════════╗"
Write-Host "║         ИЗМЕНЕНИЕ РАЗМЕРА RAM ДИСКА                      ║"
Write-Host "╚══════════════════════════════════════════════════════════╝"

# Проверка ImDisk
try {
    $imdisk = Get-Command imdisk -ErrorAction Stop
    Write-Host "`n✅ ImDisk найден" -ForegroundColor Green
} catch {
    Write-Host "`n❌ ImDisk не найден!" -ForegroundColor Red
    Write-Host "Установите: https://www.ltr-data.se/opencode.html/#ImDisk"
    exit 1
}

# Удаление текущего диска
Write-Host "`n[1/2] Удаление текущего RAM диска..."
try {
    imdisk -D -m R: 2>$null
    Write-Host "  ✅ Удалено" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️ Не найдено или не удалено" -ForegroundColor Yellow
}

# Создание нового
Write-Host "`n[2/2] Создание нового RAM диска ($SizeMB MB = $([math]::Round($SizeMB/1024, 1)) GB)..."
try {
    $result = imdisk -a -s ${SizeMB}M -m R: -p "/fs:ntfs" 2>&1
    Write-Host "  ✅ Создано" -ForegroundColor Green
    Write-Host "  $result" -ForegroundColor Gray
} catch {
    Write-Host "  ❌ Ошибка: $_" -ForegroundColor Red
    exit 1
}

# Проверка
Write-Host "`n[3/3] Проверка..."
Start-Sleep -Seconds 2

try {
    $disk = Get-PSDrive R -ErrorAction Stop
    Write-Host "  ✅ RAM диск R: доступен" -ForegroundColor Green
    Write-Host "  Размер: $([math]::Round($disk.Capacity / 1GB, 2)) GB" -ForegroundColor Cyan
    Write-Host "  Свободно: $([math]::Round($disk.Free / 1GB, 2)) GB" -ForegroundColor Cyan
} catch {
    Write-Host "  ⚠️ Диск не найден. Попробуйте переподключить." -ForegroundColor Yellow
}

Write-Host "`n╔══════════════════════════════════════════════════════════╗"
Write-Host "║                    ГОТОВО                                ║"
Write-Host "╚══════════════════════════════════════════════════════════╝"

if (-not $NoRestart) {
    Write-Host "`n⚠️ Рекомендуется перезагрузка для применения изменений" -ForegroundColor Yellow
    $response = Read-Host "Перезагрузить сейчас? (Y/N)"
    if ($response -eq 'Y' -or $response -eq 'y') {
        Restart-Computer -Force
    }
}
