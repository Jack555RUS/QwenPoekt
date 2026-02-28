# =============================================================================
# Скрипт для открытия проекта в Unity Editor (для ручной настройки)
# =============================================================================

param(
    [string]$UnityPath = "C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe",
    [string]$ProjectPath = "D:\QwenPoekt\ProbMenu\DragRaceUnity"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Unity Project Opener" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Opening project in Unity Editor..." -ForegroundColor Yellow
Write-Host ""
Write-Host "INSTRUCTIONS:" -ForegroundColor Cyan
Write-Host "1. Wait for Unity to finish importing packages" -ForegroundColor White
Write-Host "2. Open Package Manager: Window → Package Manager" -ForegroundColor White
Write-Host "3. Make sure these packages are installed:" -ForegroundColor White
Write-Host "   - UI Toolkit" -ForegroundColor Gray
Write-Host "   - Input System" -ForegroundColor Gray
Write-Host "   - Particle System (Built-in)" -ForegroundColor Gray
Write-Host "   - Audio (Built-in)" -ForegroundColor Gray
Write-Host "4. Close Unity when done" -ForegroundColor White
Write-Host ""
Write-Host "Starting Unity..." -ForegroundColor Green

Start-Process -FilePath $UnityPath -ArgumentList "-projectPath", "`"$ProjectPath`""

Write-Host ""
Write-Host "Unity is starting..." -ForegroundColor Yellow
