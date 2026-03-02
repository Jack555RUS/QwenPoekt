# 05 — БЫСТРЫЕ КОМАНДЫ (COMMANDS)

**Версия:** 1.0  
**Дата:** 2 марта 2026 г.  
**Статус:** ✅ Активно  
**Модуль:** `.qwen/rules/05-commands.md`

---

## 🎯 БЫСТРЫЕ КОМАНДЫ (ДЛЯ ОБЩЕНИЯ)

| Команда | Действие |
|---------|----------|
| `/resume` | **Восстановление сессии** (автопроверка контекста) |
| `/status` | Показать статус сессии |
| `/save-session` | Ручное автосохранение сессии |
| `/need_data` | **Запросить уточнение** — если контекста недостаточно |
| `/update` | **Предложить добавить новое знание** в базу |
| `/update_knowledge` | Сигнал о том, что нужно добавить новое знание в библиотеку |
| `/check_rules [тема]` | Напомни правила по конкретной теме |
| `/debug [описание]` | Режим глубокого анализа ошибки с использованием error_solutions.md |
| `/find_pattern [задача]` | Найди паттерн решения в базе |
| `/verify-complete` | Проверить завершение задачи (TDD) |
| `/check-encoding [файл]` | Проверить кодировку файла |
| `/workspace-help` | Помощь с доступом к workspace |
| `/unity-build-check` | Проверка перед сборкой Unity |
| `/multi-agent [задача]` | Запустить 4 агентов параллельно |
| `/backup` | Создать коммит и запушить на GitHub |
| `/move-to-old [путь]` | Переместить проект в OLD |
| `/old-analysis` | Анализировать OLD (извлечь идеи) |
| `/lazy-load [тема]` | Загрузить только нужное (ленивая загрузка) |
| `/architect-mode` | Включить полный анализ (видеть задачу в контексте проекта) |
| `/draft-pattern` | Создать черновик паттерна (после решения задачи) |
| `/more` | «Нужны детали» — ИИ даёт развёрнутый ответ |
| `/less` | «Кратче» — ИИ сокращает ответ |
| `/remember [предпочтение]` | Запомнить предпочтение в сессии |
| **`выход`**, **`перезагрузка`** | **Автоматическое сохранение сессии** |

---

## 🛠️ СКРИПТЫ АВТОМАТИЗАЦИИ

### Сборка и тестирование:

| Скрипт | Назначение |
|--------|------------|
| `auto-build-exe.ps1` | Сборка EXE |
| `clean-logs.ps1` | Очистка логов |
| `check-environment.ps1` | Проверка окружения |
| `test-all.ps1` | Запуск всех тестов |
| `test-all-changes.ps1` | Тестирование изменений |

### Аудит и проверка:

| Скрипт | Назначение |
|--------|------------|
| `AUDIT_ALL.ps1` | Единая точка входа (аудит) |
| `audit-ai-start-here.ps1` | Аудит AI_START_HERE |
| `full-file-audit.ps1` | Аудит файлов |
| `check-duplicates.ps1` | Проверка на дубликаты |
| `check-encoding.ps1` | Проверка кодировки |
| `check-anti-patterns.ps1` | Проверка нарушений |
| `check-rule-links.ps1` | Проверка ссылок |

### Git и бэкап:

| Скрипт | Назначение |
|--------|------------|
| `auto-commit-daily.ps1` | Ежедневный коммит (18:00) |
| `github-auth.ps1` | Авторизация на GitHub |
| `connect-github.ps1` | Подключение репозитория |
| `github-backup.ps1` | Резервное копирование |
| `github-compare.ps1` | Сравнение с GitHub |
| `auto-archive.ps1` | Архивация сессии |

### OLD система:

| Скрипт | Назначение |
|--------|------------|
| `move-to-old.ps1` | Перемещение в OLD |
| `old-analysis.ps1` | Анализ OLD (извлечь идеи) |
| `old-cleanup.ps1` | Очистка OLD/_ARCHIVE_60D/ |

### Безопасность:

| Скрипт | Назначение |
|--------|------------|
| `safe-delete.ps1` | Безопасное удаление |
| `backup-before-change.ps1` | Бэкап перед изменениями |
| `check-file-usage.ps1` | Проверка использования файла |

