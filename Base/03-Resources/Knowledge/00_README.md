# Навигатор по Базе Знаний

**Версия:** 1.1
**Дата:** 2026-03-02 (обновлено)
**Проект:** QwenPoekt\Base

---

## ⚠️ ВАЖНОЕ ОБНОВЛЕНИЕ

**Дата расследования:** 2026-03-02

**Выявлено:** В предыдущей версии указаны неверные данные о количестве файлов.

**Исправлено:**
- 02_UNITY: ~~715~~ → **4 файла**
- 03_PATTERNS: ~~~10~~ → **3 файла**
- **ВСЕГО:** ~~~740~~ → **24 файла**

**Причина:** Ошибка в документации (файлы не потеряны, они не существовали).

**План пополнения:** См. [`reports/KNOWLEDGE_BASE_EXPANSION_PLAN.md`](../reports/KNOWLEDGE_BASE_EXPANSION_PLAN.md)

**Расследование:** См. [`reports/Missing_FILES_INVESTIGATION.md`](../reports/Missing_FILES_INVESTIGATION.md)

---

## 🎯 НАЗНАЧЕНИЕ

Этот файл — **единая точка входа** для навигации по KNOWLEDGE_BASE/.

**Что здесь:**
- Структура базы знаний
- Быстрый поиск по категориям
- Как добавить новый материал
- Связанные ресурсы

---

## 📚 СТРУКТУРА KNOWLEDGE_BASE

```
KNOWLEDGE_BASE/
├── 00_CORE/                    # Фундамент
│   ├── project_glossary.md     # Термины проекта
│   ├── unity_fundamentals.md   # Основы Unity
│   └── csharp_standards.md     # Стандарты C#
│
├── 01_RULES/                   # Правила
│   ├── ui_toolkit_rules.md     # UI Toolkit
│   ├── before_change_rule.md   # Проверка перед изменением
│   └── file_naming_rule.md     # Именование файлов
│
├── 02_UNITY/                   # Unity документация (4 файла)
│   ├── free_ai_for_unity.md
│   ├── unity_docker_builder.md
│   ├── unity_personal_license.md
│   └── unity_silent_tests.md
│
├── 03_PATTERNS/                # Паттерны решений
│   ├── error_solutions.md      # База решений ошибок
│   └── menu_creation.md        # Создание меню
│
└── 05_METHODOLOGY/             # Методологии
    ├── META_RULES_FOR_KNOWLEDGE_ANALYSIS.md
    └── AI_SELF_LEARNING_METHODOLOGY.md
```

---

## 🔍 БЫСТРЫЙ ПОИСК

### По категории

| Категория | Файлов | Описание | Поиск |
|-----------|--------|----------|-------|
| **00_CORE** | 9 | Фундамент (глоссарий, стандарты) | `glob -path "00_CORE"` |
| **01_RULES** | 3 | Правила (ui, before_change, file_naming) | `glob -path "01_RULES"` |
| **02_TOOLS** | 2 | Инструменты (Qwen CLI, VS Code) | `glob -path "02_TOOLS"` |
| **02_UNITY** | 4 | Unity документация | `glob -path "02_UNITY"` |
| **03_CSHARP** | 2 | C# (Style Guide, Patterns) | `glob -path "03_CSHARP"` |
| **03_PATTERNS** | 3 | Паттерны решений | `glob -path "03_PATTERNS"` |
| **04_ARCHIVES** | 1 | Архивы | `glob -path "04_ARCHIVES"` |
| **05_METHODOLOGY** | 5 | Методологии ИИ | `glob -path "05_METHODOLOGY"` |
| **ИТОГО** | **24** | **База знаний** | `glob -path "KNOWLEDGE_BASE"` |

### По теме

```powershell
# Поиск по содержимому
grep_search -pattern "UI Toolkit" -glob "*.md"

# Поиск по имени файла
glob -pattern "**/ui_*.md"

# Поиск в конкретной категории
grep_search -pattern "button" -path "KNOWLEDGE_BASE/01_RULES"
```

---

## 📥 КАК ДОБАВИТЬ НОВЫЙ МАТЕРИАЛ

### Шаг 1: Прочитать инструкцию

**Файл:** [`_docs/ANALYSIS_PROCESS.md`](_docs/ANALYSIS_PROCESS.md)

**Содержит:**
- Цикл обработки информации
- Шаблоны анализа
- Чек-лист добавления

---

### Шаг 2: Использовать промпт для ИИ

**Файл:** [`_templates/AI_ANALYSIS_PROMPT.md`](_templates/AI_ANALYSIS_PROMPT.md)

**Что делает:**
- Анализирует материал
- Извлекает ключевую информацию
- Оценивает ценность (1-5)
- Создаёт метаданные
- Даёт рекомендации

---

### Шаг 3: Проверить на дубликаты

```powershell
# Поиск по теме
grep_search -pattern "ключевые слова" -glob "*.md"

# Проверка хэшей (если файл)
Get-FileHash -Path "new_file.md" -Algorithm SHA256
```

---

### Шаг 4: Создать файл с метаданными

**Шаблон:**

```markdown
# Название файла

**Версия:** 1.0
**Дата:** ГГГГ-ММ-ДД
**Статус:** ✅ Актуально / ⚠️ Устаревает / ❌ Архив

**Связанные файлы:**
- [Файл1](путь)
- [Файл2](путь)

**Теги:** #тема #подтема #ключевое_слово

**Краткое описание:**
2-3 предложения о содержании

---

## Содержание

...
```

---

### Шаг 5: Записать в журнал

**Файл:** [`reports/OPERATION_LOG.md`](reports/OPERATION_LOG.md)

