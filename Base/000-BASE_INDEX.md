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
   - 17 правил (.qwen/rules/)
   - 29 файлов для бесшовной загрузки
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

## 🚀 БЕСШОВНАЯ ЗАГРУЗКА (7 УРОВНЕЙ)

**При старте КАЖДОЙ сессии:**

### 🔴 Уровень 1: Критичные (5 файлов, 13 мин)

| # | Файл | Время | Назначение |
|---|------|-------|------------|
| 1 | [000-BASE_INDEX.md](./000-BASE_INDEX.md) | 2 мин | Главный индекс |
| 2 | [.qwen/QWEN.md](.qwen/QWEN.md) | 5 мин | System Prompt |
| 3 | [ТЕКУЩАЯ_ЗАДАЧА.md](./ТЕКУЩАЯ_ЗАДАЧА.md) | 1 мин | Активные задачи |
| 4 | [tasks-dag.json](./tasks-dag.json) | 1 мин | Список задач |
| 5 | [.resume_marker.json](./.resume_marker.json) | 1 мин | Маркер сессии |

### 🟡 Уровень 2: Обязательные (5 файлов, 10 мин)

| # | Файл | Время | Назначение |
|---|------|-------|------------|
| 6 | [AI_START_HERE.md](./AI_START_HERE.md) | 2 мин | Запуск Qwen Code |
| 7 | [AGENTS.md](./AGENTS.md) | 3 мин | Точка входа для ИИ |
| 8 | [PRE_ACTION_CHECKLIST.md](./PRE_ACTION_CHECKLIST.md) | 2 мин | Чек-лист перед действиями |
| 9 | [ANTI_PATTERNS.md](./ANTI_PATTERNS.md) | 3 мин | Запрещённые паттерны |
| 10 | [ERROR_LOG.md](./ERROR_LOG.md) | 5 мин | Журнал ошибок |

### 🟢 Уровень 3: Безопасность (5 файлов, 15 мин)

| # | Файл | Время | Назначение |
|---|------|-------|------------|
| 11 | [.qwen/rules/04-safety.md](.qwen/rules/04-safety.md) | 3 мин | Безопасность |
| 12 | [.qwen/rules/11-knowledge-sufficiency.md](.qwen/rules/11-knowledge-sufficiency.md) | 3 мин | Проверка знаний |
| 13 | [scripts/before-action-checklist-v2.ps1](./scripts/before-action-checklist-v2.ps1) | 3 мин | Проверка перед действием |
| 14 | [scripts/check-links.ps1](./scripts/check-links.ps1) | 3 мин | Проверка ссылок |
| 15 | [scripts/find-duplicates.ps1](./scripts/find-duplicates.ps1) | 3 мин | Поиск дубликатов |

### 🔵 Уровень 4: Восстановление сессии (5 файлов, 8 мин)

| # | Файл | Время | Назначение |
|---|------|-------|------------|
| 16 | [resume-session.ps1](./resume-session.ps1) | 1 мин | Скрипт восстановления |
| 17 | [.qwen/rules/06-resume.md](.qwen/rules/06-resume.md) | 2 мин | Восстановление сессии |
| 18 | [.qwen/rules/07-session-persistence.md](.qwen/rules/07-session-persistence.md) | 3 мин | Автосохранение |
| 19 | [.qwen/session-rules.json](.qwen/session-rules.json) | 1 мин | Конфигурация сессий |
| 20 | [mcp.json](./mcp.json) | 1 мин | MCP конфигурация |

### 🟣 Уровень 5: Инструменты (5 файлов, 5 мин)

| # | Файл | Назначение |
|---|------|------------|
| 21 | [scripts/summarize-context.ps1](./scripts/summarize-context.ps1) | Суммаризация контекста |
| 22 | [scripts/after-action-audit.ps1](./scripts/after-action-audit.ps1) | Аудит после действия |
| 23 | [scripts/check-external-links.ps1](./scripts/check-external-links.ps1) | Проверка внешних ссылок |
| 24 | [scripts/test-documentation.ps1](./scripts/test-documentation.ps1) | Тестирование документации |
| 25 | [scripts/full-kb-audit.ps1](./scripts/full-kb-audit.ps1) | Полный аудит базы |

### 🟤 Уровень 6: Точки входа (4 файла, 5 мин)

| # | Файл | Для кого |
|---|------|----------|
| 26 | [AI_START_HERE.md](./AI_START_HERE.md) | Пользователь |
| 27 | [AGENTS.md](./AGENTS.md) | ИИ |
| 28 | [ЗАПУСК_QWEN_CODE.md](./ЗАПУСК_QWEN_CODE.md) | Пользователь |
| 29 | [000-BASE_INDEX.md](./000-BASE_INDEX.md) | Все |

### ⚫ Уровень 7: Правила (по контексту, 20 мин)

**Все 17 правил:** [см. выше](#-все-правиласо-ссылками-по-порядку)

---

## 🔄 ВОССТАНОВЛЕНИЕ СЕССИИ

**При потере контекста:**

### Скрипты:

| Скрипт | Назначение | Команда |
|--------|------------|---------|
| [resume-session.ps1](./resume-session.ps1) | Восстановление контекста | `.\resume-session.ps1` |
| [scripts/start-session.ps1](./scripts/start-session.ps1) | Проверка при старте | `.\scripts\start-session.ps1` |
| [scripts/summarize-context.ps1](./scripts/summarize-context.ps1) | Суммаризация контекста | `.\scripts\summarize-context.ps1` |

### Правила:

| Правило | Назначение |
|---------|------------|
| [.qwen/rules/06-resume.md](.qwen/rules/06-resume.md) | Восстановление сессии |
| [.qwen/rules/07-session-persistence.md](.qwen/rules/07-session-persistence.md) | Автосохранение |

### Конфигурация:

| Файл | Назначение |
|------|------------|
| [.qwen/session-rules.json](.qwen/session-rules.json) | Конфигурация сессий |
| [mcp.json](./mcp.json) | MCP серверы (Filesystem) |
| [.qwen/settings.json](.qwen/settings.json) | Настройки Qwen Code |

---

## 🛡️ БЕЗОПАСНОСТЬ (ПЕРЕД ДЕЙСТВИЯМИ)

### Обязательные файлы:

| Файл | Назначение | Когда читать |
|------|------------|--------------|
| [PRE_ACTION_CHECKLIST.md](./PRE_ACTION_CHECKLIST.md) | Чек-лист перед действиями | Перед любыми изменениями |
| [ANTI_PATTERNS.md](./ANTI_PATTERNS.md) | Запрещённые паттерны | Перед действиями |
| [ERROR_LOG.md](./ERROR_LOG.md) | Журнал ошибок | При проблемах |

### Скрипты проверок:

| Скрипт | Назначение |
|--------|------------|
| [scripts/before-action-checklist-v2.ps1](./scripts/before-action-checklist-v2.ps1) | Проверка перед действием |
| [scripts/check-links.ps1](./scripts/check-links.ps1) | Проверка ссылок |
| [scripts/find-duplicates.ps1](./scripts/find-duplicates.ps1) | Поиск дубликатов |
| [scripts/after-action-audit.ps1](./scripts/after-action-audit.ps1) | Аудит после действия |
| [scripts/safe-kernel-change.ps1](./scripts/safe-kernel-change.ps1) | Безопасные изменения ядра |

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
| 2026-03-04 | 1.3 | Добавлены разделы: Бесшовная загрузка (29 файлов), Восстановление сессии, Безопасность |
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
