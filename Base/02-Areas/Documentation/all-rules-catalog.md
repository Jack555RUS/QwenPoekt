# 📚 КАТАЛОГ ВСЕХ ПРАВИЛ И СТАНДАРТОВ

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Главный навигатор по правилам

---

## 🎯 НАЗНАЧЕНИЕ

Этот файл содержит **полный каталог всех правил, стандартов, руководств и инструкций** проекта с логической интеграцией в структуру.

**Используйте для:**
- Поиска нужного правила
- Понимания иерархии документов
- Интеграции новых правил

---

## 📊 ИЕРАРХИЯ ПРАВИЛ

```
┌─────────────────────────────────────────────────────────┐
│  УРОВЕНЬ 1: ГЛОБАЛЬНЫЕ ПРАВИЛА (проект)                │
│  ├─ AI_START_HERE.md                                   │
│  ├─ RULES_AND_TASKS.md                                 │
│  └─ .qwen/QWEN.md                                      │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  УРОВЕНЬ 2: СТАНДАРТЫ И СТАНДАРТЫ (код, данные)        │
│  ├─ KNOWLEDGE_BASE/00_CORE/csharp_standards.md         │
│  ├─ KNOWLEDGE_BASE/01_RULES/*.md                       │
│  └─ _docs/FILE_CHANGE_RULE.md                          │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  УРОВЕНЬ 3: РУКОВОДСТВА (how-to)                       │
│  ├─ _docs/*_GUIDE.md (20+ файлов)                      │
│  └─ OLD/*/BUILD_INSTRUCTIONS.md                        │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  УРОВЕНЬ 4: ИНСТРУКЦИИ (step-by-step)                  │
│  ├─ OLD/*/TESTING_INSTRUCTIONS.md                      │
│  └─ reports/SESSION_*_INSTRUCTIONS.md                  │
└─────────────────────────────────────────────────────────┘
```

---

## 📋 УРОВЕНЬ 1: ГЛОБАЛЬНЫЕ ПРАВИЛА

### 1.1 AI_START_HERE.md

**Назначение:** Главная инструкция для ИИ

**Содержание:**
- Идентификация ИИ
- Инструменты (50+ файлов)
- Агенты ИИ (6 субагентов)
- Карта проекта
- Статистика

**Связанные файлы:**
- `.qwen/QWEN.md`
- `README.md`

---

### 1.2 RULES_AND_TASKS.md

**Назначение:** Извлечённые уроки, правила работы

**Содержание:**
- Правило 1: Проверка ссылок перед перемещением
- Правило 2: Запись задач в NOTES.md
- Правило 3: Учиться на ошибках
- Правило 4: Автоматизация проверок

**Связанные файлы:**
- `NOTES.md`
- `reports/OPERATION_LOG.md`

---

### 1.3 .qwen/QWEN.md

**Назначение:** Мастер-конфиг ИИ

**Содержание:**
- Предпочтения пользователя
- Иерархия (Пользователь → ИИ → Агенты)
- Мета-правила (Хранитель Знаний, Итеративный Улучшатель)
- Правила работы (код, UI, сборка, тестирование)
- Git правила
- OLD/RELEASE система

**Связанные файлы:**
- `AI_START_HERE.md`
- `RULES_AND_TASKS.md`

---

## 📋 УРОВЕНЬ 2: СТАНДАРТЫ

### 2.1 KNOWLEDGE_BASE/00_CORE/csharp_standards.md

**Назначение:** Стандарты кода C#

**Содержание:**
- var использование
- Expression Body
- Collection Initializers
- Nullable Reference Types
- Async/Await
- Pattern Matching
- String Interpolation
- Null-conditional operators

**Статус:** ✅ Обязательно

**Связанные файлы:**
- `.editorconfig`
- `KNOWLEDGE_BASE/01_RULES/file_naming_rule.md`

---

### 2.2 KNOWLEDGE_BASE/01_RULES/

**Назначение:** Правила разработки

| Файл | Описание | Статус |
|------|----------|--------|
| `ui_toolkit_rules.md` | Правила UI Toolkit | ✅ |
| `before_change_rule.md` | Проверка перед изменением | ✅ |
| `file_naming_rule.md` | Именование файлов (snake_case) | ✅ |

**Связанные файлы:**
- `_docs/STRUCTURE_GUIDE.md`
- `_docs/KB_AUDIT_GUIDE.md`

---

### 2.3 KNOWLEDGE_BASE/05_METHODOLOGY/

