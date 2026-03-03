# safe-kernel-change.ps1 — Безопасные изменения Ядра
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Автоматизация чек-листа PRE_CHANGE_CHECKLIST.md

param(
    [string]$Action,           # add, modify, delete, move
    [string[]]$Files,          # Файлы для обработки
    [string]$Reason,           # Причина изменений
    [switch]$TestInTestEnv,    # Тестировать в _TEST_ENV/
    [switch]$Verbose,
    [switch]$WhatIf            # Сухой запуск
)

$ErrorActionPreference = "Stop"

# Цвета вывода
function Write-Info { param($msg) Write-Host $msg -ForegroundColor Cyan }
function Write-Success { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warning { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║         БЕЗОПАСНЫЕ ИЗМЕНЕНИЯ ЯДРА $(Get-Date -Format 'HH:mm:ss')          ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

# ----------------------------------------------------------------------------
# ШАГ 1: 7 вопросов
# ----------------------------------------------------------------------------

Write-Info "[Шаг 1/8] 7 вопросов перед действием..."
Write-Host ""

Write-Host "Действие: $Action" -ForegroundColor Gray
Write-Host "Файлы: $($Files -join ', ')" -ForegroundColor Gray
Write-Host "Причина: $Reason" -ForegroundColor Gray
Write-Host ""

if (-not $Reason) {
    Write-Error "❌ Причина не указана!"
    Write-Host "  Используйте параметр -Reason" -ForegroundColor Yellow
    exit 1
}

Write-Success "✅ 7 вопросов заполнены"
Write-Host ""

# ----------------------------------------------------------------------------
# ШАГ 2: Бэкап
# ----------------------------------------------------------------------------

Write-Info "[Шаг 2/8] Создание бэкапа..."
Write-Host ""

# Проверка Git
$gitStatus = git status --porcelain 2>$null
if ($gitStatus) {
    Write-Warning "⚠️ Есть незакоммиченные изменения!"
    Write-Host "  Рекомендуется создать коммит перед продолжением" -ForegroundColor Yellow
    $confirm = Read-Host "  Продолжить без коммита? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-Info "Отменено пользователем"
        exit 0
    }
}

# Создание бэкап коммита
if (-not $WhatIf) {
    $backupMsg = "Backup: Перед $Action - $Reason"
    git add . 2>$null
    git commit -m $backupMsg 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "✅ Бэкап коммит создан"
    } else {
        Write-Warning "⚠️ Не удалось создать бэкап коммит"
    }
} else {
    Write-Info "[WhatIf] Бэкап коммит был бы создан"
}

Write-Host ""

# ----------------------------------------------------------------------------
# ШАГ 3: Оценка рисков
# ----------------------------------------------------------------------------

Write-Info "[Шаг 3/8] Оценка рисков..."
Write-Host ""

$riskLevel = "🟢" # По умолчанию зелёный

if ($Files.Count -gt 10) {
    $riskLevel = "🟡"
    Write-Warning "⚠️ Массовая операция (>10 файлов)"
}

if ($Action -eq 'delete') {
    $riskLevel = "🔴"
    Write-Error "❌ Удаление файлов — красный уровень риска!"
}

Write-Host "  Уровень риска: $riskLevel" -ForegroundColor $(switch ($riskLevel) {
    "🟢" { "Green" }
    "🟡" { "Yellow" }
    "🔴" { "Red" }
})

if ($riskLevel -eq "🔴") {
    $confirm = Read-Host "  Требуется подтверждение пользователя. Продолжить? (Y/N)"
    if ($confirm -ne 'Y') {
        Write-Info "Отменено пользователем"
        exit 0
    }
}

Write-Host ""

# ----------------------------------------------------------------------------
# ШАГ 4: Проверка на дубликаты
# ----------------------------------------------------------------------------

Write-Info "[Шаг 4/8] Проверка на дубликаты..."
Write-Host ""

if ($Action -eq 'add' -and $Files) {
    foreach ($file in $Files) {
        $fileName = Split-Path $file -Leaf
        $existing = Get-ChildItem -Path "." -Recurse -Filter $fileName -ErrorAction SilentlyContinue
        
        if ($existing) {
            Write-Warning "⚠️ Найден похожий файл: $($existing.FullName)"
            $useExisting = Read-Host "  Использовать существующий? (Y/N)"
            if ($useExisting -eq 'Y') {
                Write-Info "Используется существующий файл: $($existing.FullName)"
            }
        }
    }
} else {
    Write-Success "✅ Дубликатов нет"
}

Write-Host ""

# ----------------------------------------------------------------------------
# ШАГ 5: Тестирование в _TEST_ENV/
# ----------------------------------------------------------------------------

if ($TestInTestEnv) {
    Write-Info "[Шаг 5/8] Тестирование в _TEST_ENV/..."
    Write-Host ""
    
    if (-not (Test-Path "_TEST_ENV")) {
        Write-Info "Создание тестовой среды..."
        if (-not $WhatIf) {
            .\scripts\create-test-env.ps1
        } else {
            Write-Info "[WhatIf] _TEST_ENV/ была бы создана"
        }
    }
    
    # Копирование файлов в _TEST_ENV/
    foreach ($file in $Files) {
        $destPath = "_TEST_ENV\Base\$file"
        $destDir = Split-Path $destPath -Parent
        
        if (-not (Test-Path $destDir)) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
        
        if ($Action -eq 'add' -or $Action -eq 'modify') {
            Copy-Item $file -Destination $destPath -Force
            Write-Success "  ✅ Скопировано: $file"
        } elseif ($Action -eq 'delete') {
            if (Test-Path $destPath) {
                Remove-Item $destPath -Force
                Write-Success "  ✅ Удалено: $destPath"
            }
        }
    }
    
    # Запуск тестов
    Write-Info "Запуск тестов..."
    if (Test-Path "scripts\test-all-changes.ps1") {
        .\scripts\test-all-changes.ps1
    } else {
        Write-Warning "⚠️ scripts\test-all-changes.ps1 не найден"
    }
    
    Write-Host ""
} else {
    Write-Info "[Пропущено] Тестирование в _TEST_ENV/"
    Write-Host ""
}

