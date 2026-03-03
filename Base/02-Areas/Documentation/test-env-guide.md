# Test Environment — Тестовая среда

**Назначение:** Изолированная среда для безопасного тестирования скриптов

---

## 🚀 БЫСТРЫЙ СТАРТ

```powershell
# 1. Создать тестовую среду
.\scripts\create-test-env.ps1

# 2. Запустить тесты
.\test-pre-operation-backup.ps1 -OperationType "Test"
.\test-safe-delete.ps1 -Path "_drafts" -WhatIf
.\test-old-backup-analysis.ps1

# 3. Очистить после тестов
.\scripts\cleanup-test-env.ps1
```

---

## 📋 ЧТО ТАКОЕ _TEST_ENV?

**Изолированная тестовая среда** — это копия рабочей папки `Base`, но с изменениями:

```
D:\QwenPoekt\
├── Base/                    # ← ОРИГИНАЛ (не трогать!)
├── _BACKUP/                 # ← РЕАЛЬНЫЕ БЭКАПЫ
│
└── _TEST_ENV/               # ← ТЕСТОВАЯ СРЕДА
    ├── Base/                # Копия Base (без PROJECTS, OLD, RELEASE)
    ├── _BACKUP/             # Тестовые бэкапы
    └── reports/             # Логи тестов
```

---

## ✅ ПРЕИМУЩЕСТВА

| Преимущество | Описание |
|--------------|----------|
| **Безопасность** | Ошибки в скриптах не повредят оригинал |
| **Изоляция** | Все пути в _TEST_ENV (вне не выходит) |
| **Автоматизация** | Создание и очистка одним скриптом |
| **Быстро** | Копирование только важных файлов (~50 MB vs 2.5 GB) |
| **Чисто** | Автоматическая очистка после тестов |

---

## 📖 ИСПОЛЬЗОВАНИЕ

### Шаг 1: Создание тестовой среды

```powershell
.\scripts\create-test-env.ps1

# Вывод:
# === СОЗДАНИЕ ТЕСТОВОЙ СРЕДЫ ===
# Скопировано файлов: 850
# Общий размер: 52.3 MB
# ✅ ТЕСТОВАЯ СРЕДА ГОТОВА!
```

**Что делает:**
1. Создаёт `_TEST_ENV/Base` (копия `Base`)
2. Создаёт `_TEST_ENV/_BACKUP` (пустая папка)
3. Копирует файлы (исключая PROJECTS, OLD, RELEASE, BOOK, .git)
4. Создаёт тестовые скрипты (`test-*.ps1`)
5. Инициализирует логи

**Параметры:**

| Параметр | Описание | Пример |
|----------|----------|--------|
| `-Force` | Удалить старую среду перед созданием | `-Force` |
| `-ExcludeFolders` | Дополнительные исключения | `@("temp")` |

---

### Шаг 2: Запуск тестов

**Тестовые скрипты:**

| Скрипт | Назначение |
|--------|------------|
| `test-pre-operation-backup.ps1` | Тест бэкапа |
| `test-safe-delete.ps1` | Тест удаления |
| `test-old-backup-analysis.ps1` | Тест анализа бэкапов |

**Примеры:**

```powershell
# Тест 1: Бэкап
.\test-pre-operation-backup.ps1 -OperationType "Test"
.\test-pre-operation-backup.ps1 -OperationType "Test" -WhatIf

# Тест 2: Удаление
.\test-safe-delete.ps1 -Path "_drafts" -WhatIf
.\test-safe-delete.ps1 -Path "_drafts"

# Тест 3: Анализ бэкапов
.\test-old-backup-analysis.ps1
```

---

### Шаг 3: Очистка после тестов

```powershell
# Проверка (без удаления)
.\scripts\cleanup-test-env.ps1 -WhatIf

# Очистка с подтверждением
.\scripts\cleanup-test-env.ps1

# Очистка без подтверждения (Force)
.\scripts\cleanup-test-env.ps1 -Force

# Очистка с сохранением логов
.\scripts\cleanup-test-env.ps1 -SaveLogs
```

**Что делает:**
1. Анализирует размер _TEST_ENV
2. Сохраняет логи (если `-SaveLogs`)
3. Удаляет _TEST_ENV полностью

---

## 🛡️ ЗАЩИТА (БЕЗОПАСНОСТЬ)

### Проверка путей

**Все тестовые скрипты проверяют пути:**

```powershell
# В каждом тестовом скрипте:
if ($SourceRoot -notlike "*_TEST_ENV*") {
    Write-Error "❌ ОШИБКА БЕЗОПАСНОСТИ: путь должен быть в _TEST_ENV!"
    exit 1
}
```

**Результат:**
- ✅ Пути в `_TEST_ENV` → ОК
- ❌ Пути вне `_TEST_ENV` → Ошибка, выход

---

### Исключения при копировании

**Не копируются (экономия места):**

| Папка/Файл | Причина |
|------------|---------|
| `PROJECTS/` | Unity проекты (большие, не нужны для тестов) |
| `OLD/` | Библиотека наработок |
| `RELEASE/` | Готовые проекты |
| `_LOCAL_ARCHIVE/` | История сессий |
| `BOOK/` | PDF книги (тяжёлые) |
| `_BACKUP/` | Реальные бэкапы |
| `.git/` | Git репозиторий |
| `*.pdf`, `*.zip`, `*.rar` | Тяжёлые файлы |

**Результат:** ~50 MB вместо ~2.5 GB

---

## 📊 СТРУКТУРА _TEST_ENV