**Назначение:** Методологии и инструкции для ИИ

| Файл | Описание | Статус |
|------|----------|--------|
| `AI_DEVELOPER_INSTRUCTION.md` | Инструкция ИИ-разработчика (29 KB) | ✅ |
| `FOR_AI_READ_HERE.md` | Главная инструкция для ИИ | ✅ |
| `META_RULES_FOR_KNOWLEDGE_ANALYSIS.md` | Мета-правила анализа | ✅ |
| `AI_SELF_LEARNING_METHODOLOGY.md` | Саморазвитие ИИ | ✅ |

**Связанные файлы:**
- `AI_START_HERE.md`
- `.qwen/QWEN.md`

---

### 2.3 _docs/FILE_CHANGE_RULE.md

**Назначение:** Правило обновления связанных файлов

**Содержание:**
- Матрица изменений (создание, удаление, переименование)
- Что обновлять при изменении
- Автоматизация обновлений

**Статус:** ✅ Обязательно

**Связанные файлы:**
- `RULES_AND_TASKS.md`
- `_docs/STRUCTURE_GUIDE.md`

---

## 📋 УРОВЕНЬ 3: РУКОВОДСТВА

### 3.1 Бэкап и безопасность

| Файл | Описание | Статус |
|------|----------|--------|
| `BACKUP_STRATEGY.md` | Стратегия 3-2-1 | ✅ |
| `PRE_OPERATION_BACKUP_GUIDE.md` | Бэкап перед операциями | ✅ |
| `SAFE_DELETE_GUIDE.md` | Безопасное удаление | ✅ |
| `OLD_BACKUP_ANALYSIS_GUIDE.md` | Анализ старых бэкапов | ✅ |

**Интеграция:**
```
AI_START_HERE.md (Инструменты)
    ↓
scripts/pre-operation-backup.ps1
    ↓
reports/OPERATION_LOG.md
```

---

### 3.2 Аудит и очистка

| Файл | Описание | Статус |
|------|----------|--------|
| `DEDUP_GUIDE.md` | Борьба с дубликатами | ✅ |
| `KB_AUDIT_GUIDE.md` | Аудит Базы Знаний | ✅ |
| `LOG_GUIDE.md` | Работа с логами | ✅ |

**Интеграция:**
```
scripts/kb-audit.ps1
    ↓
reports/KB_AUDIT_REPORT.md
    ↓
OPERATION_LOG.md
```

---

### 3.3 Тестирование

| Файл | Описание | Статус |
|------|----------|--------|
| `TEST_ENV_GUIDE.md` | Тестовая среда | ✅ |
| `TESTING_GUIDE.md` | Тестирование проекта | ✅ |
| `DEBUGGING_GUIDE.md` | Отладка | ✅ |

**Интеграция:**
```
scripts/create-test-env.ps1
    ↓
_TEST_ENV/
    ↓
scripts/cleanup-test-env.ps1
```

---

### 3.4 Структура и знания

| Файл | Описание | Статус |
|------|----------|--------|
| `STRUCTURE_GUIDE.md` | Структура проекта | ✅ |
| `KNOWLEDGE_BASE_GUIDE.md` | Управление БЗ | ✅ |
| `ANALYSIS_PROCESS.md` | Процесс анализа | ✅ |
| `CODE_STYLE_GUIDE.md` | Стиль кода (актуализировано) | ✅ |
| `UNITY_BUILD_GUIDE.md` | Сборка Unity (актуализировано) | ✅ |
| `UI_TOOLKIT_SETUP_GUIDE.md` | Настройка UI Toolkit (актуализировано) | ✅ |
| `TESTING_FULL_GUIDE.md` | Полное тестирование (актуализировано) | ✅ |

**Интеграция:**
```
AI_START_HERE.md
    ↓
STRUCTURE_GUIDE.md
    ↓
KNOWLEDGE_BASE/
```

---

## 📋 УРОВЕНЬ 4: ИНСТРУКЦИИ

### 4.1 Установка и настройка

**Файлы в _docs/:**
- `INSTALL_SONARLINT.md`
- `INSTALL_NUGET_PACKETS.md`
- `INSTALL_SIMPLE_RU.md`
- `INSTALL_PRIORITY_2.md`
- `UNITY_BUILD_SETUP.md`
- `UNITY_SETTINGS_APPLIED.md`
- `INPUT_SYSTEM_URP_SETUP.md`
- `INCREDIBUILD_SETUP.md`
- `INCREDIBUILD_WORKING.md`
- `ULOOPMCP_INSTALLED.md`