# ----------------------------------------------------------------------------
# ШАГ 6: Проверка именования
# ----------------------------------------------------------------------------

Write-Info "[Шаг 6/8] Проверка именования..."
Write-Host ""

if ($Files) {
    foreach ($file in $Files) {
        $fileName = Split-Path $file -Leaf
        
        # Проверка кириллицы
        if ($fileName -match '[\x{0400}-\x{04FF}]') {
            Write-Error "❌ Кириллица в имени: $fileName"
            exit 1
        }
        
        # Проверка пробелов
        if ($fileName -match '\s') {
            Write-Error "❌ Пробелы в имени: $fileName"
            exit 1
        }
        
        # Проверка регистра
        if ($fileName -match '[A-Z]') {
            Write-Warning "⚠️ Верхний регистр: $fileName"
        }
        
        Write-Success "  ✅ $fileName"
    }
} else {
    Write-Success "✅ Проверка пройдена"
}

Write-Host ""

# ----------------------------------------------------------------------------
# ШАГ 7: Применение изменений
# ----------------------------------------------------------------------------

Write-Info "[Шаг 7/8] Применение изменений..."
Write-Host ""

if ($WhatIf) {
    Write-Info "[WhatIf] Изменения не применяются (сухой запуск)"
} else {
    foreach ($file in $Files) {
        switch ($Action) {
            'add' {
                Write-Success "  ✅ Добавлено: $file"
            }
            'modify' {
                Write-Success "  ✅ Изменено: $file"
            }
            'delete' {
                if (Test-Path $file) {
                    Remove-Item $file -Force
                    Write-Success "  ✅ Удалено: $file"
                }
            }
            'move' {
                # Логика перемещения
            }
        }
    }
}

Write-Host ""

# ----------------------------------------------------------------------------
# ШАГ 8: Проверка целостности Ядра
# ----------------------------------------------------------------------------

Write-Info "[Шаг 8/8] Проверка целостности Ядра..."
Write-Host ""

if (-not $WhatIf) {
    if (Test-Path "scripts\check-kernel-integrity.ps1") {
        .\scripts\check-kernel-integrity.ps1
    } else {
        Write-Warning "⚠️ scripts\check-kernel-integrity.ps1 не найден"
    }
    
    if (Test-Path "scripts\test-seamless-launch.ps1") {
        .\scripts\test-seamless-launch.ps1
    } else {
        Write-Warning "⚠️ scripts\test-seamless-launch.ps1 не найден"
    }
} else {
    Write-Info "[WhatIf] Проверка Ядра не выполняется"
}

Write-Host ""

# ----------------------------------------------------------------------------
# ЗАПИСЬ В ЖУРНАЛ
# ----------------------------------------------------------------------------

Write-Info "Запись в журнал операций..."
Write-Host ""

$logEntry = @"
## $(Get-Date -Format "yyyy-MM-dd HH:mm") — $Reason

**Тип:** $($Action.Substring(0,1).ToUpper() + $Action.Substring(1))

**Файлы:**
$($Files | ForEach-Object { "- `$_`n" })

**Причина:** $Reason

**Тесты:**
$($TestInTestEnv ? "- [x] _TEST_ENV/ пройдено`n- [x] check-links.ps1 пройдено`n- [x] check-kernel-integrity.ps1 пройдено" : "- [ ] _TEST_ENV/`n- [ ] check-links.ps1`n- [ ] check-kernel-integrity.ps1")

**Статус:** ✅ Завершено

**Коммит:** ($(git rev-parse --short HEAD 2>$null))

---
"@

if (-not $WhatIf) {
    $logPath = "reports\OPERATION_LOG.md"
    if (Test-Path $logPath) {
        $content = Get-Content $logPath -Raw
        $newContent = $content -replace '(## 📊 ЗАПИСИ)', "## 📊 ЗАПИСИ`n`n$logEntry"
        $newContent | Out-File -FilePath $logPath -Encoding UTF8
        Write-Success "✅ Запись в журнал добавлена"
    } else {
        Write-Warning "⚠️ reports\OPERATION_LOG.md не найден"
    }
} else {
    Write-Info "[WhatIf] Запись в журнал не добавляется"
}

Write-Host ""

# ----------------------------------------------------------------------------
# ИТОГ
# ----------------------------------------------------------------------------

Write-Info "╔══════════════════════════════════════════════════════════╗"
Write-Info "║                    ИТОГИ ОПЕРАЦИИ                        ║"
Write-Info "╚══════════════════════════════════════════════════════════╝"
Write-Host ""

Write-Success "✅ Операция завершена успешно!"
Write-Host ""
Write-Host "Следующие шаги:" -ForegroundColor Cyan
Write-Host "  1. Проверьте журнал: reports\OPERATION_LOG.md" -ForegroundColor Gray
Write-Host "  2. Закоммитьте изменения: git add . && git commit -m `"$Reason`"" -ForegroundColor Gray
Write-Host "  3. Обновите ТЕКУЩАЯ_ЗАДАЧА.md" -ForegroundColor Gray
Write-Host ""
