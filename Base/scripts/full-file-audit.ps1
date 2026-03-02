# ============================================================================
# FULL FILE AUDIT (LITE)
# Упрощённая версия для тестирования
# ============================================================================

param(
    [string]$Path = "D:\QwenPoekt\Base\KNOWLEDGE_BASE",
    [string]$OutputPath = "D:\QwenPoekt\Base\reports\FILE_AUDIT_REPORT.md"
)

Write-Host ""
Write-Host "=== FULL FILE AUDIT (LITE) ===" -ForegroundColor Cyan
Write-Host "Path: $Path" -ForegroundColor Cyan
Write-Host ""

$files = Get-ChildItem -Path $Path -Recurse -Filter "*.md" -File
Write-Host "Найдено файлов: $($files.Count)" -ForegroundColor Green
Write-Host ""

$report = "# 📊 FILE AUDIT REPORT`n`n"
$report += "**Дата:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n`n"
$report += "## 📊 СТАТИСТИКА`n`n"
$report += "| Файл | Размер |`n"
$report += "|------|--------|`n"

foreach ($file in $files) {
    $relPath = $file.FullName.Replace($Path, '').Trim('\')
    $report += "| $relPath | $($file.Length) байт |`n"
}

$report | Out-File -FilePath $OutputPath -Encoding UTF8
Write-Host "✅ Отчёт сохранён: $OutputPath" -ForegroundColor Green
