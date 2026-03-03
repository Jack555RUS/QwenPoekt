# ============================================================================
# SCHEDULE BACKUP TASKS
# ============================================================================
# Назначение: Настройка автоматического расписания для задач бэкапа
# Использование: .\scripts\schedule-backup-tasks.ps1
# Требование: Запуск от имени администратора (для Task Scheduler)
# ============================================================================

param(
    [switch]$Uninstall,
    
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# ============================================================================
# КОНФИГУРАЦИЯ
# ============================================================================

$TaskConfig = @{
    DailyCommit = @{
        Name = "QwenPoekt-Daily-Git-Commit"
        Time = "18:00"
        Script = "D:\QwenPoekt\Base\scripts\auto-commit-daily.ps1"
        Description = "Ежедневный Git коммит в 18:00"
    }
    
    WeeklyDedup = @{
        Name = "QwenPoekt-Weekly-Dedup-Audit"
        Day = "Sunday"
        Time = "09:00"
        Script = "D:\QwenPoekt\Base\scripts\weekly-dedup-audit.ps1"
        Description = "Еженедельный аудит дубликатов (воскресенье в 09:00)"
    }
    
    MonthlyCleanup = @{
        Name = "QwenPoekt-Monthly-Backup-Cleanup"
        Day = 1  # 1-е число месяца
        Time = "10:00"
        Script = "D:\QwenPoekt\Base\scripts\old-backup-cleanup.ps1"
        Description = "Ежемесячная очистка старых бэкапов (1-е число в 10:00)"
    }
}

$BasePath = "D:\QwenPoekt\Base"
$LogsPath = "D:\QwenPoekt\Base\reports\SCHEDULE_LOG.md"

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

function Test-Script-Exists {
    param([string]$ScriptPath)
    if (!(Test-Path $ScriptPath)) {
        Write-Error-Log "Скрипт не найден: $ScriptPath"
        return $false
    }
    return $true
}

function Get-TaskStatus {
    param([string]$TaskName)
    try {
        $task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        if ($task) {
            return @{
                Exists = $true
                State = $task.State
                LastRun = $task.LastRunTime
                NextRun = $task.NextRunTime
            }
        } else {
            return @{ Exists = $false }
        }
    } catch {
        return @{ Exists = $false }
    }
}

function Install-Task {
    param(
        [string]$Name,
        [string]$Script,
        [string]$Description,
        [string]$Trigger
    )
    
    Write-Info-Log "Установка задачи: $Name"
    
    # Проверка существования скрипта
    if (!(Test-Script-Exists -ScriptPath $Script)) {
        Write-Warning-Log "Скрипт не найден, пропускаем: $Script"
        return $false
    }
    
    # Удалить существующую задачу
    $existing = Get-TaskStatus -TaskName $Name
    if ($existing.Exists) {
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
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)
    $trigger.Repetition.Interval = $Trigger
    
    # Зарегистрировать задачу
    Register-ScheduledTask `
        -TaskName $Name `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -Description $Description `
        -RunLevel Highest `
        -ErrorAction Stop
    
    Write-Success-Log "Задача установлена: $Name"
    return $true
}

function Uninstall-Task {
    param([string]$Name)
    
    Write-Info-Log "Удаление задачи: $Name"
    
    $existing = Get-TaskStatus -TaskName $Name
    if ($existing.Exists) {
        Unregister-ScheduledTask -TaskName $Name -Confirm:$false
        Write-Success-Log "Задача удалена: $Name"
    } else {
        Write-Info-Log "Задача не найдена: $Name"
    }
}

function Generate-Report {
    param(
        [array]$Results,
        [string]$ReportPath
    )
    
    $report = @"
# Отчёт установки расписания

**Дата:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Пользователь:** $([Environment]::UserName)
**Администратор:** $(if (Test-Administrator) { "Да" } else { "Нет" })

---

## Задачи

"@
    
    foreach ($result in $Results) {
        $statusIcon = if ($result.Success) { "✅" } else { "❌" }
        $report += @"

### $statusIcon $($result.Name)

**Статус:** $(if ($result.Success) { "Установлена" } else { "Пропущена/Ошибка" })
**Описание:** $($result.Description)
**Скрипт:** ``````$($result.Script)``````

"@
        
        if ($result.TaskInfo) {
            $report += @"
**Состояние:** $($result.TaskInfo.State)
**Последний запуск:** $($result.TaskInfo.LastRun)
**Следующий запуск:** $($result.TaskInfo.NextRun)

"@
        }
    }
    
    $report += @"

---

## Команды управления

``````powershell
# Проверить статус задач
Get-ScheduledTask -TaskName "QwenPoekt-*"

# Запустить задачу вручную
Start-ScheduledTask -TaskName "QwenPoekt-Daily-Git-Commit"

# Удалить все задачи
.\scripts\schedule-backup-tasks.ps1 -Uninstall
``````

---

**Отчёт сгенерирован:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** schedule-backup-tasks.ps1
"@
    
    $report | Out-File -FilePath $ReportPath -Encoding UTF8
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

try {
    Write-Host ""
    Write-Log "=== НАСТРОЙКА РАСПИСАНИЯ БЭКАПА ===" -Color "Yellow"
    
    # ------------------------------------------------------------------------
    # ШАГ 0: Проверка прав администратора
    # ------------------------------------------------------------------------
    Write-Log "Шаг 0: Проверка прав администратора..."
    
    if (!(Test-Administrator)) {
        Write-Warning-Log "Требуются права администратора!"
        Write-Host ""
        Write-Host "Запустите от имени администратора:" -ForegroundColor "Yellow"
        Write-Host "  Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File .\scripts\schedule-backup-tasks.ps1'" -ForegroundColor "Gray"
        Write-Host ""
        exit 1
    }
    
    Write-Success-Log "Права администратора подтверждены"
    
    # ------------------------------------------------------------------------
    # ШАГ 1: Uninstall режим
    # ------------------------------------------------------------------------
    if ($Uninstall) {
        Write-Log "Шаг 1: Удаление задач..."
        
        foreach ($taskName in $TaskConfig.Keys) {
            Uninstall-Task -Name $TaskConfig[$taskName].Name
        }
        
        Write-Success-Log "Все задачи удалены"
        Write-Host ""
        Write-Host "Для повторной установки:" -ForegroundColor "Cyan"
        Write-Host "  .\scripts\schedule-backup-tasks.ps1" -ForegroundColor "Gray"
        Write-Host ""
        exit 0
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 2: Установка задач
    # ------------------------------------------------------------------------
    Write-Log "Шаг 2: Установка задач..."
    
    $results = @()
    
    # Daily Git Commit (ежедневно)
    Write-Host ""
    Write-Log "Задача 1: Ежедневный Git коммит (18:00)" -Color "White"
    $dailyResult = Install-Task `
        -Name $TaskConfig.DailyCommit.Name `
        -Script $TaskConfig.DailyCommit.Script `
        -Description $TaskConfig.DailyCommit.Description `
        -Trigger (New-TimeSpan -Days 1)
    
    $results += @{
        Name = "Ежедневный Git коммит"
        Success = $dailyResult
        Description = $TaskConfig.DailyCommit.Description
        Script = $TaskConfig.DailyCommit.Script
        TaskInfo = (Get-TaskStatus -TaskName $TaskConfig.DailyCommit.Name)
    }
    
    # Weekly Dedup Audit (еженедельно)
    Write-Host ""
    Write-Log "Задача 2: Еженедельный аудит дубликатов (воскресенье 09:00)" -Color "White"
    $weeklyResult = Install-Task `
        -Name $TaskConfig.WeeklyDedup.Name `
        -Script $TaskConfig.WeeklyDedup.Script `
        -Description $TaskConfig.WeeklyDedup.Description `
        -Trigger (New-TimeSpan -Days 7)
    
    $results += @{
        Name = "Еженедельный аудит"
        Success = $weeklyResult
        Description = $TaskConfig.WeeklyDedup.Description
        Script = $TaskConfig.WeeklyDedup.Script
        TaskInfo = (Get-TaskStatus -TaskName $TaskConfig.WeeklyDedup.Name)
    }
    
    # Monthly Cleanup (ежемесячно)
    Write-Host ""
    Write-Log "Задача 3: Ежемесячная очистка бэкапов (1-е число 10:00)" -Color "White"
    
    # Проверка существования скрипта
    if (Test-Script-Exists -ScriptPath $TaskConfig.MonthlyCleanup.Script) {
        $monthlyResult = Install-Task `
            -Name $TaskConfig.MonthlyCleanup.Name `
            -Script $TaskConfig.MonthlyCleanup.Script `
            -Description $TaskConfig.MonthlyCleanup.Description `
            -Trigger (New-TimeSpan -Days 30)
        
        $results += @{
            Name = "Ежемесячная очистка"
            Success = $monthlyResult
            Description = $TaskConfig.MonthlyCleanup.Description
            Script = $TaskConfig.MonthlyCleanup.Script
            TaskInfo = (Get-TaskStatus -TaskName $TaskConfig.MonthlyCleanup.Name)
        }
    } else {
        Write-Warning-Log "Скрипт old-backup-cleanup.ps1 не найден, пропускаем"
        $results += @{
            Name = "Ежемесячная очистка"
            Success = $false
            Description = $TaskConfig.MonthlyCleanup.Description
            Script = $TaskConfig.MonthlyCleanup.Script
            TaskInfo = $null
        }
    }
    
    # ------------------------------------------------------------------------
    # ШАГ 3: Генерация отчёта
    # ------------------------------------------------------------------------
    Write-Log "Шаг 3: Генерация отчёта..."
    
    Generate-Report -Results $results -ReportPath $LogsPath
    
    Write-Success-Log "Отчёт сохранён: $LogsPath"
    
    # ------------------------------------------------------------------------
    # ШАГ 4: Вывод статистики
    # ------------------------------------------------------------------------
    Write-Log "Шаг 4: Статистика..."
    
    $successCount = ($results | Where-Object { $_.Success }).Count
    $totalCount = $results.Count
    
    Write-Info-Log "Установлено задач: $successCount из $totalCount"
    
    # ------------------------------------------------------------------------
    # ЗАВЕРШЕНИЕ
    # ------------------------------------------------------------------------
    Write-Host ""
    Write-Success-Log "НАСТРОЙКА РАСПИСАНИЯ ЗАВЕРШЕНА!" -Color "Green"
    Write-Host ""
    Write-Host "Установленные задачи:" -ForegroundColor "White"
    
    foreach ($result in $results) {
        $icon = if ($result.Success) { "✅" } else { "⚠️ " }
        Write-Host "  $icon $($result.Name)" -ForegroundColor $(if ($result.Success) { "Green" } else { "Yellow" })
    }
    
    Write-Host ""
    Write-Host "Отчёт: $LogsPath" -ForegroundColor "Cyan"
    Write-Host ""
    Write-Host "Для проверки статуса:" -ForegroundColor "Cyan"
    Write-Host "  Get-ScheduledTask -TaskName `"QwenPoekt-*`"" -ForegroundColor "Gray"
    Write-Host ""
    Write-Host "Для запуска вручную:" -ForegroundColor "Cyan"
    Write-Host "  Start-ScheduledTask -TaskName `"QwenPoekt-Daily-Git-Commit`"" -ForegroundColor "Gray"
    Write-Host ""
    Write-Host "Для удаления:" -ForegroundColor "Cyan"
    Write-Host "  .\scripts\schedule-backup-tasks.ps1 -Uninstall" -ForegroundColor "Gray"
    Write-Host ""
    
} catch {
    Write-Error-Log "КРИТИЧЕСКАЯ ОШИБКА: $($_.Exception.Message)"
    Write-Error-Log "Детали: $($_.Exception.StackTrace)"
    exit 1
}
