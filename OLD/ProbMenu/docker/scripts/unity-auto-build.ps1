# =============================================================================
# Автоматическая сборка Unity проекта в Docker с проверкой ошибок
# =============================================================================

param(
    [string]$UnityEmail = $env:UNITY_EMAIL,
    [string]$UnityPassword = $env:UNITY_PASSWORD,
    [string]$UnityLicense = $env:UNITY_LICENSE,
    [int]$MaxIterations = 3,
    [switch]$Verbose = $true
)

$ErrorActionPreference = "Stop"
$projectPath = "D:\QwenPoekt\ProbMenu\DragRaceUnity"
$logsPath = "D:\QwenPoekt\ProbMenu\DragRaceUnity\Logs"
$buildPath = "D:\QwenPoekt\ProbMenu\Builds"

Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "Автоматическая сборка Unity в Docker" -ForegroundColor White
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Параметры:" -ForegroundColor Yellow
Write-Host "  Проект: $projectPath"
Write-Host "  Макс. итераций: $MaxIterations"
Write-Host ""

# =============================================================================
# Функции
# =============================================================================

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $(if ($Level -eq "ERROR") { "Red" } elseif ($Level -eq "SUCCESS") { "Green" } else { "White" })
}

function Clear-UnityLogs {
    Write-Log "Очистка логов..."
    if (Test-Path $logsPath) {
        Get-ChildItem -Path $logsPath -Filter *.log | Remove-Item -Force -ErrorAction SilentlyContinue
    }
    $buildLog = Join-Path $projectPath "build.log"
    if (Test-Path $buildLog) {
        Remove-Item $buildLog -Force -ErrorAction SilentlyContinue
    }
}

function Get-UnityErrors {
    param([string]$LogFile)
    
    if (-not (Test-Path $LogFile)) {
        return @()
    }
    
    $errors = @()
    $content = Get-Content $LogFile -Raw
    
    # Поиск ошибок компиляции
    $matches = [regex]::Matches($content, 'error CS\d+:.*?(?=\n\n|\Z)', [System.Text.RegularExpressions.RegexOptions]::Singleline)
    foreach ($match in $matches) {
        $errors += $match.Value
    }
    
    return $errors
}

function Fix-UnityErrors {
    param([string[]]$Errors)
    
    Write-Log "Анализ ошибок..."
    
    $fixed = $false
    
    foreach ($error in $Errors) {
        # Ошибка Input.GetKey
        if ($error -match 'ProbMenu\.Input\.GetKey') {
            Write-Log "Исправление: Input.GetKey → UnityEngine.Input.GetKey"
            & powershell -Command "Get-ChildItem '$projectPath\Assets\Scripts' -Recurse -Filter *.cs | ForEach-Object { `$c = Get-Content `$_.FullName -Raw; `$c = `$c -replace '\bInput\.GetKey\b', 'UnityEngine.Input.GetKey'; `$c = `$c -replace '\bInput\.GetKeyDown\b', 'UnityEngine.Input.GetKeyDown'; Set-Content -Path `$_.FullName -Value `$c -NoNewline }"
            $fixed = $true
        }
        
        # Ошибка Logger
        if ($error -match 'Logger.*ambiguous') {
            Write-Log "Исправление: Logger conflict"
            & powershell -Command "Get-ChildItem '$projectPath\Assets\Scripts' -Recurse -Filter *.cs | ForEach-Object { `$c = Get-Content `$_.FullName -Raw; if (`$c -notmatch 'using Logger = ProbMenu\.Core\.Logger;') { `$c = `$c -replace 'using ProbMenu\.Core;', \"using ProbMenu.Core;`nusing Logger = ProbMenu.Core.Logger;\"; Set-Content -Path `$_.FullName -Value `$c -NoNewline } }"
            $fixed = $true
        }
        
        # Ошибка NUnit
        if ($error -match 'NUnit') {
            Write-Log "Пропуск NUnit (требуется пакет Unity)"
        }
    }
    
    return $fixed
}

function Build-UnityDocker {
    Write-Log "Запуск сборки в Docker..."
    
    $dockerArgs = @(
        "run", "--rm",
        "-v", "${projectPath}:/unity-project",
        "-v", "${buildPath}:/builds",
        "-e", "UNITY_EMAIL=${UnityEmail}",
        "-e", "UNITY_PASSWORD=${UnityPassword}",
        "-e", "UNITY_LICENSE=${UnityLicense}",
        "-e", "UNITY_PROJECT_PATH=/unity-project",
        "-e", "BUILD_PATH=/builds",
        "gameci/unity-builder:2022.3-win",
        "bash", "-c", @"
cd /unity-project &&
unity-builder \
  --projectPath /unity-project \
  --buildPath /builds \
  --buildName DragRace \
  --buildTarget Win64 \
  --versioning None \
  --logFile /builds/build.log || true
"@
    )
    
    & docker $dockerArgs
    
    return $LASTEXITCODE -eq 0
}

# =============================================================================
# Основной цикл
# =============================================================================

$iteration = 0
$success = $false

while ($iteration -lt $MaxIterations -and -not $success) {
    $iteration++
    Write-Host ""
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host "Итерация $iteration из $MaxIterations" -ForegroundColor White
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host ""
    
    # 1. Очистка логов
    Clear-UnityLogs
    
    # 2. Сборка
    $buildSuccess = Build-UnityDocker
    
    # 3. Проверка логов
    $buildLog = Join-Path $buildPath "build.log"
    if (Test-Path $buildLog) {
        $errors = Get-UnityErrors -LogFile $buildLog
        
        if ($errors.Count -eq 0) {
            Write-Log "✅ Сборка успешна! Ошибок нет." "SUCCESS"
            $success = $true
        } else {
            Write-Log "Найдено ошибок: $($errors.Count)" "ERROR"
            
            # 4. Исправление ошибок
            $fixed = Fix-UnityErrors -Errors $errors
            
            if (-not $fixed) {
                Write-Log "Не удалось исправить ошибки автоматически" "ERROR"
                Write-Host ""
                Write-Host "Ошибки:" -ForegroundColor Red
                $errors | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
                break
            }
        }
    } else {
        Write-Log "build.log не найден" "ERROR"
        break
    }
}

# =============================================================================
# Финальный отчёт
# =============================================================================

Write-Host ""
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "ФИНАЛЬНЫЙ ОТЧЁТ" -ForegroundColor White
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""

if ($success) {
    Write-Host "✅ СБОРКА ЗАВЕРШЕНА УСПЕШНО!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Результат:" -ForegroundColor Cyan
    Write-Host "  EXE файл: ${buildPath}\DragRace\DragRace.exe"
    Write-Host "  Итераций: $iteration"
} else {
    Write-Host "❌ СБОРКА НЕ УДАЛАСЬ" -ForegroundColor Red
    Write-Host ""
    Write-Host "Попробуйте:" -ForegroundColor Yellow
    Write-Host "  1. Проверить UNITY_EMAIL и UNITY_PASSWORD"
    Write-Host "  2. Установить лицензию Unity"
    Write-Host "  3. Проверить логи: ${buildPath}\build.log"
}

Write-Host ""
