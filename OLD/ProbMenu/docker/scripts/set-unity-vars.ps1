# Установка переменных окружения для Unity Build
# Запускать от имени Администратора!

Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host "Установка переменных окружения для Unity" -ForegroundColor White
Write-Host "=============================================================================" -ForegroundColor Cyan
Write-Host ""

# Запрос переменных
$unityEmail = Read-Host "Введите UNITY_EMAIL (ваш email от Unity)"
$unityPassword = Read-Host "Введите UNITY_PASSWORD (ваш пароль от Unity)" -AsSecureString

# Проверка
if ([string]::IsNullOrEmpty($unityEmail)) {
    Write-Host "❌ UNITY_EMAIL не может быть пустым!" -ForegroundColor Red
    exit 1
}

# Преобразование пароля
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($unityPassword)
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

# Установка переменных на уровне пользователя
[Environment]::SetEnvironmentVariable("UNITY_EMAIL", $unityEmail, "User")
[Environment]::SetEnvironmentVariable("UNITY_PASSWORD", $plainPassword, "User")

Write-Host ""
Write-Host "=============================================================================" -ForegroundColor Green
Write-Host "ПЕРЕМЕННЫЕ УСТАНОВЛЕНЫ!" -ForegroundColor Green
Write-Host "=============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Установлено:" -ForegroundColor Cyan
Write-Host "  UNITY_EMAIL: $unityEmail" -ForegroundColor White
Write-Host "  UNITY_PASSWORD: ********" -ForegroundColor White
Write-Host ""
Write-Host "ВНИМАНИЕ:" -ForegroundColor Yellow
Write-Host "  Для применения переменных необходимо:" -ForegroundColor Gray
Write-Host "  1. Закрыть этот PowerShell" -ForegroundColor Gray
Write-Host "  2. Открыть НОВЫЙ PowerShell" -ForegroundColor Gray
Write-Host "  3. Запустить: .\docker\scripts\unity-auto-build.bat" -ForegroundColor Gray
Write-Host ""

# Проверка
Write-Host "Проверка..." -ForegroundColor Cyan
$checkEmail = [Environment]::GetEnvironmentVariable("UNITY_EMAIL", "User")
$checkPassword = [Environment]::GetEnvironmentVariable("UNITY_PASSWORD", "User")

if ($checkEmail -eq $unityEmail) {
    Write-Host "  ✅ UNITY_EMAIL установлен корректно" -ForegroundColor Green
} else {
    Write-Host "  ❌ UNITY_EMAIL не установлен!" -ForegroundColor Red
}

if (-not [string]::IsNullOrEmpty($checkPassword)) {
    Write-Host "  ✅ UNITY_PASSWORD установлен корректно" -ForegroundColor Green
} else {
    Write-Host "  ❌ UNITY_PASSWORD не установлен!" -ForegroundColor Red
}

Write-Host ""
