# ============================================
# Unity Execute Code — Выполнение кода в Unity
# Аналог MCP command: execute_code
# ============================================

param(
    [string]$code = "",         # C# код для выполнения
    [string]$file = "",         # Или файл со скриптом
    [string]$target = ""        # Целевой объект (опционально)
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "⚡ UNITY EXECUTE CODE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity"
$editorPath = "$projectPath\Assets\Scripts\Editor"

# ============================================
# Проверка существования Editor папки
# ============================================
Write-Host "1️⃣ Проверка Editor папки..." -ForegroundColor Yellow

if (!(Test-Path $editorPath)) {
    Write-Host "  📁 Создание папки Editor..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $editorPath | Out-Null
    Write-Host "  ✅ Editor папка создана" -ForegroundColor Green
} else {
    Write-Host "  ✅ Editor папка существует" -ForegroundColor Green
}

Write-Host ""

# ============================================
# Создание временного скрипта
# ============================================
Write-Host "2️⃣ Создание скрипта для выполнения..." -ForegroundColor Yellow

$tempScript = "$editorPath\TempExecuteCode.cs"

if ($file -ne "" -and (Test-Path $file)) {
    # Копируем указанный файл
    Copy-Item $file $tempScript -Force
    Write-Host "  ✅ Скрипт скопирован: $file" -ForegroundColor Green
} elseif ($code -ne "") {
    # Создаём скрипт из кода
    $scriptContent = @"
using UnityEngine;
using UnityEditor;

public class TempExecuteCode : MonoBehaviour
{
    [InitializeOnLoadMethod]
    public static void Execute()
    {
        Debug.Log("[TempExecuteCode] Starting execution...");
        
        // USER CODE START
        $code
        // USER CODE END
        
        Debug.Log("[TempExecuteCode] Execution complete.");
        
        // Auto-cleanup
        AssetDatabase.DeleteAsset("Assets/Scripts/Editor/TempExecuteCode.cs");
        AssetDatabase.SaveAssets();
    }
}
"@
    
    $scriptContent | Out-File -FilePath $tempScript -Encoding UTF8
    Write-Host "  ✅ Скрипт создан: $tempScript" -ForegroundColor Green
} else {
    Write-Host "  ❌ Не указан код или файл для выполнения" -ForegroundColor Red
    Write-Host "     Использование:" -ForegroundColor Yellow
    Write-Host "       .\unity-execute-code.ps1 -code 'Debug.Log(`"Hello`")'" -ForegroundColor White
    Write-Host "       .\unity-execute-code.ps1 -file 'MyScript.cs'" -ForegroundColor White
    exit 1
}

Write-Host ""

# ============================================
# Инструкция по выполнению
# ============================================
Write-Host "3️⃣ Выполнение в Unity..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  ⚠️  ВНИМАНИЕ: Скрипт будет выполнен в Unity Editor" -ForegroundColor Red
Write-Host ""
Write-Host "  Для выполнения:" -ForegroundColor Cyan
Write-Host "  1. Откройте Unity Editor" -ForegroundColor White
Write-Host "  2. Скрипт выполнится автоматически при загрузке" -ForegroundColor White
Write-Host "  3. Проверьте Console для результатов" -ForegroundColor White
Write-Host ""
Write-Host "  Или запустите вручную:" -ForegroundColor Cyan
Write-Host "  - В Unity:右键 на скрипте → Execute" -ForegroundColor White
Write-Host ""

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "EXECUTE CODE COMPLETE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Возвращаем JSON-подобный вывод для ИИ
Write-Host "📄 JSON Output (для ИИ):" -ForegroundColor Gray
Write-Host @"
{
  "scriptPath": "$tempScript",
  "status": "created",
  "autoExecute": true,
  "note": "Script will execute on next Unity Editor load"
}
"@
