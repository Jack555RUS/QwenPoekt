# check-safe-filename.ps1
# Проверка имён файлов на соответствие правилу именования
# Использование: .\check-safe-filename.ps1 [-Path <путь>] [-Recurse]

param(
    [string]$Path = ".",
    [switch]$Recurse
)

Write-Host "=== ПРОВЕРКА БЕЗОПАСНОСТИ ИМЁН ФАЙЛОВ ===" -ForegroundColor Cyan
Write-Host "Путь: $Path"
Write-Host "Рекурсивно: $($Recurse.IsPresent)"
Write-Host ""

$forbiddenChars = '[&|><*$@#;=!%`"''(),\[\]{}:]'
$cyrillic = '[А-Яа-яЁё]'
$spaces = '\s'

$files = if ($Recurse) {
    Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue
} else {
    Get-ChildItem -Path $Path -File -ErrorAction SilentlyContinue
}

$totalFiles = 0
$forbiddenErrors = 0
$cyrillicWarnings = 0
$spaceWarnings = 0
$uppercaseWarnings = 0

foreach ($file in $files) {
    $name = $file.Name
    $totalFiles++
    
    # Проверка на запрещённые символы (КРИТИЧНО)
    if ($name -match $forbiddenChars) {
        Write-Host "❌ КРИТИЧНО: $($file.FullName)" -ForegroundColor Red
        Write-Host "   Запрещённые символы в имени!" -ForegroundColor Red
        $forbiddenErrors++
    }
    
    # Проверка на кириллицу (ПРЕДУПРЕЖДЕНИЕ)
    if ($name -match $cyrillic) {
        Write-Host "⚠️  ПРЕДУПРЕЖДЕНИЕ: $($file.FullName)" -ForegroundColor Yellow
        Write-Host "   Кириллица (только латиница)" -ForegroundColor Yellow
        $cyrillicWarnings++
    }
    
    # Проверка на пробелы (ПРЕДУПРЕЖДЕНИЕ)
    if ($name -match $spaces) {
        Write-Host "⚠️  ПРЕДУПРЕЖДЕНИЕ: $($file.FullName)" -ForegroundColor Yellow
        Write-Host "   Пробелы (замените на _)" -ForegroundColor Yellow
        $spaceWarnings++
    }
    
    # Проверка на заглавные буквы для файлов (ПРЕДУПРЕЖДЕНИЕ)
    if ($file.Extension -match '\.(md|cs|ps1|json|xml|yaml|yml|unity|uxml|uss)$' -and $name -match '[A-Z]') {
        # Исключаем папки с PascalCase (это нормально для папок)
        if ($file.DirectoryName -notmatch '[A-Z]') {
            Write-Host "⚠️  ПРЕДУПРЕЖДЕНИЕ: $($file.FullName)" -ForegroundColor Yellow
            Write-Host "   Заглавные буквы (только lowercase для файлов)" -ForegroundColor Yellow
            $uppercaseWarnings++
        }
    }
}

Write-Host ""
Write-Host "=== ИТОГИ ПРОВЕРКИ ===" -ForegroundColor Cyan
Write-Host "Всего файлов проверено: $totalFiles"

if ($forbiddenErrors -gt 0) {
    Write-Host "❌ Критичные ошибки: $forbiddenErrors" -ForegroundColor Red
}
if ($cyrillicWarnings -gt 0) {
    Write-Host "⚠️  Кириллица: $cyrillicWarnings" -ForegroundColor Yellow
}
if ($spaceWarnings -gt 0) {
    Write-Host "⚠️  Пробелы: $spaceWarnings" -ForegroundColor Yellow
}
if ($uppercaseWarnings -gt 0) {
    Write-Host "⚠️  Заглавные буквы: $uppercaseWarnings" -ForegroundColor Yellow
}

if ($forbiddenErrors -eq 0 -and $cyrillicWarnings -eq 0 -and $spaceWarnings -eq 0 -and $uppercaseWarnings -eq 0) {
    Write-Host ""
    Write-Host "✅ Все имена файлов безопасны и соответствуют правилу!" -ForegroundColor Green
    Write-Host ""
    exit 0
} else {
    Write-Host ""
    if ($forbiddenErrors -gt 0) {
        Write-Host "❌ Найдены критичные проблемы! Требуется переименование." -ForegroundColor Red
    } else {
        Write-Host "⚠️  Найдены предупреждения. Рекомендуется переименовать." -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Правило: KNOWLEDGE_BASE/01_RULES/file_naming_rule.md" -ForegroundColor Cyan
    exit 1
}