### Сессии (восстановление):

| Скрипт | Назначение |
|--------|------------|
| `auto-save-session.ps1` | **Автосохранение при выходе/перезагрузке** |
| `start-session.ps1` | **Проверка контекста при старте** |
| `end-session.ps1` | Ручное завершение сессии (legacy) |
| `end-session.ps1` | Завершение сессии |

### Утилиты:

| Скрипт | Назначение |
|--------|------------|
| `build-knowledge-graph.ps1` | Граф связей знаний |
| `calculate-kb-metrics.ps1` | Метрики качества БЗ |
| `update-dashboard.ps1` | Dashboard (KB_DASHBOARD.html) |
| `weekly-knowledge-audit.ps1` | Еженедельный аудит |
| `check-knowledge-stats.ps1` | Проверка статистики |
| `organize-root.ps1` | Организация корня |
| `update-ai-start-here.ps1` | Обновление AI_START_HERE.md |

---

## 🔧 ОТЛАДКА

| Скрипт | Назначение |
|--------|------------|
| `debug-unity.ps1` | Запуск Unity в режиме отладки |
| `debug-vs.ps1` | Открытие Visual Studio с отладкой |
| `unity-get-logs.ps1` | Получение логов Unity |

**Руководства:**
- [`PROJECTS/DragRaceUnity/DEBUGGING_GUIDE.md`](../PROJECTS/DragRaceUnity/DEBUGGING_GUIDE.md)
- [`PROJECTS/DragRaceUnity/DEBUG_CHECKLIST.md`](../PROJECTS/DragRaceUnity/DEBUG_CHECKLIST.md)

---

## 📊 МЕТРИКИ И ОТЧЁТЫ

| Скрипт | Назначение |
|--------|------------|
| `calculate-kb-metrics.ps1` | Метрики качества БЗ |
| `update-dashboard.ps1` | Dashboard (KB_DASHBOARD.html) |
| `check-knowledge-stats.ps1` | Проверка статистики |

**Отчёты:**
- [`reports/UnityCsReference_ANALYSIS.md`](../reports/UnityCsReference_ANALYSIS.md)
- [`reports/AI_START_HERE_AUDIT.md`](../reports/AI_START_HERE_AUDIT.md)
- [`reports/BROKEN_LINKS_ANALYSIS.md`](../reports/BROKEN_LINKS_ANALYSIS.md)
- [`reports/SESSION_HANDOVER.md`](../reports/SESSION_HANDOVER.md)

---

## 🎯 ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ

### Пример 1: Проверка задачи

```
/verify-complete
```

**Что делает:**
- ✅ Код компилируется?
- ✅ Тесты проходят?
- ✅ EXE собирается?
- ✅ Кнопки работают?

---

### Пример 2: Ленивая загрузка

```
/lazy-load UI
```

**Что загружает:**
- ✅ `01_RULES/ui_toolkit_rules.md`
- ✅ `03_PATTERNS/error_solutions.md` (UI раздел)
- ❌ Не читать `02_UNITY/2D_ANIMATION.md` (не нужно)

---

### Пример 3: Мульти-агент

```
/multi-agent создать кнопку меню
```

**Агенты:**
- **Agent 1 (Code)** — Пишет код
- **Agent 2 (Tests)** — Пишет тесты
- **Agent 3 (Docs)** — Обновляет документацию
- **Agent 4 (Build)** — Проверяет сборку

---

### Пример 4: Бэкап

```
/backup
```

**Что делает:**
1. git add .
2. git commit -m "Backup: ..."
3. git push origin master

---

## 🔗 СВЯЗАННЫЕ МОДУЛИ

| Модуль | Назначение |
|--------|------------|
| **`01-core.md`** | Идентификация, предпочтения |
| **`02-workflow.md`** | Процесс работы |
| **`03-git.md`** | Git, OLD, RELEASE, бэкап |
| **`04-safety.md`** | Безопасность, encoding, workspace |

**Полный конфиг:** [`.qwen/QWEN.md`](../QWEN.md)

---

**Последнее обновление:** 2 марта 2026 г.
