# ============================================
# PowerShell Профиль Оптимизации
# ============================================
# Файл: $PROFILE
# Путь: C:\Users\Jackal\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
# ============================================

# 1. Отключение телеметрии
$env:POWERSHELL_TELEMETRY_OPTOUT = 1
$env:DOTNET_CLI_TELEMETRY_OPTOUT = 1

# 2. Оптимизация памяти Node.js
$env:NODE_OPTIONS = "--max-old-space-size=32768"

# 3. Кэширование истории
Set-PSReadlineOption -HistorySavePath "$env:TEMP\PSReadLine_History.txt"
Set-PSReadlineOption -MaximumHistoryCount 10000

# 4. Кодировка
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 5. Быстрые алиасы
function ll { Get-ChildItem @args }
function la { Get-ChildItem -Force @args }
function lt { Get-ChildItem -Recurse @args }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

# 6. Git алиасы
function g { git @args }
function gs { git status @args }
function ga { git add @args }
function gc { git commit -m "$args" }
function gp { git push @args }
function gl { git log --oneline -10 }
function gd { git diff @args }

# 7. Node.js алиасы
function ni { npm install @args }
function ns { npm start @args }
function nt { npm test @args }
function nb { npm run build @args }

# 8. Функции производительности
function cls2 {
    Clear-Host
    [GC]::Collect()
}

function node-memory {
    node -e "console.log('Heap Limit:', (require('v8').getHeapStatistics().heap_size_limit/1024/1024/1024).toFixed(2), 'GB')"
}

function git-opt {
    Write-Host "Git оптимизации:" -ForegroundColor Cyan
    git config --global --list
}

# 9. Приветствие
Write-Host ""
Write-Host "✅ PowerShell профиль оптимизации загружен" -ForegroundColor Green
Write-Host "📊 NODE_OPTIONS: $env:NODE_OPTIONS" -ForegroundColor Cyan
Write-Host "📁 Профиль: $PROFILE" -ForegroundColor Cyan
Write-Host ""
Write-Host "Доступные команды:" -ForegroundColor Yellow
Write-Host "  g, gs, ga, gc, gp, gl, gd - Git команды" -ForegroundColor Gray
Write-Host "  ni, ns, nt, nb - NPM команды" -ForegroundColor Gray
Write-Host "  node-memory - Проверка памяти Node.js" -ForegroundColor Gray
Write-Host "  git-opt - Проверка Git оптимизаций" -ForegroundColor Gray
Write-Host "  cls2 - Очистка + GC" -ForegroundColor Gray
Write-Host ""
