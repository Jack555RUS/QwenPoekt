# 🔗 CROSS-REFERENCE LINKS — ПЕРЕКРЁСТНЫЕ ССЫЛКИ

**Дата:** 1 марта 2026 г.  
**Версия:** 1.0  
**Назначение:** Навигатор по основным правилам и файлам проекта

---

## 📚 ОСНОВНЫЕ ФАЙЛЫ

| Файл | Описание | Где используется |
|------|----------|------------------|
| [`AI_START_HERE.md`](./AI_START_HERE.md) | Точка входа для ИИ | QWEN.md (Раздел 0) |
| [`.qwen/QWEN.md`](./.qwen/QWEN.md) | Главный конфиг ИИ | AI_START_HERE.md (Раздел 0) |
| [`RULES_AND_TASKS.md`](./RULES_AND_TASKS.md) | Правила и задачи | NOTES.md |
| [`NOTES.md`](./NOTES.md) | Текущие задачи | — |

---

## 📋 ПРАВИЛА

### Основные правила

| Правило | Файл | Где упоминается |
|---------|------|-----------------|
| **Проверка перед внесением** | [`01_RULES/before_change_rule.md`](./KNOWLEDGE_BASE/01_RULES/before_change_rule.md) | AI_START_HERE.md (Раздел 2), QWEN.md (Раздел 10) |
| **Именование файлов** | [`01_RULES/file_naming_rule.md`](./KNOWLEDGE_BASE/01_RULES/file_naming_rule.md) | AI_START_HERE.md (Раздел 2), QWEN.md (Раздел 10), META_RULES_FOR_KNOWLEDGE_ANALYSIS.md |
| **UI Toolkit** | [`01_RULES/ui_toolkit_rules.md`](./KNOWLEDGE_BASE/01_RULES/ui_toolkit_rules.md) | AI_START_HERE.md (Раздел 2) |

### Методологии

| Правило | Файл | Где упоминается |
|---------|------|-----------------|
| **Мета-правила анализа** | [`05_METHODOLOGY/META_RULES_FOR_KNOWLEDGE_ANALYSIS.md`](./KNOWLEDGE_BASE/05_METHODOLOGY/META_RULES_FOR_KNOWLEDGE_ANALYSIS.md) | QWEN.md (Раздел 8) |
| **Саморазвитие ИИ** | [`05_METHODOLOGY/AI_SELF_LEARNING_METHODOLOGY.md`](./KNOWLEDGE_BASE/05_METHODOLOGY/AI_SELF_LEARNING_METHODOLOGY.md) | AI_START_HERE.md (Раздел 8) |

---

## 🗂️ OLD/RELEASE/ARCHIVE СИСТЕМА

| Компонент | Файл | Где упоминается |
|-----------|------|-----------------|
| **OLD система (полная)** | [`QWEN.md`](./.qwen/QWEN.md) (Раздел 6A, 6B, 6C) | AI_START_HERE.md (Раздел 2.5) |
| **OLD система (краткая)** | [`AI_START_HERE.md`](./AI_START_HERE.md) (Раздел 2.5) | — |
| **Скрипт анализа** | [`scripts/old-analysis.ps1`](./scripts/old-analysis.ps1) | AI_START_HERE.md (Раздел 2.5), QWEN.md (Раздел 6A) |
| **Скрипт очистки** | [`scripts/old-cleanup.ps1`](./scripts/old-cleanup.ps1) | AI_START_HERE.md (Раздел 2.5), QWEN.md (Раздел 6A) |
| **Скрипт перемещения** | [`scripts/move-to-old.ps1`](./scripts/move-to-old.ps1) | AI_START_HERE.md (Раздел 2.5), QWEN.md (Раздел 6A) |
| **Отчёт о внедрении** | [`reports/OLD_RELEASE_ARCHIVE_IMPLEMENTATION.md`](./reports/OLD_RELEASE_ARCHIVE_IMPLEMENTATION.md) | AI_START_HERE.md (Раздел 16) |

---

## 🔧 GIT И АВТОМАТИЗАЦИЯ

| Компонент | Файл | Где упоминается |
|-----------|------|-----------------|
| **Git правило** | [`QWEN.md`](./.qwen/QWEN.md) (Раздел 6) | AI_START_HERE.md (Раздел 4) |
| **Auto-commit** | [`scripts/auto-commit-daily.ps1`](./scripts/auto-commit-daily.ps1) | AI_START_HERE.md (Раздел 4), QWEN.md (Раздел 6) |
| **Проверка дубликатов** | [`scripts/check-duplicates.ps1`](./scripts/check-duplicates.ps1) | AI_START_HERE.md (Раздел 8), QWEN.md (Раздел 8) |
| **Организация корня** | [`scripts/organize-root.ps1`](./scripts/organize-root.ps1) | — |
| **Обновление AI_START_HERE** | [`scripts/update-ai-start-here.ps1`](./scripts/update-ai-start-here.ps1) | AI_START_HERE.md (Раздел 18) |

