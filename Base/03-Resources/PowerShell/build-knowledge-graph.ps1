# ============================================================================
# BUILD KNOWLEDGE GRAPH
# Построение графа связей между файлами Базы Знаний
# ============================================================================
# Использование: .\scripts\build-knowledge-graph.ps1 [-Path "путь"] [-OutputPath "путь"]
# ============================================================================

param(
    [string]$Path = "D:\QwenPoekt\Base\KNOWLEDGE_BASE",
    [string]$OutputPath = "D:\QwenPoekt\Base\reports\KNOWLEDGE_GRAPH.md",
    [string]$JsonOutputPath = "D:\QwenPoekt\Base\reports\knowledge_graph.json"
)

$ErrorActionPreference = "Continue"

# ============================================================================
# ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ
# ============================================================================

$GraphDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$Nodes = @()
$Edges = @()
$FileMap = @{}  # fullPath -> nodeId

# ============================================================================
# ФУНКЦИИ
# ============================================================================

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Get-NodeId {
    param([string]$Path)
    if (!$FileMap.ContainsKey($Path)) {
        $FileMap[$Path] = "node" + $FileMap.Count
    }
    return $FileMap[$Path]
}

function Extract-Links {
    param([string]$Content)
    
    $links = @()
    $pattern = '\[([^\]]+)\]\(([^\)]+)\)'
    
    $matches = [regex]::Matches($Content, $pattern)
    foreach ($match in $matches) {
        $links += $match.Groups[2].Value
    }
    
    return $links
}