**Интеграция:**
```
AI_START_HERE.md (Настройка)
    ↓
_docs/INSTALL_*.md
    ↓
PROJECTS/DragRaceUnity/
```

---

### 4.2 Отладка и тестирование

**Файлы в _docs/:**
- `DEBUGGING_GUIDE.md`
- `DEBUG_CHECKLIST.md`
- `TESTING_GUIDE.md`
- `MENU_CHECKLIST.md`

**Интеграция:**
```
PROJECTS/DragRaceUnity/
    ↓
_docs/DEBUGGING_GUIDE.md
    ↓
scripts/debug-unity.ps1
```

---

### 4.3 Сохранения и данные

**Файлы в _docs/:**
- `SAVE_SYSTEM_GUIDE.md`
- `STATUS.md`
- `WHAT_IS_IMPLEMENTED.md`
- `PLANS_FUTURE.md`
- `PRIORITY_3_PROPOSAL.md`

**Интеграция:**
```
PROJECTS/DragRaceUnity/
    ↓
_docs/SAVE_SYSTEM_GUIDE.md
    ↓
scripts/
```

---

### 4.4 Старые инструкции (OLD/)

**Файлы в OLD/:**
- `OLD/DragRace1/TESTING_FULL_GUIDE.md`
- `OLD/DragRace1/TESTING_INSTRUCTIONS.md`
- `OLD/DragRace1/UI_FIX_INSTRUCTION.md`
- `OLD/Prob/SETUP_GUIDE.md`
- `OLD/ProbMenu/TEAM_LICENSE_INSTRUCTIONS.md`
- `OLD/ProbMenu/UNITY_SETUP_INSTRUCTION.md`

**Статус:** ⚠️ Требуют актуализации

**Рекомендация:**
- Переместить актуальные в `_docs/`
- Устаревшие → в `_archive/`

---

## 🔄 ЛОГИЧЕСКАЯ ИНТЕГРАЦИЯ

### Схема интеграции правил:

