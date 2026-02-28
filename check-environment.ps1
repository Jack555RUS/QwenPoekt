# ============================================
# Проверка окружения проекта DragRaceUnity
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ПРОВЕРКА ОКРУЖЕНИЯ" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Проверка Unity
Write-Host "🔍 Unity..." -ForegroundColor Yellow
$unityPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\Unity Technologies\Installer" -ErrorAction SilentlyContinue
if ($unityPath) {
    Write-Host "  ✅ Unity установлен" -ForegroundColor Green
} else {
    Write-Host "  ❌ Unity не найден" -ForegroundColor Red
}

# Проверка Visual Studio
Write-Host ""
Write-Host "🔍 Visual Studio..." -ForegroundColor Yellow
$vsPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\SxS\VS7" -ErrorAction SilentlyContinue
if ($vsPath) {
    Write-Host "  ✅ Visual Studio установлен" -ForegroundColor Green
} else {
    Write-Host "  ❌ Visual Studio не найден" -ForegroundColor Red
}

# Проверка .NET SDK
Write-Host ""
Write-Host "🔍 .NET SDK..." -ForegroundColor Yellow
try {
    $dotnetVersion = dotnet --version
    Write-Host "  ✅ .NET SDK: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ .NET SDK не найден" -ForegroundColor Red
}

# Проверка расширений VS Code
Write-Host ""
Write-Host "🔍 VS Code расширения..." -ForegroundColor Yellow
$extensions = code --list-extensions 2>$null
$requiredExtensions = @(
    "streetsidesoftware.code-spell-checker",
    "streetsidesoftware.code-spell-checker-russian"
)

foreach ($ext in $requiredExtensions) {
    if ($extensions -like "*$ext*") {
        Write-Host "  ✅ $ext" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $ext (не установлен)" -ForegroundColor Red
    }
}

# Проверка анализаторов в проекте
Write-Host ""
Write-Host "🔍 Анализаторы проекта..." -ForegroundColor Yellow
$projectPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity\packages.config"
if (Test-Path $projectPath) {
    $packages = Get-Content $projectPath
    $analyzers = @("StyleCop", "SonarAnalyzer", "Microsoft.Unity.Analyzers")
    
    foreach ($analyzer in $analyzers) {
        if ($packages -like "*$analyzer*") {
            Write-Host "  ✅ $analyzer" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  $analyzer (не найден)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "  ⚠️  packages.config не найден" -ForegroundColor Yellow
}

# Проверка Incredibuild
Write-Host ""
Write-Host "🔍 Incredibuild..." -ForegroundColor Yellow
$ibService = Get-Service -Name "*incredibuild*" -ErrorAction SilentlyContinue
if ($ibService) {
    Write-Host "  ✅ Incredibuild: $($ibService.Status)" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Incredibuild не найден" -ForegroundColor Yellow
}

# Проверка структуры проекта
Write-Host ""
Write-Host "🔍 Структура проекта..." -ForegroundColor Yellow
$requiredFolders = @(
    "D:\QwenPoekt\PROJECTS\DragRaceUnity\Assets",
    "D:\QwenPoekt\PROJECTS\DragRaceUnity\ProjectSettings",
    "D:\QwenPoekt\KNOWLEDGE_BASE",
    "D:\QwenPoekt\.qwen"
)

foreach ($folder in $requiredFolders) {
    if (Test-Path $folder) {
        Write-Host "  ✅ $folder" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $folder (не найдена)" -ForegroundColor Red
    }
}

# Проверка файлов документации
Write-Host ""
Write-Host "🔍 Документация..." -ForegroundColor Yellow
$requiredFiles = @(
    "D:\QwenPoekt\ДЛЯ_ИИ_ЧИТАТЬ_СЮДА.md",
    "D:\QwenPoekt\ТЕКУЩАЯ_ЗАДАЧА.md",
    "D:\QwenPoekt\.qwen\QWEN.md",
    "D:\QwenPoekt\PROJECTS\DragRaceUnity\README.md",
    "D:\QwenPoekt\KNOWLEDGE_BASE\00_README.md"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file (не найден)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ПРОВЕРКА ЗАВЕРШЕНА" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
