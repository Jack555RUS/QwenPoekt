# ============================================================================
# CREATE SCHEDULED TASKS MANUALLY
# ============================================================================
# Назначение: Создание задач Task Scheduler вручную (альтернатива schedule-backup-tasks.ps1)
# Использование: Запустить от имени администратора
# ============================================================================

$ErrorActionPreference = "Stop"

# ============================================================================
# КОНФИГУРАЦИЯ
# ============================================================================

$Tasks = @(
    @{
        Name = "QwenPoekt-Daily-Git-Commit"
        Description = "Ежедневный Git коммит в 18:00"
        Script = "D:\QwenPoekt\Base\scripts\auto-commit-daily.ps1"
        Time = "18:00"
        Daily = $true
    },
    @{
        Name = "QwenPoekt-Weekly-Dedup-Audit"
        Description = "Еженедельный аудит дубликатов (воскресенье в 09:00)"
        Script = "D:\QwenPoekt\Base\scripts\weekly-dedup-audit.ps1"
        Time = "09:00"
        DayOfWeek = [Microsoft.PowerShell.Commands.DayOfWeek]::Sunday
        Weekly = $true
    },
    @{
        Name = "QwenPoekt-Monthly-Backup-Cleanup"
        Description = "Ежемесячная очистка старых бэкапов (1-е число в 10:00)"
        Script = "D:\QwenPoekt\Base\scripts\old-backup-cleanup.ps1"
        Time = "10:00"
        DaysOfMonth = 1
        Monthly = $true
    }
)

$BasePath = "D:\QwenPoekt\Base"

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

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Create-ScheduledTask {
    param(
        [string]$Name,
        [string]$Description,
        [string]$Script,
        [string]$Time,
        [bool]$Daily,
        [bool]$Weekly,
        [bool]$Monthly,
        $DayOfWeek,
        $DaysOfMonth
    )
    
    Write-Info-Log "Создание задачи: $Name"
    
    # Проверка существования скрипта
    if (!(Test-Path $Script)) {
        Write-Warning-Log "Скрипт не найден: $Script"
        Write-Info-Log "Пропускаем задачу: $Name"
        return $false
    }
    
    # Удалить существующую задачу
    $existing = Get-ScheduledTask -TaskName $Name -ErrorAction SilentlyContinue
    if ($existing) {
        Write-Info-Log "Удаление существующей задачи..."
        Unregister-ScheduledTask -TaskName $Name -Confirm:$false
    }
    
    # Создать действие
    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
        -Argument "-ExecutionPolicy Bypass -File `"$Script`"" `
        -WorkingDirectory (Split-Path $Script -Parent)
    
    # Создать настройки
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RunOnlyIfNetworkAvailable:$false `
        -ExecutionTimeLimit (New-TimeSpan -Hours 2)
    
    # Создать триггер
    $hour = [int]($Time.Split(':')[0])
    $minute = [int]($Time.Split(':')[1])
    
    if ($Daily) {
        $trigger = New-ScheduledTaskTrigger -Daily -At $hour:$minute -DaysInterval 1
    }
    elseif ($Weekly) {
        $trigger = New-ScheduledTaskTrigger -Weekly -At $hour:$minute -DaysOfWeek $DayOfWeek
    }
    elseif ($Monthly) {
        $trigger = New-ScheduledTaskTrigger -Monthly -At $hour:$minute -DaysOfMonth $DaysOfMonth
    }
    
    # Зарегистрировать задачу
    Register-ScheduledTask `
        -TaskName $Name `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Description $Description `
        -RunLevel Highest `
        -ErrorAction Stop
    
    Write-Success-Log "Задача создана: $Name"
    return $true
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== СОЗДАНИЕ ЗАДАЧ TASK SCHEDULER ===" -Color "Yellow"
    
    # ------------------------------------------------------------------------
    # ШАГ 0: Проверка прав администратора
    # ------------------------------------------------------------------------
    Write-Log "Шаг 0: Проверка прав администратора..."
    
    if (!(Test-Administrator)) {
        Write-Error-Log "Требуются права администратора!"
        Write-Host ""
        Write-Host "Запустите от имени администратора:" -ForegroundColor "Yellow"
        Write-Host "  Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File .\create-tasks-manual.ps1'" -ForegroundColor "Gray"
        Write-Host ""
        exit 1
    }
    
    Write-Success-Log "Права администратора подтверждены"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Создание задач
    # ------------------------------------------------------------------------
    Write-Log "Шаг 1: Создание задач..."
    
    $createdCount = 0
    
    foreach ($task in $Tasks) {
        Write-Host ""
        $result = Create-ScheduledTask `
            -Name $task.Name `
            -Description $task.Description `
            -Script $task.Script `
            -Time $task.Time `
            -Daily $task.Daily `
            -Weekly $task.Weekly `
            -Monthly $task.Monthly `
            -DayOfWeek $task.DayOfWeek `
            -DaysOfMonth $task.DaysOfMonth
        
        if ($result) {
            $createdCount++
        }
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Проверка созданных задач
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Проверка созданных задач..."
    
    Write-Host ""
    Write-Log "Созданные задачи:" -Color "White"
    
    foreach ($task in $Tasks) {
        $scheduledTask = Get-ScheduledTask -TaskName $task.Name -ErrorAction SilentlyContinue
        if ($scheduledTask) {
            Write-Host "  ✅ $($task.Name)" -ForegroundColor "Green"
            Write-Info-Log "     Состояние: $($scheduledTask.State)"
            Write-Info-Log "     Следующий запуск: $($scheduledTask.NextRunTime)"
        } else {
            Write-Host "  ❌ $($task.Name)" -ForegroundColor "Red"
        }
    }
    
    # ------------------------------------------------------------------------
    # ЗАВЕРШЕНИЕ
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Success-Log "СОЗДАНО ЗАДАЧ: $createdCount из $($Tasks.Count)" -Color "Green"
    Write-Host ""
    Write-Host "Для проверки:" -ForegroundColor "Cyan"
    Write-Host "  Get-ScheduledTask -TaskName `"QwenPoekt-*`"" -ForegroundColor "Gray"
    Write-Host ""
    Write-Host "Для запуска вручную:" -ForegroundColor "Cyan"
    Write-Host "  Start-ScheduledTask -TaskName `"QwenPoekt-Daily-Git-Commit`"" -ForegroundColor "Gray"
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
