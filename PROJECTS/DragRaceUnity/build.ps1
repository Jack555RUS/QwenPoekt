# Скрипт сборки Unity билда для DragRaceUnity
# Требует установленный Unity 6000.3.10f1

$unityPath = "C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe"
$projectPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity"
$buildPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity\Build\DragRace.exe"

Write-Host "=== Сборка DragRaceUnity ===" -ForegroundColor Cyan
Write-Host "Unity: $unityPath"
Write-Host "Проект: $projectPath"
Write-Host "Билд: $buildPath"
Write-Host ""

# Создаём папку для билда
$buildDir = Split-Path $buildPath -Parent
if (!(Test-Path $buildDir)) {
    New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
    Write-Host "Создана папка: $buildDir" -ForegroundColor Green
}

# Запускаем Unity в пакетном режиме
Write-Host "Запуск сборки..." -ForegroundColor Yellow

& $unityPath -batchmode -quit -projectPath $projectPath -executeMethod "BuildScript.PerformBuild" -logFile build.log

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "=== Сборка завершена успешно! ===" -ForegroundColor Green
    Write-Host "EXE файл: $buildPath"
} else {
    Write-Host ""
    Write-Host "=== Ошибка сборки (код: $LASTEXITCODE) ===" -ForegroundColor Red
    Write-Host "Проверьте build.log для деталей"
}
