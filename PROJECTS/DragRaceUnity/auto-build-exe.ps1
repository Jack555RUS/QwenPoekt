# Автоматическая сборка EXE для DragRaceUnity
# Создаёт билд после успешной компиляции

$ErrorActionPreference = "Stop"
$projectPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity"
$unityPath = "C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe"
$buildOutput = "$projectPath\Build\DragRace.exe"
$logFile = "$projectPath\build_exe.log"

Write-Host "=== Сборка EXE для DragRaceUnity ===" -ForegroundColor Cyan
Write-Host "Проект: $projectPath"
Write-Host "Выходной файл: $buildOutput"
Write-Host ""

# Очистка логов перед сборкой
Write-Host "[Очистка] Удаление старых логов..." -ForegroundColor Yellow
$logsToDelete = @(
    "$projectPath\build_exe.log",
    "$projectPath\autofix.log",
    "$projectPath\compile_attempt_*.log"
)
foreach ($log in $logsToDelete) {
    $files = Get-Item $log -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        Remove-Item $file.FullName -Force
    }
}
Write-Host "[Очистка] Готово" -ForegroundColor Green
Write-Host ""

# Создаём папку для билда
$buildDir = Split-Path $buildOutput -Parent
if (!(Test-Path $buildDir)) {
    New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
    Write-Host "[Создано] Папка: $buildDir" -ForegroundColor Green
}

# Очищаем старый билд
if (Test-Path $buildDir) {
    Write-Host "[Очистка] Удаление старого билда..." -ForegroundColor Yellow
    Get-ChildItem -Path $buildDir -Recurse | Remove-Item -Force -Recurse
    Write-Host "[Очистка] Готово" -ForegroundColor Green
}

Write-Host ""
Write-Host "[Сборка] Запуск Unity для сборки..." -ForegroundColor Yellow

# Запускаем Unity для сборки
$proc = Start-Process -FilePath $unityPath `
    -ArgumentList "-batchmode", "-quit", "-projectPath", $projectPath, 
                  "-executeMethod", "BuildScript.PerformBuild", "-logFile", $logFile `
    -Wait -PassThru -NoNewWindow

Write-Host ""

# Проверяем результат
if (Test-Path $buildOutput) {
    $size = (Get-Item $buildOutput).Length / 1MB
    Write-Host "=== СБОРКА УСПЕШНА! ===" -ForegroundColor Green
    Write-Host "EXE файл: $buildOutput"
    Write-Host "Размер: $([math]::Round($size, 2)) MB"
    Write-Host ""
    Write-Host "Запуск игры..." -ForegroundColor Cyan
    
    # Запускаем игру для быстрой проверки
    Start-Process $buildOutput
    Write-Host "Игра запущена!" -ForegroundColor Green
}
else {
    Write-Host "=== СБОРКА НЕУДАЧНА ===" -ForegroundColor Red
    Write-Host "Проверьте лог: $logFile"
    
    if (Test-Path $logFile) {
        Write-Host ""
        Write-Host "Последние строки лога:" -ForegroundColor Yellow
        Get-Content $logFile -Tail 20
    }
}

Write-Host ""
Write-Host "Нажмите любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