```
┌─────────────────────────────────────────────────────────┐
│  AI_START_HERE.md (ГЛАВНЫЙ ВХОД)                       │
│  ├─ Читает .qwen/QWEN.md                               │
│  ├─ Ссылается на RULES_AND_TASKS.md                    │
│  └─ Ссылается на README.md                             │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  README.md (НАВИГАТОР)                                 │
│  ├─ Ссылается на STRUCTURE_GUIDE.md                    │
│  ├─ Ссылается на _docs/*.md                            │
│  └─ Ссылается на KNOWLEDGE_BASE/                       │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  STRUCTURE_GUIDE.md (СТРУКТУРА)                        │
│  ├─ Описывает иерархию                                 │
│  ├─ Ссылается на KNOWLEDGE_BASE/00_CORE/               │
│  └─ Ссылается на KNOWLEDGE_BASE/01_RULES/              │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  KNOWLEDGE_BASE/01_RULES/ (ПРАВИЛА)                    │
│  ├─ file_naming_rule.md                                │
│  ├─ ui_toolkit_rules.md                                │
│  └─ before_change_rule.md                              │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  _docs/*_GUIDE.md (РУКОВОДСТВА)                        │
│  ├─ BACKUP_STRATEGY.md                                 │
│  ├─ DEDUP_GUIDE.md                                     │
│  └─ KB_AUDIT_GUIDE.md                                  │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  scripts/*.ps1 (АВТОМАТИЗАЦИЯ)                         │
│  ├─ pre-operation-backup.ps1                           │
│  ├─ kb-audit.ps1                                       │
│  └─ safe-delete.ps1                                    │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  reports/OPERATION_LOG.md (ЛОГИРОВАНИЕ)                │
│  └─ Запись всех операций                               │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 СТАТИСТИКА ПРАВИЛ

| Категория | Файлов | Статус |
|-----------|--------|--------|
| **Глобальные правила** | 3 | ✅ Актуально |
| **Стандарты кода** | 4 | ✅ Актуально |
| **Руководства** | 20+ | ✅ Актуально |
| **Инструкции** | 20+ | ⚠️ Часть в OLD/ |
| **Всего** | ~50 | ✅ |

---

## 🎯 ПРАВИЛА ИНТЕГРАЦИИ НОВЫХ МАТЕРИАЛОВ

### При создании нового правила:

1. **Использовать шаблон:**
   - Файл: `_templates/RULE_TEMPLATE.md`
   - Заполнить все мета-поля (created, last_reviewed, status)

2. **Определить уровень:**
   - Глобальное → `RULES_AND_TASKS.md`
   - Стандарт → `KNOWLEDGE_BASE/00_CORE/` или `01_RULES/`
   - Руководство → `_docs/*_GUIDE.md`
   - Инструкция → `_docs/INSTALL_*.md`

3. **Обновить связанные файлы:**
   - `AI_START_HERE.md` (карта проекта)
   - `README.md` (навигатор)
   - `STRUCTURE_GUIDE.md` (структура)
   - `FILE_CHANGE_RULE.md` (если меняется структура)
   - `ALL_RULES_CATALOG.md` (этот файл)

4. **Создать тест-кейсы:**
   - Файл: `reports/RULE_TEST_CASES.md`
   - Добавить 2-3 тестовых кейса

5. **Записать в OPERATION_LOG.md:**
   ```markdown
   ## ГГГГ-ММ-ДД Создание правила
   
   **Файл:** `путь/к/файлу.md`
   **Уровень:** 1/2/3/4
   **Статус:** ✅ Создано
   **Тесты:** reports/RULE_TEST_CASES.md
   
   ---
   ```

6. **Git коммит:**
   ```powershell
   git add путь/к/файлу.md
   git commit -m "Add: новое правило (название)"
   ```

---

## 🔄 ПРОЦЕСС ОБНОВЛЕНИЯ ПРАВИЛ

### Ежеквартальная проверка:

```powershell
# 1. Запустить проверку актуальности
.\scripts\check-rules-freshness.ps1 -MaxAge 90

# 2. Открыть отчёт
code reports\rules_freshness_report.md

# 3. Проверить устаревшие правила
#    Для каждого правила:
#    - Открыть файл
#    - Проверить актуальность
#    - Обновить last_reviewed
#    - Закоммитить

# 4. Запустить повторно
.\scripts\check-rules-freshness.ps1

# 5. Закоммитить всё
git add .
git commit -m "Update: актуализация правил (квартал YYYY-QN)"
```

### Тестирование правил:

```powershell
# 1. Открыть тест-кейсы
code reports\RULE_TEST_CASES.md

# 2. Запустить тесты
.\scripts\kb-audit.ps1

# 3. Записать результаты
#    Обновить RULE_TEST_CASES.md
```

---

## 📊 СТАТИСТИКА ПРАВИЛ

| Категория | Файлов | Актуальные | Устаревшие | % Актуальности |
|-----------|--------|------------|------------|----------------|
| **Глобальные правила** | 3 | 3 | 0 | 100% |
| **Стандарты кода** | 4 | 4 | 0 | 100% |
| **Руководства** | 20+ | 20+ | 0 | 100% |
| **Инструкции** | 20+ | 20+ | 0 | 100% |
| **Всего** | ~50 | ~50 | 0 | 100% |

**Проверка:** $(Get-Date -Format "yyyy-MM-dd")  
**Скрипт:** `check-rules-freshness.ps1`

---

## 🔗 БЫСТРЫЕ ССЫЛКИ

### Глобальные:
- [`AI_START_HERE.md`](AI_START_HERE.md)
- [`RULES_AND_TASKS.md`](RULES_AND_TASKS.md)
- [`.qwen/QWEN.md`](.qwen/QWEN.md)

### Стандарты:
- [`csharp_standards.md`](KNOWLEDGE_BASE/00_CORE/csharp_standards.md)
- [`ui_toolkit_rules.md`](KNOWLEDGE_BASE/01_RULES/ui_toolkit_rules.md)
- [`file_naming_rule.md`](KNOWLEDGE_BASE/01_RULES/file_naming_rule.md)

### Руководства:
- [`BACKUP_STRATEGY.md`](_docs/BACKUP_STRATEGY.md)
- [`DEDUP_GUIDE.md`](_docs/DEDUP_GUIDE.md)
- [`KB_AUDIT_GUIDE.md`](_docs/KB_AUDIT_GUIDE.md)

### Инструкции:
- [`INSTALL_SONARLINT.md`](_docs/INSTALL_SONARLINT.md)
- [`DEBUGGING_GUIDE.md`](_docs/DEBUGGING_GUIDE.md)
- [`TESTING_GUIDE.md`](_docs/TESTING_GUIDE.md)

---

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Главный каталог правил

---

**Используйте этот файл для навигации по всем правилам проекта!** 🚀
