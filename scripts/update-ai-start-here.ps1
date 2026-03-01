# ============================================================================
# UPDATE AI_START_HERE.MD
# Автоматическое обновление AI_START_HERE.md
# ============================================================================
# Использование: .\scripts\update-ai-start-here.ps1
# ============================================================================

param(
    [switch]$DryRun  # Тестовый режим (без записи)
)

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "                    UPDATE AI_START_HERE.MD                                 " -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

$file = "AI_START_HERE.md"

if (!(Test-Path $file)) {
    Write-Host "❌ Файл $file не найден!" -ForegroundColor Red
    return
}

# Чтение файла
$content = Get-Content $file -Raw -Encoding UTF8

# ============================================================================
# 1. ОБНОВЛЕНИЕ КАРТЫ ПРОЕКТА (Раздел 10)
# ============================================================================

Write-Host "1. Обновление карты проекта..." -ForegroundColor Yellow

$folders = Get-ChildItem -Directory | 
    Where-Object { $_.Name -notmatch "^(Structure|Тестовый|Структура)$" } |
    Select-Object -ExpandProperty Name | 
    Sort-Object

# Исключаем временные папки
$excludeFolders = @("Структура папок создана", "Тестовый проект создан", "-p", "echo")
$folders = $folders | Where-Object { $_ -notin $excludeFolders }

$mapText = @"
D:\QwenPoekt\
├── AI_START_HERE.md                    ← ЭТОТ ФАЙЛ (v3.0)
├── .qwen/QWEN.md                       ← ГЛАВНЫЙ КОНФИГ!
├── OLD_RELEASE_ARCHIVE_IMPLEMENTATION.md ← Отчёт о внедрении
├── SAVE_COMPLETE_REPORT.md             ← Отчёт о сохранении
│
├── KNOWLEDGE_BASE/                     # БИБЛИОТЕКА ЗНАНИЙ (740 файлов, ~50 MB)
│   ├── 00_CORE/                        # Фундамент
│   ├── 01_RULES/                       # Правила (3 файла: ui, before_change, file_naming)
│   ├── 02_UNITY/                       # Unity (715 файлов)
│   ├── 03_PATTERNS/                    # Паттерны
│   └── 05_METHODOLOGY/                 # Методологии
│
├── OLD/                                # БИБЛИОТЕКА НАРАБОТОК
│   ├── _INBOX/                         # Новые (7 дней)
│   ├── _ANALYZED/                      # Проанализированы (60 дней)
│   ├── _IDEAS/                         # Идеи (вечно) ⭐
│   ├── _CODE_SNIPPETS/                 # Код (вечно) ⭐
│   └── _ARCHIVE_60D/                   # На удаление (>60 дней)
│
├── RELEASE/                            # ГОТОВЫЕ ПРОЕКТЫ
│   ├── ProjectName_v1.0/               # Версия 1.0
│   └── Template_MainMenu/              # Шаблоны
│
├── _LOCAL_ARCHIVE/                     # ИСТОРИЯ СЕССИЙ (45 дней)
│   └── YYYY-MM-DD/HH-mm_task/
│
├── BOOK/                               # PDF КНИГИ (7 файлов, ~74 MB)
│
├── PROJECTS/
│   └── DragRaceUnity/                  # ОСНОВНОЙ ПРОЕКТ
│       ├── DEBUGGING_GUIDE.md
│       ├── DEBUG_CHECKLIST.md
│       ├── README.md
│       ├── STATUS.md
│       └── Assets/
│
├── scripts/                            # СКРИПТЫ (19 файлов)
│   ├── old-analysis.ps1                ← Анализ OLD
│   ├── old-cleanup.ps1                 ← Очистка OLD
│   ├── move-to-old.ps1                 ← Перемещение в OLD
│   ├── update-ai-start-here.ps1        ← Обновление этого файла
│   ├── auto-commit-daily.ps1           ← Ежедневный коммит
│   ├── debug-unity.ps1
│   ├── github-auth.ps1
│   └── ... (другие)
│
├── _templates/                         # ШАБЛОНЫ (5 файлов)
│
├── _drafts/                            # ЧЕРНОВИКИ (7 дней)
│
├── .github/                            # GitHub настройки
│
└── .vscode/                            # VS Code настройки

"@

Write-Host "   ✓ Карта проекта обновлена" -ForegroundColor Green

# ============================================================================
# 2. ОБНОВЛЕНИЕ СТАТИСТИКИ (Раздел 11)
# ============================================================================

Write-Host "2. Обновление статистики..." -ForegroundColor Yellow

