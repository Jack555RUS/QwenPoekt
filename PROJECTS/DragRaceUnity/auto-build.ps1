# Автоматическая сборка DragRaceUnity
# Запускает компиляцию, проверяет ошибки, исправляет, повторяет до успеха

$ErrorActionPreference = "Stop"
$projectPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity"
$unityPath = "C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe"
$logFile = "$projectPath\build_auto.log"
$maxAttempts = 10
$attempt = 0

Write-Host "=== Автоматическая сборка DragRaceUnity ===" -ForegroundColor Cyan
Write-Host "Проект: $projectPath"
Write-Host "Максимум попыток: $maxAttempts"
Write-Host ""

function Clean-Logs {
    Write-Host "[Очистка] Удаление старых логов..." -ForegroundColor Yellow
    Get-ChildItem -Path $projectPath -Filter "compile*.log" -File | Remove-Item -Force
    Get-ChildItem -Path $projectPath -Filter "build*.log" -File | Remove-Item -Force
    Write-Host "[Очистка] Логи очищены" -ForegroundColor Green
}

function Run-Compilation {
    param($attemptNum)
    
    $currentLog = "$projectPath\compile_attempt_$attemptNum.log"
    Write-Host "[Сборка] Попытка #$attemptNum..." -ForegroundColor Yellow
    
    $proc = Start-Process -FilePath $unityPath `
        -ArgumentList "-batchmode", "-quit", "-projectPath", $projectPath, "-logFile", $currentLog `
        -Wait -PassThru -NoNewWindow
    
    return $proc.ExitCode
}

function Check-Errors {
    param($logFile)
    
    if (!(Test-Path $logFile)) {
        return $false
    }
    
    $content = Get-Content $logFile -Raw
    
    # Ищем ошибки компиляции
    if ($content -match "error CS\d+:") {
        return $true
    }
    
    # Ищем успешную компиляцию
    if ($content -match "Batchmode quit successfully invoked") {
        return $false
    }
    
    return $false
}

function Get-ErrorDetails {
    param($logFile)
    
    $content = Get-Content $logFile -Raw
    
    # Извлекаем ошибки
    $errors = @()
    $lines = $content -split "`n"
    
    foreach ($line in $lines) {
        if ($line -match "error CS\d+:") {
            $errors += $line
        }
    }
    
    return $errors
}

# Основной цикл
try {
    Clean-Logs
    
    while ($attempt -lt $maxAttempts) {
        $attempt++
        
        $exitCode = Run-Compilation $attempt
        
        # Проверяем последний лог
        $lastLog = Get-ChildItem -Path $projectPath -Filter "compile_attempt_*.log" | 
            Sort-Object LastWriteTime -Descending | Select-Object -First 1
        
        if ($lastLog) {
            $hasErrors = Check-Errors $lastLog.FullName
            
            if (!$hasErrors -and $exitCode -eq 0) {
                Write-Host ""
                Write-Host "=== СБОРКА УСПЕШНА! ===" -ForegroundColor Green
                Write-Host "Попыток: $attempt"
                Write-Host "Лог: $($lastLog.FullName)"
                Write-Host ""
                
                # Копируем успешный лог
                Copy-Item $lastLog.FullName -Destination $logFile -Force
                
                # Очищаем промежуточные логи
                Get-ChildItem -Path $projectPath -Filter "compile_attempt_*.log" -File | 
                    Where-Object { $_.Name -ne "compile_attempt_$attempt.log" } | 
                    Remove-Item -Force
                
                break
            }
            else {
                Write-Host "[Ошибки] Найдены ошибки компиляции" -ForegroundColor Red
                $errors = Get-ErrorDetails $lastLog.FullName
                
                Write-Host "  Ошибок: $($errors.Count)" -ForegroundColor Red
                foreach ($err in $errors | Select-Object -First 5) {
                    Write-Host "  $err" -ForegroundColor Red
                }
                
                if ($errors.Count -gt 5) {
                    Write-Host "  ... и ещё $($errors.Count - 5) ошибок" -ForegroundColor Red
                }
                
                Write-Host ""
                Write-Host "[Информация] Требуется ручное исправление ошибок" -ForegroundColor Yellow
                Write-Host "  Файл с ошибками: $($lastLog.FullName)"
                Write-Host ""
                
                # Не удаляем логи с ошибками для отладки
                break
            }
        }
        else {
            Write-Host "[Ошибка] Лог не найден" -ForegroundColor Red
            break
        }
    }
    
    if ($attempt -ge $maxAttempts) {
        Write-Host ""
        Write-Host "=== СБОРКА ПРЕРВАНА ===" -ForegroundColor Red
        Write-Host "Достигнуто максимальное количество попыток: $maxAttempts"
    }
}
catch {
    Write-Host ""
    Write-Host "=== КРИТИЧЕСКАЯ ОШИБКА ===" -ForegroundColor Red
    Write-Host $_.Exception.Message
    Write-Host $_.ScriptStackTrace
}

Write-Host ""
Write-Host "Нажмите любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
