# -*- coding: utf-8 -*-
# Racing Game Auto Build Script
# Usage: .\build.ps1 [-RunTests] [-BuildOnly] [-Help]

param(
    [string]$UnityEditorPath = "C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe",
    [string]$ProjectPath = "D:\QwenPoekt\Prob",
    [string]$BuildOutput = "D:\QwenPoekt\Prob\Build",
    [switch]$RunTests,
    [switch]$BuildOnly,
    [switch]$Help
)

function Show-Help {
    Write-Host "=== Racing Game Build Script ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\build.ps1 [-RunTests] [-BuildOnly] [-Help]"
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Yellow
    Write-Host "  -RunTests   Run tests before build"
    Write-Host "  -BuildOnly  Build only without tests"
    Write-Host "  -Help       Show this help"
    Write-Host ""
}

if ($Help) {
    Show-Help
    exit 0
}

# Check Unity path
if (-not (Test-Path $UnityEditorPath)) {
    Write-Host "ERROR: Unity Editor not found at: $UnityEditorPath" -ForegroundColor Red
    Write-Host "Specify correct path with -UnityEditorPath parameter" -ForegroundColor Yellow
    exit 1
}

Write-Host "=== RACING GAME BUILD ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectPath" -ForegroundColor Green
Write-Host "Output: $BuildOutput" -ForegroundColor Green
Write-Host ""

# Create build folder
if (-not (Test-Path $BuildOutput)) {
    New-Item -ItemType Directory -Path $BuildOutput | Out-Null
    Write-Host "Created build folder: $BuildOutput" -ForegroundColor Green
}

# Function to run Unity in batch mode
function Invoke-UnityBuild {
    param(
        [string]$Method,
        [string]$Logfile = "Build.log"
    )
    
    $arguments = @(
        "-batchmode"
        "-quit"
        "-nographics"
        "-projectPath `"$ProjectPath`""
        "-executeMethod $Method"
        "-logFile `"$BuildOutput\$Logfile`""
    )
    
    Write-Host "Starting Unity Build..." -ForegroundColor Cyan
    Write-Host "Method: $Method" -ForegroundColor Gray
    
    $process = Start-Process -FilePath $UnityEditorPath `
        -ArgumentList $arguments `
        -Wait `
        -PassThru `
        -NoNewWindow
    
    return $process.ExitCode
}

# Run tests
if ($RunTests) {
    Write-Host "=== RUNNING TESTS ===" -ForegroundColor Yellow
    
    $exitCode = Invoke-UnityBuild -Method "AutoBuildScript.TestMenuSystems" -Logfile "Tests.log"
    
    if ($exitCode -eq 0) {
        Write-Host "Tests passed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Tests failed (exit code: $exitCode)" -ForegroundColor Red
        if (-not $BuildOnly) {
            exit 1
        }
    }
}

# Build game
Write-Host "=== BUILDING GAME ===" -ForegroundColor Yellow

$exitCode = Invoke-UnityBuild -Method "AutoBuildScript.PerformBuild" -Logfile "Build.log"

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "BUILD SUCCESS!" -ForegroundColor Green
    Write-Host "EXE file: $BuildOutput\RacingGame.exe" -ForegroundColor Cyan
    Write-Host ""
    
    # Check if file exists
    if (Test-Path "$BuildOutput\RacingGame.exe") {
        $fileSize = (Get-Item "$BuildOutput\RacingGame.exe").Length / 1MB
        Write-Host "File size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Green
    }
} else {
    Write-Host ""
    Write-Host "BUILD FAILED (exit code: $exitCode)" -ForegroundColor Red
    Write-Host "Check log: $BuildOutput\Build.log" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Cyan
