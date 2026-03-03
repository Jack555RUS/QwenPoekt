# ============================================================================
# MIGRATE TO BASE/PROJECTS STRUCTURE
# Скрипт миграции основной системы на структуру БАЗА/ПРОЕКТЫ
# ============================================================================
# Использование: .\scripts\migrate-to-base-projects.ps1 [-Confirm]
# ============================================================================

param(
    [switch]$AutoConfirm
)

$ErrorActionPreference = "Stop"

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "         MIGRATE TO BASE/PROJECTS STRUCTURE                                " -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# КОНФИГУРАЦИЯ
# ============================================================================

$ROOT = "D:\QwenPoekt"
$BASE = "$ROOT\_TEST_ENV\Base"
$PROJECTS_TARGET = "$ROOT\_TEST_ENV\Projects"

# Папки для перемещения в Base/
$TO_BASE = @(
    "KNOWLEDGE_BASE",
    "scripts",
    ".qwen",
    "_docs",
    "_templates",
    "reports",
    "_drafts",
    "BOOK",
    "OLD",
    "RELEASE",
    "_LOCAL_ARCHIVE",
    ".github",
    ".vscode",
    "echo",
    "-p",
    "_archive",
    "Структура папок создана",
    "Тестовый проект создан"
)

# Папки для перемещения в Projects/
$TO_PROJECTS = @(
    "PROJECTS"
)

# Файлы для перемещения в Base/
$FILES_TO_BASE = @(
    "AI_START_HERE.md",
    "RULES_AND_TASKS.md",
    "ТЕКУЩАЯ_ЗАДАЧА.md",
    "OLD_RELEASE_ARCHIVE_IMPLEMENTATION.md",
    "SAVE_COMPLETE_REPORT.md",
    "AI_START_HERE_ANALYSIS.md",
    "DEBUGGING_IMPLEMENTATION_COMPLETE.md",
    "ALL_TASKS_COMPLETED.md",
    "KNOWLEDGE_PRESERVATION_CHECK.md",
    "NOTES.md",
    "ДЛЯ_ИИ_ЧИТАТЬ_СЮДА.md"
)

# ============================================================================
# ПРОВЕРКА
# ============================================================================

Write-Host "1. ПРОВЕРКА ПЕРЕД МИГРАЦИЕЙ" -ForegroundColor Yellow
Write-Host ""

# Проверка существования папок
Write-Host "   Проверка исходных папок..." -ForegroundColor Gray

$sourceExists = @(
    "$ROOT\KNOWLEDGE_BASE",
    "$ROOT\scripts",
    "$ROOT\PROJECTS"
)

$missing = @()
foreach ($path in $sourceExists) {
    if (!(Test-Path $path)) {
        $missing += $path
    }
}

if ($missing.Count -gt 0) {
    Write-Host "   ❌ Отсутствуют папки:" -ForegroundColor Red
    foreach ($path in $missing) {
        Write-Host "      - $path" -ForegroundColor Red
    }
    exit 1
}

Write-Host "   ✅ Все исходные папки найдены" -ForegroundColor Green
Write-Host ""

# Проверка целевых папок
Write-Host "   Проверка целевых папок..." -ForegroundColor Gray

