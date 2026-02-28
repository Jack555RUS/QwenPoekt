# =============================================================================
# ТЕСТОВОЕ ЗАПУСК (без реальных переменных Unity)
# =============================================================================

param(
    [switch]$DryRun = $true
)

Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "ТЕСТОВЫЙ ЗАПУСК АВТОМАТИЧЕСКОЙ СБОРКИ" -ForegroundColor White
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "D:\QwenPoekt\ProbMenu\DragRaceUnity"
$logsPath = "D:\QwenPoekt\ProbMenu\DragRaceUnity\Logs"
$buildPath = "D:\QwenPoekt\ProbMenu\Builds"

# =============================================================================
# 1. Проверка Docker
# =============================================================================

Write-Host "[1/5] Проверка Docker..." -ForegroundColor Yellow
$dockerVersion = docker --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Docker установлен: $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "  ❌ Docker не найден!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# =============================================================================
# 2. Проверка переменных окружения
# =============================================================================

Write-Host "[2/5] Проверка переменных окружения..." -ForegroundColor Yellow
$unityEmail = [Environment]::GetEnvironmentVariable("UNITY_EMAIL", "User")
$unityPassword = [Environment]::GetEnvironmentVariable("UNITY_PASSWORD", "User")

if ([string]::IsNullOrEmpty($unityEmail)) {
    Write-Host "  ⚠️  UNITY_EMAIL не установлен" -ForegroundColor Yellow
    Write-Host "     Для реальной сборки установите:" -ForegroundColor Gray
    Write-Host "     [Environment]::SetEnvironmentVariable('UNITY_EMAIL', 'email', 'User')" -ForegroundColor Gray
} else {
    Write-Host "  ✅ UNITY_EMAIL установлен" -ForegroundColor Green
}

if ([string]::IsNullOrEmpty($unityPassword)) {
    Write-Host "  ⚠️  UNITY_PASSWORD не установлен" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ UNITY_PASSWORD установлен" -ForegroundColor Green
}
Write-Host ""

# =============================================================================
# 3. Проверка проекта
# =============================================================================

Write-Host "[3/5] Проверка проекта..." -ForegroundColor Yellow
if (Test-Path $projectPath) {
    Write-Host "  ✅ Проект найден: $projectPath" -ForegroundColor Green
    
    $scriptsCount = (Get-ChildItem -Path "$projectPath\Assets\Scripts" -Recurse -Filter *.cs).Count
    Write-Host "  ✅ Скриптов найдено: $scriptsCount" -ForegroundColor Green
} else {
    Write-Host "  ❌ Проект не найден!" -ForegroundColor Red
    exit 1
}
Write-Host ""

# =============================================================================
# 4. Очистка логов
# =============================================================================

Write-Host "[4/5] Очистка логов..." -ForegroundColor Yellow
if (Test-Path $logsPath) {
    $logFiles = Get-ChildItem -Path $logsPath -Filter *.log
    if ($logFiles.Count -gt 0) {
        $logFiles | Remove-Item -Force
        Write-Host "  ✅ Удалено логов: $($logFiles.Count)" -ForegroundColor Green
    } else {
        Write-Host "  ℹ️  Логи уже чисты" -ForegroundColor Gray
    }
}

$buildLog = Join-Path $buildPath "build.log"
if (Test-Path $buildLog) {
    Remove-Item $buildLog -Force
    Write-Host "  ✅ build.log удалён" -ForegroundColor Green
}
Write-Host ""

# =============================================================================
# 5. Сухой запуск (Dry Run)
# =============================================================================

if ($DryRun) {
    Write-Host "[5/5] ТЕСТОВЫЙ РЕЖИМ (Dry Run)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Для РЕАЛЬНОЙ сборки в Docker необходимо:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Установить переменные окружения:" -ForegroundColor White
    Write-Host "   `"UNITY_EMAIL`" = ваш email от Unity" -ForegroundColor Gray
    Write-Host "   `"UNITY_PASSWORD`" = ваш пароль от Unity" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Запустить команду:" -ForegroundColor White
    Write-Host "   .\docker\scripts\unity-auto-build.ps1" -ForegroundColor Gray
    Write-Host ""
    Write-Host "ИЛИ с существующими переменными:" -ForegroundColor White
    Write-Host "   docker run --rm -v ... gameci/unity-builder:2022.3-win ..." -ForegroundColor Gray
    Write-Host ""
} else {
    Write-Host "[5/5] Запуск Docker сборки..." -ForegroundColor Yellow
    # Здесь был бы реальный запуск Docker
    Write-Host "  ℹ️  Требуется UNITY_EMAIL и UNITY_PASSWORD" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "ТЕСТ ЗАВЕРШЁН" -ForegroundColor White
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "Статус: ✅ ТЕСТОВЫЙ ЗАПУСК УСПЕШЕН" -ForegroundColor Green
    Write-Host ""
    Write-Host "Следующие шаги:" -ForegroundColor Yellow
    Write-Host "1. Установите UNITY_EMAIL и UNITY_PASSWORD" -ForegroundColor White
    Write-Host "2. Запустите: .\docker\scripts\unity-auto-build.ps1" -ForegroundColor White
    Write-Host ""
}
