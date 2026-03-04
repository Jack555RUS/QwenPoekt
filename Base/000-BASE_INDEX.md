# 📚 BASE INDEX — ГЛАВНЫЙ ИНДЕКС БАЗЫ

**Версия:** 1.0
**Дата:** 4 марта 2026 г.
**Статус:** 🔴 **КРИТИЧНО** (НЕ УДАЛЯТЬ!)
**Файл:** `000-BASE_INDEX.md`

---

## ⚠️ ЗАЩИТА ОТ УДАЛЕНИЯ

**Этот файл — КРИТИЧНЫЙ!**

### 🛑 ТРИГГЕРЫ (если пользователь хочет удалить):

**Если пользователь пишет:**
- "удалить этот файл"
- "delete this file"
- "убрать индекс"
- "удалить BASE_INDEX"
- "delete BASE_INDEX"

**Ответ (ОБЯЗАТЕЛЬНО):**
```
⚠️ ВНИМАНИЕ! Этот файл критичный!

📋 BASE_INDEX.md содержит:
   - Все правила базы (17 файлов)
   - Список задач (tasks-dag.json)
   - Карту знаний (03-Resources/)
   - Точки входа (AI_START_HERE.md, AGENTS.md)

❌ Удаление = Потеря контекста и правил!

Альтернативы:
   - Переместить в архив (не удалять)
   - Скрыть (переименовать в _BASE_INDEX.md)
   - Обновить содержимое (не удалять)

Вы уверены что хотите удалить? (Y/N)
```

### ✅ ТРИГГЕРЫ (загрузка базы):

**Если пользователь пишет:**
- "Загрузить базу"
- "Прочти индекс"
- "BASE_INDEX"
- "base-index"

**Ответ:**
```
✅ БАЗА ЗАГРУЖЕНА!

📋 Прочитано из BASE_INDEX.md:
   - 16 правил (.qwen/rules/)
   - Задачи (tasks-dag.json, ТЕКУЩАЯ_ЗАДАЧА.md)
   - Карта знаний (03-Resources/)

🎯 Готов к работе!
```

---

## 🚀 БЫСТРЫЙ СТАРТ (ДЛЯ ИИ)

**При старте КАЖДОЙ сессии:**

### 1. Прочти этот файл:
```
000-BASE_INDEX.md
```

### 2. Прочти правила (критичные):
```
.qwen/rules/00-auto-context.md
.qwen/rules/01-core.md
.qwen/rules/13-user-alignment.md
.qwen/rules/10-think-before-action.md
.qwen/rules/02-workflow.md
```

### 3. Прочти задачи:
```
tasks-dag.json
ТЕКУЩАЯ_ЗАДАЧА.md
```

### 4. Доложи о готовности:
```
✅ БАЗА ЗАГРУЖЕНА!

📋 Прочитано:
   - BASE_INDEX.md ✅
   - Правила (5 критичных) ✅
   - Задачи (активные) ✅

🎯 Готов к работе!
```

---

## 📋 ВСЕ ПРАВИЛА (со ссылками, по порядку)

### 🔴 КРИТИЧНЫЕ (читать всегда):

| # | Правило | Файл | Назначение |
|---|---------|------|------------|
| 00 | Авто-контекст | [00-auto-context.md](.qwen/rules/00-auto-context.md) | Авто-чтение контекста |
| 01 | Ядро | [01-core.md](.qwen/rules/01-core.md) | Идентификация, иерархия |
| 02 | 3 уровня | [02-workflow.md](.qwen/rules/02-workflow.md) | Процесс внедрения |
| 10 | 7 шагов | [10-think-before-action.md](.qwen/rules/10-think-before-action.md) | Мышление перед действием |
| 13 | Согласование | [13-user-alignment.md](.qwen/rules/13-user-alignment.md) | 5 шагов ответа |

### 🟡 СРЕДНИЕ (по контексту):

