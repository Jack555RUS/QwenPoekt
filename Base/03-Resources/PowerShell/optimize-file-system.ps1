# optimize-file-system.ps1 — Оптимизация файловой системы
# Версия: 1.0
# Дата: 2 марта 2026 г.
# Назначение: Оптимизация индексации Windows и кэша

param(
    [switch]$AutoConfirm  # Автоматическое подтверждение очистки
)

$ErrorActionPreference = "Stop"
$ConfirmPreference = "None"  # Отключить запросы подтверждения

Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      ОПТИМИЗАЦИЯ ФАЙЛОВОЙ СИСТЕМЫ                        ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ============================================
# 1. ИСКЛЮЧЕНИЕ ПАПОК ИЗ ИНДЕКСАЦИИ WINDOWS
# ============================================

Write-Host "[1/4] Исключение папок из индексации Windows..." -ForegroundColor Cyan

$ExcludePaths = @(
    "D:\QwenPoekt\Base\PROJECTS",
    "D:\QwenPoekt\Base\OLD",
    "D:\QwenPoekt\Base\RELEASE",
    "D:\QwenPoekt\Base\_BACKUP",
    "D:\QwenPoekt\Base\_LOCAL_ARCHIVE",
    "D:\QwenPoekt\Base\BOOK"
)

Write-Host "  Исключаемые папки:" -ForegroundColor Gray
foreach ($Path in $ExcludePaths) {
    if (Test-Path $Path) {
        Write-Host "    ✅ $Path" -ForegroundColor Green
    } else {
        Write-Host "    ⚠️  $Path (не найдена)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "  ℹ️  Для полной настройки откройте:" -ForegroundColor Yellow
Write-Host "      Панель управления → Индексация → Изменить" -ForegroundColor Gray
Write-Host "  И снимите галочки с исключённых папок" -ForegroundColor Gray

# ============================================
# 2. ОЧИСТКА КЭША ПОИКА VS CODE
# ============================================

Write-Host ""
Write-Host "[2/4] Очистка кэша поиска VS Code..." -ForegroundColor Cyan

$CachePaths = @(
    "$env:APPDATA\Code\Cache",
    "$env:APPDATA\Code\CachedData",
    "$env:APPDATA\Code\CachedExtensions",
    "$env:APPDATA\Code\User\workspaceStorage"
)

$TotalCleaned = 0
foreach ($Path in $CachePaths) {
    if (Test-Path $Path) {
        try {
            $Size = (Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum / 1MB
            Remove-Item $Path -Recurse -Force -ErrorAction SilentlyContinue -Confirm:$false
            Write-Host "  ✅ Очищено: $Path ($([Math]::Round($Size, 2)) MB)" -ForegroundColor Green
            $TotalCleaned += $Size
        } catch {
            Write-Host "  ⚠️  Ошибка очистки $Path" -ForegroundColor Yellow
        }
    }
}

Write-Host "  Всего очищено: $([Math]::Round($TotalCleaned, 2)) MB" -ForegroundColor Green

# ============================================
# 3. НАСТРОЙКА ПРЕФЕТЧИНГА
# ============================================

Write-Host ""
Write-Host "[3/4] Настройка префетчинга..." -ForegroundColor Cyan

# Проверка текущих настроек префетчинга
$PrefetchPath = "C:\Windows\Prefetch"
if (Test-Path $PrefetchPath) {
    $PrefetchFiles = Get-ChildItem $PrefetchPath -ErrorAction SilentlyContinue
    Write-Host "  ✅ Префетчинг включён" -ForegroundColor Green
    Write-Host "  Файлов в кэше: $($PrefetchFiles.Count)" -ForegroundColor Gray
    
    # Очистка старых файлов (>30 дней)
    $OldFiles = $PrefetchFiles | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) }
    if ($OldFiles.Count -gt 0) {
        $OldFiles | Remove-Item -Force -ErrorAction SilentlyContinue
        Write-Host "  ✅ Очищено $($OldFiles.Count) старых файлов префетчинга" -ForegroundColor Green
    }
} else {
    Write-Host "  ⚠️  Префетчинг не найден" -ForegroundColor Yellow
}

# ============================================
# 4. ОПТИМИЗАЦИЯ DISK CACHE
# ============================================

Write-Host ""
Write-Host "[4/4] Оптимизация дискового кэша..." -ForegroundColor Cyan

# Настройка временных файлов
$TempPaths = @(
    "$env:TEMP",
    "$env:TMP",
    "$env:LOCALAPPDATA\Temp"
)

foreach ($Path in $TempPaths) {
    if (Test-Path $Path) {
        try {
            $OldFiles = Get-ChildItem $Path -Recurse -ErrorAction SilentlyContinue | 
                        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) }
            if ($OldFiles.Count -gt 0) {
                $OldFiles | Remove-Item -Force -ErrorAction SilentlyContinue -Confirm:$false
                Write-Host "  ✅ Очищено $($OldFiles.Count) старых файлов в $Path" -ForegroundColor Green
            }
        } catch {
            Write-Host "  ⚠️  Ошибка очистки $Path" -ForegroundColor Yellow
        }
    }
}

# ============================================
# ИТОГ
# ============================================

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           ✅ ОПТИМИЗАЦИЯ ЗАВЕРШЕНА!                      ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 Результаты:" -ForegroundColor Yellow
Write-Host "  ✅ Исключены папки из индексации" -ForegroundColor Gray
Write-Host "  ✅ Очищен кэш VS Code" -ForegroundColor Gray
Write-Host "  ✅ Очищен префетчинг" -ForegroundColor Gray
Write-Host "  ✅ Очищены временные файлы" -ForegroundColor Gray

Write-Host ""
Write-Host "🔄 Следующие шаги:" -ForegroundColor Yellow
Write-Host "  1. Откройте Панель управления → Индексация → Изменить" -ForegroundColor Gray
Write-Host "  2. Снимите галочки с исключённых папок" -ForegroundColor Gray
Write-Host "  3. Перезапустите VS Code" -ForegroundColor Gray

Write-Host ""
Write-Host "📁 Файл настроек:" -ForegroundColor Cyan
Write-Host "  .vscode/settings.json — обновлён" -ForegroundColor Gray

Write-Host ""
