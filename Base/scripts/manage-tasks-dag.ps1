# manage-tasks-dag.ps1 — Управление DAG задач
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Управление зависимостями задач

param(
    [string]$Action = "list",  # list, add, update, check, visualize
    [string]$TaskName,         # Имя задачи
    [string]$Status,           # pending, in_progress, completed
    [string[]]$DependsOn,      # Зависимости
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Пути
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$DagPath = Join-Path $BasePath "tasks-dag.json"

# ----------------------------------------------------------------------------
# ФУНКЦИИ
# ----------------------------------------------------------------------------

function Get-Dag {
    if (-not (Test-Path $DagPath)) {
        throw "DAG файл не найден: $DagPath"
    }
    return Get-Content $DagPath -Raw | ConvertFrom-Json
}

function Save-Dag {
    param([object]$Dag)
    $Dag | ConvertTo-Json -Depth 10 | Out-File -FilePath $DagPath -Encoding UTF8
}

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host $Message -ForegroundColor $Color
}

function List-Tasks {
    param([object]$Dag)
    
    Write-Log "╔══════════════════════════════════════════════════════════╗"
    Write-Log "║                    DAG ЗАДАЧ $(Get-Date -Format 'HH:mm:ss')                ║"
    Write-Log "╚══════════════════════════════════════════════════════════╝"
    Write-Log ""
    
    $sortedTasks = $Dag.tasks.PSObject.Properties | Sort-Object { $_.Value.order }
    
    foreach ($taskProp in $sortedTasks) {
        $task = $taskProp.Value
        $name = $taskProp.Name
        
        $icon = switch ($task.status) {
            "completed" { "✅" }
            "in_progress" { "⏳" }
            "pending" { "⏸️ " }
            default { "❓" }
        }
        
        $deps = if ($task.depends_on.Count -gt 0) { 
            "→ $($task.depends_on -join ", ") "
        } else { 
            "(нет зависимостей)"
        }
        
        Write-Log "$icon [$($task.order)] $name"
        Write-Log "   $($task.title)" -Color "Gray"
        Write-Log "   $deps" -Color "Gray"
        Write-Log ""
    }
}

function Add-Task {
    param(
        [object]$Dag,
        [string]$Name,
        [string]$Title,
        [string]$Status,
        [string[]]$DependsOn,
        [int]$Order
    )
    
    if ($Dag.tasks.$Name) {
        Write-Log "⚠️  Задача уже существует: $Name" -Color "Yellow"
        return
    }
    
    $Dag.tasks | Add-Member -MemberType NoteProperty -Name $Name -Value @{
        title = $Title
        status = $Status
        depends_on = $DependsOn
        order = $Order
        created_at = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    }
    
    Save-Dag -Dag $Dag
    Write-Log "✅ Задача добавлена: $Name" -Color "Green"
}

function Update-TaskStatus {
    param(
        [object]$Dag,
        [string]$Name,
        [string]$Status
    )
    
    if (-not $Dag.tasks.$Name) {
        Write-Log "❌ Задача не найдена: $Name" -Color "Red"
        return
    }
    
    $Dag.tasks.$Name.status = $Status
    
    if ($Status -eq "completed") {
        $Dag.tasks.$Name.completed_at = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    } elseif ($Status -eq "in_progress") {
        $Dag.tasks.$Name.started_at = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    }
    
    Save-Dag -Dag $Dag
    Write-Log "✅ Статус обновлён: $Name → $Status" -Color "Green"
}

function Check-Dependencies {
    param([object]$Dag)
    
    Write-Log "╔══════════════════════════════════════════════════════════╗"
    Write-Log "║              ПРОВЕРКА ЗАВИСИМОСТЕЙ $(Get-Date -Format 'HH:mm:ss')           ║"
    Write-Log "╚══════════════════════════════════════════════════════════╝"
    Write-Log ""
    
    $errors = @()
    $warnings = @()
    
    foreach ($taskProp in $Dag.tasks.PSObject.Properties) {
        $task = $taskProp.Value
        $name = $taskProp.Name
        
        # Проверка: зависимости существуют
        foreach ($dep in $task.depends_on) {
            if (-not $Dag.tasks.$dep) {
                $errors += "Задача '$name' зависит от несуществующей '$dep'"
            }
        }
        
        # Проверка: циклические зависимости (упрощённо)
        if ($task.depends_on -contains $name) {
            $errors += "Задача '$name' зависит сама от себя"
        }
        
        # Проверка: статус зависимостей
        if ($task.status -eq "in_progress" -or $task.status -eq "completed") {
            foreach ($dep in $task.depends_on) {
                if ($Dag.tasks.$dep.status -ne "completed") {
                    $warnings += "Задача '$name' ($($task.status)) зависит от '$dep' ($($Dag.tasks.$dep.status))"
                }
            }
        }
    }
    
    if ($errors.Count -gt 0) {
        Write-Log "❌ ОШИБКИ:" -Color "Red"
        foreach ($error in $errors) {
            Write-Log "  • $error" -Color "Red"
        }
        Write-Log ""
    }
    
    if ($warnings.Count -gt 0) {
        Write-Log "⚠️  ПРЕДУПРЕЖДЕНИЯ:" -Color "Yellow"
        foreach ($warning in $warnings) {
            Write-Log "  • $warning" -Color "Yellow"
        }
        Write-Log ""
    }
    
    if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
        Write-Log "✅ Зависимости в порядке" -Color "Green"
    }
    
    Write-Log ""
    Write-Log "📊 Итого:"
    Write-Log "  • Ошибки: $($errors.Count)"
    Write-Log "  • Предупреждения: $($warnings.Count)"
}

