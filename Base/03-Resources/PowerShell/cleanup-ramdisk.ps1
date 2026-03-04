# cleanup-ramdisk.ps1 — Автоматическая очистка R:\Temp
# Версия: 1.0
# Дата: 4 марта 2026 г.

param(
    [switch]$WhatIf,
    [switch]$Verbose,
    [switch]$AutoConfirm
)

$ErrorActionPreference = "Stop"
$TempPath = "R:\Temp"

Write-Host "╔══════════════════════════════════════════════════════════╗"
Write-Host "║         ОЧИСТКА RAM ДИСКА (R:\Temp)                      ║"
Write-Host "╚══════════════════════════════════════════════════════════╝"

# Счётчики
$deletedCount = 0
$deletedSize = 0

function Remove-TempFiles {
    param($Filter, $Description)
    
    Write-Host "`n[$deletedCount/6] $Description..."
    $items = Get-ChildItem $TempPath -Filter $Filter -ErrorAction SilentlyContinue
    
    foreach ($item in $items) {
        try {
            if ($item.PSIsContainer) {
                $itemSize = (Get-ChildItem $item.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            } else {
                $itemSize = $item.Length
            }
            
            if ($WhatIf) {
                Write-Host "  [WhatIf] $($item.Name)" -ForegroundColor Yellow
            } else {
                Remove-Item $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
                $deletedSize += $itemSize
            }
            $deletedCount++
        } catch {
            Write-Host "  ⚠️ Ошибка: $($item.Name) - $_" -ForegroundColor Red
        }
    }
}

# 1. VS Code temp files
Remove-TempFiles -Filter "*.tmp.ico" -Description "VS Code temp files"

# 2. Chrome BITS
Remove-TempFiles -Filter "chrome_BITS_*" -Description "Chrome BITS downloads"

# 3. Docker tar
Remove-TempFiles -Filter "docker-tar-extract*" -Description "Docker tar extracts"

# 4. Installation logs
Remove-TempFiles -Filter "dd_*.log" -Description "Installation logs"

# 5. Node.js cache
Remove-TempFiles -Filter "node-compile-cache" -Description "Node.js compile cache"

# 6. Старые файлы (>7 дней)
Write-Host "`n[6/6] Старые файлы (>7 дней)..."
$cutoff = (Get-Date).AddDays(-7)
$files = Get-ChildItem $TempPath -File -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cutoff }
foreach ($file in $files) {
    if ($WhatIf) {
        Write-Host "  [WhatIf] $($file.Name)" -ForegroundColor Yellow
    } else {
        Remove-Item $file.FullName -Force -ErrorAction SilentlyContinue
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
    Write-Host "  .\cleanup-ramdisk.ps1" -ForegroundColor Gray
}