function Resolve-RelativePath {
    param([string]$SourcePath, [string]$RelativeLink)
    
    $sourceDir = Split-Path $SourcePath -Parent
    
    # Убираем якоря
    $link = $RelativeLink.Split('#')[0]
    
    # Пропускаем внешние ссылки
    if ($link -match '^https?://') {
        return $null
    }
    
    # Разрешаем относительный путь
    try {
        $resolved = Join-Path $sourceDir $link
        $resolved = $resolved.Replace('\', '/').Replace('/./', '/')
        
        # Нормализация пути
        $parts = $resolved.Split('/')
        $result = @()
        foreach ($part in $parts) {
            if ($part -eq '..') {
                if ($result.Count -gt 0) {
                    $result = $result[0..($result.Count-2)]
                }
            } elseif ($part -ne '.' -and $part -ne '') {
                $result += $part
            }
        }
        
        return ($result -join '/') -replace '/', '\'
    } catch {
        return $null
    }
}

function Calculate-Centrality {
    param([hashtable]$AdjacencyList)
    
    $centrality = @{}
    
    foreach ($node in $AdjacencyList.Keys) {
        $connections = $AdjacencyList[$node].Count
        $centrality[$node] = $connections
    }
    
    return $centrality
}

function Find-Isolated {
    param([hashtable]$AdjacencyList)
    
    $isolated = @()
    
    foreach ($node in $AdjacencyList.Keys) {
        if ($AdjacencyList[$node].Count -eq 0) {
            $isolated += $node
        }
    }
    
    return $isolated
}

function Find-Clusters {
    param(
        [hashtable]$AdjacencyList,
        [int]$MinSize = 3
    )
    
    # Упрощённый алгоритм кластеризации по связям
    $visited = @{}
    $clusters = @()
    
    foreach ($startNode in $AdjacencyList.Keys) {
        if ($visited.ContainsKey($startNode)) { continue }
        
        $cluster = @()
        $queue = @($startNode)
        
        while ($queue.Count -gt 0) {
            $node = $queue[0]
            $queue = $queue[1..($queue.Count-1)]
            
            if ($visited.ContainsKey($node)) { continue }
            $visited[$node] = $true
            $cluster += $node
            
            foreach ($neighbor in $AdjacencyList[$node]) {
                if (!$visited.ContainsKey($neighbor)) {
                    $queue += $neighbor
                }
            }
        }
        
        if ($cluster.Count -ge $MinSize) {
            $clusters += ,@($cluster)
        }
    }
    
    return $clusters
}

# ============================================================================
# ОСНОВНАЯ ЛОГИКА
# ============================================================================

Write-Host ""
Write-Log "=== ПОСТРОЕНИЕ ГРАФА ЗНАНИЙ ===" -Color "Yellow"
Write-Log "Дата: $GraphDate" -Color "Yellow"
Write-Log "Путь: $Path" -Color "Yellow"
Write-Host ""

# Сбор всех файлов
Write-Log "1. Сбор файлов..." -Color "Cyan"
$allFiles = Get-ChildItem -Path $Path -Recurse -Filter "*.md" -File
Write-Log "   Найдено файлов: $($allFiles.Count)" -Color "Green"
Write-Host ""

# Построение графа
Write-Log "2. Анализ связей..." -Color "Cyan"

$adjacencyList = @{}

foreach ($file in $allFiles) {
    $nodeId = Get-NodeId -Path $file.FullName
    $relativePath = $file.FullName.Replace($Path, '').Trim('\').Replace('\', '/')
    
    # Добавляем узел
    $Nodes += [PSCustomObject]@{
        id = $nodeId
        file = $relativePath
        size = $file.Length
        links = 0
    }
    
    $adjacencyList[$nodeId] = @()
    
    # Читаем содержимое
    try {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        
        # Извлекаем ссылки
        $links = Extract-Links -Content $content
        
        foreach ($link in $links) {
            $resolvedPath = Resolve-RelativePath -SourcePath $file.FullName -RelativeLink $link
            
            if ($resolvedPath -and (Test-Path $resolvedPath)) {
                $targetNodeId = Get-NodeId -Path $resolvedPath
                $targetRelativePath = $resolvedPath.Replace($Path, '').Trim('\').Replace('\', '/')
                
                # Добавляем ребро
                $Edges += [PSCustomObject]@{
                    source = $nodeId
                    target = $targetNodeId
                    sourceFile = $relativePath
                    targetFile = $targetRelativePath
                    linkText = $link
                }
                
                $adjacencyList[$nodeId] += $targetNodeId
            }
        }
    } catch {
        Write-Log "   ⚠️  Ошибка чтения: $($file.Name)" -Color "Yellow"
    }
}

Write-Log "   Найдено связей: $($Edges.Count)" -Color "Green"
Write-Host ""

# Анализ графа
Write-Log "3. Анализ графа..." -Color "Cyan"

$centrality = Calculate-Centrality -AdjacencyList $adjacencyList
$isolated = Find-Isolated -AdjacencyList $adjacencyList
$clusters = Find-Clusters -AdjacencyList $adjacencyList -MinSize 3

# Обновляем узлы с метриками
foreach ($node in $Nodes) {
    $node.links = $centrality[$node.id]
}

# Сортировка по центральности
$topNodes = $Nodes | Sort-Object links -Descending | Select-Object -First 10

Write-Log "   Изолированных файлов: $($isolated.Count)" -Color $(if ($isolated.Count -gt 0) { "Yellow" } else { "Green" })
Write-Log "   Найдено кластеров: $($clusters.Count)" -Color "Green"
Write-Host ""

# Генерация отчёта
Write-Log "4. Генерация отчёта..." -Color "Cyan"

# Mermaid диаграмма (упрощённая)
$mermaidGraph = "```mermaid`ngraph TD`n"

# Добавляем только топ-20 узлов для читаемости
$top20Nodes = $Nodes | Sort-Object links -Descending | Select-Object -First 20
$edgeLimit = 50
$edgeCount = 0

foreach ($node in $top20Nodes) {
    $label = $node.file.Split('/')[-1].Replace('.md', '')
    $mermaidGraph += "    $($node.id)[`"$label`"]`n"
}

foreach ($edge in $Edges) {
    if ($edgeCount -ge $edgeLimit) { break }
    if ($top20Nodes.id -contains $edge.source -and $top20Nodes.id -contains $edge.target) {
        $mermaidGraph += "    $($edge.source) --- $($edge.target)`n"
        $edgeCount++
    }
}

$mermaidGraph += "```"

$reportContent = @"
# 🕸️ ГРАФ ЗНАНИЙ — $GraphDate

**Дата:** $GraphDate  
**Скрипт:** build-knowledge-graph.ps1  
**Путь:** $Path

---

## 📊 СТАТИСТИКА

| Показатель | Значение |
|------------|----------|
| **Всего файлов** | $($Nodes.Count) |
| **Всего связей** | $($Edges.Count) |
| **Средняя связность** | $(if ($Nodes.Count -gt 0) { [math]::Round($Edges.Count / $Nodes.Count, 2) } else { 0 }) |
| **Изолированных** | $($isolated.Count) |
| **Кластеров** | $($clusters.Count) |

---

## 🏆 ТОП-10 ЦЕНТРАЛЬНЫХ ФАЙЛОВ

| Файл | Связей | Роль |
|------|--------|------|
$($topNodes | ForEach-Object { "| $($_.file) | $($_.links) | $(if ($_.links -ge 10) { '🔴 Хаб' } elseif ($_.links -ge 5) { '🟡 Узел' } else { '🟢 Лист' }) |" })

---

## 🗺️ ВИЗУАЛИЗАЦИЯ (Топ-20 узлов)

$mermaidGraph

> **Примечание:** Показаны только топ-20 узлов и до $edgeLimit связей для читаемости.

---

## ⚠️ ИЗОЛИРОВАННЫЕ ФАЙЛЫ

$($isolated.Count -gt 0 ? @"
$(foreach ($nodeId in $isolated) {
    $node = $Nodes | Where-Object { $_.id -eq $nodeId }
    "- $($node.file)"
})

**Рекомендация:** Добавить ссылки на эти файлы из других статей.
"@ : "✅ Изолированных файлов нет!")

---

## 🔗 КЛАСТЕРЫ

$($clusters.Count -gt 0 ? @"
$(for ($i = 0; $i -lt $clusters.Count; $i++) {
    "### Кластер $($i + 1) ($($clusters[$i].Count) файлов)"
    foreach ($nodeId in $clusters[$i]) {
        $node = $Nodes | Where-Object { $_.id -eq $nodeId }
        "- $($node.file)"
    }
    ""
})
"@ : "Кластеры не найдены (требуется минимум 3 файла в кластере)")

---

## 📈 МЕТРИКИ ГРАФА

### Распределение связности:

| Диапазон | Файлов | Процент |
|----------|--------|---------|
| **0 связей** | $(($Nodes | Where-Object { $_.links -eq 0 }).Count) | $(if ($Nodes.Count -gt 0) { [math]::Round(($Nodes | Where-Object { $_.links -eq 0 }).Count / $Nodes.Count * 100, 1) } else { 0 })% |
| **1-4 связи** | $(($Nodes | Where-Object { $_.links -ge 1 -and $_.links -le 4 }).Count) | $(if ($Nodes.Count -gt 0) { [math]::Round(($Nodes | Where-Object { $_.links -ge 1 -and $_.links -le 4 }).Count / $Nodes.Count * 100, 1) } else { 0 })% |
| **5-9 связей** | $(($Nodes | Where-Object { $_.links -ge 5 -and $_.links -le 9 }).Count) | $(if ($Nodes.Count -gt 0) { [math]::Round(($Nodes | Where-Object { $_.links -ge 5 -and $_.links -le 9 }).Count / $Nodes.Count * 100, 1) } else { 0 })% |
| **10+ связей** | $(($Nodes | Where-Object { $_.links -ge 10 }).Count) | $(if ($Nodes.Count -gt 0) { [math]::Round(($Nodes | Where-Object { $_.links -ge 10 }).Count / $Nodes.Count * 100, 1) } else { 0 })% |

---

**Статус:** ✅ ГРАФ ПОСТРОЕН

**Следующий шаг:** Запустить \`calculate-kb-metrics.ps1\` для расчёта метрик качества
"@

$reportContent | Out-File -FilePath $OutputPath -Encoding UTF8

# JSON экспорт
$jsonData = @{
    date = $GraphDate
    stats = @{
        totalFiles = $Nodes.Count
        totalEdges = $Edges.Count
        avgConnectivity = if ($Nodes.Count -gt 0) { [math]::Round($Edges.Count / $Nodes.Count, 2) } else { 0 }
        isolated = $isolated.Count
        clusters = $clusters.Count
    }
    nodes = $Nodes
    edges = $Edges
    topNodes = $topNodes
    isolatedFiles = $isolated | ForEach-Object { ($Nodes | Where-Object { $_.id -eq $_ }).file }
    clusters = $clusters | ForEach-Object {
        $_ | ForEach-Object { ($Nodes | Where-Object { $_.id -eq $_ }).file }
    }
}

$jsonData | ConvertTo-Json -Depth 10 | Out-File -FilePath $JsonOutputPath -Encoding UTF8

Write-Log "   Отчёт сохранён: $OutputPath" -Color "Green"
Write-Log "   JSON сохранён: $JsonOutputPath" -Color "Green"
Write-Host ""

# ============================================================================
# ИТОГИ
# ============================================================================

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Log "ИТОГИ:" -Color "Cyan"
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "  Всего файлов: $($Nodes.Count)" -ForegroundColor White
Write-Host "  Всего связей: $($Edges.Count)" -ForegroundColor White
Write-Host "  Средняя связность: $(if ($Nodes.Count -gt 0) { [math]::Round($Edges.Count / $Nodes.Count, 2) } else { 0 })" -ForegroundColor White
Write-Host "  Изолированных: $($isolated.Count)" -ForegroundColor $(if ($isolated.Count -gt 0) { "Yellow" } else { "Green" })
Write-Host "  Кластеров: $($clusters.Count)" -ForegroundColor White
Write-Host ""

if ($isolated.Count -eq 0) {
    Write-Host "✅ ВСЕ ФАЙЛЫ СВЯЗАНЫ!" -ForegroundColor Green
} else {
    Write-Host "⚠️ $($isolated.Count) изолированных файлов" -ForegroundColor Yellow
    Write-Host "   См. отчёт: $OutputPath" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Нажмите любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
