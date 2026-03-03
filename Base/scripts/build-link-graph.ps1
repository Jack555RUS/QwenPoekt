# build-link-graph.ps1 — Построение графа ссылок
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Визуализация связей между файлами

param(
    [string]$Path = ".",
    [switch]$Recursive,
    [string]$OutputFormat = "markdown"  # markdown, graphviz, json
)

$ErrorActionPreference = "Stop"

# Пути
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$outputPath = Join-Path $BasePath "reports\LINK_GRAPH.md"

# ----------------------------------------------------------------------------
# ФУНКЦИИ
# ----------------------------------------------------------------------------

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host $Message -ForegroundColor $Color
}

function Get-MarkdownLinks {
    param([string]$FilePath)
    
    $content = Get-Content $FilePath -Raw -Encoding UTF8
    $links = @()
    
    $pattern = '\[([^\]]+)\]\(([^)]+)\)'
    $matches = [regex]::Matches($content, $pattern)
    
    foreach ($match in $matches) {
        $url = $match.Groups[2].Value
        
        if ($url -match '^https?://' -or $url -match '^#' -or $url -match '^mailto:') {
            continue
        }
        
        $linkPath = ($url -split '#')[0]
        
        if ($linkPath) {
            $links += $linkPath
        }
    }
    
    return $links
}

function Build-LinkGraph {
    param([string]$SearchPath, [switch]$Recursive)
    
    $getParams = @{
        Path = $SearchPath
        Include = "*.md"
        ErrorAction = "SilentlyContinue"
    }
    
    if ($Recursive) {
        $getParams.Recurse = $true
    }
    
    $files = Get-ChildItem @getParams
    $graph = @{}
    
    foreach ($file in $files) {
        $links = Get-MarkdownLinks -FilePath $file.FullName
        
        if ($links.Count -gt 0) {
            $graph[$file.FullName] = $links
        }
    }
    
    return $graph
}

function Generate-MarkdownGraph {
    param([object]$Graph)
    
    $report = @"
# 🕸️ GRAPH ССЫЛОК

**Дата:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Файлов:** $($Graph.Count)

---

## 📊 УЗЛЫ (файлы со ссылками)

"@
    
    $sortedGraph = $graph.GetEnumerator() | Sort-Object { $_.Value.Count } -Descending
    
    foreach ($entry in $sortedGraph) {
        $fileName = Split-Path $entry.Key -Leaf
        $linkCount = $entry.Value.Count
        
        $report += "### 📄 $fileName ($linkCount ссылок)`n`n"
        
        foreach ($link in $entry.Value) {
            $linkName = Split-Path $link -Leaf
            $report += "- → $linkName`n"
        }
        
        $report += "`n"
    }
    
    $report += @"

---

## 📈 СТАТИСТИКА

| Метрика | Значение |
|---------|----------|
| **Всего файлов** | $($Graph.Count) |
| **Всего ссылок** | $($graph.Values | Measure-Object -Sum).Sum |
| **Среднее ссылок** | $([Math]::Round(($graph.Values | Measure-Object -Sum).Sum / $Graph.Count, 2)) |

---

**Отчёт сгенерирован:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** build-link-graph.ps1
"@
    
    return $report
}

# ----------------------------------------------------------------------------
# ОСНОВНАЯ ЛОГИКА
# ----------------------------------------------------------------------------

try {
    Write-Log "╔══════════════════════════════════════════════════════════╗"
    Write-Log "║         ПОСТРОЕНИЕ ГРАФА ССЫЛОК $(Get-Date -Format 'HH:mm:ss')          ║"
    Write-Log "╚══════════════════════════════════════════════════════════╝"
    Write-Log ""
    
    $searchPath = if ($Path -eq ".") { $BasePath } else { $Path }
    
    Write-Log "📁 Путь: $searchPath" -Color "Cyan"
    Write-Log "🔍 Формат: $OutputFormat" -Color "Cyan"
    Write-Log ""
    
    Write-Log "🔨 Построение графа..." -Color "Cyan"
    $graph = Build-LinkGraph -SearchPath $searchPath -Recursive:$Recursive
    
    Write-Log "  ✅ Найдено узлов: $($graph.Count)" -Color "Green"
    Write-Log ""
    
    Write-Log "📝 Генерация отчёта..." -Color "Cyan"
    $report = Generate-MarkdownGraph -Graph $graph
    
    $report | Out-File -FilePath $outputPath -Encoding UTF8
    Write-Log "  ✅ Отчёт сохранён: $outputPath" -Color "Green"
    Write-Log ""
    
    Write-Log "╔══════════════════════════════════════════════════════════╗"
    Write-Log "║           ГРАФ ПОСТРОЕН ✅                               ║"
    Write-Log "╚══════════════════════════════════════════════════════════╝"
    
} catch {
    Write-Log "❌ ОШИБКА: $($_.Exception.Message)" -Color "Red"
    exit 1
}