**Формат:**

```markdown
## ГГГГ-ММ-ДД ЧЧ:ММ Добавление: название

**Тип:** Статья / Правило / Паттерн / Код

**Путь:** `KNOWLEDGE_BASE/.../file.md`

**Статус:** ✅ Добавлено

---
```

---

### Шаг 6: Git коммит (если крупное изменение)

```powershell
git add KNOWLEDGE_BASE/.../file.md
git commit -m "Add: название файла"
```

---

## 📊 НОВЫЕ ПОСТУПЛЕНИЯ

| Дата | Файл | Категория | Статус |
|------|------|-----------|--------|
| 2026-03-02 | CODE_STYLE.md | 03_CSHARP | ✅ Добавлено |
| 2026-03-02 | DESIGN_PATTERNS_UNITY.md | 03_CSHARP | ✅ Добавлено |
| 2026-03-02 | UNITY_CS_REFERENCE_ANALYSIS.md | 00_CORE | ✅ Добавлено |
| 2026-03-02 | ObjectPool.cs | PROJECTS | ✅ Добавлено |
| 2026-03-02 | EventBus.cs | PROJECTS | ✅ Добавлено |
| 2026-03-02 | Commands.cs | PROJECTS | ✅ Добавлено |

**План пополнения:**
- 8 книг ждут конспектов (84 MB)
- 12 GitHub репозиториев ждут анализа

---

## 🔗 СВЯЗАННЫЕ РЕСУРСЫ

### Внутри проекта

| Файл | Описание |
|------|----------|
| [AI_START_HERE.md](../AI_START_HERE.md) | Главная инструкция проекта |
| [.qwen/QWEN.md](../.qwen/QWEN.md) | Мастер-конфиг ИИ |
| [README.md](../README.md) | Навигатор по проекту |
| [reports/OPERATION_LOG.md](../reports/OPERATION_LOG.md) | Журнал операций |

### Внешние ресурсы

| Ресурс | Описание |
|--------|----------|
| [Unity Docs](https://docs.unity3d.com/Manual/) | Официальная документация Unity |
| [.NET Docs](https://docs.microsoft.com/dotnet/) | Документация C#/.NET |
| [PowerShell Docs](https://docs.microsoft.com/powershell/) | Документация PowerShell |

---

## 📋 ЧЕК-ЛИСТ ПРОВЕРКИ БАЗЫ

### Еженедельно

```
[ ] Проверить _drafts/ (>7 дней → удалить/переместить)
[ ] Проверить OPERATION_LOG.md (заполняется ли)
[ ] Проверить Git статус (есть ли не закоммиченное)
```

### Ежемесячно

```
[ ] Запустить check-duplicates-advanced.ps1
[ ] Проверить KNOWLEDGE_BASE/ (актуальность)
[ ] Обновить этот файл (навигатор)
[ ] Ревизия старых файлов (>60 дней без использования)
```

---

## ⚠️ ПРАВИЛА ИМЕНОВАНИЯ

**Обязательно:**

- ✅ **Латиница** (a-z, A-Z)
- ✅ **Нижний регистр** (file_name.md)
- ✅ **Подчёркивание** (не пробелы)
- ✅ **Даты:** ГГГГ-ММ-ДД (2026-03-02)

**Запрещено:**

- ❌ **Пробелы** (use_underscore.md)
- ❌ **Спецсимволы** (!"№;%:?*[]{}$&|<>)
- ❌ **Кириллица** (only_latin.md)
- ❌ **Начало с дефиса** (-file.md)

**Подробности:** [`01_RULES/file_naming_rule.md`](01_RULES/file_naming_rule.md)

---

## 🎯 СЛЕДУЮЩИЕ ШАГИ

**Актуальный план:**

### 🔴 Приоритет 1: Пополнение KNOWLEDGE_BASE

1. **Конспекты книг (8 шт.):**
   - C# Style Guide → `03_CSHARP/CODE_STYLE.md` ✅
   - UI Toolkit Unity 6 → `02_UNITY/UI_TOOLKIT_BOOK.md`
   - Design Patterns → `03_CSHARP/DESIGN_PATTERNS_BOOK.md` ✅
   - Scriptable Objects → `02_UNITY/SCRIPTABLE_OBJECTS_BOOK.md`
   - URP Cookbook → `02_UNITY/URP_COOKBOOK_BOOK.md`

2. **Анализ репозиториев (12 шт.):**
   - UnityCsReference → `00_CORE/UNITY_CS_REFERENCE_ANALYSIS.md` ✅
   - ui-toolkit-dragon-crashers → `02_UNITY/DRAGON_CRASHERS_ANALYSIS.md`
   - QuizU → `02_UNITY/QUIZU_ANALYSIS.md`

### 🟡 Приоритет 2: Исправление документации

1. **Обновить `_docs/SCRIPTS_CATALOG.md`** — Каталог всех скриптов
2. **Создать `reports/KNOWLEDGE_BASE_EXPANSION_PLAN.md`** — План расширения

### 🟢 Приоритет 3: Автоматизация

1. **Создать `scripts/weekly-knowledge-audit.ps1`** — Еженедельный аудит
2. **Создать `scripts/check-knowledge-stats.ps1`** — Проверка статистики

---

**Версия:** 1.1 (ИСПРАВЛЕНА СТАТИСТИКА)  
**Дата:** 2026-03-02  
**Статус:** ✅ Актуально  

**Изменения:**
- Исправлена статистика (24 файла вместо 740)
- Добавлены новые поступления (C# Style Guide, Design Patterns, etc.)
- Обновлён план пополнения базы

---

**Нашёл что искал? Приступай к работе!** 🚀
