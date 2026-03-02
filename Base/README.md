# 🚀 QwenPoekt\Base — База Знаний Unity Проекта

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Проект:** DragRaceUnity (Unity 6000.3.10f1)

---

## ⚡ БЫСТРЫЙ СТАРТ

### Для нового участника:

```powershell
# 1. Прочитать этот файл (вы здесь!)

# 2. Прочитать главную инструкцию
code AI_START_HERE.md

# 3. Прочитать правила
code .qwen/QWEN.md

# 4. Начать работу
code ТЕКУЩАЯ_ЗАДАЧА.md
```

---

## 🛡️ БЕЗОПАСНОСТЬ (ВАЖНО!)

### Главное правило:

> **Перед тестированием → Создай _TEST_ENV!**

**Почему:**

- ✅ Тесты в изоляции (`_TEST_ENV/`)
- ✅ Оригинал Base не трогается
- ✅ Автоматическая очистка после тестов

**Команды:**

```powershell
# Создать тестовую среду
.\scripts\create-test-env.ps1

# Тестировать в _TEST_ENV (не в Base!)
.\test-pre-operation-backup.ps1 -OperationType "Test"
.\test-safe-delete.ps1 -Path "_drafts"

# Очистить после тестов
.\scripts\cleanup-test-env.ps1
```

---

## 📚 ИНСТРУКЦИИ ПО БЕЗОПАСНОСТИ

| Файл | Назначение | Когда читать |
|------|------------|--------------|
| **[AI_START_HERE.md](AI_START_HERE.md)** | Главная инструкция проекта | Перед началом работы |
| **[.qwen/QWEN.md](.qwen/QWEN.md)** | Мастер-конфиг ИИ (правила) | Обязательно! |
| **[_docs/TEST_ENV_GUIDE.md](_docs/TEST_ENV_GUIDE.md)** | Тестовая среда (_TEST_ENV) | Перед тестированием |
| **[_docs/PRE_OPERATION_BACKUP_GUIDE.md](_docs/PRE_OPERATION_BACKUP_GUIDE.md)** | Бэкап перед операциями | Перед удалением/перемещением |
| **[_docs/SAFE_DELETE_GUIDE.md](_docs/SAFE_DELETE_GUIDE.md)** | Безопасное удаление | Перед удалением папок |
| **[_docs/OLD_BACKUP_ANALYSIS_GUIDE.md](_docs/OLD_BACKUP_ANALYSIS_GUIDE.md)** | Анализ старых бэкапов | Раз в месяц (очистка) |

---

## 📁 СТРУКТУРА ПРОЕКТА

```
Base/
├── AI_START_HERE.md              ← Главная инструкция
├── .qwen/QWEN.md                 ← Мастер-конфиг ИИ
├── RULES_AND_TASKS.md            ← Правила и задачи
├── NOTES.md                      ← Заметки сессии
├── ТЕКУЩАЯ_ЗАДАЧА.md             ← Текущая задача
│
├── KNOWLEDGE_BASE/               ← База знаний (740 файлов)
│   ├── 00_CORE/                  ← Фундамент
│   ├── 01_RULES/                 ← Правила
│   ├── 02_UNITY/                 ← Unity (715 файлов)
│   ├── 03_PATTERNS/              ← Паттерны
│   └── 05_METHODOLOGY/           ← Методологии
│
├── scripts/                      ← Скрипты автоматизации
│   ├── pre-operation-backup.ps1  ← Бэкап перед операцией
│   ├── safe-delete.ps1           ← Безопасное удаление
│   ├── old-backup-analysis.ps1   ← Анализ бэкапов
│   ├── create-test-env.ps1       ← Создание тестовой среды
│   └── ...
│
├── _docs/                        ← Документация
│   ├── TEST_ENV_GUIDE.md         ← Тестовая среда
│   ├── PRE_OPERATION_BACKUP_GUIDE.md
│   ├── SAFE_DELETE_GUIDE.md
│   └── OLD_BACKUP_ANALYSIS_GUIDE.md
│
├── reports/                      ← Отчёты
│   ├── OPERATION_LOG.md          ← Журнал операций
│   └── ...
│
├── _templates/                   ← Шаблоны
├── _archive/                     ← Архив
└── .vscode/                      ← Настройки VS Code
```

---

## 🔧 СКРИПТЫ (БЫСТРЫЙ ДОСТУП)

### Бэкап и безопасность:

