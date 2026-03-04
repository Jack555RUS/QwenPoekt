# cleanup-unnecessary-files.ps1 — Удаление ненужных файлов
# Версия: 1.0
# Дата: 4 марта 2026 г.

$ErrorActionPreference = "Continue"

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         ОЧИСТКА НЕНУЖНЫХ ФАЙЛОВ                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# 1. Удаление mcp-session-saver.js
Write-Host "[1/4] Удаление mcp-session-saver.js..." -ForegroundColor Cyan
if (Test-Path "mcp-session-saver.js") {
    Remove-Item "mcp-session-saver.js" -Force
    Write-Host "  ✅ Удалено" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ Не найдено (уже удалено)" -ForegroundColor Yellow
}

# 2. Очистка sessions/
Write-Host "`n[2/4] Очистка sessions/..." -ForegroundColor Cyan
if (Test-Path "sessions") {
    Get-ChildItem "sessions" -Directory | ForEach-Object {
        Remove-Item $_.FullName -Recurse -Force
    }
    Write-Host "  ✅ sessions/ очищен" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ sessions/ не найдена" -ForegroundColor Yellow
}

# 3. Очистка logs/
Write-Host "`n[3/4] Очистка logs/..." -ForegroundColor Cyan
if (Test-Path "logs") {
    Get-ChildItem "logs" -Filter "before-action-v2-*.log" | Remove-Item -Force
    Write-Host "  ✅ logs/ очищен" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ logs/ не найдена" -ForegroundColor Yellow
}

# 4. Очистка Task Scheduler
Write-Host "`n[4/4] Очистка Task Scheduler..." -ForegroundColor Cyan
try {
    Unregister-ScheduledTask -TaskName "QwenSessionAutoSave" -Confirm:$false 2>$null
    Write-Host "  ✅ Task Scheduler очищен" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️ Задача не найдена (уже удалена)" -ForegroundColor Yellow
}

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    ОЧИСТКА ЗАВЕРШЕНА                     ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Write-Host "Удалено:" -ForegroundColor Cyan
Write-Host "  - mcp-session-saver.js (не используется)" -ForegroundColor Gray
Write-Host "  - sessions/* (архив, можно восстановить)" -ForegroundColor Gray
Write-Host "  - logs/before-action-v2-*.log (не нужны)" -ForegroundColor Gray
Write-Host "  - Task Scheduler QwenSessionAutoSave" -ForegroundColor Gray
Write-Host ""
Write-Host "Осталось:" -ForegroundColor Green
Write-Host "  ✅ resume-session.ps1 (восстановление контекста)" -ForegroundColor Gray
Write-Host "  ✅ .resume_marker.json (контекст сессии)" -ForegroundColor Gray
Write-Host ""
