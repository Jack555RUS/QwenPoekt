# =============================================================================
# PowerShell скрипт для автоматической сборки DragRace.exe
# =============================================================================
# Использование: .\scripts\build-unity.ps1 [-BuildPath "путь"]
# =============================================================================

param(
    [string]$BuildPath = "D:\QwenPoekt\ProbMenu\Builds",
    [string]$BuildName = "DragRace",
    [switch]$CleanBuild = $true
)

# =============================================================================
# Конфигурация
# =============================================================================
$UnityEditorPath = "C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe"
$ProjectPath = "D:\QwenPoekt\ProbMenu\DragRaceUnity"
$LogFile = "D:\QwenPoekt\ProbMenu\Builds\build_log.txt"

# =============================================================================
# Функции
# =============================================================================

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor White
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Text)
    Write-Host ""
    Write-Host "▶ $Text" -ForegroundColor Green
    Write-Host ""
}

function Write-Error-Custom {
    param([string]$Text)
    Write-Host ""
    Write-Host "❌ ОШИБКА: $Text" -ForegroundColor Red
    Write-Host ""
}

function Write-Success {
    param([string]$Text)
    Write-Host ""
    Write-Host "✅ $Text" -ForegroundColor Green
    Write-Host ""
}

# =============================================================================
# Основная логика
# =============================================================================

Write-Header "DragRace Unity Build Script"

Write-Host "Дата: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Путь к проекту: $ProjectPath"
Write-Host "Путь к сборке: $BuildPath"
Write-Host "Имя сборки: $BuildName"
Write-Host ""

# Проверка существования Unity
Write-Step "Проверка Unity Editor"
if (Test-Path $UnityEditorPath) {
    Write-Success "Unity Editor найден: $UnityEditorPath"
} else {
    Write-Error-Custom "Unity Editor не найден по пути: $UnityEditorPath"
    Write-Host "Проверьте путь к Unity Editor в переменной `$UnityEditorPath"
    exit 1
}

# Проверка существования проекта
Write-Step "Проверка проекта"
if (Test-Path $ProjectPath) {
    Write-Success "Проект найден: $ProjectPath"
} else {
    Write-Error-Custom "Проект не найден: $ProjectPath"
    exit 1
}

# Создание папки для сборки
Write-Step "Создание папки для сборки"
if (-not (Test-Path $BuildPath)) {
    New-Item -ItemType Directory -Path $BuildPath | Out-Null
    Write-Success "Папка создана: $BuildPath"
} else {
    Write-Success "Папка существует: $BuildPath"
}

# Очистка старой сборки
if ($CleanBuild) {
    Write-Step "Очистка старой сборки"
    $oldBuildPath = Join-Path $BuildPath $BuildName
    if (Test-Path $oldBuildPath) {
        Remove-Item -Path $oldBuildPath -Recurse -Force
        Write-Success "Старая сборка удалена"
    } else {
        Write-Host "Старая сборка не найдена, очистка не требуется" -ForegroundColor Yellow
    }
}

# Запуск сборки
Write-Header "Запуск сборки"

$arguments = @(
    "-batchmode",
    "-quit",
    "-projectPath `"$ProjectPath`"",
    "-buildTarget standalone",
    "-executeMethod BuildScript.PerformBuild",
    "-logFile `"$LogFile`""
)

Write-Host "Команда:"
Write-Host "`"$UnityEditorPath`" $($arguments -join ' ')" -ForegroundColor Gray
Write-Host ""

Write-Step "Сборка проекта (это может занять 2-5 минут)..."

try {
    $process = Start-Process -FilePath $UnityEditorPath `
        -ArgumentList $arguments `
        -Wait `
        -PassThru `
        -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        Write-Success "Сборка завершена успешно!"
        Write-Host "Путь к сборке: $(Join-Path $BuildPath $BuildName)"
    } else {
        Write-Error-Custom "Сборка завершилась с ошибкой (код: $($process.ExitCode))"
        Write-Host "Проверьте лог файл: $LogFile"
    }
} catch {
    Write-Error-Custom "Ошибка при запуске Unity: $_"
    exit 1
}

# Проверка результата
Write-Step "Проверка результата"
$finalBuildPath = Join-Path $BuildPath "$BuildName\$BuildName.exe"
if (Test-Path $finalBuildPath) {
    Write-Success "EXE файл создан: $finalBuildPath"
    
    $fileSize = (Get-Item $finalBuildPath).Length / 1MB
    Write-Host "Размер файла: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Cyan
} else {
    Write-Error-Custom "EXE файл не найден: $finalBuildPath"
    Write-Host "Проверьте лог файл: $LogFile" -ForegroundColor Yellow
}

Write-Header "Сборка завершена"

Write-Host ""
Write-Host "Следующие шаги:" -ForegroundColor Cyan
Write-Host "1. Перейти в папку: $BuildPath\$BuildName"
Write-Host "2. Запустить: $BuildName.exe"
Write-Host "3. Протестировать игру"
Write-Host ""
