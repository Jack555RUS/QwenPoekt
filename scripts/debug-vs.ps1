# ============================================
# Debug Visual Studio — Открытие решения
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🐛 ОТКРЫТИЕ VISUAL STUDIO С ОТЛАДКОЙ" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$slnPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity\DragRaceUnity.sln"
$vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"

Write-Host "📁 Решение: $slnPath" -ForegroundColor Yellow
Write-Host "💻 Visual Studio: $vsPath" -ForegroundColor Yellow
Write-Host ""

Write-Host "🔄 Открытие Visual Studio..." -ForegroundColor Yellow

Start-Process $vsPath -ArgumentList $slnPath, "/debug"

Write-Host "✅ Visual Studio открыт!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Следующие шаги:" -ForegroundColor Cyan
Write-Host "  1. Unity → Attach to Unity" -ForegroundColor White
Write-Host "  2. Установите точки останова" -ForegroundColor White
Write-Host "  3. Нажмите Play в Unity" -ForegroundColor White
Write-Host ""
