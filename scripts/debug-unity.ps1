# ============================================
# Debug Unity — Запуск Unity в режиме отладки
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🐛 ЗАПУСК UNITY В РЕЖИМЕ ОТЛАДКИ" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$unityPath = "C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe"
$projectPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity"

Write-Host "📁 Проект: $projectPath" -ForegroundColor Yellow
Write-Host "🎮 Unity: $unityPath" -ForegroundColor Yellow
Write-Host ""

Write-Host "🔄 Запуск Unity..." -ForegroundColor Yellow

Start-Process $unityPath -ArgumentList "-projectPath", $projectPath, "-debugMode"

Write-Host "✅ Unity запущен в режиме отладки!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 В Visual Studio:" -ForegroundColor Cyan
Write-Host "  1. Откройте DragRaceUnity.sln" -ForegroundColor White
Write-Host "  2. Unity → Attach to Unity" -ForegroundColor White
Write-Host "  3. Установите точки останова" -ForegroundColor White
Write-Host "  4. Нажмите Play в Unity" -ForegroundColor White
Write-Host ""
