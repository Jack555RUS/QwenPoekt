# ============================================================================
# WEEKLY DEDUP AUDIT
# ============================================================================
# Назначение: Еженедельный автоматический аудит дубликатов
# Использование: .\scripts\weekly-dedup-audit.ps1
# Расписание: Каждое воскресенье в 09:00 (настраивается)
# ============================================================================

param(
    [string]$SourceRoot = "D:\QwenPoekt\Base",
    
    [string]$IndexPath = "D:\QwenPoekt\Base\meta\file_hashes.json",
    
    [string]$ReportPath = "D:\QwenPoekt\Base\reports\DEDUP_WEEKLY_AUDIT.md",
    
    [string]$LogPath = "D:\QwenPoekt\Base\reports\OPERATION_LOG.md",
    
    [switch]$SendEmail,
    
    [string]$EmailTo = ""
)

$ErrorActionPreference = "Stop"

# ============================================================================
# ФУНКЦИИ
# ============================================================================

function Write-Log {
    param(
        [string]$Message,
        [string]$Color = "Cyan"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] $Message"
    Write-Host $logEntry -ForegroundColor $Color
}

function Write-Error-Log {
    param([string]$Message)
    Write-Log "❌ ОШИБКА: $Message" -Color "Red"
}

function Write-Success-Log {
    param([string]$Message)
    Write-Log "✅ $Message" -Color "Green"
}

function Write-Warning-Log {
    param([string]$Message)
    Write-Log "⚠️  $Message" -Color "Yellow"
}

function Write-Info-Log {
    param([string]$Message)
    Write-Log "  $Message" -Color "Gray"
}

function Test-Path-Safe {
    param([string]$Path)
    try {
        return Test-Path $Path
    } catch {
        return $false
    }
}

function Ensure-Directory-Exists {
    param([string]$Path)
    if (!(Test-Path-Safe -Path $Path)) {
        New-Item -Path $Path -ItemType Directory -Force | Out-Null
    }
}

function Send-Notification {
    param(
        [string]$Subject,
        [string]$Body,
        [string]$To
    )
    
    # Заглушка для отправки email
    # В реальности настроить SMTP или другой сервис
    Write-Log "Отправка уведомления: $To" -Color "Gray"
    Write-Log "Тема: $Subject" -Color "Gray"
    
    # Пример для PowerShell 7+:
    # Send-MailMessage -From "audit@qwenpoekt.local" -To $To -Subject $Subject -Body $Body
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== ЕЖЕНЕДЕЛЬНЫЙ АУДИТ ДУПЛИКАТОВ ===" -Color "Yellow"
    Write-Log "Дата: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")" -Color "Yellow"
    
    # ------------------------------------------------------------------------
    # ШАГ 0: Проверка окружения
    # ------------------------------------------------------------------------
    Write-Log "Шаг 0: Проверка окружения..."
    
    if (!(Test-Path-Safe -Path $SourceRoot)) {
        Write-Error-Log "Источник не существует: $SourceRoot"
        exit 1
    }
    
    Ensure-Directory-Exists -Path (Split-Path $ReportPath -Parent)
    Ensure-Directory-Exists -Path (Split-Path $IndexPath -Parent)
    
    Write-Success-Log "Окружение готово"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Генерация индекса хэшей
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Генерация индекса хэшей..."
    
    $generateScript = Join-Path $SourceRoot "scripts\generate-file-hashes.ps1"
    
    if (!(Test-Path-Safe -Path $generateScript)) {
        Write-Error-Log "Скрипт не найден: $generateScript"
        exit 1
    }
    
    # Запустить генерацию индекса
    & $generateScript -Force
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Log "Генерация индекса не удалась!"
        exit 1
    }
    
    Write-Success-Log "Индекс сгенерирован"
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Проверка дубликатов
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Проверка дубликатов..."
    
    $checkScript = Join-Path $SourceRoot "scripts\check-hash-duplicates.ps1"
    
    if (!(Test-Path-Safe -Path $checkScript)) {
        Write-Error-Log "Скрипт не найден: $checkScript"
        exit 1
    }
    
    # Запустить проверку дубликатов
    & $checkScript -ReportPath $ReportPath
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Log "Проверка дубликатов не удалась!"
        exit 1
    }
    
    Write-Success-Log "Проверка завершена"
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Загрузка результатов
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Загрузка результатов..."
    
    # Загрузить индекс
    $index = Get-Content $IndexPath -Raw | ConvertFrom-Json
    
    # Загрузить отчёт о дубликатах
    $dupReport = Get-Content $ReportPath -Raw
    
    # Извлечь количество дубликатов из отчёта
    $duplicateCount = 0
    if ($dupReport -match "Групп дубликатов: (\d+)") {
        $duplicateCount = [int]$matches[1]
    }
    
    Write-Info-Log "Файлов в индексе: $($index.totalFiles)"
    Write-Info-Log "Групп дубликатов: $duplicateCount"
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Генерация сводного отчёта
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Генерация сводного отчёта..."
    
    $weeklyReport = @"