| Скрипт | Назначение | Команда |
|--------|------------|---------|
| **pre-operation-backup.ps1** | Бэкап перед операцией | `.\scripts\pre-operation-backup.ps1 -OperationType "Test"` |
| **safe-delete.ps1** | Безопасное удаление | `.\scripts\safe-delete.ps1 -Path "OLD/_INBOX/Project"` |
| **old-backup-analysis.ps1** | Анализ старых бэкапов | `.\scripts\old-backup-analysis.ps1` |

### Тестирование:

| Скрипт | Назначение | Команда |
|--------|------------|---------|
| **create-test-env.ps1** | Создание тестовой среды | `.\scripts\create-test-env.ps1` |
| **cleanup-test-env.ps1** | Очистка после тестов | `.\scripts\cleanup-test-env.ps1` |
| **test-pre-operation-backup.ps1** | Тест бэкапа | `.\test-pre-operation-backup.ps1 -OperationType "Test"` |
| **test-safe-delete.ps1** | Тест удаления | `.\test-safe-delete.ps1 -Path "_drafts"` |
| **test-old-backup-analysis.ps1** | Тест анализа | `.\test-old-backup-analysis.ps1` |

### Git и автоматизация:

| Скрипт | Назначение | Команда |
|--------|------------|---------|
| **auto-commit-daily.ps1** | Ежедневный коммит (18:00) | `.\scripts\auto-commit-daily.ps1` |
| **github-auth.ps1** | Авторизация на GitHub | `.\scripts\github-auth.ps1` |
| **github-backup.ps1** | Резервное копирование | `.\scripts\github-backup.ps1` |

---

## 📊 СТАТИСТИКА ПРОЕКТА

| Категория | Файлов | Размер |
|-----------|--------|--------|
| **KNOWLEDGE_BASE** | ~740 | ~50 MB |
| **scripts** | 40+ | ~1 MB |
| **reports** | 40+ | ~0.5 MB |
| **_docs** | 10+ | ~0.5 MB |
| **ВСЕГО** | ~800 | ~52 MB |

---

## 🎯 НАЧАЛО РАБОТЫ

### 1. Прочитать обязательные файлы:

```
[ ] AI_START_HERE.md (главная инструкция)
[ ] .qwen/QWEN.md (мастер-конфиг ИИ)
[ ] ТЕКУЩАЯ_ЗАДАЧА.md (текущая задача)
```

### 2. Настроить окружение:

```powershell
# Проверить среду
.\scripts\check-environment.ps1

# Создать тестовую среду (для тестов)
.\scripts\create-test-env.ps1
```

### 3. Начать работу:

```powershell
# Открыть текущую задачу
code ТЕКУЩАЯ_ЗАДАЧА.md

# Открыть заметки сессии
code NOTES.md
```

---

## 🔄 ЖИЗНЕННЫЙ ЦИКЛ ОПЕРАЦИИ

```
┌─────────────────────────────────────────────────────────┐
│  1. Прочитать AI_START_HERE.md                         │
│     ↓                                                   │
│  2. Определить задачу (ТЕКУЩАЯ_ЗАДАЧА.md)              │
│     ↓                                                   │
│  3. Создать бэкап (pre-operation-backup.ps1)           │
│     ↓                                                   │
│  4. Тестировать в _TEST_ENV (test-*.ps1)               │
│     ↓                                                   │
│  5. Применить к Base (если тесты OK)                   │
│     ↓                                                   │
│  6. Записать в OPERATION_LOG.md                        │
│     ↓                                                   │
│  7. Git коммит (auto-commit-daily.ps1)                 │
└─────────────────────────────────────────────────────────┘
```

---

## ⚠️ ПРЕДУПРЕЖДЕНИЯ

| Уровень | Когда | Действие |
|---------|-------|----------|
| **🟢 Низкий** | Чтение, WhatIf режим | ✅ Делать без спроса |
| **🟡 Средний** | Бэкап, создание файлов | ⚠️ Сообщить после |
| **🔴 Высокий** | Удаление, перемещение, архитектура | ✅ Спросить до |

---

## 🔗 GITHUB РЕСУРСЫ

**Репозиторий:** [QwenPoekt](https://github.com/Jackal/QwenPoekt) (приватный)

**Команды:**

```powershell
# Проверить статус
git status

# Сравнить с GitHub
.\scripts\github-compare.ps1

# Создать бэкап
.\scripts\github-backup.ps1
```

---

## 📞 КОНТАКТЫ

**Путь проекта:** `D:\QwenPoekt\Base`

**Ресурсы:**
- [Unity Docs](https://docs.unity3d.com/Manual/)
- [.NET Docs](https://docs.microsoft.com/dotnet/)
- [PowerShell Docs](https://docs.microsoft.com/powershell/)

---

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Актуально

---

**Прочитал? Приступай к работе!** 🚀
