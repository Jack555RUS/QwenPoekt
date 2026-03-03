# 🔄 ЕЖЕНЕДЕЛЬНЫЙ АУДИТ БАЗЫ ЗНАНИЙ
# Автоматическая проверка состояния KNOWLEDGE_BASE

# ============================================
# НАСТРОЙКИ
# ============================================

$BasePath = $PSScriptRoot
$KnowledgeBasePath = Join-Path $BasePath "KNOWLEDGE_BASE"
$OldPath = Join-Path $BasePath "OLD"
$ArchivePath = Join-Path $BasePath "_archive"
$DraftsPath = Join-Path $BasePath "_drafts"
$ReportsPath = Join-Path $BasePath "reports"

$ReportDate = Get-Date -Format "yyyy-MM-dd_HH-mm"
$ReportFile = Join-Path $ReportsPath "AUDIT_$ReportDate.md"

# ============================================
# ФУНКЦИИ
# ============================================

function Get-FileCount {
    param([string]$Path)
    $count = (Get-ChildItem -Path $Path -Recurse -File -Include *.md -ErrorAction SilentlyContinue).Count
    return $count
}

function Get-OldFiles {
    param([string]$Path, [int]$Days)
    $cutoff = (Get-Date).AddDays(-$Days)
    $files = Get-ChildItem -Path $Path -Recurse -File -Include *.md -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $cutoff }
    return $files
}

function Test-RootMess {
    $messPatterns = @(
        "--name-only", "-r", "echo", "git", "ls-tree", "move",
        "Папка создана", "Перемещение завершено", "Структура папок",
        "Тестовый проект", "⚠", "✓"
    )
    
    $found = @()
    foreach ($pattern in $messPatterns) {
        $items = Get-ChildItem -Path $BasePath -Directory | Where-Object { $_.Name -like "*$pattern*" }
        if ($items) { $found += $items }
    }
    return $found
}

# ============================================
# АУДИТ
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ЕЖЕНЕДЕЛЬНЫЙ АУДИТ БАЗЫ" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Статистика
Write-Host "📊 СТАТИСТИКА:" -ForegroundColor Yellow

$kbCount = Get-FileCount -Path $KnowledgeBasePath
$oldCount = Get-FileCount -Path $OldPath
$archiveCount = Get-FileCount -Path $ArchivePath
$reportsCount = Get-FileCount -Path $ReportsPath
$draftsCount = Get-FileCount -Path $DraftsPath

Write-Host "  KNOWLEDGE_BASE: $kbCount файлов"
Write-Host "  OLD/: $oldCount файлов"
Write-Host "  _archive/: $archiveCount файлов"
Write-Host "  reports/: $reportsCount файлов"
Write-Host "  _drafts/: $draftsCount файлов"
Write-Host ""

# Проверка _drafts/
Write-Host "🔍 ПРОВЕРКА _drafts/:" -ForegroundColor Yellow

$oldDrafts = Get-OldFiles -Path $DraftsPath -Days 7
if ($oldDrafts.Count -gt 0) {
    Write-Host "  ⚠️ Найдено старых черновиков (>7 дней): $($oldDrafts.Count)" -ForegroundColor Red
    foreach ($file in $oldDrafts) {
        $daysOld = (New-TimeSpan -Start $file.LastWriteTime -End (Get-Date)).Days
        Write-Host "    - $($file.Name) ($daysOld дней)" -ForegroundColor Red
    }
} else {
    Write-Host "  ✅ Черновиков старше 7 дней нет" -ForegroundColor Green
}
Write-Host ""

# Проверка корня
Write-Host "🔍 ПРОВЕРКА КОРНЯ:" -ForegroundColor Yellow

$mess = Test-RootMess
if ($mess.Count -gt 0) {
    Write-Host "  ⚠️ Найден мусор в корне: $($mess.Count) папок" -ForegroundColor Red
    foreach ($item in $mess) {
        Write-Host "    - $($item.Name)" -ForegroundColor Red
    }
} else {
    Write-Host "  ✅ Корень чист" -ForegroundColor Green
}
Write-Host ""

# Проверка Git
Write-Host "🔍 ПРОВЕРКА GIT:" -ForegroundColor Yellow

$gitStatus = git status --porcelain 2>$null
if ($gitStatus) {
    $uncommitted = ($gitStatus | Measure-Object).Count
    Write-Host "  ⚠️ Не закоммичено файлов: $uncommitted" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ Git чист" -ForegroundColor Green
}
Write-Host ""

# Генерация отчёта
Write-Host "📝 ГЕНЕРАЦИЯ ОТЧЁТА:" -ForegroundColor Yellow

$reportContent = @"
# 🔄 АУДИТ БАЗЫ — $((Get-Date).ToString("yyyy-MM-dd"))

**Дата:** $(Get-Date -Format "dd.MM.yyyy HH:mm")  
**Скрипт:** weekly-knowledge-audit.ps1

---

## 📊 СТАТИСТИКА

| Папка | Файлов |
|-------|--------|
| **KNOWLEDGE_BASE** | $kbCount |
| **OLD/** | $oldCount |
| **_archive/** | $archiveCount |
| **reports/** | $reportsCount |
| **_drafts/** | $draftsCount |
| **ИТОГО** | $($kbCount + $oldCount + $archiveCount + $reportsCount + $draftsCount) |

---

## 🔍 ПРОВЕРКИ

### _drafts/ (старше 7 дней)

$($oldDrafts.Count -gt 0 ? "⚠️ Найдено: $($oldDrafts.Count)" : "✅ Чисто")

$($oldDrafts | ForEach-Object { "- $($_.Name) ($((New-TimeSpan -Start $_.LastWriteTime -End (Get-Date)).Days) дней)" })

### Корень (мусор)

$($mess.Count -gt 0 ? "⚠️ Найдено: $($mess.Count)" : "✅ Чисто")

$($mess | ForEach-Object { "- $($_.Name)" })

### Git

$($gitStatus ? "⚠️ Не закоммичено: $(($gitStatus | Measure-Object).Count)" : "✅ Чисто")

---

## ✅ РЕКОМЕНДАЦИИ

$($oldDrafts.Count -gt 0 ? "- Переместить старые черновики в OLD/_ANALYZED/" : "")
$($mess.Count -gt 0 ? "- Очистить корень (запустить cleanup-root-mess.ps1)" : "")
$($gitStatus ? "- Закоммитить изменения" : "")

---

**Статус:** $($mess.Count -eq 0 -and $oldDrafts.Count -eq 0 -and -not $gitStatus ? "✅ ВСЁ В ПОРЯДКЕ" : "⚠️ ТРЕБУЕТСЯ ВНИМАНИЕ")
"@

$reportContent | Out-File -FilePath $ReportFile -Encoding UTF8

Write-Host "  ✅ Отчёт сохранён: $ReportFile"
Write-Host ""

# Итоги
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "ИТОГИ:" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

$status = "✅ ВСЁ В ПОРЯДКЕ"
if ($mess.Count -gt 0 -or $oldDrafts.Count -gt 0 -or $gitStatus) {
    $status = "⚠️ ТРЕБУЕТСЯ ВНИМАНИЕ"
}

Write-Host "Статус: $status" -ForegroundColor $(if ($status -eq "✅ ВСЁ В ПОРЯДКЕ") { "Green" } else { "Yellow" })
Write-Host ""
Write-Host "Нажмите любую клавишу для выхода..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
