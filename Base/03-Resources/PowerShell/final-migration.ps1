# ============================================================================
# FINAL MIGRATION - Сессия 3
# Финальное перемещение из _TEST_ENV в основную систему
# ============================================================================
# Использование: .\scripts\final-migration.ps1 [-Confirm]
# ============================================================================

param(
    [switch]$AutoConfirm
)

$ErrorActionPreference = "Stop"

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "                    FINAL MIGRATION - Сессия 3                             " -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# КОНФИГУРАЦИЯ
# ============================================================================

$ROOT = "D:\QwenPoekt"
$TEST_BASE = "$ROOT\_TEST_ENV\Base"
$TEST_PROJECTS = "$ROOT\_TEST_ENV\Projects"
$TARGET_BASE = "$ROOT\Base"
$TARGET_PROJECTS = "$ROOT\Projects"

# ============================================================================
# ПРОВЕРКА
# ============================================================================

Write-Host "1. ПРОВЕРКА ПЕРЕД МИГРАЦИЕЙ" -ForegroundColor Yellow
Write-Host ""

if (!(Test-Path $TEST_BASE)) {
    Write-Host "   ❌ _TEST_ENV\Base не найдена!" -ForegroundColor Red
    exit 1
}

if (!(Test-Path $TEST_PROJECTS)) {
    Write-Host "   ❌ _TEST_ENV\Projects не найдена!" -ForegroundColor Red
    exit 1
}

Write-Host "   ✅ _TEST_ENV\Base найдена" -ForegroundColor Green
Write-Host "   ✅ _TEST_ENV\Projects найдена" -ForegroundColor Green

# Проверка целевых папок
if (Test-Path $TARGET_BASE) {
    Write-Host "   ⚠️  Base уже существует (будет заменена)" -ForegroundColor Yellow
} else {
    Write-Host "   ✅ Base будет создана" -ForegroundColor Green
}

if (Test-Path $TARGET_PROJECTS) {
    Write-Host "   ⚠️  Projects уже существует (будет заменена)" -ForegroundColor Yellow
} else {
    Write-Host "   ✅ Projects будет создана" -ForegroundColor Green
}

Write-Host ""

if (!$AutoConfirm) {
    $response = Read-Host "   Продолжить миграцию? (y/n)"
    if ($response -ne 'y') { exit 0 }
}

# ============================================================================
# МИГРАЦИЯ BASE
# ============================================================================

Write-Host "2. МИГРАЦИЯ BASE" -ForegroundColor Yellow
Write-Host ""

# Очистка старых пустых папок в корне
$emptyFolders = @(
    "$ROOT\KNOWLEDGE_BASE",
    "$ROOT\scripts",
    "$ROOT\reports",
    "$ROOT\_docs",
    "$ROOT\_templates",
    "$ROOT\_drafts",
    "$ROOT\_LOCAL_ARCHIVE",
    "$ROOT\OLD",
    "$ROOT\RELEASE",
    "$ROOT\.github",
    "$ROOT\.vscode",
    "$ROOT\BOOK",
    "$ROOT\echo",
    "$ROOT\-p",
    "$ROOT\_archive",
    "$ROOT\Структура папок создана",
    "$ROOT\Тестовый проект создан"
)

Write-Host "   Удаление старых пустых папок..." -ForegroundColor Gray
foreach ($folder in $emptyFolders) {
    if (Test-Path $folder) {
        $items = Get-ChildItem $folder -Recurse -File
        if ($items.Count -eq 0) {
            Remove-Item $folder -Force -Recurse
            Write-Host "   ✅ Удалено: $folder" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Пропущено (не пустое): $folder" -ForegroundColor Yellow
        }
    }
}

# Перемещение Base
Write-Host ""
Write-Host "   Перемещение _TEST_ENV\Base → Base..." -ForegroundColor Gray

if (Test-Path $TARGET_BASE) {
    Remove-Item $TARGET_BASE -Recurse -Force
    Write-Host "   ✅ Старая Base удалена" -ForegroundColor Green
}

# Копирование вместо перемещения (файл может быть заблокирован)
Copy-Item -Path $TEST_BASE -Destination $TARGET_BASE -Recurse -Force
Write-Host "   ✅ Base скопирована" -ForegroundColor Green