```
_TEST_ENV/
├── Base/                        # Копия Base (облегчённая)
│   ├── 03-Resources/PowerShell/                 # Скрипты
│   │   ├── pre-operation-backup.ps1
│   │   ├── safe-delete.ps1
│   │   ├── old-backup-analysis.ps1
│   │   ├── test-pre-operation-backup.ps1    ← Тестовая версия
│   │   ├── test-safe-delete.ps1             ← Тестовая версия
│   │   └── test-old-backup-analysis.ps1     ← Тестовая версия
│   ├── reports/                 # Отчёты
│   ├── 02-Areas/Documentation/                   # Документация
│   ├── _templates/              # Шаблоны
│   ├── KNOWLEDGE_BASE/          # База знаний
│   └── ...                      # Другие папки
│
├── _BACKUP/                     # Тестовые бэкапы
│   └── 2026-03-02_03-30_Test/   ← Пример тестового бэкапа
│
└── reports/                     # Логи тестов
    ├── TEST_LOG.md              ← Журнал тестов
    ├── CREATE_TEST_ENV_REPORT.md
    └── BACKUP_ANALYSIS_REPORT.md
```

---

## 🔄 ЖИЗНЕННЫЙ ЦИКЛ ТЕСТА

```
1. СОЗДАНИЕ
   └─ create-test-env.ps1
      ├─ Копирование Base → _TEST_ENV/Base
      ├─ Создание _TEST_ENV/_BACKUP
      └─ Создание тестовых скриптов

2. ТЕСТИРОВАНИЕ
   └─ test-*.ps1
      ├─ test-pre-operation-backup.ps1
      ├─ test-safe-delete.ps1
      └─ test-old-backup-analysis.ps1

3. ОЧИСТКА
   └─ cleanup-test-env.ps1
      ├─ Сохранение логов (опционально)
      └─ Удаление _TEST_ENV
```

---

## 📋 ЧЕК-ЛИСТ ТЕСТИРОВАНИЯ

```
[ ] 1. Создать тестовую среду
      .\create-test-env.ps1

[ ] 2. Проверить структуру
      ls _TEST_ENV

[ ] 3. Запустить тесты (с -WhatIf сначала)
      .\test-pre-operation-backup.ps1 -OperationType "Test" -WhatIf
      .\test-safe-delete.ps1 -Path "_drafts" -WhatIf
      .\test-old-backup-analysis.ps1

[ ] 4. Запустить тесты (без -WhatIf)
      .\test-pre-operation-backup.ps1 -OperationType "Test"
      .\test-safe-delete.ps1 -Path "_drafts"

[ ] 5. Проверить логи
      code _TEST_ENV\reports\TEST_LOG.md

[ ] 6. Очистить тестовую среду
      .\cleanup-test-env.ps1 -SaveLogs
```

---

## ⚠️ ВАЖНЫЕ ПРАВИЛА

1. **ВСЕГДА создавай _TEST_ENV** перед тестированием новых скриптов
2. **НЕ тестируй на оригинале** (Base) без проверки в _TEST_ENV
3. **ОЧИЩАЙ _TEST_ENV** после завершения тестов
4. **СОХРАНЯЙ логи** ( `-SaveLogs` ) для отчёта
5. **ПРОВЕРЯЙ пути** в скриптах (должны быть в _TEST_ENV)

---

## 🎯 СВЯЗАННЫЕ СКРИПТЫ

| Скрипт | Назначение |
|--------|------------|
| `create-test-env.ps1` | Создание тестовой среды |
| `cleanup-test-env.ps1` | Очистка после тестов |
| `test-pre-operation-backup.ps1` | Тест бэкапа |
| `test-safe-delete.ps1` | Тест удаления |
| `test-old-backup-analysis.ps1` | Тест анализа бэкапов |

---

## 🧠 ОТЛИЧИЯ ТЕСТОВЫХ СКРИПТОВ

| Функция | Оригинал | Тестовая версия |
|---------|----------|-----------------|
| **Пути** | `D:\QwenPoekt\Base` | `D:\QwenPoekt\_TEST_ENV\Base` |
| **Бэкап** | `D:\QwenPoekt\_BACKUP` | `D:\QwenPoekt\_TEST_ENV\_BACKUP` |
| **Лог** | `reports\OPERATION_LOG.md` | `_TEST_ENV\reports\TEST_LOG.md` |
| **Проверка** | Нет | ✅ Выход за _TEST_ENV → Ошибка |
| **Префикс** | Нет | `test-` |

---

## 💡 СОВЕТЫ

### Быстрое тестирование

```powershell
# 1. Создать среду
.\create-test-env.ps1

# 2. Запустить все тесты
.\test-pre-operation-backup.ps1 -OperationType "FullTest"
.\test-safe-delete.ps1 -Path "_drafts"
.\test-old-backup-analysis.ps1

# 3. Очистить
.\cleanup-test-env.ps1 -SaveLogs
```

### Отладка скриптов

```powershell
# 1. Создать среду
.\create-test-env.ps1

# 2. Внести изменения в тестовый скрипт
code _TEST_ENV\Base\scripts\test-safe-delete.ps1

# 3. Запустить тест
.\test-safe-delete.ps1 -Path "_drafts" -WhatIf

# 4. Повторять (шаги 2-3) до успеха

# 5. Скопировать в Base
Copy-Item "_TEST_ENV\Base\scripts\test-safe-delete.ps1" "scripts\safe-delete.ps1"

# 6. Очистить
.\cleanup-test-env.ps1
```

---

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готов к использованию

