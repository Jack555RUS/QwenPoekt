# 🚀 БЕСШОВНЫЙ ЗАПУСК — АВТОНОМНАЯ ИНСТРУКЦИЯ

**Версия:** 1.0
**Дата:** 2026-03-03
**Статус:** ✅ **АВТОНОМНО** (работает без .qwen/)

---

## ⚡ ЭКСТРЕННЫЙ ЗАПУСК (если .qwen/ слетел)

**Этот файл работает БЕЗ любых зависимостей!**

---

## 🎯 БЫСТРЫЙ СТАРТ (5 минут)

### 1. Проверка целостности

```powershell
# Проверка существования критичных файлов
Test-Path "AI_START_HERE.md"      # Должен быть ✅
Test-Path "AGENTS.md"              # Должен быть ✅
Test-Path "ТЕКУЩАЯ_ЗАДАЧА.md"      # Должен быть ✅
Test-Path ".resume_marker.json"    # Маркер сессии
```

---

### 2. Восстановление контекста

**Прочитать маркер:**
```powershell
Get-Content .resume_marker.json | ConvertFrom-Json
```

**Или прочитать последнюю сессию:**
```powershell
Get-ChildItem "sessions\" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1
```

---

### 3. Запуск без .qwen/

**Если .qwen/ папка отсутствует:**

```powershell
# 1. Проверить наличие
if (-not (Test-Path ".qwen")) {
    Write-Warning ".qwen/ папка отсутствует!"
    Write-Host "Используйте автономный режим — этот файл."
}

# 2. Прочитать базовые правила
Get-Content "AGENTS.md" -Head 50

# 3. Прочитать текущую задачу
Get-Content "ТЕКУЩАЯ_ЗАДАЧА.md"
```

---

## 📋 МИНИМУМ ДЛЯ РАБОТЫ

**Критичные файлы (должны быть всегда):**

| Файл | Назначение | Критичность |
|------|------------|-------------|
| **AI_START_HERE.md** | Главная инструкция | 🔴 Критично |
| **AGENTS.md** | Точка входа | 🔴 Критично |
| **.resume_marker.json** | Маркер сессии | 🟡 Важно |
| **ТЕКУЩАЯ_ЗАДАЧА.md** | Активная задача | 🟡 Важно |
| **scripts/start-session.ps1** | Запуск сессии | 🟡 Важно |

**Опциональные (восстанавливаются):**

| Файл | Назначение |
|------|------------|
| **.qwen/QWEN.md** | Полный конфиг (можно восстановить из git) |
| **.qwen/rules/** | Правила (можно восстановить из git) |
| **mcp.json** | MCP конфиг (можно пересоздать) |

---

## 🔄 ВОССТАНОВЛЕНИЕ .qwen/

**Если .qwen/ слетел:**

```powershell
# 1. Проверить git
git status

# 2. Восстановить из git
git checkout HEAD -- .qwen/

# 3. Или создать заново
New-Item -ItemType Directory -Path ".qwen" -Force
New-Item -ItemType Directory -Path ".qwen/rules" -Force

# 4. Восстановить правила из 03-Resources
Copy-Item "03-Resources/Knowledge/01_RULES/*" ".qwen/rules/" -Force
```

---

## 🛡️ БЕЗОПАСНЫЙ ЗАПУСК

**Чек-лист перед запуском:**

```markdown
[✅] 1. AI_START_HERE.md существует
[✅] 2. AGENTS.md существует
[✅] 3. .resume_marker.json читается
[✅] 4. sessions/ папка доступна
[✅] 5. PowerShell профиль загружен
```

---

## 📊 ПРОВЕРКА ЦЕЛОСТНОСТИ

**Скрипт проверки:**

```powershell
# scripts/check-kernel-integrity.ps1
$criticalFiles = @(
    "AI_START_HERE.md",
    "AGENTS.md",
    "ТЕКУЩАЯ_ЗАДАЧА.md",
    ".resume_marker.json"
)

$missing = @()
foreach ($file in $criticalFiles) {
    if (-not (Test-Path $file)) {
        $missing += $file
    }
}

if ($missing.Count -gt 0) {
    Write-Error "❌ Критичные файлы отсутствуют: $($missing -join ', ')"
    exit 1
} else {
    Write-Success "✅ Все критичные файлы на месте"
}
```

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`AI_START_HERE.md`](./AI_START_HERE.md) — Основная инструкция
- [`AGENTS.md`](./AGENTS.md) — Точка входа
- [`scripts/check-kernel-integrity.ps1`](./scripts/check-kernel-integrity.ps1) — Проверка целостности
- [`scripts/start-session.ps1`](./scripts/start-session.ps1) — Запуск сессии

---

**Этот файл работает ВСЕГДА, даже если всё остальное слетело!** 🚀

**Последнее обновление:** 3 марта 2026 г.
**Версия:** 1.0 (Автономный режим)