# ============================================================================
# МИГРАЦИЯ PROJECTS
# ============================================================================

Write-Host ""
Write-Host "3. МИГРАЦИЯ PROJECTS" -ForegroundColor Yellow
Write-Host ""

Write-Host "   Перемещение _TEST_ENV\Projects → Projects..." -ForegroundColor Gray

if (Test-Path $TARGET_PROJECTS) {
    # Слияние с существующей папкой
    Get-ChildItem $TEST_PROJECTS -Directory | ForEach-Object {
        $dest = "$TARGET_PROJECTS\$($_.Name)"
        if (Test-Path $dest) {
            Remove-Item $dest -Recurse -Force
        }
        Copy-Item -Path $_.FullName -Destination $TARGET_PROJECTS -Recurse -Force
        Write-Host "   ✅ Перемещено: $($_.Name)" -ForegroundColor Green
    }
} else {
    Copy-Item -Path $TEST_PROJECTS -Destination $TARGET_PROJECTS -Recurse -Force
    Write-Host "   ✅ Projects скопирована" -ForegroundColor Green
}

# ============================================================================
# .GITIGNORE
# ============================================================================

Write-Host ""
Write-Host "4. СОЗДАНИЕ .GITIGNORE" -ForegroundColor Yellow
Write-Host ""

$gitignoreContent = @"
# ===========================================
# .gitignore для БАЗЫ (System)
# ===========================================

# Исключаем PROJECTS (это отдельный репозиторий)
Projects/

# Исключаем OLD/RELEASE (библиотека наработок)
Base/OLD/
Base/RELEASE/

# Исключаем локальный архив
Base/_LOCAL_ARCHIVE/

# Исключаем черновики
Base/_drafts/

# Исключаем книги (тяжёлые PDF)
Base/BOOK/

# Исключаем временные файлы
*.tmp
*.log
logs/

# Исключаем сборки Unity
Projects/*/Build/
Projects/*/Library/
Projects/*/Temp/
Projects/*/Obj/
Projects/*/*.csproj.user

# VS Code
.vscode/
*.code-workspace

# Qwen
.qwen/tmp/

# Тестовая среда (после миграции будет удалена)
_TEST_ENV/

# Резервные копии
*.backup
"@

$gitignorePath = "$ROOT\.gitignore"

$gitignoreContent | Out-File -FilePath $gitignorePath -Encoding UTF8
Write-Host "   ✅ Создан .gitignore" -ForegroundColor Green

# ============================================================================
# ОЧИСТКА _TEST_ENV
# ============================================================================

Write-Host ""
Write-Host "5. ОЧИСТКА _TEST_ENV" -ForegroundColor Yellow
Write-Host ""

Write-Host "   Удаление _TEST_ENV..." -ForegroundColor Gray
Remove-Item $TEST_BASE -Recurse -Force
Remove-Item $TEST_PROJECTS -Recurse -Force
Remove-Item "$ROOT\_TEST_ENV" -Recurse -Force
Write-Host "   ✅ _TEST_ENV удалена" -ForegroundColor Green

# ============================================================================
# ИТОГИ
# ============================================================================

Write-Host ""
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
Write-Host "│   └── *.md" -ForegroundColor Gray
Write-Host "│" -ForegroundColor White
Write-Host "├── Projects/                       ← ПРОЕКТЫ" -ForegroundColor White
Write-Host "│   └── DragRaceUnity/" -ForegroundColor Gray
Write-Host "│" -ForegroundColor White
Write-Host "├── .gitignore                      ← Создан" -ForegroundColor White
Write-Host "└── _TEST_ENV/                      ← ❌ Удалена" -ForegroundColor Red
Write-Host ""

Write-Host "✅ МИГРАЦИЯ ЗАВЕРШЕНА!" -ForegroundColor Green
Write-Host ""

Write-Host "📋 СЛЕДУЮЩИЕ ШАГИ:" -ForegroundColor Cyan
Write-Host ""
Write-Host "   1. Закоммитить изменения в Git" -ForegroundColor Yellow
Write-Host "   2. Инициализировать Git в Base/ и Projects/" -ForegroundColor Yellow
Write-Host "   3. Открыть Base/AI_START_HERE.md" -ForegroundColor Yellow
Write-Host ""
