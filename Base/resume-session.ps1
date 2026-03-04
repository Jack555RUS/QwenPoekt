# resume-session.ps1 — Восстановление контекста сессии
# Версия: 1.0
# Дата: 4 марта 2026 г.
# Назначение: Автоматическое восстановление контекста для Qwen Code

$ErrorActionPreference = "Stop"

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         ВОССТАНОВЛЕНИЕ КОНТЕКСТА СЕССИИ                 ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# 1. Проверка .resume_marker.json
Write-Host "[1/3] Проверка контекста..." -ForegroundColor Cyan

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
Write-Host "`n[2/3] Чтение контекста..." -ForegroundColor Cyan

$context = Get-Content ".resume_marker.json" -Raw
$contextObj = $context | ConvertFrom-Json

Write-Host "  📅 Дата: $($contextObj.Date)" -ForegroundColor Gray
Write-Host "  📋 Задача: $($contextObj.CurrentTask)" -ForegroundColor Gray
Write-Host "  📍 Следующий шаг: $($contextObj.NextStep)" -ForegroundColor Gray

# 3. Копирование в буфер
Write-Host "`n[3/3] Копирование в буфер..." -ForegroundColor Cyan

$context | Set-Clipboard

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
