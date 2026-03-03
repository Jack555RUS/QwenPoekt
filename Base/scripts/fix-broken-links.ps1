# fix-broken-links.ps1 — Автоматическое исправление битых ссылок
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Массовое исправление путей к файлам

param(
    [string]$Path = ".",
    [switch]$WhatIf,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message, [string]$Color = "Cyan")
    Write-Host $Message -ForegroundColor $Color
}

Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║         ИСПРАВЛЕНИЕ БИТЫХ ССЫЛОК $(Get-Date -Format 'HH:mm:ss')           ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""

# Правила замены
$replacements = @{
    "_docs/" = "02-Areas/Documentation/"
    "KNOWLEDGE_BASE/00_CORE/" = "03-Resources/Knowledge/00_CORE/"
    "KNOWLEDGE_BASE/01_RULES/" = "03-Resources/Knowledge/01_RULES/"
    "KNOWLEDGE_BASE/02_TOOLS/" = "03-Resources/Knowledge/02_TOOLS/"
    "KNOWLEDGE_BASE/02_UNITY/" = "03-Resources/Knowledge/02_UNITY/"
    "KNOWLEDGE_BASE/03_CSHARP/" = "03-Resources/Knowledge/03_CSHARP/"
    "KNOWLEDGE_BASE/03_PATTERNS/" = "03-Resources/Knowledge/03_PATTERNS/"
    "KNOWLEDGE_BASE/04_ARCHIVES/" = "03-Resources/Knowledge/04_ARCHIVES/"
    "KNOWLEDGE_BASE/05_METHODOLOGY/" = "03-Resources/Knowledge/05_METHODOLOGY/"
    "scripts/" = "03-Resources/PowerShell/"
}

Write-Log "Правила замены:"
foreach ($key in $replacements.Keys) {
    Write-Log "  $key → $($replacements[$key])" -Color "Gray"
}
Write-Log ""

# Сбор файлов
$files = Get-ChildItem -Path $Path -Filter "*.md" -Recurse
Write-Log "Найдено файлов: $($files.Count)"
Write-Log ""

# Исправление
$fixedCount = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $original = $content
    
    foreach ($key in $replacements.Keys) {
        $content = $content -replace $key, $replacements[$key]
    }
    
    if ($content -ne $original) {
        if ($WhatIf) {
            Write-Log "  [WhatIf] $($file.FullName)" -Color "Yellow"
        } else {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8
            Write-Log "  ✅ $($file.FullName)" -Color "Green"
        }
        $fixedCount++
    } elseif ($Verbose) {
        Write-Log "  ✓ $($file.FullName) (без изменений)" -Color "Gray"
    }
}

Write-Log ""
Write-Log "╔══════════════════════════════════════════════════════════╗"
Write-Log "║                    ИТОГИ                                 ║"
Write-Log "╚══════════════════════════════════════════════════════════╝"
Write-Log ""
Write-Log "Исправлено файлов: $fixedCount" -Color "Cyan"

if ($WhatIf) {
    Write-Log ""
    Write-Log "Это пробный запуск. Для реального исправления:" -Color "Yellow"
    Write-Log "  .\scripts\fix-broken-links.ps1" -Color "Gray"
}