| # | Правило | Файл | Назначение |
|---|---------|------|------------|
| 03 | Git | [03-git.md](.qwen/rules/03-git.md) | Git, OLD, RELEASE |
| 04 | Безопасность | [04-safety.md](.qwen/rules/04-safety.md) | Encoding, workspace |
| 05 | Команды | [05-commands.md](.qwen/rules/05-commands.md) | 30+ команд |
| 06 | Восстановление | [06-resume.md](.qwen/rules/06-resume.md) | Сессии |
| 07 | Сохранение | [07-session-persistence.md](.qwen/rules/07-session-persistence.md) | Автосохранение |
| 08 | Массовые операции | [08-mass-operations.md](.qwen/rules/08-mass-operations.md) | >100 файлов |
| 08-MCP | MCP сервер | [08-mcp-saver.md](.qwen/rules/08-mcp-saver.md) | MCP Session Saver |
| 09 | Логика | [09-logic-and-analysis.md](.qwen/rules/09-logic-and-analysis.md) | 10 уровней анализа |
| 11 | Знания | [11-knowledge-sufficiency.md](.qwen/rules/11-knowledge-sufficiency.md) | Проверка знаний |
| 12 | Работа с ПО | [12-software-best-practices.md](.qwen/rules/12-software-best-practices.md) | Программы |
| 14 | Контекст | [14-context-management.md](.qwen/rules/14-context-management.md) | Summarization |
| 15 | Auto-Update | [15-base-index-auto-update.md](.qwen/rules/15-base-index-auto-update.md) | Обновление BASE_INDEX |

**ВСЕГО:** 17 правил (без тестовых)

---

## 🎯 ЗАДАЧИ (со ссылками)

### 📁 ФАЙЛЫ ЗАДАЧ:

| Файл | Назначение |
|------|------------|
| [tasks-dag.json](./tasks-dag.json) | Список задач с зависимостями (DAG) |
| [ТЕКУЩАЯ_ЗАДАЧА.md](./ТЕКУЩАЯ_ЗАДАЧА.md) | Активные задачи, статус, планы |

### 🔴 ТЕКУЩИЕ (активные):

| Задача | Статус | Приоритет |
|--------|--------|-----------|
| Неделя 1: v2 использование | ⏳ В работе (День 1/7) | 🔴 Высокий |
| INDEX.md (единый индекс) | ✅ Завершено | 🔴 Высокий |

### 🟡 BACKLOG:

| Задача | Оценка | Приоритет |
|--------|--------|-----------|
| Аудит базы | 2-4 часа | 🟡 Средний |
| Саморазвитие БЗ | 8-12 часов | 🟡 Средний |
| Индикатор токенов | 1-8 часов | 🟢 Низкий |
| Confidence Scoring | 3-4 часа | 🟢 Низкий |
| Agent Coordination | 6-8 часов | 🟢 Низкий |
| Автоматизация правил | 4-6 часов | 🟢 Низкий |

### 🟢 UNITY (отложено):

| Задача | Когда |
|--------|-------|
| Диалог подтверждения выхода | Через 5 дней |
| Сцена гонки | Через 5 дней |
| Управление передачами | Через 5 дней |
| ИИ соперник | Через 5 дней |

---

## 📚 БАЗА ЗНАНИЙ (карта)

### 📁 СТРУКТУРА:

```
D:\QwenPoekt\Base/
│
├── 🚀 ТОЧКИ ВХОДА (10 файлов)
│   ├── AI_START_HERE.md — Запуск Qwen Code
│   ├── AGENTS.md — Точка входа для ИИ
│   ├── 000-BASE_INDEX.md — ЭТОТ ФАЙЛ (главный индекс)
│   ├── ЗАПУСК_QWEN_CODE.md — Полная инструкция
│   ├── ЗАПУСК_QWEN_CODE_ПОЛНОЕ_РУКОВОДСТВО.md
│   ├── ТЕКУЩАЯ_ЗАДАЧА.md — Активные задачи
│   ├── ERROR_LOG.md — Журнал ошибок
│   ├── ANTI_PATTERNS.md — Запрещённые паттерны
│   ├── PRE_ACTION_CHECKLIST.md — Чек-лист перед действиями
│   └── README.md — Навигатор
│
├── 🤖 КОНФИГУРАЦИЯ ИИ (.qwen/)
│   ├── QWEN.md — Мастер-контекст (1100+ строк)
│   ├── rules/ — Правила (17 файлов)
│   │   ├── 00-auto-context.md
│   │   ├── 01-core.md
│   │   ├── 02-workflow.md
│   │   ├── 03-git.md
│   │   ├── 04-safety.md
│   │   ├── 05-commands.md
│   │   ├── 06-resume.md
│   │   ├── 07-session-persistence.md
│   │   ├── 08-mass-operations.md
│   │   ├── 08-mcp-saver.md
│   │   ├── 09-logic-and-analysis.md
│   │   ├── 10-think-before-action.md
│   │   ├── 11-knowledge-sufficiency.md
│   │   ├── 12-software-best-practices.md
│   │   ├── 13-user-alignment.md
│   │   ├── 14-context-management.md
│   │   └── 15-base-index-auto-update.md
│   ├── agents/ — Агенты (8 файлов)
│   ├── session-rules.json — Конфигурация сессий
│   ├── settings.json — Настройки Qwen Code
│   └── CURRENT_CONTEXT.md — Текущий контекст
│
├── 📚 БАЗА ЗНАНИЙ (03-Resources/)
│   ├── Knowledge/ — Знания (~85 файлов)
│   │   ├── 00_CORE/ — Фундамент (9 файлов)
│   │   ├── 01_RULES/ — Правила (2 файла)
│   │   └── ... (остальные)
│   ├── PowerShell/ — Скрипты (~80 файлов)
│   ├── AI/ — AI документы
│   ├── BOOKS/ — Книги (библиография)
│   ├── CSharp/ — C# ресурсы
│   └── Unity/ — Unity ресурсы
│
├── 📝 ОТЧЁТЫ (reports/)
│   ├── TASK_FLOW.md
│   ├── WEEKLY_REVIEW.md
│   ├── DAILY_CHECKIN/
│   ├── DEEP_ANALYSIS_GUIDE.md
│   ├── ERROR_LEARNING_GUIDE.md
│   ├── ERROR_METRICS_DASHBOARD.md
│   └── ... (~40 файлов)
│
├── 🔧 СКРИПТЫ (scripts/)
│   ├── before-action-checklist-v2.ps1
│   ├── after-action-audit.ps1
│   ├── summarize-context.ps1
│   ├── resume-session.ps1
│   ├── check-links.ps1
│   ├── find-duplicates.ps1
│   └── ... (~40 скриптов)
│
├── 💾 СЕССИИ (sessions/)
│   └── YYYY-MM-DD_HH-mm/
│
├── 📦 NPM (node_modules/)
│   └── ~10,000 файлов
│
└── 🎮 ПРОЕКТЫ (PROJECTS/)
    └── DragRaceUnity/
```

