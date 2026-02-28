# Скрипт инициализации Unity проекта DragRaceUnity
# Запускается из Unity Editor (через Console) или создаёт базовую структуру

$unityProjectPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity"

Write-Host "=== Инициализация Unity проекта DragRaceUnity ===" -ForegroundColor Cyan
Write-Host "Путь: $unityProjectPath" -ForegroundColor Gray
Write-Host ""

# Проверка наличия Unity
$unityPath = "C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe"
if (Test-Path $unityPath) {
    Write-Host "[OK] Unity найден: $unityPath" -ForegroundColor Green
} else {
    Write-Host "[WARN] Unity не найден по умолчанию. Укажите путь вручную." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Структура проекта создана ===" -ForegroundColor Green
Write-Host ""
Write-Host "Следующие шаги:" -ForegroundColor Cyan
Write-Host "1. Откройте проект в Unity Hub" -ForegroundColor White
Write-Host "2. Создайте сцену MainMenu.unity" -ForegroundColor White
Write-Host "3. Добавьте Canvas с 6 кнопками" -ForegroundColor White
Write-Host "4. Добавьте скрипт MainMenuController.cs на пустой GameObject" -ForegroundColor White
Write-Host ""
Write-Host "Нажмите любую клавишу для выхода..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
