# unity-build.ps1
# Автоматическая сборка Drag Racing Unity проекта

param(
    [string]$unityPath = "C:\Program Files\Unity\Hub\Editor\6000.0.0f1\Editor\Unity.exe",
    [string]$projectPath = "D:\QwenPoekt\ProbMenu\DragRaceUnity",
    [string]$buildPath = "D:\QwenPoekt\ProbMenu\DragRaceUnity\Builds\DragRacing.exe",
    [switch]$clean,
    [switch]$help
)

if ($help) {
    Write-Host @"
Drag Racing Unity Build Script

Использование:
  .\unity-build.ps1 [-unityPath <path>] [-projectPath <path>] [-buildPath <path>] [-clean]

Параметры:
  -unityPath    Путь к Unity.exe (по умолчанию: стандартный путь)
  -projectPath  Путь к проекту Unity
  -buildPath    Путь для выходного файла билда
  -clean        Очистить папку Builds перед сборкой
  -help         Показать эту справку

Примеры:
  .\unity-build.ps1
  .\unity-build.ps1 -clean
  .\unity-build.ps1 -buildPath "C:\MyBuilds\DragRacing.exe"

"@
    exit
}

# Проверка существования Unity
if (-not (Test-Path $unityPath)) {
    Write-Host "❌ Unity не найден по пути: $unityPath" -ForegroundColor Red
    Write-Host "Укажите правильный путь через -unityPath" -ForegroundColor Yellow
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Drag Racing Unity Build" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Очистка
if ($clean) {
    Write-Host "[1/4] Очистка папки Builds..." -ForegroundColor Yellow
    $buildsDir = Split-Path $buildPath -Parent
    if (Test-Path $buildsDir) {
        Remove-Item $buildsDir -Recurse -Force
        Write-Host "  ✅ Папка очищена" -ForegroundColor Green
    }
} else {
    Write-Host "[1/4] Пропуск очистки (используйте -clean для очистки)" -ForegroundColor Gray
}

# Создание папки для билда
Write-Host "[2/4] Создание папки для билда..." -ForegroundColor Yellow
$buildsDir = Split-Path $buildPath -Parent
if (-not (Test-Path $buildsDir)) {
    New-Item -ItemType Directory -Path $buildsDir | Out-Null
    Write-Host "  ✅ Папка создана: $buildsDir" -ForegroundColor Green
}

# Запуск Unity с сборкой
Write-Host "[3/4] Запуск Unity..." -ForegroundColor Yellow
Write-Host "  Проект: $projectPath"
Write-Host "  Билд: $buildPath"
Write-Host ""

$arguments = @(
    "-batchmode"
    "-nographics"
    "-projectPath `"$projectPath`""
    "-executeMethod ProbMenu.Editor.AutoBuildScript.BuildWindowsX64"
    "-quit"
    "-logFile build-log.txt"
)

Write-Host "Аргументы: $($arguments -join ' ')" -ForegroundColor Gray
Write-Host ""

try {
    $process = Start-Process -FilePath $unityPath -ArgumentList $arguments -PassThru -Wait
    
    Write-Host "[4/4] Ожидание завершения сборки..." -ForegroundColor Yellow
    
    if ($process.WaitForExit(600000)) { # 10 минут таймаут
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        
        # Проверка результата
        if (Test-Path $buildPath) {
            Write-Host "  ✅ СБОРКА УСПЕШНА!" -ForegroundColor Green
            Write-Host "  Файл: $buildPath" -ForegroundColor White
            
            $size = (Get-Item $buildPath).Length / 1MB
            Write-Host "  Размер: $([math]::Round($size, 2)) MB" -ForegroundColor White
            Write-Host ""
            Write-Host "  Запустить? (Y/N): " -NoNewline -ForegroundColor Yellow
            $response = Read-Host
            if ($response -eq 'Y' -or $response -eq 'y') {
                Start-Process $buildPath
            }
        } else {
            Write-Host "  ❌ Билд не найден!" -ForegroundColor Red
            Write-Host "  Проверьте build-log.txt для деталей" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ⏱️ Таймаут! Сборка длилась больше 10 минут" -ForegroundColor Red
        $process.Kill()
    }
} catch {
    Write-Host "  ❌ Ошибка: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Готово!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