# Еженедельный аудит дубликатов

**Дата аудита:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Неделя:** $(Get-Date -Format "yyyy-Www")

---

## Сводка

| Метрика | Значение |
|---------|----------|
| Всего файлов | $($index.totalFiles) |
| Групп дубликатов | $duplicateCount |
| Статус | $(if ($duplicateCount -eq 0) { "✅ Чисто" } else { "⚠️  Требует внимания" }) |

---

## Динамика

| Неделя | Файлов | Дубликаты |
|--------|--------|-----------|
| $(Get-Date -Format "yyyy-Www") | $($index.totalFiles) | $duplicateCount |

---

## Рекомендации

$(if ($duplicateCount -eq 0) {
"✅ **Дубликатов не найдено!**

Продолжайте в том же духе. База Знаний чиста."
} else {
"⚠️  **Найдены дубликаты!**

Рекомендуемые действия:

1. [ ] Открыть отчёт: \`reports\DEDUP_AUDIT_REPORT.md\`
2. [ ] Проверить каждую группу дубликатов
3. [ ] Удалить лишние файлы
4. [ ] Перегенерировать индекс"
})

---

## Детальный отчёт

Полный отчёт: \`reports\DEDUP_AUDIT_REPORT.md\`

---

**Аудит выполнен:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** weekly-dedup-audit.ps1
"@
    
    $weeklyReport | Out-File -FilePath $ReportPath -Encoding UTF8
    
    Write-Success-Log "Отчёт сохранён: $ReportPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 5: Запись в журнал операций
    # ------------------------------------------------------------------------
    Write-Log "Шаг 5: Запись в журнал..."
    
    $logEntry = @"

## $(Get-Date -Format 'yyyy-MM-dd HH:mm') Еженедельный аудит дубликатов

**Тип:** Автоматический аудит

**Параметры:**
- Файлов в индексе: $($index.totalFiles)
- Групп дубликатов: $duplicateCount
- Отчёт: $ReportPath

**Статус:** ✅ Завершено

---
"@
    
    if (Test-Path $LogPath) {
        Add-Content -Path $LogPath -Value $logEntry -Encoding UTF8
        Write-Success-Log "Запись в журнал: $LogPath"
    } else {
        Write-Warning-Log "Журнал не найден: $LogPath"
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 6: Отправка уведомления (опционально)
    # ------------------------------------------------------------------------
    if ($SendEmail -and $EmailTo) {
        Write-Log "Шаг 6: Отправка уведомления..."
        
        $subject = "Еженедельный аудит дубликатов: $(if ($duplicateCount -eq 0) { "Чисто" } else { "Найдены дубликаты" })"
        
        $body = @"
Еженедельный аудит завершён.

**Результаты:**
- Файлов: $($index.totalFiles)
- Дубликаты: $duplicateCount групп

**Отчёт:** $ReportPath

$(if ($duplicateCount -gt 0) {
"⚠️  Требуется проверка дубликатов!"
} else {
"✅ Дубликатов не найдено!"
})
"@
        
        Send-Notification -Subject $subject -Body $body -To $EmailTo
        
        Write-Success-Log "Уведомление отправлено: $EmailTo"
    }
    
    # ------------------------------------------------------------------------
    # ЗАВЕРШЕНИЕ
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Success-Log "ЕЖЕНЕДЕЛЬНЫЙ АУДИТ ЗАВЕРШЁН!" -Color "Green"
    Write-Host ""
    Write-Host "Результаты:" -ForegroundColor "White"
    Write-Host "  Файлов: $($index.totalFiles)" -ForegroundColor "White"
    Write-Host "  Дубликаты: $duplicateCount групп" -ForegroundColor $(if ($duplicateCount -gt 0) { "Yellow" } else { "Green" })
    Write-Host ""
    Write-Host "Отчёт: $ReportPath" -ForegroundColor "Cyan"
    Write-Host "Журнал: $LogPath" -ForegroundColor "Cyan"
    Write-Host ""
    
    if ($duplicateCount -gt 0) {
        Write-Host "⚠️  Найдены дубликаты!" -ForegroundColor "Yellow"
        Write-Host "Для проверки:" -ForegroundColor "Cyan"
        Write-Host "  .\scripts\check-hash-duplicates.ps1" -ForegroundColor "Gray"
        Write-Host ""
    }
    
    # Выход с кодом 0 (успех)
    exit 0
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    
    # Записать ошибку в журнал
    $errorEntry = @"

## $(Get-Date -Format 'yyyy-MM-dd HH:mm') ОШИБКА аудита дубликатов

**Тип:** Критическая ошибка

**Ошибка:** $($_.Exception.Message)

**Статус:** ❌ Провалено

---
"@
    
    if (Test-Path $LogPath) {
        Add-Content -Path $LogPath -Value $errorEntry -Encoding UTF8
    }
    
    exit 1
}
