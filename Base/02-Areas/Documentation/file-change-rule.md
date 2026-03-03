# Правило обновления связанных файлов

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Обязательно к исполнению

---

## 🎯 ЦЕЛЬ

При изменении любого файла в проекте **автоматически обновлять все связанные документы**.

---

## 📋 МАТРИЦА ИЗМЕНЕНИЙ

### Тип 1: Создание файла

**Когда:** Создан новый файл (скрипт, документ, шаблон)

**Что обновлять:**

| Файл | Что добавить |
|------|--------------|
| `02-Areas/Documentation/STRUCTURE_GUIDE.md` | В каталог скриптов/документов |
| `README.md` | В таблицу скриптов (если применимо) |
| `AI_START_HERE.md` | В карту проекта |
| `02-Areas/Documentation/*_GUIDE.md` | В связанные руководства |
| `reports/OPERATION_LOG.md` | Запись о создании |

**Пример:**
```
Создан: 03-Resources/PowerShell/end-session.ps1
Обновить:
  ✅ 02-Areas/Documentation/STRUCTURE_GUIDE.md (каталог скриптов)
  ✅ 02-Areas/Documentation/BACKUP_STRATEGY.md (раздел бэкапа)
  ✅ README.md (таблица скриптов)
  ✅ AI_START_HERE.md (карта проекта)
  ✅ 02-Areas/Documentation/END_SESSION_COMMAND.md (инструкция)
```

---

### Тип 2: Удаление файла

**Когда:** Удалён файл

**Что делать:**

1. **Найти все ссылки:**
   ```powershell
   grep_search -pattern "удалённый_файл" -glob "*.md"
   ```

2. **Обновить каждое упоминание:**
   - Удалить ссылку
   - Или заменить на новую

3. **Обновить каталоги:**
   - `02-Areas/Documentation/STRUCTURE_GUIDE.md`
   - `README.md`
   - `AI_START_HERE.md`

---

### Тип 3: Переименование файла (КРИТИЧНО!)

**Когда:** Переименован файл

**Что делать:**

1. **Найти ВСЕ ссылки (grep_search):**
   ```powershell
   # Старое имя
   grep_search -pattern "old_name" -glob "*.md"
   
   # Проверить каждый файл
   ```

2. **Обновить каждую ссылку:**
   ```markdown
   # Было:
   [Описание](old_name.md)
   
   # Стало:
   [Описание](new_name.md)
   ```

3. **Проверить пути:**
   ```powershell
   Test-Path "путь/к/новому_файлу"
   ```

4. **Обновить каталоги:**
   - `02-Areas/Documentation/STRUCTURE_GUIDE.md`
   - `README.md`
   - `AI_START_HERE.md`

**Пример:**
```
Переименован: file_naming_rule.md → file_naming_convention.md

Найти ссылки (9 файлов):
  ✅ 01_RULES/README.md
  ✅ 02-Areas/Documentation/STRUCTURE_GUIDE.md
  ✅ README.md
  ✅ AI_START_HERE.md
  ✅ ...

Обновить каждую ссылку!
```

---

### Тип 4: Перемещение файла

**Когда:** Файл перемещён в другую папку

**Что делать:**

1. **Найти все ссылки:**
   ```powershell
   grep_search -pattern "старый_путь" -glob "*.md"
   ```

2. **Обновить пути:**
   ```markdown
   # Было:
   [Описание](old_folder/file.md)
   
   # Стало:
   [Описание](new_folder/file.md)
   ```

3. **Проверить пути:**
   ```powershell
   Test-Path "новый_путь/к/файлу"
   ```

---

### Тип 5: Изменение функции/параметров

**Когда:** Изменена функция скрипта, добавлены параметры

**Что обновлять:**

| Файл | Что изменить |
|------|--------------|
| `02-Areas/Documentation/*_GUIDE.md` | Примеры использования |
| `README.md` | Таблица параметров |
| `_templates/*.md` | Шаблоны вызова |
| `reports/*.md` | Отчёты с примерами |

**Пример:**
```
Изменён: safe-delete.ps1
Добавлен параметр: -Force

Обновить:
  ✅ 02-Areas/Documentation/SAFE_DELETE_GUIDE.md (примеры)
  ✅ README.md (таблица параметров)
  ✅ _templates/SCRIPT_ANALYSIS.md (шаблон)
```

---

## 🔧 ИНСТРУМЕНТЫ ДЛЯ ПРОВЕРКИ

### 1. Поиск ссылок

```powershell
# Найти все упоминания файла
grep_search -pattern "имя_файла" -glob "*.md"

# Найти все упоминания скрипта
grep_search -pattern "имя_скрипта.ps1" -glob "*.md"

# Найти все ссылки на документ
grep_search -pattern "\.md\)" -glob "*.md"
```

