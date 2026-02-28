# ============================================
# Connect GitHub Repository — Подключение к GitHub
# ============================================

param(
    [string]$githubUser = "Jackal",
    [string]$repoName = "QwenPoekt"
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🔗 ПОДКЛЮЧЕНИЕ К GITHUB" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$gitPath = "C:\Program Files\Git\bin\git.exe"

# Проверка Git
if (!(Test-Path $gitPath)) {
    Write-Host "❌ Git не найден!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Git найден" -ForegroundColor Green
Write-Host ""

# Шаг 1: Проверка remote
Write-Host "1️⃣ Проверка remote..." -ForegroundColor Yellow
$remote = & $gitPath remote get-url origin 2>&1

if ($remote -like "*fatal*") {
    Write-Host "  ℹ️  Remote не найден" -ForegroundColor Gray
} else {
    Write-Host "  ✅ Remote найден: $remote" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 Remote уже настроен! Пропускаем этот шаг." -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# Шаг 2: Инструкция по созданию репозитория
Write-Host "2️⃣ Создание репозитория на GitHub" -ForegroundColor Yellow
Write-Host ""
Write-Host "  📝 Откройте в браузере:" -ForegroundColor Cyan
Write-Host "  https://github.com/new" -ForegroundColor White
Write-Host ""
Write-Host "  📝 Введите:" -ForegroundColor Cyan
Write-Host "  Repository name: $repoName" -ForegroundColor White
Write-Host "  Description: Knowledge Base & DragRaceUnity Project" -ForegroundColor White
Write-Host "  Visibility: Public или Private" -ForegroundColor White
Write-Host ""
Write-Host "  ⚠️  НЕ нажимайте 'Initialize with README'" -ForegroundColor Red
Write-Host ""
Write-Host "  Нажмите 'Create repository' и вернитесь..." -ForegroundColor Yellow
Write-Host ""

# Ожидание подтверждения
$continue = Read-Host "Готово? (y/n)"
if ($continue -ne "y") {
    Write-Host "❌ Отменено" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Шаг 3: Добавление remote
Write-Host "3️⃣ Добавление remote..." -ForegroundColor Yellow

$httpsUrl = "https://github.com/$githubUser/$repoName.git"
$sshUrl = "git@github.com:$githubUser/$repoName.git"

Write-Host ""
Write-Host "  Выберите тип подключения:" -ForegroundColor Cyan
Write-Host "  1 - HTTPS (рекомендуется)" -ForegroundColor White
Write-Host "  2 - SSH (если настроен)" -ForegroundColor White
$choice = Read-Host "Ваш выбор (1 или 2)"

if ($choice -eq "1") {
    & $gitPath remote add origin $httpsUrl
    Write-Host "  ✅ Remote добавлен (HTTPS)" -ForegroundColor Green
} elseif ($choice -eq "2") {
    & $gitPath remote add origin $sshUrl
    Write-Host "  ✅ Remote добавлен (SSH)" -ForegroundColor Green
} else {
    Write-Host "❌ Неверный выбор" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Шаг 4: Проверка remote
Write-Host "4️⃣ Проверка remote..." -ForegroundColor Yellow
$remote = & $gitPath remote get-url origin

Write-Host "  ✅ Remote: $remote" -ForegroundColor Green
Write-Host ""

# Шаг 5: Загрузка коммитов
Write-Host "5️⃣ Загрузка коммитов на GitHub" -ForegroundColor Yellow
Write-Host ""
Write-Host "  💡 Выполните команду:" -ForegroundColor Cyan
Write-Host "  git push -u origin master" -ForegroundColor White
Write-Host ""

$push = Read-Host "Выполнить push сейчас? (y/n)"
if ($push -eq "y") {
    Write-Host ""
    Write-Host "  🔄 Загрузка..." -ForegroundColor Yellow
    & $gitPath push -u origin master
    Write-Host "  ✅ Готово!" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ПОДКЛЮЧЕНИЕ ЗАВЕРШЕНО" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 Ваш репозиторий:" -ForegroundColor Cyan
Write-Host "https://github.com/$githubUser/$repoName" -ForegroundColor White
Write-Host ""