---

## ✅ TDD И ПРОВЕРКИ

| Компонент | Файл | Где упоминается |
|-----------|------|-----------------|
| **TDD правило** | [`QWEN.md`](./.qwen/QWEN.md) (Раздел 12.5) | AI_START_HERE.md (Раздел 12.5) |
| **Скрипт проверки** | [`scripts/tdd-verify-complete.ps1`](./scripts/tdd-verify-complete.ps1) | _docs/CHEAT_SHEET.md |
| **Команда** | `/verify-complete` | AI_START_HERE.md (Раздел 9), QWEN.md (Раздел 12.5), _docs/CHEAT_SHEET.md |

---

## 📊 ОТЧЁТЫ

| Отчёт | Файл | Тема |
|-------|------|------|
| **OLD/RELEASE внедрение** | [`reports/OLD_RELEASE_ARCHIVE_IMPLEMENTATION.md`](./reports/OLD_RELEASE_ARCHIVE_IMPLEMENTATION.md) | OLD система |
| **Сохранение наработок** | [`reports/SAVE_COMPLETE_REPORT.md`](./reports/SAVE_COMPLETE_REPORT.md) | Сохранение |
| **Аудит AI_START_HERE** | [`reports/FULL_AI_START_HERE_AUDIT.md`](./reports/FULL_AI_START_HERE_AUDIT.md) | Аудит |
| **Qwen Insights** | [`reports/QWEN_INSIGHTS_IMPLEMENTATION.md`](./reports/QWEN_INSIGHTS_IMPLEMENTATION.md) | Qwen Insights |
| **Все выполненные задачи** | [`reports/ALL_TASKS_COMPLETED.md`](./reports/ALL_TASKS_COMPLETED.md) | История задач |

---

## 📖 ДОКУМЕНТАЦИЯ

| Документ | Файл | Описание |
|----------|------|----------|
| **Cheat Sheet** | [`_docs/CHEAT_SHEET.md`](./_docs/CHEAT_SHEET.md) | Быстрые команды |
| **Scripts README** | [`_docs/SCRIPTS_README.md`](./_docs/SCRIPTS_README.md) | Описание скриптов |
| **Answer Template** | [`_templates/ANSWER_TEMPLATE.md`](./_templates/ANSWER_TEMPLATE.md) | Шаблон ответа |

---

## 🔍 ВНЕШНИЕ ИСТОЧНИКИ

| Источник | Ссылка | Приоритет |
|----------|--------|-----------|
| **Unity Docs** | https://docs.unity3d.com/Manual/ | ✅ 100% |
| **.NET Docs** | https://docs.microsoft.com/dotnet/ | ✅ 100% |
| **GitHub** | https://github.com | ✅ 90% (1000+ звёзд) |
| **Stack Overflow** | https://stackoverflow.com | ⚠️ 70% (принятые ответы) |

---

## 📋 БЫСТРЫЙ ДОСТУП ПО ТЕМАМ

### Хочу узнать...

| Тема | Файл | Раздел |
|------|------|--------|
| **Как начать работу** | [`AI_START_HERE.md`](./AI_START_HERE.md) | Раздел 12 |
| **Где мои задачи** | [`NOTES.md`](./NOTES.md) | — |
| **Как организовать файлы** | [`01_RULES/file_naming_rule.md`](./KNOWLEDGE_BASE/01_RULES/file_naming_rule.md) | — |
| **Как проверить перед изменением** | [`01_RULES/before_change_rule.md`](./KNOWLEDGE_BASE/01_RULES/before_change_rule.md) | — |
| **Как использовать OLD** | [`AI_START_HERE.md`](./AI_START_HERE.md) | Раздел 2.5 |
| **Как коммитить** | [`QWEN.md`](./.qwen/QWEN.md) | Раздел 6 |
| **Где правила ИИ** | [`QWEN.md`](./.qwen/QWEN.md) | — |
| **Как учиться у лучших** | [`QWEN.md`](./.qwen/QWEN.md) | Раздел "Внешние источники" |

---

## 🔄 АВТОМАТИЧЕСКОЕ ОБНОВЛЕНИЕ

**Этот файл следует обновлять:**
- При создании нового важного файла
- При изменении структуры проекта
- При добавлении новой системы

**Команда для проверки:**
```powershell
.\scripts\check-duplicates.ps1
```

---

**Последнее обновление:** 1 марта 2026 г.  
**Версия:** 1.0
