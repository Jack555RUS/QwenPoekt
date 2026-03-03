# build-link-graph.ps1 — Граф ссылок и валидация
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Построение графа ссылок и проверка битых

param(
    [string]$Path = ".",
    [switch]$Validate,
    [string]$OutputPath = "reports\LINK_GRAPH.md"
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host $Message -ForegroundColor $Color
}

Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║         ГРАФ ССЫЛОК И ВАЛИДАЦИЯ $(Get-Date -Format 'HH:mm:ss')          ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""

# Сбор файлов
$files = Get-ChildItem -Path $Path -Filter "*.md" -Recurse
Write-Log "Найдено Markdown файлов: $($files.Count)"
Write-Log ""

# Извлечение ссылок
Write-Log "Извлечение ссылок..."
$graph = @{}
$broken = @()

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $links = [regex]::Matches($content, '\[([^\]]+)\]\(([^)]+)\)')
    
    $fileLinks = @()
    foreach ($link in $links) {
        $url = $link.Groups[2].Value
        if ($url -notmatch '^https?://|^#|^mailto:') {
            $linkPath = ($url -split '#')[0]
            if ($linkPath) {
                $fileLinks += $linkPath
                
                # Проверка существования
                if ($Validate -and $linkPath) {
                    $resolved = Resolve-Path (Join-Path $file.DirectoryName $linkPath) -ErrorAction SilentlyContinue
                    if (-not $resolved) {
                        $broken += @{
                            File = $file.FullName
                            Link = $url
                            Line = $content.Substring(0, $link.Index).Split("`n").Count
                        }
                    }
                }
            }
        }
    }
    
    $graph[$file.Name] = $fileLinks
}

$totalLinks = ($graph.Values | ForEach-Object { $_.Count } | Measure-Object -Sum).Sum
Write-Log "  Всего ссылок: $totalLinks"
Write-Log ""

# Отчёт
Write-Log "Генерация отчёта..."
$report = @"
# 🕸️ LINK GRAPH — ГРАФ ССЫЛОК

**Дата:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
**Файлов:** $($graph.Count)

---

## 📊 СТАТИСТИКА

| Метрика | Значение |
|---------|----------|
| **Файлов** | $($graph.Count) |
| **Ссылок** | $totalLinks |
| **Битых** | $($broken.Count) |

---

## 🔗 ГРАФ

"@

foreach ($entry in $graph.GetEnumerator() | Select-Object -First 20) {
    $report += "### $($entry.Key)`n`n"
    foreach ($link in $entry.Value | Select-Object -First 10) {
        $report += "- → $link`n"
    }
    $report += "`n"
}

if ($Validate) {
    $report += @"

---

## ❌ БИТЫЕ ССЫЛКИ

"@
    
    if ($broken.Count -eq 0) {
        $report += "**Битых ссылок не найдено!** ✅`n"
    } else {
        foreach ($item in $broken) {
            $report += "- **$($item.File)** (строка $($item.Line)): ``$($item.Link)```n"
        }
    }
}

$report | Out-File -FilePath $OutputPath -Encoding UTF8
Write-Log "  ✅ Отчёт сохранён: $OutputPath"
Write-Log ""

# Итог
Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║                    ИТОГИ                                 ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""
Write-Log "Файлов: $($graph.Count)" -Color "Cyan"
Write-Log "Ссылок: $totalLinks" -Color "Cyan"

if ($Validate) {
    if ($broken.Count -eq 0) {
        Write-Log "Битых ссылок: 0 ✅" -Color "Green"
    } else {
        Write-Log "Битых ссылок: $($broken.Count) ❌" -Color "Red"
    }
}

Write-Log ""
