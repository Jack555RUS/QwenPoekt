# ============================================================================
# MOVE TO OLD
# Перемещение заброшенного проекта в OLD/_INBOX/
# ============================================================================
# Использование: .\scripts\move-to-old.ps1 -ProjectPath "путь" -Reason "причина"
# ============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath,
    
    [string]$Reason = "Abandoned"
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "                    MOVE TO OLD                                             " -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Проверка существования проекта
if (!(Test-Path $ProjectPath)) {
    Write-Host "❌ Проект не найден: $ProjectPath" -ForegroundColor Red
    return
}

$inboxPath = "OLD/_INBOX"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$projectName = Split-Path $ProjectPath -Leaf
$destPath = "$inboxPath\$timestamp`_$projectName"

Write-Host "📁 Проект: $projectName" -ForegroundColor White
Write-Host "📝 Причина: $Reason" -ForegroundColor White
Write-Host "📂 Назначение: $destPath" -ForegroundColor White
Write-Host ""

# Создать папку _INBOX если нет
if (!(Test-Path $inboxPath)) {
    New-Item -ItemType Directory -Force -Path $inboxPath | Out-Null
    Write-Host "✓ Создана папка: $inboxPath" -ForegroundColor Green
}

# Копировать проект
Write-Host "Копирование файлов..." -ForegroundColor Cyan
Copy-Item $ProjectPath -Destination $destPath -Recurse -Force

# Создать метаданные
$metadata = @"
# 📋 Project Archived

**Name:** $projectName
**Date:** $(Get-Date -Format 'yyyy-MM-dd HH:mm')
**Reason:** $Reason
**Original Path:** $ProjectPath
**Archive Path:** $destPath

---

## 📊 Status

- [ ] Analysis pending
- [ ] Ideas extracted
- [ ] Code saved
- [ ] Ready for archive

---

## 📝 Notes

_Добавьте заметки о проекте (что было реализовано, какие идеи были)_

---

## 🔍 Quick Info

_Краткое описание проекта, его назначение и ключевые особенности_

"@

$metadata | Out-File "$destPath\_METADATA.md" -Encoding UTF8

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "                    MOVE COMPLETE                                           " -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "✓ Перемещено: $destPath" -ForegroundColor Green
Write-Host ""
Write-Host "⏳ Следующий шаг:" -ForegroundColor Yellow
Write-Host "   Запустите анализ: .\scripts\old-analysis.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "📄 Методанные: $destPath\_METADATA.md" -ForegroundColor Cyan
Write-Host ""
