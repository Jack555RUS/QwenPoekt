# 📚 ИНДЕКС ВСЕХ ПРАВИЛ

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Активно

---

## 🎯 НАЗНАЧЕНИЕ

Этот файл содержит **полный индекс всех правил** в Базе Знаний с ссылками и кратким описанием.

---

## 📋 ГЛОБАЛЬНЫЕ ПРАВИЛА (Уровень 1)

| Файл | Описание | Статус |
|------|----------|--------|
| [`AI_START_HERE.md`](../AI_START_HERE.md) | Главная инструкция проекта | ✅ |
| [`RULES_AND_TASKS.md`](../RULES_AND_TASKS.md) | Правила и задачи (извлечённые уроки) | ✅ |
| [`.qwen/QWEN.md`](../.qwen/QWEN.md) | Мастер-конфиг ИИ | ✅ |

---

## 📋 СТАНДАРТЫ КОДА (Уровень 2)

### 00_CORE/

| Файл | Описание | Автор | Версия |
|------|----------|-------|--------|
| [`csharp_standards.md`](00_CORE/csharp_standards.md) | Стандарты кода C# | Project Core | 1.0 |
| [`project_glossary.md`](00_CORE/project_glossary.md) | Терминология проекта | Project Core | 1.0 |
| [`csharp_fast_learning.md`](00_CORE/csharp_fast_learning.md) | Быстрое изучение C# | Qwen Code | 1.0 |
| [`csharp_silent_testing.md`](00_CORE/csharp_silent_testing.md) | Тихие тесты C# | Qwen Code | 1.0 |
| [`FOR_AI_READ_HERE.md`](00_CORE/FOR_AI_READ_HERE.md) | Контекст для ИИ | Qwen Code | 2.0 |
| [`roslynator_cli.md`](00_CORE/roslynator_cli.md) | Roslynator CLI | Qwen Code | 1.0 |

---

## 📋 МЕТОДОЛОГИИ (Уровень 2)

### 05_METHODOLOGY/

| Файл | Описание | Автор | Версия |
|------|----------|-------|--------|
| [`AI_DEVELOPER_INSTRUCTION.md`](05_METHODOLOGY/AI_DEVELOPER_INSTRUCTION.md) | Инструкция ИИ-разработчика | Qwen Code | 2.0 |
| [`ai_programming_tips.md`](05_METHODOLOGY/ai_programming_tips.md) | Советы ИИ по программированию | Qwen Code | 1.0 |
| [`qwen_modes.md`](05_METHODOLOGY/qwen_modes.md) | Режимы Qwen 3.5 Plus | Qwen Code | 1.0 |

---

## 📋 РУКОВОДСТВА (Уровень 3)

### 02-Areas/Documentation/

| Файл | Описание | Статус |
|------|----------|--------|
| [`ALL_RULES_CATALOG.md`](02-Areas/Documentation/ALL_RULES_CATALOG.md) | Каталог всех правил | ✅ |
| [`BACKUP_STRATEGY.md`](02-Areas/Documentation/BACKUP_STRATEGY.md) | Стратегия 3-2-1 | ✅ |
| [`DEDUP_GUIDE.md`](02-Areas/Documentation/DEDUP_GUIDE.md) | Борьба с дубликатами | ✅ |
| [`KB_AUDIT_GUIDE.md`](02-Areas/Documentation/KB_AUDIT_GUIDE.md) | Аудит Базы Знаний | ✅ |
| [`STRUCTURE_GUIDE.md`](02-Areas/Documentation/STRUCTURE_GUIDE.md) | Структура проекта | ✅ |

---

## 📋 ШАБЛОНЫ (Уровень 4)

### _templates/

| Файл | Описание | Статус |
|------|----------|--------|
| [`RULE_TEMPLATE.md`](_templates/RULE_TEMPLATE.md) | Шаблон правила с мета-полями | ✅ |
| [`AI_ANALYSIS_PROMPT.md`](_templates/AI_ANALYSIS_PROMPT.md) | Промпт для ИИ-аналитика | ✅ |

---

## 📋 ТЕСТЫ (Уровень 4)

### reports/

| Файл | Описание | Статус |
|------|----------|--------|
| [`RULE_TEST_CASES.md`](reports/RULE_TEST_CASES.md) | Тест-кейсы для правил | ✅ |
| [`DEEP_RULES_ANALYSIS.md`](reports/DEEP_RULES_ANALYSIS.md) | Глубокий анализ 9 правил | ✅ |

---

## 📊 СТАТИСТИКА

| Категория | Файлов | Средняя версия |
|-----------|--------|----------------|
| **Глобальные правила** | 3 | - |
| **Стандарты кода** | 6 | 1.0 |
| **Методологии** | 3 | 1.3 |
| **Руководства** | 5 | - |
| **Шаблоны** | 2 | - |
| **Тесты** | 2 | - |
| **ВСЕГО** | **21** | **1.0** |

---

## 🔄 ПРОЦЕСС ОБНОВЛЕНИЯ

### Ежеквартальная проверка:

```powershell
# 1. Запустить проверку актуальности
.\scripts\check-rules-freshness.ps1 -MaxAge 90

# 2. Открыть отчёт
code reports\rules_freshness_report.md

# 3. Проверить устаревшие правила

# 4. Закоммитить изменения
git add .
git commit -m "Update: актуализация правил (квартал YYYY-QN)"
```

---

## 🔗 БЫСТРЫЕ ССЫЛКИ

### Для ИИ:
1. [`AI_START_HERE.md`](../AI_START_HERE.md) — Главная инструкция
2. [`.qwen/QWEN.md`](../.qwen/QWEN.md) — Мастер-конфиг
3. [`AI_DEVELOPER_INSTRUCTION.md`](05_METHODOLOGY/AI_DEVELOPER_INSTRUCTION.md) — Инструкция разработчика

### Для разработки:
1. [`csharp_standards.md`](00_CORE/csharp_standards.md) — Стандарты кода
2. [`project_glossary.md`](00_CORE/project_glossary.md) — Терминология
3. [`STRUCTURE_GUIDE.md`](02-Areas/Documentation/STRUCTURE_GUIDE.md) — Структура

### Для тестирования:
1. [`RULE_TEST_CASES.md`](reports/RULE_TEST_CASES.md) — Тест-кейсы
2. [`check-rules-freshness.ps1`](../03-Resources/PowerShell/check-rules-freshness.ps1) — Проверка актуальности

---

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готово к использованию

