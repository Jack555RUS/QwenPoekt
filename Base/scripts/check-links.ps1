# check-links.ps1 — Проверка ссылок в Markdown
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Поиск и проверка битых ссылок

param(
    [string]$Path = ".",       # Путь для сканирования
    [string]$Pattern = "*.md", # Шаблон файлов
    [switch]$Recursive,        # Рекурсивно
    [switch]$Fix,              # Исправить (удалить битые)
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

# Пути
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$BasePath = Split-Path -Parent $ScriptPath
$ReportPath = Join-Path $BasePath "reports\LINK_CHECK_REPORT.md"

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
    
    # Поиск ссылок: [text](url)
    $pattern = '\[([^\]]+)\]\(([^)]+)\)'
    $matches = [regex]::Matches($content, $pattern)
    
    foreach ($match in $matches) {
        $text = $match.Groups[1].Value
        $url = $match.Groups[2].Value
        
        # Пропускаем внешние ссылки и якоря
        if ($url -match '^https?://' -or $url -match '^#' -or $url -match '^mailto:') {
            continue
        }
        
        # Извлекаем путь без якоря
        $linkPath = ($url -split '#')[0]
        
        if ($linkPath) {
            $links += @{
                Text = $text
                Url = $url
                LinkPath = $linkPath
                Line = $content.Substring(0, $match.Index).Split("`n").Count
            }
        }
    }
    
    return $links
}

function Resolve-LinkPath {
    param(
        [string]$LinkPath,
        [string]$SourceFile
    )
    
    $sourceDir = Split-Path $SourceFile -Parent
    
    # Обработка относительных путей
    if ($LinkPath -notmatch '^[A-Za-z]:') {
        $resolved = Join-Path $sourceDir $LinkPath
        $resolvedPathObj = Resolve-Path $resolved -ErrorAction SilentlyContinue
        if ($resolvedPathObj) {
            return $resolvedPathObj.Path
        }
        return $null
    }
    
    return $LinkPath
}

function Check-Links {
    param(
        [string]$SearchPath,
        [switch]$Recursive
    )
    
    $getParams = @{
        Path = $SearchPath
        Include = "*.md"
        ErrorAction = "SilentlyContinue"
    }
    
    if ($Recursive) {
        $getParams.Recurse = $true
    }
    
    $files = Get-ChildItem @getParams
    Write-Log "📊 Найдено файлов: $($files.Count)" -Color "Cyan"
    Write-Log ""
    
    $results = @{
        Total = 0
        Valid = 0
        Broken = @()
        Files = @()
    }
    
    foreach ($file in $files) {
        Write-Log "📄 $($file.Name)" -Color "Gray"
        
        $links = Get-MarkdownLinks -FilePath $file.FullName
        $fileResults = @{
            File = $file.FullName
            Links = @()
        }
        
        foreach ($link in $links) {
            $results.Total++
            
            $resolvedPath = Resolve-LinkPath -LinkPath $link.LinkPath -SourceFile $file.FullName
            
            $isValid = $false
            if ($resolvedPath -and (Test-Path $resolvedPath)) {
                $isValid = $true
                $results.Valid++
                
                if ($Verbose) {
                    Write-Log "  ✅ $($link.Text) → $($link.Url)" -Color "Green"
                }
            } else {
                $results.Broken += @{
                    File = $file.FullName
                    Line = $link.Line
                    Text = $link.Text
                    Url = $link.Url
                    ResolvedPath = $resolvedPath
                }
                
                Write-Log "  ❌ $($link.Text) → $($link.Url) (строка $($link.Line))" -Color "Red"
            }
            
            $fileResults.Links += @{
                Link = $link
                IsValid = $isValid
                ResolvedPath = $resolvedPath
            }
        }
        
        $results.Files += $fileResults
        Write-Log ""
    }
    
    return $results
}

