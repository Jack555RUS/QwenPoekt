@echo off
echo ============================================================
echo   Racing Game - Automatic Setup and Build
echo ============================================================
echo.

REM Check for Unity
echo [1/5] Checking for Unity...
set UNITY_PATH=
if exist "C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe" (
    set UNITY_PATH=C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe
) else if exist "C:\Program Files\Unity\Hub\Editor\6\Editor\Unity.exe" (
    set UNITY_PATH=C:\Program Files\Unity\Hub\Editor\6\Editor\Unity.exe
) else if exist "C:\Program Files\Unity\Editor\Unity.exe" (
    set UNITY_PATH=C:\Program Files\Unity\Editor\Unity.exe
)

if "%UNITY_PATH%"=="" (
    echo ERROR: Unity not found!
    echo.
    echo Please install Unity 6000.3.10f1 or newer.
    echo Or open project manually in Unity and use:
    echo   Menu: RacingGame -^> Quick Setup and Build
    pause
    exit /b 1
)

echo FOUND Unity: %UNITY_PATH%
echo.

REM Create build folder
echo [2/5] Creating build folder...
set BUILD_DIR=%~dp0Build
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
echo DONE: %BUILD_DIR%
echo.

REM Run Unity to configure and build
echo [3/5] Configuring project in Unity...
echo.
echo This may take several minutes. Please wait...
echo.

REM Create C# script for Unity
set SCRIPT_PATH=%~dp0TempBuildScript.cs
(
echo using UnityEditor;
echo using UnityEngine;
echo using System.IO;
echo.
echo public class TempBuildScript
echo {
echo     public static void Build()
echo     {
echo         Debug.Log("Starting auto-build...");
echo.
echo         // Configure scenes
echo         EditorBuildSettings.scenes = new EditorBuildSettingsScene[]
echo         {
echo             new EditorBuildSettingsScene("Assets/Scenes/MainMenu.unity", true),
echo             new EditorBuildSettingsScene("Assets/Scenes/Game.unity", true),
echo             new EditorBuildSettingsScene("Assets/Scenes/Garage.unity", true),
echo             new EditorBuildSettingsScene("Assets/Scenes/Tuning.unity", true),
echo             new EditorBuildSettingsScene("Assets/Scenes/Shop.unity", true)
echo         };
echo.
echo         // Configure player settings
echo         PlayerSettings.productName = "Racing Game";
echo         PlayerSettings.companyName = "DefaultCompany";
echo         PlayerSettings.bundleVersion = "1.0.0";
echo         PlayerSettings.defaultScreenWidth = 800;
echo         PlayerSettings.defaultScreenHeight = 600;
echo.
echo         // Build
echo         string[] scenes = {
echo             "Assets/Scenes/MainMenu.unity",
echo             "Assets/Scenes/Game.unity",
echo             "Assets/Scenes/Garage.unity",
echo             "Assets/Scenes/Tuning.unity",
echo             "Assets/Scenes/Shop.unity"
echo         };
echo.
echo         BuildPlayerOptions options = new BuildPlayerOptions
echo         {
echo             scenes = scenes,
echo             locationPathName = "Build/RacingGame.exe",
echo             target = BuildTarget.StandaloneWindows64,
echo             options = BuildOptions.None
echo         };
echo.
echo         BuildReport report = BuildPipeline.BuildPlayer(options);
echo.
echo         if (report.summary.result == BuildResult.Succeeded)
echo         {
echo             Debug.Log("BUILD SUCCESSFUL!");
echo             Debug.Log("Size: " + report.summary.totalSize + " bytes");
echo         }
echo         else
echo         {
echo             Debug.LogError("BUILD FAILED!");
echo         }
echo.
echo         EditorApplication.Exit(0);
echo     }
echo }
) > "%SCRIPT_PATH%"

echo Starting Unity build process...
echo.

REM Run Unity with build script
start /WAIT "" "%UNITY_PATH%" -projectPath "%~dp0" -executeMethod TempBuildScript.Build -logFile "%BUILD_DIR%\build.log" -batchmode -quit

REM Clean up temp script
del "%SCRIPT_PATH%" 2>nul

echo.
echo [4/5] Build completed!
echo.
echo [5/5] Checking result...
echo.

if exist "%BUILD_DIR%\RacingGame.exe" (
    echo ============================================================
    echo   BUILD SUCCESSFUL!
    echo ============================================================
    echo.
    echo Game file: %BUILD_DIR%\RacingGame.exe
    echo.
    echo To play the game:
    echo   1. Open folder: %BUILD_DIR%
    echo   2. Run: RacingGame.exe
    echo.
    echo Logs:
    echo   - Build: %BUILD_DIR%\build.log
    echo.
    echo ============================================================
    echo.
    
    REM Open build folder
    explorer "%BUILD_DIR%"
    
    pause
    exit /b 0
) else (
    echo ============================================================
    echo   BUILD FAILED
    echo ============================================================
    echo.
    echo Possible issues:
    echo   1. Unity version mismatch
    echo   2. Compilation errors in project
    echo   3. Insufficient permissions
    echo.
    echo Check log: %BUILD_DIR%\build.log
    echo.
    echo Manual build:
    echo   1. Open project in Unity
    echo   2. Menu: RacingGame -^> Quick Setup and Build
    echo   3. Or: File -^> Build Settings -^> Build
    echo.
    echo ============================================================
    pause
    exit /b 1
)
