# Автоматическая настройка MainMenu через Unity Editor
# Запускает Editor скрипт MainMenuAutoFix

$unityPath = "C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe"
$projectPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity"
$logFile = "$projectPath\autofix.log"

Write-Host "=== Автоматическая настройка MainMenu ===" -ForegroundColor Cyan
Write-Host "Проект: $projectPath"
Write-Host ""

# Запускаем Unity с выполнением скрипта
Write-Host "[Запуск] Unity Editor..." -ForegroundColor Yellow

$process = Start-Process -FilePath $unityPath `
    -ArgumentList "-batchmode", "-quit", "-projectPath", $projectPath, 
                  "-executeMethod", "MainMenuAutoFix.FixMainMenu", 
                  "-logFile", $logFile `
    -Wait -PassThru -NoNewWindow

Write-Host ""

if ($process.ExitCode -eq 0) {
    Write-Host "=== НАСТРОЙКА УСПЕШНА! ===" -ForegroundColor Green
    Write-Host "EXE файл: $projectPath\Build\DragRace.exe"
    Write-Host ""
    Write-Host "Запуск игры..." -ForegroundColor Cyan
    Start-Process "$projectPath\Build\DragRace.exe"
} else {
    Write-Host "=== ОШИБКА НАСТРОЙКИ ===" -ForegroundColor Red
    Write-Host "Код ошибки: $($process.ExitCode)"
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
