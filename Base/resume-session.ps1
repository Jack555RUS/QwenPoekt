# resume-session.ps1 — Восстановление контекста сессии
# Версия: 1.1
# Дата: 4 марта 2026 г.
# Назначение: Автоматическое восстановление контекста для Qwen Code
# Обновление: Query Refinement (переформулирование запросов)

$ErrorActionPreference = "Stop"

# ----------------------------------------------------------------------------
# ФУНКЦИИ
# ----------------------------------------------------------------------------

function Invoke-QueryRefinement {
    param(
        [string]$UserQuery,
        [string]$Context,
        [string[]]$History
    )
    
    # Словарь местоимений
    $pronouns = @{
        "там" = "location"
        "он" = "person"
        "она" = "person"
        "это" = "object"
        "тот" = "object"
        "тех" = "object"
        "туда" = "location"
        "оттуда" = "location"
    }
    
    # Замена местоимений (простая эвристика)
    $refinedQuery = $UserQuery
    
    # Извлечение сущностей из контекста
    if ($Context) {
        # Поиск имён собственных (INDEX.md, PowerShell, etc.)
        $entityPattern = '[A-Z][a-zA-Z0-9_-]+\s*(\.md|\.ps1|\.json|\.js|\.ts|\.cs)?'
        $entities = [regex]::Matches($Context, $entityPattern)
        
        foreach ($pronoun in $pronouns.Keys) {
            if ($UserQuery -match $pronoun) {
                if ($entities.Count -gt 0) {
                    $entity = $entities[0].Value
                    $refinedQuery = $refinedQuery -replace $pronoun, "в $entity"
                }
            }
        }
    }
    
    # Добавление контекста
    if ($Context -and $refinedQuery -eq $UserQuery) {
        $shortContext = if ($Context.Length -gt 100) { $Context.Substring(0, 100) + "..." } else { $Context }
        $refinedQuery = "$refinedQuery (контекст: $shortContext)"
    }
    
    return $refinedQuery
}

# ----------------------------------------------------------------------------
# ОСНОВНАЯ ЛОГИКА
# ----------------------------------------------------------------------------

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         ВОССТАНОВЛЕНИЕ КОНТЕКСТА СЕССИИ                 ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# 1. Проверка .resume_marker.json
Write-Host "[1/4] Проверка контекста..." -ForegroundColor Cyan

if (-not (Test-Path ".resume_marker.json")) {
    Write-Host "  ❌ .resume_marker.json НЕ найден" -ForegroundColor Red
    Write-Host "     Нет сохранённой сессии для восстановления" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  💡 Создайте сессию:" -ForegroundColor Cyan
    Write-Host "     1. Напишите в чат: /save-session"
    Write-Host "     2. Или завершите сессию корректно"
    Write-Host ""
    exit 1
}

Write-Host "  ✅ .resume_marker.json найден" -ForegroundColor Green

# 2. Чтение контекста
Write-Host "`n[2/4] Чтение контекста..." -ForegroundColor Cyan

$context = Get-Content ".resume_marker.json" -Raw
$contextObj = $context | ConvertFrom-Json

Write-Host "  📅 Дата: $($contextObj.Date)" -ForegroundColor Gray
Write-Host "  📋 Задача: $($contextObj.CurrentTask)" -ForegroundColor Gray
Write-Host "  📍 Следующий шаг: $($contextObj.NextStep)" -ForegroundColor Gray

# Проверка суммаризации
if ($contextObj.ContextSummary) {
    Write-Host "  📝 Суммаризация: найдена" -ForegroundColor Gray
    Write-Host "     $($contextObj.ContextSummary.Substring(0, [Math]::Min(80, $contextObj.ContextSummary.Length)))..." -ForegroundColor Gray
}

# 3. Query Refinement (переформулирование запроса)
Write-Host "`n[3/4] Query Refinement..." -ForegroundColor Cyan

$userQuery = Read-Host "  Введите ваш запрос (или нажмите Enter для пропуска)"

if ($userQuery -and $userQuery.Trim().Length -gt 0) {
    $history = @($contextObj.CurrentTask, $contextObj.NextStep)
    $refinedQuery = Invoke-QueryRefinement -UserQuery $userQuery -Context $contextObj.CurrentTask -History $history
    
    Write-Host "  🔍 Уточнённый запрос:" -ForegroundColor Cyan
    Write-Host "     $refinedQuery" -ForegroundColor White
} else {
    $refinedQuery = $contextObj.NextStep
    Write-Host "  ℹ️  Запрос не введён, используем следующий шаг:" -ForegroundColor Gray
    Write-Host "     $refinedQuery" -ForegroundColor White
}

# 4. Копирование в буфер
Write-Host "`n[4/4] Копирование в буфер..." -ForegroundColor Cyan

# Формирование контекста для вставки
$contextForClipboard = @"
$context

====================================
ЗАПРОС ПОЛЬЗОВАТЕЛЯ:
$refinedQuery
====================================
"@

$contextForClipboard | Set-Clipboard

Write-Host "  ✅ Контекст скопирован в буфер!" -ForegroundColor Green

# Вывод содержимого
Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         СКОПИРОВАНО (вставьте в чат Qwen Code)           ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "====================================" -ForegroundColor Yellow
Write-Host "КОНТЕКСТ ПРЕДЫДУЩЕЙ СЕССИИ:" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Yellow
Write-Host ""
Write-Host $context
Write-Host ""
Write-Host "====================================" -ForegroundColor Yellow
Write-Host ""

# Инструкция
Write-Host "📋 ДЕЙСТВИЯ:" -ForegroundColor Cyan
Write-Host "  1. Перейдите в чат Qwen Code"
Write-Host "  2. Вставьте контекст (Ctrl+V)"
Write-Host "  3. Напишите: `"Восстанови контекст сессии`""
Write-Host "  4. Нажмите Enter"
Write-Host ""
Write-Host "ℹ️  ПРИМЕЧАНИЕ:" -ForegroundColor Yellow
Write-Host "   Qwen Code НЕ поддерживает автоматическое восстановление"
Write-Host "   контекста из локальных файлов. Это решение копирует"
Write-Host "   контекст в буфер для ручной вставки."
Write-Host ""

# Последняя сессия
Write-Host "📋 ПОСЛЕДНЯЯ СЕССИЯ:" -ForegroundColor Cyan

if (Test-Path "sessions") {
    $lastSession = Get-ChildItem "sessions" -Directory | 
        Sort-Object LastWriteTime -Descending | 
        Select-Object -First 1
    
    if ($lastSession) {
        Write-Host "  Папка: $($lastSession.Name)" -ForegroundColor Gray
        
        $chatFile = Join-Path $lastSession.FullName "chat.md"
        if (Test-Path $chatFile) {
            $lines = (Get-Content $chatFile | Measure-Object -Line).Lines
            Write-Host "  Файл: chat.md ($lines строк)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ⚠️ Сессии не найдены" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠️ Папка sessions/ не найдена" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Готово! Вставьте контекст в чат Qwen Code" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
