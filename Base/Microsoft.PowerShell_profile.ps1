# ============================================
# POWER SHELL ПРОФИЛЬ ОПТИМИЗАЦИИ
# ============================================
# Файл: $PROFILE
# ============================================

# ============================================
# 1. ОТКЛЮЧЕНИЕ ТЕЛЕМЕТРИИ
# ============================================

$env:POWERSHELL_TELEMETRY_OPTOUT = 1
$env:DOTNET_CLI_TELEMETRY_OPTOUT = 1

# ============================================
# 2. ОПТИМИЗАЦИЯ ПАМЯТИ NODE.JS
# ============================================

# Установить лимит памяти 32GB для Node.js процессов
$env:NODE_OPTIONS = "--max-old-space-size=32768"

# ============================================
# 3. КЭШИРОВАНИЕ ИСТОРИИ
# ============================================

# Сохранение истории в быстрый кэш
Set-PSReadlineOption -HistorySavePath "$env:TEMP\PSReadLine_History.txt"
Set-PSReadlineOption -MaximumHistoryCount 10000

# ============================================
# 4. ПОЛИТИКА ВЫПОЛНЕНИЯ СКРИПТОВ
# ============================================

# Разрешить локальные скрипты (безопасно для разработки)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force

# ============================================
# 5. КОДИРОВКА
# ============================================

# UTF-8 по умолчанию
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ============================================
# 6. АЛИАСЫ ДЛЯ БЫСТРОЙ РАБОТЫ
# ============================================

# Быстрые команды
Set-Alias -Name ll -Value Get-ChildItem
Set-Alias -Name la -Value Get-ChildItem -Force
Set-Alias -Name lt -Value Get-ChildItem -Recurse
Set-Alias -Name .. -Value "Set-Location .."
Set-Alias -Name ... -Value "Set-Location ..\.."
Set-Alias -Name .... -Value "Set-Location ..\..\.."

# Git алиасы
function g { git @args }
function gs { git status @args }
function ga { git add @args }
function gc { git commit -m $args }
function gp { git push @args }
function gl { git log --oneline -10 }
function gd { git diff @args }

# Node.js алиасы
function ni { npm install @args }
function ns { npm start @args }
function nt { npm test @args }
function nb { npm run build @args }

# ============================================
# 7. ФУНКЦИИ ПРОИЗВОДИТЕЛЬНОСТИ
# ============================================

# Быстрая очистка терминала
function cls2 {
    Clear-Host
    [GC]::Collect()
}

# Проверка Node.js памяти
function node-memory {
    node -e "console.log('Heap Limit:', (require('v8').getHeapStatistics().heap_size_limit/1024/1024/1024).toFixed(2), 'GB')"
}

# Проверка Git настроек
function git-opt {
    Write-Host "Git оптимизации:" -ForegroundColor Cyan
    git config --global --list | Select-String "pack|core"
}

# ============================================
# 8. ПРИВЕТСТВИЕ
# ============================================

Write-Host "✅ PowerShell профиль оптимизации загружен" -ForegroundColor Green
Write-Host "📊 NODE_OPTIONS: $env:NODE_OPTIONS" -ForegroundColor Cyan
Write-Host "📁 Профиль: $PROFILE" -ForegroundColor Cyan

# ============================================
# 9. БЫСТРЫЕ КОМАНДЫ
# ============================================

Write-Host ""
Write-Host "Доступные команды:" -ForegroundColor Yellow
Write-Host "  g, gs, ga, gc, gp, gl, gd - Git команды" -ForegroundColor Gray
Write-Host "  ni, ns, nt, nb - NPM команды" -ForegroundColor Gray
Write-Host "  node-memory - Проверка памяти Node.js" -ForegroundColor Gray
Write-Host "  git-opt - Проверка Git оптимизаций" -ForegroundColor Gray
Write-Host "  cls2 - Очистка + GC" -ForegroundColor Gray
Write-Host ""
