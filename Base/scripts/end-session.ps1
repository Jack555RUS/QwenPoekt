# ============================================================================
# ЗАВЕРШЕНИЕ СЕССИИ
# ============================================================================
# Назначение: Автоматическое завершение сессии по команде
# Использование: .\scripts\end-session.ps1
# ============================================================================

$ErrorActionPreference = "Continue"
$BasePath = "D:\QwenPoekt\Base"
$ReportsPath = "$BasePath\reports"
$LogPath = "$ReportsPath\OPERATION_LOG.md"

# ============================================================================
# ФУНКЦИИ
# ============================================================================

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Get-GitStatus {
    $status = git status --porcelain
    return ($status | Measure-Object).Count
}

function Get-FileCount {
    param([string]$Path)
    return (Get-ChildItem $Path -Recurse -File).Count
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ЗАВЕРШЕНИЕ СЕССИИ ===" "Yellow"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Проверка изменений
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Проверка изменений..."
    $filesChanged = Get-GitStatus
    Write-Log "Изменено файлов: $filesChanged" "Gray"
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Git add + коммит
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Git коммит..."
    
    if ($filesChanged -gt 0) {
        git add . 2>&1 | Out-Null
        
        $commitMsg = "End: Завершение сессии $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        
        # Игнорируем предупреждения Git (warnings не являются ошибками)
        $WarningPreference = 'SilentlyContinue'
        git commit -m $commitMsg 2>&1 | Where-Object { $_ -notlike 'warning:*' } | Out-Null
        
        $hash = (git log -n 1 --oneline).Split(' ')[0]
        Write-Log "Git коммит: $hash" "Green"
    } else {
        Write-Log "Нет изменений для коммита" "Gray"
        $hash = "N/A"
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Обновление OPERATION_LOG.md
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Обновление OPERATION_LOG.md..."
    
    $entry = @"

## $(Get-Date -Format 'yyyy-MM-dd HH:mm') ЗАВЕРШЕНИЕ СЕССИИ

**Тип:** Автоматическое завершение

**Статус:** ✅ ЗАВЕРШЕНО

---
"@
    
    Add-Content -Path $LogPath -Value $entry -Encoding UTF8
    Write-Log "OPERATION_LOG.md обновлён" "Green"
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Создание отчёта
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Создание отчёта..."
    
    $reportPath = "$ReportsPath\SESSION_$(Get-Date -Format 'yyyy-MM-dd_HH-mm').md"
    
    $report = @"
# Отчёт сессии

**Дата завершения:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Статус:** ✅ Завершено

---

## Итоги

**Git коммит:** $hash
**Изменено файлов:** $filesChanged
**Всего файлов:** $(Get-FileCount -Path $BasePath)
**Всего коммитов:** $(git rev-list --count HEAD)

---

**Сессия завершена!** 🎉
"@
    
    $report | Out-File $reportPath -Encoding UTF8
    Write-Log "Отчёт: $reportPath" "Green"
    
    # ------------------------------------------------------------------------
    # ШАГ 5: Финальная статистика
    # ------------------------------------------------------------------------
    Write-Log "Шаг 5: Статистика..."
    
    Write-Host ""
    Write-Log "=== ИТОГИ СЕССИИ ===" "Yellow"
    Write-Host ""
    Write-Host "  Изменено файлов: $filesChanged" -ForegroundColor White
    Write-Host "  Git коммит: $hash" -ForegroundColor White
    Write-Host "  Всего файлов: $(Get-FileCount -Path $BasePath)" -ForegroundColor White
    Write-Host "  Всего коммитов: $(git rev-list --count HEAD)" -ForegroundColor White
    Write-Host ""
    Write-Host "  Отчёт: $reportPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Log "СЕССИЯ ЗАВЕРШЕНА!" "Green"
    Write-Host ""
    
} catch {
    Write-Log "❌ ОШИБКА: $($_.Exception.Message)" "Red"
    exit 1
}