---

## 🔗 БЫСТРЫЕ ССЫЛКИ

| Раздел | Файл |
|--------|------|
| **Запустить ИИ** | [AI_START_HERE.md](./AI_START_HERE.md) |
| **Агенты** | [AGENTS.md](./AGENTS.md) |
| **Правила (папка)** | [.qwen/rules/](.qwen/rules/) |
| **Правила (список)** | [см. выше](#-все-правиласо-ссылками) |
| **Задачи** | [tasks-dag.json](./tasks-dag.json) |
| **Текущая задача** | [ТЕКУЩАЯ_ЗАДАЧА.md](./ТЕКУЩАЯ_ЗАДАЧА.md) |
| **Отчёты** | [reports/](reports/) |
| **Скрипты** | [scripts/](scripts/) |
| **Ошибки** | [ERROR_LOG.md](./ERROR_LOG.md) |
| **Анти-паттерны** | [ANTI_PATTERNS.md](./ANTI_PATTERNS.md) |

---

## 🛡️ ЗАЩИТА (техническая)

### Git (не удалять из репозитория):

```
# В .gitignore НЕ добавлять этот файл!
# 000-BASE_INDEX.md всегда в Git
```

### Бэкап (перед любыми изменениями):

```powershell
# Перед изменением этого файла:
git add 000-BASE_INDEX.md
git commit -m "Backup: BASE_INDEX перед обновлением"
```

### Проверка (перед удалением):

```markdown
[ ] 1. Есть ли бэкап?
[ ] 2. Все ссылки обновлены?
[ ] 3. Пользователь подтвердил?
[ ] 4. Альтернативы рассмотрены?
```

---

## 📝 ИСТОРИЯ ИЗМЕНЕНИЙ

| Дата | Версия | Изменения |
|------|--------|-----------|
| 2026-03-04 | 1.2 | Добавлено правило 15 (Auto-Update) |
| 2026-03-04 | 1.1 | Удалён мусор (all_rule.md, 99-test) |
| 2026-03-04 | 1.0 | Создан (000-BASE_INDEX.md) |

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

| Файл | Назначение |
|------|------------|
| [.qwen/QWEN.md](.qwen/QWEN.md) | Мастер-контекст (System Prompt) |
| [.qwen/CURRENT_CONTEXT.md](.qwen/CURRENT_CONTEXT.md) | Текущий контекст сессии |
| [.resume_marker.json](./.resume_marker.json) | Маркер восстановления |
| [AI_START_HERE.md](./AI_START_HERE.md) | Точка входа для пользователя |
| [AGENTS.md](./AGENTS.md) | Точка входа для ИИ |

---

**Создано:** 2026-03-04
**Статус:** 🔴 **КРИТИЧНО** (НЕ УДАЛЯТЬ!)
**Следующий пересмотр:** 2026-03-11 (еженедельно)
**Хранение:** `D:\QwenPoekt\Base\000-BASE_INDEX.md`