if (!(Test-Path $BASE)) {
    Write-Host "   ❌ Целевая папка Base/ не существует: $BASE" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ Base/ существует" -ForegroundColor Green

if (!(Test-Path $PROJECTS_TARGET)) {
    Write-Host "   ⚠️  Projects/ не существует, будет создано" -ForegroundColor Yellow
    if (!$AutoConfirm) {
        $response = Read-Host "   Продолжить? (y/n)"
        if ($response -ne 'y') { exit 0 }
    }
    New-Item -ItemType Directory -Force -Path $PROJECTS_TARGET | Out-Null
}

Write-Host "   ✅ Projects/ готов" -ForegroundColor Green
Write-Host ""

# ============================================================================
# МИГРАЦИЯ
# ============================================================================

Write-Host "2. МИГРАЦИЯ ФАЙЛОВ" -ForegroundColor Yellow
Write-Host ""

# Перемещение папок в Base/
Write-Host "   Перемещение папок в Base/..." -ForegroundColor Gray

foreach ($folder in $TO_BASE) {
    $source = "$ROOT\$folder"
    $target = "$BASE\$folder"
    
    if (Test-Path $source) {
        try {
            if (Test-Path $target) {
                Write-Host "   ⚠️  Пропущено (уже существует): $folder" -ForegroundColor Yellow
            } else {
                Move-Item -Path $source -Destination $target -Force
                Write-Host "   ✅ Перемещено: $folder" -ForegroundColor Green
            }
        } catch {
            Write-Host "   ❌ Ошибка: $folder - $_" -ForegroundColor Red
        }
    } else {
        Write-Host "   ⚠️  Не найдено: $folder" -ForegroundColor Yellow
    }
}

Write-Host ""

# Перемещение файлов в Base/
Write-Host "   Перемещение файлов в Base/..." -ForegroundColor Gray

foreach ($file in $FILES_TO_BASE) {
    $source = "$ROOT\$file"
    $target = "$BASE\$file"
    
    if (Test-Path $source) {
        try {
            if (Test-Path $target) {
                Write-Host "   ⚠️  Пропущено (уже существует): $file" -ForegroundColor Yellow
            } else {
                Move-Item -Path $source -Destination $target -Force
                Write-Host "   ✅ Перемещено: $file" -ForegroundColor Green
            }
        } catch {
            Write-Host "   ❌ Ошибка: $file - $_" -ForegroundColor Red
        }
    } else {
        Write-Host "   ⚠️  Не найдено: $file" -ForegroundColor Yellow
    }
}

Write-Host ""

# Перемещение PROJECTS в Projects/
Write-Host "   Перемещение PROJECTS в Projects/..." -ForegroundColor Gray

foreach ($folder in $TO_PROJECTS) {
    $source = "$ROOT\$folder"
    $target = "$PROJECTS_TARGET\$folder"
    
    if (Test-Path $source) {
        try {
            if (Test-Path $target) {
                Write-Host "   ⚠️  Пропущено (уже существует): $folder" -ForegroundColor Yellow
            } else {
                Move-Item -Path $source -Destination $target -Force
                Write-Host "   ✅ Перемещено: $folder" -ForegroundColor Green
            }
        } catch {
            Write-Host "   ❌ Ошибка: $folder - $_" -ForegroundColor Red
        }
    } else {
        Write-Host "   ⚠️  Не найдено: $folder" -ForegroundColor Yellow
    }
}

Write-Host ""

# ============================================================================
# .GITIGNORE
# ============================================================================

Write-Host "3. СОЗДАНИЕ .GITIGNORE" -ForegroundColor Yellow
Write-Host ""

$gitignoreContent = @"
# ===========================================
# .gitignore для БАЗЫ (System)
# ===========================================

# Исключаем PROJECTS (это отдельный репозиторий)
PROJECTS/

# Исключаем OLD/RELEASE (библиотека наработок)
OLD/
RELEASE/

# Исключаем локальный архив
_LOCAL_ARCHIVE/

# Исключаем черновики
_drafts/

# Исключаем книги (тяжёлые PDF)
BOOK/

# Исключаем временные файлы
*.tmp
*.log
logs/

# Исключаем сборки Unity
PROJECTS/*/Build/
PROJECTS/*/Library/
PROJECTS/*/Temp/
PROJECTS/*/Obj/
PROJECTS/*/*.csproj.user

# VS Code
.vscode/
*.code-workspace

# Qwen
.qwen/tmp/

# Тестовая среда
_TEST_ENV/
"@

$gitignorePath = "$ROOT\.gitignore"

if (Test-Path $gitignorePath) {
    Write-Host "   ⚠️  .gitignore уже существует" -ForegroundColor Yellow
    $backup = "$ROOT\.gitignore.backup"
    Copy-Item -Path $gitignorePath -Destination $backup -Force
    Write-Host "   ✅ Создана резервная копия: .gitignore.backup" -ForegroundColor Green
}

$gitignoreContent | Out-File -FilePath $gitignorePath -Encoding UTF8
Write-Host "   ✅ Создан .gitignore" -ForegroundColor Green
Write-Host ""

# ============================================================================
# ИТОГИ
# ============================================================================

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "                    МИГРАЦИЯ ЗАВЕРШЕНА                                     " -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 СТРУКТУРА ПОСЛЕ МИГРАЦИИ:" -ForegroundColor Cyan
Write-Host ""
Write-Host "D:\QwenPoekt/" -ForegroundColor White
Write-Host "├── Base/                           ← БАЗА (System)" -ForegroundColor White
Write-Host "│   ├── .qwen/" -ForegroundColor Gray
Write-Host "│   ├── KNOWLEDGE_BASE/" -ForegroundColor Gray
Write-Host "│   ├── scripts/" -ForegroundColor Gray
Write-Host "│   ├── reports/" -ForegroundColor Gray
Write-Host "│   └── *.md" -ForegroundColor Gray
Write-Host "│" -ForegroundColor White
Write-Host "├── Projects/                       ← ПРОЕКТЫ" -ForegroundColor White
Write-Host "│   └── DragRaceUnity/" -ForegroundColor Gray
Write-Host "│" -ForegroundColor White
Write-Host "├── .gitignore                      ← Создан" -ForegroundColor White
Write-Host "└── _TEST_ENV/                      ← Тестовая среда" -ForegroundColor White
Write-Host ""

Write-Host "✅ МИГРАЦИЯ ЗАВЕРШЕНА!" -ForegroundColor Green
Write-Host ""

Write-Host "📋 СЛЕДУЮЩИЕ ШАГИ:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   1. Проверить ссылки в файлах" -ForegroundColor Yellow
Write-Host "   2. Закоммитить изменения в Git" -ForegroundColor Yellow
Write-Host "   3. Протестировать работу Qwen Code" -ForegroundColor Yellow
Write-Host ""
