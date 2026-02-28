# Проверка переменных окружения Unity

Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "ПРОВЕРКА ПЕРЕМЕННЫХ ОКРУЖЕНИЯ UNITY" -ForegroundColor White
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""

# Проверка на уровне сессии
Write-Host "[1/3] Проверка текущей сессии..." -ForegroundColor Yellow
$sessionEmail = $env:UNITY_EMAIL
$sessionPassword = $env:UNITY_PASSWORD

if ([string]::IsNullOrEmpty($sessionEmail)) {
    Write-Host "  ❌ UNITY_EMAIL: НЕ УСТАНОВЛЕН" -ForegroundColor Red
} else {
    Write-Host "  ✅ UNITY_EMAIL: $sessionEmail" -ForegroundColor Green
}

if ([string]::IsNullOrEmpty($sessionPassword)) {
    Write-Host "  ❌ UNITY_PASSWORD: НЕ УСТАНОВЛЕН" -ForegroundColor Red
} else {
    Write-Host "  ✅ UNITY_PASSWORD: ********" -ForegroundColor Green
}
Write-Host ""

# Проверка на уровне пользователя
Write-Host "[2/3] Проверка на уровне пользователя..." -ForegroundColor Yellow
$userEmail = [Environment]::GetEnvironmentVariable("UNITY_EMAIL", "User")
$userPassword = [Environment]::GetEnvironmentVariable("UNITY_PASSWORD", "User")

if ([string]::IsNullOrEmpty($userEmail)) {
    Write-Host "  ❌ UNITY_EMAIL: НЕ УСТАНОВЛЕН" -ForegroundColor Red
} else {
    Write-Host "  ✅ UNITY_EMAIL: $userEmail" -ForegroundColor Green
}

if ([string]::IsNullOrEmpty($userPassword)) {
    Write-Host "  ❌ UNITY_PASSWORD: НЕ УСТАНОВЛЕН" -ForegroundColor Red
} else {
    Write-Host "  ✅ UNITY_PASSWORD: ********" -ForegroundColor Green
}
Write-Host ""

# Проверка Docker
Write-Host "[3/3] Проверка Docker..." -ForegroundColor Yellow
$dockerVersion = docker --version 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✅ Docker: $dockerVersion" -ForegroundColor Green
} else {
    Write-Host "  ❌ Docker: НЕ УСТАНОВЛЕН" -ForegroundColor Red
}
Write-Host ""

# Итог
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "ИТОГИ" -ForegroundColor White
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""

if (-not [string]::IsNullOrEmpty($userEmail) -and -not [string]::IsNullOrEmpty($userPassword)) {
    Write-Host "✅ ПЕРЕМЕННЫЕ УСТАНОВЛЕНЫ КОРЕКТНО!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Можно запускать сборку:" -ForegroundColor Cyan
    Write-Host "  .\docker\scripts\unity-auto-build.bat" -ForegroundColor White
} else {
    Write-Host "❌ ПЕРЕМЕННЫЕ НЕ УСТАНОВЛЕНЫ!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Для установки выполните:" -ForegroundColor Cyan
    Write-Host "  1. Откройте PowerShell ОТ АДМИНИСТРАТОРА" -ForegroundColor White
    Write-Host "  2. Выполните:" -ForegroundColor White
    Write-Host "     [Environment]::SetEnvironmentVariable('UNITY_EMAIL', 'email', 'User')" -ForegroundColor Gray
    Write-Host "     [Environment]::SetEnvironmentVariable('UNITY_PASSWORD', 'password', 'User')" -ForegroundColor Gray
    Write-Host "  3. Закройте PowerShell и откройте НОВЫЙ" -ForegroundColor White
    Write-Host "  4. Запустите этот скрипт снова для проверки" -ForegroundColor White
    Write-Host ""
    Write-Host "ИЛИ используйте скрипт установки:" -ForegroundColor Cyan
    Write-Host "  .\docker\scripts\set-unity-vars.ps1" -ForegroundColor White
}

Write-Host ""
