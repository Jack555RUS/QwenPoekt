# ============================================
# Unity Get Logs — Получение логов консоли
# Аналог MCP command: get_logs
# ============================================

param(
    [int]$last = 20,          # Количество последних строк
    [string]$type = "error"   # Тип логов: error, warning, all
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "📋 UNITY GET LOGS" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity"
$logPath = "$projectPath\Logs"

# ============================================
# Проверка существования логов
# ============================================
Write-Host "1️⃣ Проверка папки логов..." -ForegroundColor Yellow

if (Test-Path $logPath) {
    Write-Host "  ✅ Папка логов найдена: $logPath" -ForegroundColor Green
    
    # Получаем последний лог
    $latestLog = Get-ChildItem $logPath -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    if ($latestLog) {
        Write-Host "  📄 Последний лог: $($latestLog.Name)" -ForegroundColor Cyan
        Write-Host "  🕐 Дата: $($latestLog.LastWriteTime)" -ForegroundColor Gray
        Write-Host ""
        
        # Читаем лог
        Write-Host "2️⃣ Чтение логов (последние $last строк, тип: $type)..." -ForegroundColor Yellow
        Write-Host ""
        
        $logContent = Get-Content $latestLog.FullName -Tail $last
        
        # Фильтрация по типу
        switch ($type) {
            "error" {
                $logContent | Where-Object { $_ -match "error|Error|ERROR|Exception" } | ForEach-Object {
                    Write-Host "  ❌ $_" -ForegroundColor Red
                }
            }
            "warning" {
                $logContent | Where-Object { $_ -match "warning|Warning|WARNING" } | ForEach-Object {
                    Write-Host "  ⚠️  $_" -ForegroundColor Yellow
                }
            }
            "all" {
                $logContent | ForEach-Object {
                    if ($_ -match "error|Error|ERROR|Exception") {
                        Write-Host "  ❌ $_" -ForegroundColor Red
                    } elseif ($_ -match "warning|Warning|WARNING") {
                        Write-Host "  ⚠️  $_" -ForegroundColor Yellow
                    } else {
                        Write-Host "  ℹ️  $_" -ForegroundColor Gray
                    }
                }
            }
        }
        
        Write-Host ""
        Write-Host "============================================" -ForegroundColor Cyan
        Write-Host "LOGS COMPLETE" -ForegroundColor Cyan
        Write-Host "============================================" -ForegroundColor Cyan
        
    } else {
        Write-Host "  ⚠️  Лог-файлы не найдены" -ForegroundColor Yellow
        Write-Host "     Это нормально, если проект не запускался" -ForegroundColor Gray
    }
} else {
    Write-Host "  ❌ Папка логов не найдена: $logPath" -ForegroundColor Red
    Write-Host "     Это нормально для нового проекта" -ForegroundColor Gray
}

Write-Host ""

# Возвращаем JSON-подобный вывод для ИИ
Write-Host "📄 JSON Output (для ИИ):" -ForegroundColor Gray
Write-Host @"
{
  "logPath": "$logPath",
  "latestLog": "$($latestLog.Name)",
  "lastRead": $last,
  "filter": "$type",
  "hasErrors": $(if ($logContent -match "error|Error|ERROR|Exception") { "true" } else { "false" })
}
"@