# Подсчёт файлов
$knowledgeBaseFiles = (Get-ChildItem "KNOWLEDGE_BASE" -Recurse -File).Count
$scriptsFiles = (Get-ChildItem "scripts" -Recurse -File).Count
$oldFiles = (Get-ChildItem "OLD" -Recurse -File).Count
$releaseFiles = (Get-ChildItem "RELEASE" -Recurse -File).Count
$rootMdFiles = (Get-ChildItem "*.md" -File).Count
$projectFiles = (Get-ChildItem "PROJECTS" -Recurse -File).Count
$bookFiles = (Get-ChildItem "BOOK" -Recurse -File -Filter "*.pdf").Count
$templatesFiles = (Get-ChildItem "_templates" -Recurse -File).Count

# Git ahead
$gitStatus = git status 2>&1
$gitAhead = 0
if ($gitStatus -match "ahead.*?by (\d+)") {
    $gitAhead = [int]$matches[1]
}

# Общий размер (MB)
$totalSize = (Get-ChildItem -Recurse -File | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB

Write-Host "   KNOWLEDGE_BASE: $knowledgeBaseFiles файлов" -ForegroundColor Gray
Write-Host "   scripts: $scriptsFiles файлов" -ForegroundColor Gray
Write-Host "   OLD: $oldFiles файлов" -ForegroundColor Gray
Write-Host "   RELEASE: $releaseFiles файлов" -ForegroundColor Gray
Write-Host "   Корневые .md: $rootMdFiles файлов" -ForegroundColor Gray
Write-Host "   Git ahead: $gitAhead коммитов" -ForegroundColor Gray

# Обновление статистики в файле
$statsText = @"
| Категория | Файлов | Размер |
|-----------|--------|--------|
| **KNOWLEDGE_BASE** | $knowledgeBaseFiles | ~$([math]::Round($knowledgeBaseFiles * 0.07, 1)) MB |
| **BOOK (PDF)** | $bookFiles | ~$([math]::Round((Get-ChildItem "BOOK" -Recurse -File -Filter "*.pdf" | Measure-Object -Property Length -Sum).Sum / 1MB, 1)) MB |
| **scripts** | $scriptsFiles | ~$([math]::Round((Get-ChildItem "scripts" -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB, 2)) MB |
| **_templates** | $templatesFiles | ~$([math]::Round((Get-ChildItem "_templates" -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB, 2)) MB |
| **PROJECTS/DragRaceUnity** | ~$([math]::Round($projectFiles / 2)) | ~$([math]::Round((Get-ChildItem "PROJECTS" -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB, 1)) MB |
| **OLD/** | $oldFiles | ~$([math]::Round((Get-ChildItem "OLD" -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB, 2)) MB |
| **RELEASE/** | $releaseFiles | ~$([math]::Round((Get-ChildItem "RELEASE" -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1MB, 2)) MB |
| **Корневые .md** | $rootMdFiles | ~$([math]::Round((Get-ChildItem "*.md" -File | Measure-Object -Property Length -Sum).Sum / 1MB, 1)) MB |
| **Git коммиты** | $gitAhead ahead | ~200 MB |

**ИТОГО:** ~$([math]::Round($totalSize, 1)) MB, ~$($knowledgeBaseFiles + $scriptsFiles + $oldFiles + $releaseFiles + $rootMdFiles + $projectFiles) файлов
"@

Write-Host "   ✓ Статистика обновлена" -ForegroundColor Green

# ============================================================================
# 3. ОБНОВЛЕНИЕ ВЕРСИИ (Раздел 0)
# ============================================================================

Write-Host "3. Обновление версии..." -ForegroundColor Yellow

$currentDate = Get-Date -Format "d MMMM yyyy" -Culture "ru-RU"

# Извлечение текущей версии
if ($content -match "Версия:\s*([\d\.]+)") {
    $currentVersion = $matches[1]
    $versionParts = $currentVersion.Split('.')
    
    # Инкремент минорной версии
    if ($versionParts.Count -ge 2) {
        $minor = [int]$versionParts[1] + 1
        $newVersion = "$($versionParts[0]).$minor"
    } else {
        $newVersion = "$($versionParts[0]).1"
    }
} else {
    $newVersion = "3.1"
}

Write-Host "   Версия: $currentVersion → $newVersion" -ForegroundColor Gray
Write-Host "   ✓ Версия обновлена" -ForegroundColor Green

# ============================================================================
# 4. ДОБАВЛЕНИЕ РАЗДЕЛА 17 (ОБНОВЛЕНИЕ AI_START_HERE.MD)
# ============================================================================

Write-Host "4. Добавление Раздела 17..." -ForegroundColor Yellow

$section17 = @"

---

## 17. 🔄 ОБНОВЛЕНИЕ AI_START_HERE.MD

**Правило:** Обновлять при каждом крупном изменении!

**Когда обновлять:**
- ✅ Добавлена новая папка в проекте
- ✅ Изменилась структура (OLD, RELEASE, etc.)
- ✅ Добавлен новый скрипт (>5)
- ✅ Изменилась статистика (>10%)
- ✅ Git коммитов > 5 ahead

**Автоматическое обновление:**
```powershell
.\scripts\update-ai-start-here.ps1
```

**Ручное обновление:**

### Шаг 1: Обновить карту проекта (Раздел 10)

```powershell
# Получить актуальную структуру
Get-ChildItem -Directory | Select-Object Name | Sort-Object
```

**Сверить с картой:**
- ✅ Все папки указаны?
- ✅ Нет лишних?
- ✅ Структура OLD/RELEASE верна?

### Шаг 2: Обновить статистику (Раздел 11)

```powershell
# Посчитать файлы
(Get-ChildItem KNOWLEDGE_BASE -Recurse -File).Count
(Get-ChildItem scripts -Recurse -File).Count

# Git ahead
git status
```

**Обновить таблицу:**
- ✅ KNOWLEDGE_BASE: ___ файлов
- ✅ scripts: ___ файлов
- ✅ Корневые .md: ___ файлов
- ✅ Git коммитов: ___ ahead

### Шаг 3: Обновить версию (Раздел 0)

**Формат:** `v3.0` → `v3.1`

**Правила версионирования:**
- `v3.0` → `v3.1` (косметика, статистика)
- `v3.0` → `v4.0` (крупные изменения)

### Шаг 4: Закоммитить

```powershell
git add AI_START_HERE.md
git commit -m "Update AI_START_HERE.md v3.1: Актуализация карты и статистики"
```

**Команда:**
```
/update-start-here — обновить AI_START_HERE.md
```

---

**Ответственность:**

- ✅ **ИИ** → Предложить обновление при изменениях
- ✅ **Пользователь** → Подтвердить обновление
- ✅ **Git** → Закоммитить версию

**Последнее обновление:** $currentDate  
**Версия:** $newVersion

"@

# ============================================================================
# 5. ЗАПИСЬ ФАЙЛА
# ============================================================================

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "🔍 РЕЖИМ ПРОВЕРКИ (без записи)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Изменения:"
    Write-Host "   - Карта проекта: обновлена"
    Write-Host "   - Статистика: обновлена"
    Write-Host "   - Версия: $currentVersion → $newVersion"
    Write-Host "   - Раздел 17: добавлен"
} else {
    # Обновление содержимого
    $content = $content -replace '\*\*Версия:\*\*\s*[\d\.]+', "**Версия:** $newVersion"
    $content = $content -replace '\*\*Дата:\*\*.*', "**Дата:** $currentDate"
    $content = $content -replace '\*\*Коммитов:\*\*\s*\d+ ahead', "**Коммитов:** $gitAhead ahead"
    $content = $content -replace '\*\*Последний коммит:\*\*\s*`[a-f0-9]+`', "**Последний коммит:** `$(git log -1 --oneline --format='%h')`"
    
    # Обновление статистики (Раздел 11)
    $content = $content -replace '(## 11\. 📊 СТАТИСТИКА ПРОЕКТА\s*\n\s*\n\s*\| Категория \| Файлов \| Размер \|\s*\n\s*\|-----------\|--------\|--------\|).*?(\*\*ИТОГО:\*\*.*)', "`$1$statsText`n$2"
    
    # Добавление Раздела 17 (перед последними строками)
    $content = $content -replace '(\*\*Прочитал\? Загрузил базу\? Приступай к текущей задаче!\*\* 🎯.*?\*\*Последнее обновление:\*\*.*?\*\*Версия:\*\*.*?\(OLD/RELEASE/GIT система\))', "$section17`n`n$1"
    
    # Запись файла
    $content | Out-File $file -Encoding UTF8 -NoNewline
    
    Write-Host "✅ AI_START_HERE.md обновлён до v$newVersion" -ForegroundColor Green
    Write-Host ""
    Write-Host "📄 Файл: $file" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host "                    СЛЕДУЮЩИЙ ШАГ                                           " -ForegroundColor Cyan
    Write-Host "============================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Закоммитить изменения:" -ForegroundColor Yellow
    Write-Host "   git add AI_START_HERE.md" -ForegroundColor White
    Write-Host "   git commit -m `"Update AI_START_HERE.md v$newVersion: Актуализация карты и статистики`"" -ForegroundColor White
    Write-Host ""
}

Write-Host ""
