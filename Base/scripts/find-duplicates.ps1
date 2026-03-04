# find-duplicates.ps1 — Поиск дубликатов файлов
# Версия: 1.0
# Дата: 4 марта 2026 г.
# Назначение: Поиск дубликатов по имени, содержимому и функции

param(
    [string]$Path = "D:\QwenPoekt\Base",
    [switch]$ByHash,        # Поиск по хэшу (полные дубликаты)
    [switch]$ByName,        # Поиск по имени
    [switch]$ByFunction,    # Поиск по функции
    [switch]$Verbose,
    [string]$OutputPath = "reports\duplicates-report.md"
)

$ErrorActionPreference = "Stop"

# Цвета
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"
$Gray = "Gray"

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         ПОИСК ДУБЛИКАТОВ ФАЙЛОВ                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# ============================================
# ФУНКЦИЯ 1: Get-FileHash
# ============================================

function Get-FileMD5 {
    param([string]$FilePath)
    
    try {
        $hash = Get-FileHash $FilePath -Algorithm MD5 -ErrorAction Stop
        return $hash.Hash
    } catch {
        return $null
    }
}

# ============================================
# ФУНКЦИЯ 2: Analyze-FileFunction
# ============================================

function Analyze-FileFunction {
    param([string]$FilePath)
    
    $fileName = Split-Path $FilePath -Leaf
    $folder = Split-Path $FilePath -Parent
    $folderName = Split-Path $folder -Leaf
    
    # Определение функции по имени и расположению
    $function = switch -Regex ($fileName.ToLower()) {
        ".*readme.*" { "Навигатор/Документация" }
        ".*rule.*" { "Правило" }
        ".*template.*" { "Шаблон" }
        ".*log.*" { "Журнал" }
        ".*report.*" { "Отчёт" }
        ".*checklist.*" { "Чек-лист" }
        ".*task.*" { "Задачи" }
        ".*audit.*" { "Аудит" }
        ".*analysis.*" { "Анализ" }
        ".*guide.*" { "Руководство" }
        ".*instruction.*" { "Инструкция" }
        ".*method.*" { "Методика" }
        ".*pattern.*" { "Паттерн" }
        ".*example.*" { "Пример" }
        default { "Документ общего назначения" }
    }
    
    # Уточнение по папке
    if ($folderName -match "rules") {
        $function = "Правило"
    } elseif ($folderName -match "reports") {
        $function = "Отчёт"
    } elseif ($folderName -match "templates") {
        $function = "Шаблон"
    }
    
    return @{
        FileName = $fileName
        Folder = $folder
        FolderName = $folderName
        Function = $function
    }
}

# ============================================
# ФУНКЦИЯ 3: Compare-FileContent
# ============================================

function Compare-FileContent {
    param(
        [string]$File1,
        [string]$File2
    )
    
    # Получаем содержимое (первые 100 строк)
    $content1 = Get-Content $File1 -Head 100 -Raw
    $content2 = Get-Content $File2 -Head 100 -Raw
    
    # Сравниваем заголовки
    $headers1 = $content1 -split "`n" | Where-Object { $_ -match "^#{1,3}" } | Select-Object -First 10
    $headers2 = $content2 -split "`n" | Where-Object { $_ -match "^#{1,3}" } | Select-Object -First 10
    
    # Подсчёт совпадений
    $matchCount = 0
    foreach ($h1 in $headers1) {
        foreach ($h2 in $headers2) {
            if ($h1.Trim() -eq $h2.Trim()) {
                $matchCount++
            }
        }
    }
    
    $totalHeaders = $headers1.Count + $headers2.Count
    $matchPercent = if ($totalHeaders -gt 0) { [math]::Round(($matchCount / $totalHeaders) * 100, 2) } else { 0 }
    
    return @{
        MatchPercent = $matchPercent
        MatchCount = $matchCount
        TotalHeaders = $totalHeaders
        IsDuplicate = ($matchPercent -gt 50)
    }
}

# ============================================
# ФУНКЦИЯ 4: Find-FunctionalDuplicates
# ============================================

function Find-FunctionalDuplicates {
    param([string]$SearchPath)
    
    Write-Host "[1/4] Поиск функциональных дубликатов..." -ForegroundColor Cyan
    
    # Получаем все .md файлы (исключая .venv, node_modules)
    $files = Get-ChildItem $SearchPath -Recurse -Filter "*.md" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\.venv|node_modules" }
    
    # Анализируем функцию каждого файла
    $analyzed = @()
    foreach ($file in $files) {
        $analysis = Analyze-FileFunction -FilePath $file.FullName
        $analyzed += $analysis
    }
    
    # Группируем по функции
    $grouped = $analyzed | Group-Object -Property Function
    
    # Находим группы с более чем 1 файлом
    $duplicates = $grouped | Where-Object { $_.Count -gt 1 }
    
    Write-Host "  Найдено групп: $($duplicates.Count)" -ForegroundColor $(if ($duplicates.Count -gt 0) { $Yellow } else { $Green })
    
    return $duplicates
}

# ============================================
# ФУНКЦИЯ 5: Find-HashDuplicates
# ============================================

