# ============================================
# Настройка Code Spell Checker для VS Code
# ============================================

$settingsPath = "$env:APPDATA\Code\User\settings.json"

# Создать папку если нет
$settingsDir = Split-Path $settingsPath -Parent
if (!(Test-Path $settingsDir)) {
    New-Item -Path $settingsDir -ItemType Directory -Force | Out-Null
    Write-Host "✅ Создана папка: $settingsDir"
}

# Глобальные настройки
$globalSettings = @{
    "cSpell.enabled" = $true
    "cSpell.language" = "en,ru"
    "cSpell.showStatus" = $true
    "cSpell.showStatusOnHover" = $true
    "cSpell.diagnosticLevel" = "Warning"
    "cSpell.enabledLanguageIds" = @("markdown", "plaintext", "text", "comment")
    "cSpell.words" = @(
        "Unity",
        "ScriptableObject",
        "Incredibuild",
        "Qwen",
        "QwenPoekt",
        "DragRace",
        "DragRaceUnity",
        "MainMenu",
        "GameMenu",
        "TextMeshPro",
        "EventSystem",
        "RectTransform",
        "VisualElement",
        "UXML",
        "USS",
        "SonarLint",
        "StyleCop",
        "ZLinq",
        "uLoopMCP",
        "Analyzers"
    )
    "files.autoSave" = "afterDelay"
    "files.autoSaveDelay" = 1000
    "editor.formatOnSave" = $true
    "editor.tabSize" = 4
    "editor.insertSpaces" = $true
}

# Сохранить настройки
$globalSettings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8
Write-Host "✅ Настройки сохранены: $settingsPath"

# Перезагрузить VS Code
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ГОТОВО!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Теперь нужно перезагрузить VS Code:" -ForegroundColor Yellow
Write-Host "  1. Нажми Ctrl+Shift+P" -ForegroundColor White
Write-Host "  2. Введи: 'Developer: Reload Window'" -ForegroundColor White
Write-Host "  3. Нажми Enter" -ForegroundColor White
Write-Host ""
Write-Host "Проверка:" -ForegroundColor Yellow
Write-Host "  1. Открой любой .md файл" -ForegroundColor White
Write-Host "  2. Напиши: 'Привет как дила'" -ForegroundColor White
Write-Host "  3. Слово 'дила' должно подсветиться красным" -ForegroundColor White
Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