---

### 2. Проверка путей

```powershell
# Проверить существование файла
Test-Path "путь/к/файлу"

# Проверить все ссылки в файле
Get-Content "файл.md" | Select-String "\[.*\]\(.*\)"
```

---

### 3. Автоматическая проверка

**Скрипт:** `03-Resources/PowerShell/check-broken-links.ps1` (будет создан)

```powershell
# Проверить все ссылки в проекте
.\scripts\check-broken-links.ps1
```

---

## 📋 ЧЕК-ЛИСТ ПРИ ИЗМЕНЕНИИ

### При создании файла:

```markdown
[ ] 1. Создан файл
[ ] 2. Добавлен в 02-Areas/Documentation/STRUCTURE_GUIDE.md
[ ] 3. Добавлен в README.md (если применимо)
[ ] 4. Добавлен в AI_START_HERE.md
[ ] 5. Создана инструкция (02-Areas/Documentation/*_GUIDE.md)
[ ] 6. Запись в OPERATION_LOG.md
[ ] 7. Git коммит
```

---

### При переименовании файла:

```markdown
[ ] 1. grep_search старого имени
[ ] 2. Найти ВСЕ ссылки (проверить каждый .md файл)
[ ] 3. Обновить каждую ссылку
[ ] 4. Проверить пути (Test-Path)
[ ] 5. Обновить каталоги
[ ] 6. Запись в OPERATION_LOG.md
[ ] 7. Git коммит
```

---

### При удалении файла:

```markdown
[ ] 1. grep_search имени
[ ] 2. Найти все ссылки
[ ] 3. Удалить или обновить ссылки
[ ] 4. Обновить каталоги
[ ] 5. Запись в OPERATION_LOG.md
[ ] 6. Git коммит
```

---

## 🎯 ПРИМЕРЫ

### Пример 1: Создание end-session.ps1

**Создано:**
- `03-Resources/PowerShell/end-session.ps1`

**Обновлено:**
- ✅ `02-Areas/Documentation/END_SESSION_COMMAND.md` (инструкция)
- ✅ `02-Areas/Documentation/BACKUP_STRATEGY.md` (раздел бэкапа)
- ✅ `README.md` (таблица скриптов)
- ✅ `02-Areas/Documentation/STRUCTURE_GUIDE.md` (каталог)
- ✅ `AI_START_HERE.md` (карта проекта)

**Git коммитов:** 3

---

### Пример 2: Переименование файла

**Было:** `file_naming_rule.md`  
**Стало:** `file_naming_convention.md`

**Найдено ссылок:** 9

**Обновлено файлов:**
- ✅ `01_RULES/README.md`
- ✅ `02-Areas/Documentation/STRUCTURE_GUIDE.md`
- ✅ `README.md`
- ✅ `AI_START_HERE.md`
- ✅ `03-Resources/Knowledge/01_RULES/file_naming_rule.md` (оглавление)

**Git коммитов:** 1 (все вместе)

---

## ⚠️ ЧАСТЫЕ ОШИБКИ

| Ошибка | Последствия | Как избежать |
|--------|-------------|--------------|
| **Не найдены все ссылки** | Битые ссылки в 5+ файлах | grep_search перед изменением |
| **Не проверены пути** | Ссылки ведут в никуда | Test-Path после обновления |
| **Разные коммиты** | Сложно откатить | Один коммит на изменение |
| **Не обновлены каталоги** | Файл не найти | STRUCTURE_GUIDE, README, AI_START_HERE |

---

## 📊 СТАТИСТИКА

**При создании скрипта:**
- Обновить: 5+ файлов
- Ссылок: 10+
- Коммитов: 1-3

**При переименовании:**
- Найти: 20+ ссылок
- Обновить: 10+ файлов
- Коммитов: 1

**При перемещении:**
- Найти: 15+ ссылок
- Обновить: 8+ файлов
- Коммитов: 1

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

| Файл | Назначение |
|------|------------|
| [02-Areas/Documentation/STRUCTURE_GUIDE.md](02-Areas/Documentation/STRUCTURE_GUIDE.md) | Каталог всех файлов |
| [README.md](README.md) | Навигатор по проекту |
| [AI_START_HERE.md](AI_START_HERE.md) | Карта проекта |
| [reports/OPERATION_LOG.md](reports/OPERATION_LOG.md) | Журнал изменений |

---

**Правило действует с:** 2026-03-02  
**Обязательно для:** Всех изменений файлов

---

**Соблюдай правило → не будет битых ссылок!** ✅