function Find-HashDuplicates {
    param([string]$SearchPath)
    
    Write-Host "`n[2/4] Поиск дубликатов по хэшу..." -ForegroundColor Cyan
    
    # Получаем все файлы (исключая .venv, node_modules)
    $files = Get-ChildItem $SearchPath -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "\\.venv|node_modules" }
    
    # Вычисляем хэш для каждого
    $hashes = @()
    foreach ($file in $files) {
        $hash = Get-FileMD5 -FilePath $file.FullName
        if ($hash) {
            $hashes += @{
                Path = $file.FullName
                Hash = $hash
                Size = $file.Length
            }
        }
    }
    
    # Группируем по хэшу
    $grouped = $hashes | Group-Object -Property Hash
    
    # Находим дубликаты
    $duplicates = $grouped | Where-Object { $_.Count -gt 1 }
    
    Write-Host "  Найдено дубликатов: $($duplicates.Count)" -ForegroundColor $(if ($duplicates.Count -gt 0) { $Yellow } else { $Green })
    
    return $duplicates
}

# ============================================
# ОСНОВНОЙ СЦЕНАРИЙ
# ============================================

# 1. Поиск функциональных дубликатов
$functionalDups = Find-FunctionalDuplicates -SearchPath $Path

# 2. Поиск дубликатов по хэшу
$hashDups = Find-HashDuplicates -SearchPath $Path

# 3. Формирование отчёта
Write-Host "`n[3/4] Формирование отчёта..." -ForegroundColor Cyan

$report = @"
# 📊 ОТЧЁТ: ДУБЛИКАТЫ ФАЙЛОВ

**Дата:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Путь:** $Path  
**Статус:** ✅ Завершено

---

## 📊 ОБЩАЯ СТАТИСТИКА

| Тип дубликатов | Найдено |
|----------------|---------|
| **Функциональные** | $($functionalDups.Count) групп |
| **По хэшу** | $($hashDups.Count) групп |

---

## 🔍 ФУНКЦИОНАЛЬНЫЕ ДУБЛИКАТЫ

**Определение:** Файлы с одинаковой функцией (могут иметь разное содержимое)

"@

foreach ($group in $functionalDups | Select-Object -First 10) {
    $report += @"

### Функция: $($group.Name)

| # | Файл | Путь |
|---|------|------|
"@
    $i = 1
    foreach ($file in $group.Group) {
        $report += "| $i | $($file.FileName) | $($file.Folder) |`n"
        $i++
    }
    $report += "`n"
}

$report += @"

---

## 🔍 ДУБЛИКАТЫ ПО ХЭШУ

**Определение:** Полные копии файлов (одинаковое содержимое)

"@

foreach ($group in $hashDups | Select-Object -First 10) {
    $report += @"

### Хэш: $($group.Name.Substring(0, 16))...

| # | Файл | Размер |
|---|------|--------|
"@
    $i = 1
    foreach ($file in $group.Group) {
        $sizeKB = [math]::Round($file.Size / 1KB, 2)
        $report += "| $i | $($file.Path) | $sizeKB KB |`n"
        $i++
    }
    $report += "`n"
}

$report += @"

---

## 💡 РЕКОМЕНДАЦИИ

### Для функциональных дубликатов:

1. **Проанализировать содержимое** — могут быть разные темы
2. **Сравнить заголовки** — использовать Compare-FileContent
3. **Объединить или разделить** — в зависимости от содержимого
4. **Обновить ссылки** — после объединения/разделения

### Для дубликатов по хэшу:

1. **Удалить лишние копии** — оставить одну
2. **Обновить ссылки** — на оставшийся файл
3. **Проверить зависимости** — что ссылается на удаляемые

---

## 🛠️ СКРИПТЫ

**Использовать:**

```powershell
# Сравнить содержимое двух файлов
Compare-FileContent -File1 "file1.md" -File2 "file2.md"

# Найти функциональные дубликаты
Find-FunctionalDuplicates -SearchPath "D:\QwenPoekt\Base"

# Найти дубликаты по хэшу
Find-HashDuplicates -SearchPath "D:\QwenPoekt\Base"
```

---

**Отчёт создан:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Следующий шаг:** Проанализировать дубликаты, принять решение

"@

# 4. Сохранение отчёта
Write-Host "`n[4/4] Сохранение отчёта..." -ForegroundColor Cyan

if (-not (Test-Path (Split-Path $OutputPath -Parent))) {
    New-Item -ItemType Directory -Path (Split-Path $OutputPath -Parent) -Force | Out-Null
}

$report | Out-File -FilePath $OutputPath -Encoding UTF8

Write-Host "`n╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    ИТОГИ                                 ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n✅ Отчёт сохранён: $OutputPath" -ForegroundColor Green
Write-Host "📊 Функциональных дубликатов: $($functionalDups.Count) групп" -ForegroundColor $(if ($functionalDups.Count -gt 0) { $Yellow } else { $Green })
Write-Host "📊 Дубликатов по хэшу: $($hashDups.Count) групп" -ForegroundColor $(if ($hashDups.Count -gt 0) { $Yellow } else { $Green })

Write-Host "`n═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Следующий шаг: Проанализировать отчёт" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