function Visualize-Dag {
    param([object]$Dag)
    
    Write-Log "╔══════════════════════════════════════════════════════════╗"
    Write-Log "║              ВИЗУАЛИЗАЦИЯ DAG $(Get-Date -Format 'HH:mm:ss')                ║"
    Write-Log "╚══════════════════════════════════════════════════════════╝"
    Write-Log ""
    
    $sortedTasks = $Dag.tasks.PSObject.Properties | Sort-Object { $_.Value.order }
    
    Write-Log "ГРАФ ЗАВИСИМОСТЕЙ:"
    Write-Log ""
    
    foreach ($taskProp in $sortedTasks) {
        $task = $taskProp.Value
        $name = $taskProp.Name
        
        $icon = switch ($task.status) {
            "completed" { "✅" }
            "in_progress" { "⏳" }
            "pending" { "⏸️ " }
        }
        
        if ($task.depends_on.Count -eq 0) {
            Write-Log "$icon $name"
        } else {
            foreach ($dep in $task.depends_on) {
                Write-Log "$icon $name ← $dep"
            }
        }
    }
    
    Write-Log ""
    Write-Log "Формат GraphViz (для визуализации):"
    Write-Log ""
    Write-Log "digraph DAG {" -Color "Gray"
    Write-Log "  rankdir=LR;" -Color "Gray"
    
    foreach ($taskProp in $sortedTasks) {
        $task = $taskProp.Value
        $name = $taskProp.Name
        
        $color = switch ($task.status) {
            "completed" { "green" }
            "in_progress" { "yellow" }
            "pending" { "gray" }
        }
        
        Write-Log "  `"$name`" [color=$color];" -Color "Gray"
    }
    
    foreach ($taskProp in $sortedTasks) {
        $task = $taskProp.Value
        $name = $taskProp.Name
        
        foreach ($dep in $task.depends_on) {
            Write-Log "  `"$dep`" -> `"$name`";" -Color "Gray"
        }
    }
    
    Write-Log "}" -Color "Gray"
}

# ----------------------------------------------------------------------------
# ОСНОВНАЯ ЛОГИКА
# ----------------------------------------------------------------------------

try {
    $Dag = Get-Dag
    
    switch ($Action) {
        "list" {
            List-Tasks -Dag $Dag
        }
        "add" {
            if (-not $TaskName) { throw "Укажите имя задачи" }
            if (-not $Status) { $Status = "pending" }
            
            $maxOrder = ($Dag.tasks.PSObject.Properties | Measure-Object { $_.Value.order } -Maximum).Maximum
            $newOrder = $maxOrder + 1
            
            Add-Task -Dag $Dag -Name $TaskName -Title $TaskName -Status $Status -DependsOn $DependsOn -Order $newOrder
            List-Tasks -Dag $Dag
        }
        "update" {
            if (-not $TaskName) { throw "Укажите имя задачи" }
            if (-not $Status) { throw "Укажите статус" }
            
            Update-TaskStatus -Dag $Dag -Name $TaskName -Status $Status
            List-Tasks -Dag $Dag
        }
        "check" {
            Check-Dependencies -Dag $Dag
        }
        "visualize" {
            Visualize-Dag -Dag $Dag
        }
        default {
            Write-Log "❌ Неизвестное действие: $Action" -Color "Red"
            Write-Log ""
            Write-Log "Доступные действия:" -Color "Cyan"
            Write-Log "  list       — Показать все задачи" -Color "Gray"
            Write-Log "  add        — Добавить задачу" -Color "Gray"
            Write-Log "  update     — Обновить статус" -Color "Gray"
            Write-Log "  check      — Проверить зависимости" -Color "Gray"
            Write-Log "  visualize  — Визуализировать граф" -Color "Gray"
        }
    }
    
} catch {
    Write-Log "❌ ОШИБКА: $($_.Exception.Message)" -Color "Red"
    exit 1
}
