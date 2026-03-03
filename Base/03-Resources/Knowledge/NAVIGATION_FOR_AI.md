# 🧭 НАВИГАТОР ДЛЯ ИИ — ПОСЛЕ PARA ВНЕДРЕНИЯ

**Версия:** 1.0
**Дата:** 3 марта 2026 г.
**Статус:** ✅ **Активно**
**Назначение:** Быстрая навигация по новой структуре Base

---

## ⚠️ ВАЖНОЕ ОБНОВЛЕНИЕ

**Дата:** 3 марта 2026 г.

**Изменения:**
- ✅ **PARA структура внедрена** (Неделя 2 завершена)
- ✅ **KNOWLEDGE_BASE** → `03-Resources/Knowledge/`
- ✅ **03-Resources/PowerShell/** → `03-Resources/PowerShell/`
- ✅ **02-Areas/Documentation/** → `02-Areas/Documentation/`
- ✅ **reports/** → `03-Resources/Knowledge/`
- ✅ **BOOK/** → `D:\QwenPoekt\BOOK\` (вне Base)
- ✅ **OLD/** → `D:\QwenPoekt\OLD\` (вне Base)

---

## 📁 НОВАЯ СТРУКТУРА BASE

```
D:\QwenPoekt\Base\
├── 01-Projects/          # 🔴 ТЕКУЩИЕ ЗАДАЧИ (спринт)
│   └── (пусто)           # Заполняется задачами
│
├── 02-Areas/             # 🟡 ОБЛАСТИ ОТВЕТСТВЕННОСТИ (марафон)
│   └── Documentation/    # ✅ 62 файла (документация)
│
├── 03-Resources/         # 🟢 РЕСУРСЫ (библиотека)
│   ├── PowerShell/       # ✅ 78 скриптов (.ps1, .bat, .js)
│   ├── Knowledge/        # ✅ 80 файлов (знания, отчёты)
│   ├── AI/               # ✅ ~10 файлов (ИИ ресурсы)
│   ├── BOOKS/            # ✅ 1 файл (библиография)
│   ├── CSharp/           # (пусто)
│   └── Unity/            # (пусто)
│
├── 04-Archives/          # ⚫ АРХИВ (завершённое)
│   └── (пусто)           # Заполняется архивами
│
├── .qwen/                # ⚙️ КОНФИГУРАЦИЯ ИИ
│   ├── QWEN.md           # ✅ Главный конфиг (41 KB)
│   ├── rules/            # ✅ 8 правил (01-08)
│   ├── agents/           # ✅ 8 агентов
│   └── session-rules.json # ✅ Настройки сессий
│
├── sessions/             # 💾 АВТОСОХРАНЕНИЕ СЕССИЙ
│   └── YYYY-MM-DD_HH-mm/ # ✅ 490+ сессий
│
└── 03-Resources/PowerShell/              # 🔧 ВСПОМОГАТЕЛЬНЫЕ СКРИПТЫ
    ├── auto-save-chat-silent.bat
    └── ... (6 файлов)
```

---

## 🔍 БЫСТРЫЙ ПОИСК

### **Знания (Knowledge):**

| Что | Где | Файлов |
|-----|-----|--------|
| **00_README.md** | `03-Resources/Knowledge/00_README.md` | Навигатор |
| **FOR_AI_READ_HERE.md** | `03-Resources/Knowledge/FOR_AI_READ_HERE.md` | Для ИИ |
| **csharp_standards.md** | `03-Resources/Knowledge/csharp_standards.md` | C# стандарты |
| **error_solutions.md** | `03-Resources/Knowledge/error_solutions.md` | База ошибок |
| **design_patterns_unity.md** | `03-Resources/Knowledge/design_patterns_unity.md` | Паттерны Unity |

---

### **Скрипты (PowerShell):**

| Что | Где | Файлов |
|-----|-----|--------|
| **pre-move-check.ps1** | `03-Resources/PowerShell/pre-move-check.ps1` | Проверка перед перемещением |
| **update-links-after-move.ps1** | `03-Resources/PowerShell/update-links-after-move.ps1` | Обновление ссылок |
| **auto-save-chat.ps1** | `03-Resources/PowerShell/auto-save-chat.ps1` | Автосохранение |
| **start-session.ps1** | `03-Resources/PowerShell/start-session.ps1` | Восстановление сессии |
| **check-session-rules.ps1** | `03-Resources/PowerShell/check-session-rules.ps1` | Проверка правил |

---

### **Документация (Areas):**

| Что | Где | Файлов |
|-----|-----|--------|
| **para-structure-guide.md** | `02-Areas/Documentation/para-structure-guide.md` | PARA структура |
| **para-week2-complete.md** | `02-Areas/Documentation/para-week2-complete.md` | Отчёт Недели 2 |
| **seamless-launch-investigation.md** | `02-Areas/Documentation/seamless-launch-investigation.md` | Расследование запуска |
| **move-files-rules-investigation.md** | `02-Areas/Documentation/move-files-rules-investigation.md` | Расследование правил |
| **UI_TOOLKIT_SETUP_GUIDE.md** | `02-Areas/Documentation/UI_TOOLKIT_SETUP_GUIDE.md` | UI Toolkit |

---

### **Конфигурация ИИ (.qwen):**

| Что | Где | Файлов |
|-----|-----|--------|
| **QWEN.md** | `.qwen/QWEN.md` | Главный конфиг (41 KB) |
| **rules/01-core.md** | `.qwen/rules/01-core.md` | Идентификация |
| **rules/02-workflow.md** | `.qwen/rules/02-workflow.md` | Процесс работы |
| **rules/08-mass-operations.md** | `.qwen/rules/08-mass-operations.md` | Массовые операции (НОВОЕ!) |
| **agents/README.md** | `.qwen/agents/README.md` | Агенты (8 файлов) |

---

## 🎯 ТОЧКИ ВХОДА ДЛЯ ИИ

### **1. При старте сессии:**

```powershell
# 1. Прочитать QWEN.md
Get-Content ".qwen/QWEN.md" -Head 50

# 2. Проверить сессию
.\03-Resources\PowerShell\start-session.ps1 -Resume

# 3. Проверить задачи
Get-Content "01-Projects\TASK.md" -ErrorAction SilentlyContinue
```

---

### **2. При поиске знаний:**

```powershell
# 1. Открыть навигатор
Get-Content "03-Resources\Knowledge\00_README.md"

# 2. Найти конкретное знание
Get-ChildItem "03-Resources\Knowledge" -Filter "*csharp*" -Recurse

# 3. Проверить ошибки
Get-Content "03-Resources\Knowledge\error_solutions.md"
```

---

### **3. При выполнении операций:**

```powershell
# 1. Перемещение файлов (>100 файлов)
.\03-Resources\PowerShell\pre-move-check.ps1 `
  -SourcePath "old/" `
  -DestinationPath "04-Archives/" `
  -Filter "*.md"

# 2. После перемещения
.\03-Resources\PowerShell\update-links-after-move.ps1 `
  -OldPath "old/" `
  -NewPath "04-Archives/"

# 3. Закоммитить
git add . && git commit -m "Move: файлы из old/ в 04-Archives/"
```

---

## ⚠️ КРИТИЧНЫЕ ИЗМЕНЕНИЯ

### **Ссылки в AI_START_HERE.md (вне Base):**

**Файл:** `D:\QwenPoekt\AI_START_HERE.md`

**Заменить:**
```markdown
# БЫЛО:
- [`00_CORE/csharp_standards.md`](./03-Resources/Knowledge/00_CORE/csharp_standards.md)
- [`03-Resources/PowerShell/auto-save-chat.ps1`](./03-Resources/PowerShell/auto-save-chat.ps1)
- [`02-Areas/Documentation/PARA_GUIDE.md`](./02-Areas/Documentation/PARA_GUIDE.md)

# СТАЛО:
- [`Base/03-Resources/Knowledge/csharp_standards.md`](./Base/03-Resources/Knowledge/csharp_standards.md)
- [`Base/03-Resources/PowerShell/auto-save-chat.ps1`](./Base/03-Resources/PowerShell/auto-save-chat.ps1)
- [`Base/02-Areas/Documentation/para-structure-guide.md`](./Base/02-Areas/Documentation/para-structure-guide.md)
```

**Действие:** Требуется ручное обновление (файл вне workspace)

---

## 📊 СТАТИСТИКА

| Категория | Файлов | Размер | Путь |
|-----------|--------|--------|------|
| **Знания** | 80 | ~2 MB | `03-Resources/Knowledge/` |
| **Скрипты** | 78 | ~1 MB | `03-Resources/PowerShell/` |
| **Документация** | 62 | ~1 MB | `02-Areas/Documentation/` |
| **Конфигурация ИИ** | 24 | ~100 KB | `.qwen/` |
| **Сессии** | 490+ | ~10 MB | `sessions/` |
| **ВСЕГО** | ~734 | ~14 MB | `Base/` |

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`para-structure-guide.md`](./02-Areas/Documentation/para-structure-guide.md) — Руководство PARA
- [`seamless-launch-investigation.md`](./02-Areas/Documentation/seamless-launch-investigation.md) — Расследование запуска
- [`move-files-rules-investigation.md`](./02-Areas/Documentation/move-files-rules-investigation.md) — Расследование правил
- [`error_solutions.md`](./03-Resources/Knowledge/error_solutions.md) — База ошибок
- [`QWEN.md`](./.qwen/QWEN.md) — Главный конфиг

---

## 🗣️ ДЛЯ ИИ

**При старте:**
1. ✅ Прочитать этот файл (навигация)
2. ✅ Прочитать QWEN.md (конфигурация)
3. ✅ Проверить сессию (start-session.ps1)
4. ✅ Проверить задачи (01-Projects/)

**При поиске:**
1. ✅ Использовать 00_README.md (навигатор)
2. ✅ Искать в 03-Resources/Knowledge/ (знания)
3. ✅ Проверить error_solutions.md (ошибки)

**При операциях:**
1. ✅ pre-move-check.ps1 (проверка)
2. ✅ update-links-after-move.ps1 (ссылки)
3. ✅ 08-mass-operations.md (правила)

---

**Создано:** 3 марта 2026 г.
**Причина:** PARA внедрение (Неделя 2 завершена)
**Статус:** ✅ **Активно**

