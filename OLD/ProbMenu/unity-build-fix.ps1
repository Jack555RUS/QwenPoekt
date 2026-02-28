# =============================================================================
# Скрипт автоматической установки модулей Unity и сборки проекта
# =============================================================================

param(
    [string]$UnityPath = "C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe",
    [string]$ProjectPath = "D:\QwenPoekt\ProbMenu\DragRaceUnity",
    [string]$LogPath = "D:\QwenPoekt\ProbMenu\Builds\unity-build-fix.log"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Unity Build Fix Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Проверка существования Unity
if (-not (Test-Path $UnityPath)) {
    Write-Host "ERROR: Unity not found at $UnityPath" -ForegroundColor Red
    Write-Host "Please update UnityPath parameter" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Unity found: $UnityPath" -ForegroundColor Green

# Проверка существования проекта
if (-not (Test-Path $ProjectPath)) {
    Write-Host "ERROR: Project not found at $ProjectPath" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Project found: $ProjectPath" -ForegroundColor Green

# Создание папки для логов
$logDir = Split-Path $LogPath -Parent
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    Write-Host "[OK] Created log directory: $logDir" -ForegroundColor Green
}

# =============================================================================
# Шаг 1: Проверка и создание Package Manifest
# =============================================================================
Write-Host ""
Write-Host "--- Step 1: Checking Package Manifest ---" -ForegroundColor Yellow

$manifestPath = Join-Path $ProjectPath "Packages\manifest.json"

if (-not (Test-Path $manifestPath)) {
    Write-Host "ERROR: manifest.json not found!" -ForegroundColor Red
    exit 1
}

Write-Host "[OK] manifest.json found" -ForegroundColor Green

# Чтение manifest.json
$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json

# Необходимые пакеты (версии для Unity 6000.3.x)
$requiredPackages = @{
    "com.unity.ugui" = "1.0.0"
    "com.unity.inputsystem" = "1.7.0"
    "com.unity.test-framework" = "1.3.9"
}

$packagesToAdd = @()

foreach ($pkg in $requiredPackages.GetEnumerator()) {
    if ($manifest.dependencies.PSObject.Properties.Name -contains $pkg.Key) {
        Write-Host "[OK] Package exists: $($pkg.Key)" -ForegroundColor Green
    } else {
        Write-Host "[ADD] Missing package: $($pkg.Key) v$($pkg.Value)" -ForegroundColor Yellow
        $packagesToAdd += $pkg.Key
    }
}

# =============================================================================
# Шаг 2: Обновление manifest.json с недостающими пакетами
# =============================================================================
if ($packagesToAdd.Count -gt 0) {
    Write-Host ""
    Write-Host "--- Step 2: Adding Missing Packages ---" -ForegroundColor Yellow
    
    foreach ($pkg in $packagesToAdd) {
        if (-not ($manifest.dependencies.PSObject.Properties.Name -contains $pkg)) {
            $version = $requiredPackages[$pkg]
            $manifest.dependencies | Add-Member -MemberType NoteProperty -Name $pkg -Value $version
            Write-Host "[ADDED] $pkg v$version" -ForegroundColor Green
        }
    }
    
    # Сохранение обновленного manifest.json
    $manifest | ConvertTo-Json -Depth 10 | Out-File $manifestPath -Encoding UTF8
    Write-Host "[OK] manifest.json updated" -ForegroundColor Green
}

# =============================================================================
# Шаг 3: Проверка Assembly Definitions
# =============================================================================
Write-Host ""
Write-Host "--- Step 3: Checking Assembly Definitions ---" -ForegroundColor Yellow

$asmdefPath = "D:\QwenPoekt\ProbMenu\DragRaceUnity\Assets\Scripts\DragRaceUnity.AsmDef"

# Создаём основной Assembly Definition если нет
if (-not (Test-Path $asmdefPath)) {
    $asmdef = @{
        name = "DragRaceUnity"
        rootNamespace = "ProbMenu"
        references = @()
        includePlatforms = @()
        excludePlatforms = @()
        allowUnsafeCode = $false
        overrideReferences = $false
        precompiledReferences = @()
        autoReferenced = $true
        generateReferenceInfo = $false
    }
    
    $asmdef | ConvertTo-Json -Depth 10 | Out-File $asmdefPath -Encoding UTF8
    Write-Host "[CREATED] Main Assembly Definition: DragRaceUnity.AsmDef" -ForegroundColor Green
} else {
    Write-Host "[OK] Assembly Definition exists" -ForegroundColor Green
}

# =============================================================================
# Шаг 4: Проверка Built-in модулей через ProjectSettings
# =============================================================================
Write-Host ""
Write-Host "--- Step 4: Checking Project Settings ---" -ForegroundColor Yellow

$projectSettingsPath = Join-Path $ProjectPath "ProjectSettings\ProjectSettings.asset"

if (Test-Path $projectSettingsPath) {
    $settings = Get-Content $projectSettingsPath -Raw
    
    # Проверка Input System
    if ($settings -match "activeInputHandler: 0") {
        Write-Host "[WARNING] Input System may not be configured" -ForegroundColor Yellow
        Write-Host "  Please set: Edit → Project Settings → Player → Active Input Handling → Both" -ForegroundColor Gray
    } else {
        Write-Host "[OK] Input System configured" -ForegroundColor Green
    }
} else {
    Write-Host "[WARNING] ProjectSettings.asset not found" -ForegroundColor Yellow
}

# =============================================================================
# Шаг 5: Запуск Unity для импорта пакетов
# =============================================================================
Write-Host ""
Write-Host "--- Step 5: Importing Packages in Unity ---" -ForegroundColor Yellow
Write-Host "This may take several minutes..." -ForegroundColor Gray

$unityArgs = @(
    "-batchmode",
    "-nographics",
    "-quit",
    "-projectPath", "`"$ProjectPath`"",
    "-logFile", "`"$LogPath`""
)

Write-Host "Starting Unity..." -ForegroundColor Cyan
Write-Host "Command: $UnityPath $($unityArgs -join ' ')" -ForegroundColor Gray
Write-Host ""

# Запуск Unity
$process = Start-Process -FilePath $UnityPath -ArgumentList $unityArgs -Wait -PassThru

if ($process.ExitCode -eq 0) {
    Write-Host "[OK] Unity completed successfully" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Unity exited with code: $($process.ExitCode)" -ForegroundColor Yellow
}

# =============================================================================
# Шаг 6: Проверка лога на ошибки
# =============================================================================
Write-Host ""
Write-Host "--- Step 6: Checking Build Log ---" -ForegroundColor Yellow

if (Test-Path $LogPath) {
    $logContent = Get-Content $LogPath -Raw
    
    # Проверка на успешный импорт пакетов
    if ($logContent -match "Package Manager") {
        Write-Host "[OK] Package Manager processed" -ForegroundColor Green
    }
    
    # Проверка на ошибки компиляции
    if ($logContent -match "error CS") {
        $errorCount = ([regex]::Matches($logContent, "error CS")).Count
        Write-Host "[ERROR] Found $errorCount compiler errors" -ForegroundColor Red
        
        # Показать последние ошибки
        Write-Host ""
        Write-Host "Last 10 errors:" -ForegroundColor Red
        Get-Content $LogPath | Select-String "error CS" | Select-Object -Last 10 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor DarkRed
        }
    } else {
        Write-Host "[OK] No compiler errors found" -ForegroundColor Green
    }
} else {
    Write-Host "[ERROR] Log file not created" -ForegroundColor Red
}

# =============================================================================
# Шаг 7: Попытка сборки
# =============================================================================
Write-Host ""
Write-Host "--- Step 7: Attempting Build ---" -ForegroundColor Yellow

$buildLogPath = "D:\QwenPoekt\ProbMenu\Builds\unity-build-result.log"

$buildArgs = @(
    "-batchmode",
    "-nographics",
    "-quit",
    "-projectPath", "`"$ProjectPath`"",
    "-executeMethod", "BuildScript.PerformBuild",
    "-logFile", "`"$buildLogPath`""
)

Write-Host "Starting Unity Build..." -ForegroundColor Cyan

$buildProcess = Start-Process -FilePath $UnityPath -ArgumentList $buildArgs -Wait -PassThru

if ($buildProcess.ExitCode -eq 0) {
    Write-Host "[SUCCESS] Build completed successfully!" -ForegroundColor Green
    
    # Проверка наличия собранного файла
    $buildPath = "D:\QwenPoekt\ProbMenu\Builds\DragRace\DragRace.exe"
    if (Test-Path $buildPath) {
        Write-Host "[OK] Build executable found: $buildPath" -ForegroundColor Green
    }
} else {
    Write-Host "[ERROR] Build failed with exit code: $($buildProcess.ExitCode)" -ForegroundColor Red
    
    if (Test-Path $buildLogPath) {
        Write-Host ""
        Write-Host "Build errors:" -ForegroundColor Red
        Get-Content $buildLogPath | Select-String "error" | Select-Object -Last 20 | ForEach-Object {
            Write-Host "  $_" -ForegroundColor DarkRed
        }
    }
}

# =============================================================================
# Завершение
# =============================================================================
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Script Completed" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Log files:" -ForegroundColor Gray
Write-Host "  Import log: $LogPath" -ForegroundColor Gray
Write-Host "  Build log:  $buildLogPath" -ForegroundColor Gray
Write-Host ""

# Пауза для просмотра результатов
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