function Generate-Report {
    param([object]$Results)
    
    $report = @"
# 🔗 LINK CHECK REPORT

**Дата:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Путь:** $BasePath

---

## 📊 СТАТИСТИКА

| Метрика | Значение |
|---------|----------|
| **Всего ссылок** | $($Results.Total) |
| **Рабочих** | $($Results.Valid) |
| **Битых** | $($Results.Broken.Count) |
| **Процент** | $([Math]::Round($Results.Valid / $Results.Total * 100, 2))% |

---

## ❌ БИТЫЕ ССЫЛКИ

"@
    
    if ($Results.Broken.Count -eq 0) {
        $report += "`n**Битых ссылок не найдено!** ✅`n"
    } else {
        $report += "`n"
        
        # Группировка по файлам
        $grouped = $Results.Broken | Group-Object { $_.File }
        
        foreach ($group in $grouped) {
            $fileName = Split-Path $group.Name -Leaf
            $report += "### 📄 $fileName`n`n"
            $report += "| Строка | Текст | Ссылка |`n"
            $report += "|--------|-------|--------|`n"
            
            foreach ($item in $group.Group) {
                $report += "| $($item.Line) | $($item.Text) | $($item.Url) |`n"
            }
            
            $report += "`n"
        }
    }
    
    $report += @"

---

## 📁 ПРОВЕРЕННЫЕ ФАЙЛЫ

"@
    
    foreach ($fileResult in $Results.Files) {
        $fileName = Split-Path $fileResult.File -Leaf
        $linkCount = $fileResult.Links.Count
        $validCount = ($fileResult.Links | Where-Object { $_.IsValid }).Count
        
        $icon = if ($validCount -eq $linkCount) { "✅" } else { "⚠️ " }
        
        $report += "- $icon **$fileName** — $validCount/$linkCount ссылок`n"
    }
    
    $report += @"

---

**Отчёт сгенерирован:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Скрипт:** check-links.ps1
"@
    
    $report | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Log "📁 Отчёт сохранён: $ReportPath" -Color "Cyan"
}

# ----------------------------------------------------------------------------
# ОСНОВНАЯ ЛОГИКА
# ----------------------------------------------------------------------------

try {
    Write-Log "╔══════════════════════════════════════════════════════════╗"
    Write-Log "║         ПРОВЕРКА ССЫЛОК $(Get-Date -Format 'HH:mm:ss')                   ║"
    Write-Log "╚══════════════════════════════════════════════════════════╝"
    Write-Log ""
    
    $searchPath = if ($Path -eq ".") { $BasePath } else { $Path }
    
    Write-Log "📁 Путь: $searchPath" -Color "Cyan"
    Write-Log "🔍 Шаблон: $Pattern" -Color "Cyan"
    $recText = if ($Recursive) { "Да" } else { "Нет" }
    Write-Log "🔄 Рекурсивно: $recText" -Color "Cyan"
    Write-Log ""
    
    $results = Check-Links -SearchPath $searchPath -Recursive:$Recursive
    
    Write-Log "╔══════════════════════════════════════════════════════════╗"
    Write-Log "║                    ИТОГИ ПРОВЕРКИ                        ║"
    Write-Log "╚══════════════════════════════════════════════════════════╝"
    Write-Log ""
    Write-Log "📊 Статистика:" -Color "Cyan"
    Write-Log "  • Всего ссылок: $($results.Total)"
    Write-Log "  • Рабочих: $($results.Valid)"
    Write-Log "  • Битых: $($results.Broken.Count)"
    
    if ($results.Total -gt 0) {
        $percent = [Math]::Round($results.Valid / $results.Total * 100, 2)
        Write-Log "  • Процент: $percent%"
    }
    
    Write-Log ""
    
    if ($results.Broken.Count -eq 0) {
        Write-Log "✅ Битых ссылок не найдено!" -Color "Green"
    } else {
        Write-Log "❌ Найдено битых ссылок: $($results.Broken.Count)" -Color "Red"
        Write-Log ""
        Write-Log "📌 См. отчёт: $ReportPath" -Color "Cyan"
    }
    
    Generate-Report -Results $results
    
} catch {
    Write-Log "❌ ОШИБКА: $($_.Exception.Message)" -Color "Red"
    exit 1
}
