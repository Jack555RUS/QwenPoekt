# ============================================
# Unity Query Scene — Диагностика объектов сцены
# Аналог MCP command: query
# ============================================

param(
    [string]$target = "Canvas/MainMenu/PlayButton",  # Путь к объекту
    [string]$scene = "MainMenu"                       # Сцена
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🔍 UNITY QUERY SCENE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$projectPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity"

# ============================================
# Проверка существования объекта в сцене
# ============================================
Write-Host "1️⃣ Проверка объекта: $target" -ForegroundColor Yellow

# Ищем файл сцены
$scenePath = "$projectPath\Assets\Scenes\$scene.unity"
if (Test-Path $scenePath) {
    Write-Host "  ✅ Сцена найдена: $scenePath" -ForegroundColor Green
    
    # Читаем сцену
    $sceneContent = Get-Content $scenePath -Raw
    
    # Ищем объект по имени
    $objectName = ($target -split '/')[-1]
    if ($sceneContent -match "name: $objectName") {
        Write-Host "  ✅ Объект найден в сцене: $objectName" -ForegroundColor Green
        
        # Извлекаем информацию о компоненте
        if ($sceneContent -match "m_Script:.*?guid:.*?fileID:.*?type:") {
            Write-Host "  📦 Компоненты:" -ForegroundColor Cyan
            
            # Button component
            if ($sceneContent -match "MonoBehaviour:.*?MonoBehaviour") {
                $monoBehaviours = ($sceneContent -split "MonoBehaviour:").Count - 1
                Write-Host "    MonoBehaviour: $monoBehaviours" -ForegroundColor Gray
            }
            
            # RectTransform
            if ($sceneContent -match "RectTransform:") {
                $rectTransforms = ($sceneContent -split "RectTransform:").Count - 1
                Write-Host "    RectTransform: $rectTransforms" -ForegroundColor Gray
            }
        }
        
        # Проверяем дочерние объекты
        Write-Host ""
        Write-Host "2️⃣ Проверка дочерних объектов..." -ForegroundColor Yellow
        
        # Ищем иерархию
        $hierarchyPattern = "(?s)m_Children:\s*-\s*\d+"
        if ($sceneContent -match $hierarchyPattern) {
            $childrenCount = ([regex]::Matches($sceneContent, $hierarchyPattern)).Count
            Write-Host "  📁 Дочерних объектов: $childrenCount" -ForegroundColor Cyan
            
            if ($childrenCount -eq 0 -and $objectName -like "*Button*") {
                Write-Host "  ⚠️  ВНИМАНИЕ: У кнопки нет дочерних объектов!" -ForegroundColor Red
                Write-Host "     Возможная причина: Отсутствует TextMeshPro" -ForegroundColor Yellow
            }
        }
        
        # Проверяем TextMeshPro
        Write-Host ""
        Write-Host "3️⃣ Проверка TextMeshPro..." -ForegroundColor Yellow
        
        if ($sceneContent -match "TextMeshProUGUI|TextMeshPro") {
            $tmpCount = ([regex]::Matches($sceneContent, "TextMeshPro")).Count
            Write-Host "  ✅ TextMeshPro найден: $tmpCount экземпляров" -ForegroundColor Green
            
            # Проверяем, привязан ли к кнопке
            if ($sceneContent -match "m_fontAsset|m_text") {
                Write-Host "  📝 Текст настроен" -ForegroundColor Green
            }
        } else {
            Write-Host "  ❌ TextMeshPro НЕ найден в сцене!" -ForegroundColor Red
            Write-Host "     Решение: Window → TextMeshPro → Import TMP Essentials" -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "  ❌ Объект НЕ найден в сцене: $objectName" -ForegroundColor Red
        Write-Host "     Возможная причина: Неправильное имя или объект не добавлен" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ❌ Сцена НЕ найдена: $scenePath" -ForegroundColor Red
    Write-Host "     Проверьте путь к сцене" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "QUERY COMPLETE" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Возвращаем JSON-подобный вывод для ИИ
Write-Host "📄 JSON Output (для ИИ):" -ForegroundColor Gray
Write-Host @"
{
  "scene": "$scene",
  "target": "$target",
  "exists": $(if ($sceneContent -match "name: $objectName") { "true" } else { "false" }),
  "children": $childrenCount,
  "textMeshPro": $(if ($sceneContent -match "TextMeshPro") { "true" } else { "false" })
}
"@
