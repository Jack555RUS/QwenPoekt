# 04 — БЕЗОПАСНОСТЬ (SAFETY)

**Версия:** 1.0  
**Дата:** 2 марта 2026 г.  
**Статус:** ✅ Активно  
**Модуль:** `.qwen/rules/04-safety.md`

---

## 🛡️ БЕЗОПАСНОЕ ВЫПОЛНЕНИЕ КОДА

**Правило:** Проверяй код перед выполнением!

### Чек-лист проверки:

```markdown
[ ] 1. Нет удаления объектов?
[ ] 2. Нет зацикливания?
[ ] 3. Есть проверка существования?
[ ] 4. Можно откатить?
```

### Пример безопасного кода:

```csharp
if (GetComponent<Button>() != null)  // Проверка
{
    // Добавляем текст только если нет
    if (transform.childCount == 0)
    {
        AddText();
    }
}
```

---

## 📝 FILE ENCODING

**При создании файлов** (.bat, .ps1, .json, .yaml, .cs):

- ✅ **Кодировка:** UTF-8 **без BOM**
- ✅ **Проверять после записи**
- ✅ **Тестировать с русскими символами**

**Команда:** `/check-encoding [файл]`

**Причина:** 5+ сессий провалено из-за encoding issues с русскими символами

### Как создать файл правильно:

```powershell
# ✅ PowerShell: UTF-8 без BOM
$content | Out-File -FilePath "file.ps1" -Encoding UTF8NoBOM

# ✅ C#: UTF-8 без BOM
[System.IO.File]::WriteAllText("file.cs", $content, [System.Text.UTF8Encoding]::new($false))
```

### Проверка:

```powershell
.\scripts\check-encoding.ps1 -Path "file.ps1"
```

---

## 📁 WORKSPACE ACCESS

**Если нужен доступ к файлам вне workspace:**

1. ⚠️ **СТОП** — не пытайся обходных путей
2. ✅ **Скажи пользователю:** "Нужно добавить папку в VS Code workspace"
3. ✅ **Инструкция:** File → Add Folder to Workspace → [путь]

**Команда:** `/workspace-help` — показать инструкцию

**Причина:** 3+ сессии потрачены на workarounds вместо решения

---

## 🔒 БЕЗОПАСНОСТЬ ДАННЫХ

### Перед удалением файлов:

```powershell
# 1. Dry-run (проверка)
.\scripts\safe-delete.ps1 -Path "_TEMP/" -DryRun

# 2. Просмотр отчёта
# 3. Подтверждение

# 4. Фактическое удаление
.\scripts\safe-delete.ps1 -Path "_TEMP/" -AutoConfirm
```

### Перед крупными изменениями:

```powershell
# 1. Бэкап
git add .
git commit -m "Backup: Перед [причина]"

# 2. Архивация
.\scripts\auto-archive.ps1 -Reason "Before [action]"

# 3. Только потом изменения
```

---

## ⚠️ СТОП-ТРИГГЕРЫ (НЕМЕДЛЕННО ПРЕКРАТИТЬ)

**Триггеры:**
- 🔴 Удаление файлов без бэкапа
- 🔴 Изменение структуры без подтверждения
- 🔴 Запуск скриптов с незнакомым кодом
- 🔴 Доступ к чувствительным данным (.env, ключи, пароли)

**Действие:**
1. Остановиться
2. Записать в [`ERROR_LOG.md`](../../ERROR_LOG.md)
3. Спросить подтверждения
4. Создать правило в [`ANTI_PATTERNS.md`](../../ANTI_PATTERNS.md)

---

## 🔄 АВТОМАТИЧЕСКАЯ ЗАЩИТА

### Скрипты безопасности:

| Скрипт | Назначение |
|--------|------------|
| `check-encoding.ps1` | Проверка кодировки файлов |
| `safe-delete.ps1` | Безопасное удаление (с проверкой) |
| `check-duplicates.ps1` | Проверка на дубликаты |
| `check-anti-patterns.ps1` | Проверка нарушений |
| `backup-before-change.ps1` | Бэкап перед изменениями |

### Pre-Action Checklist:

Перед любыми действиями проверять [`PRE_ACTION_CHECKLIST.md`](../../PRE_ACTION_CHECKLIST.md)

---

## 📊 МЕТРИКИ БЕЗОПАСНОСТИ

| Метрика | Цель | Текущее | Статус |
|---------|------|---------|--------|
| **Бэкап перед изменениями** | 100% | 50% | 🟡 В процессе |
| **Проверка encoding** | 100% | 30% | 🔴 Критично |
| **Проверка ссылок** | 100% | 30% | 🔴 Критично |
| **Тестирование в _TEST_ENV/** | 100% | 0% | 🔴 Критично |

---

## 🎯 ПРИМЕРЫ БЕЗОПАСНЫХ ОПЕРАЦИЙ

### Пример 1: Создание скрипта

```powershell
# ✅ 1. Бэкап
git commit -m "Backup: Перед созданием скрипта"

# ✅ 2. Создать черновик
New-Item -Path "_drafts/new-script.ps1" -ItemType File

# ✅ 3. Написать код (UTF-8 без BOM)
$content | Out-File -FilePath "_drafts/new-script.ps1" -Encoding UTF8NoBOM

# ✅ 4. Тестировать в _TEST_ENV
Copy-Item "_drafts/new-script.ps1" "_TEST_ENV/"
.\scripts\test-all-changes.ps1

# ✅ 5. Внедрить
Move-Item "_drafts/new-script.ps1" "scripts/"
git add scripts/new-script.ps1
git commit -m "Add: new-script.ps1"
```

---

### Пример 2: Удаление папки

```powershell
# ✅ 1. Бэкап
git commit -m "Backup: Перед очисткой _TEMP/"

# ✅ 2. Проверка ссылок
.\scripts\check-file-usage.ps1 -Path "_TEMP/"

# ✅ 3. Dry-run
.\scripts\safe-delete.ps1 -Path "_TEMP/" -DryRun

# ✅ 4. Подтверждение пользователя

# ✅ 5. Удаление
.\scripts\safe-delete.ps1 -Path "_TEMP/" -AutoConfirm
```

---

## 🔗 СВЯЗАННЫЕ МОДУЛИ

| Модуль | Назначение |
|--------|------------|
| **`01-core.md`** | Идентификация, предпочтения |
| **`02-workflow.md`** | Процесс работы |
| **`03-git.md`** | Git, OLD, RELEASE, бэкап |
| **`05-commands.md`** | Быстрые команды |

**Файлы безопасности:**
- [`PRE_ACTION_CHECKLIST.md`](../../PRE_ACTION_CHECKLIST.md)
- [`ANTI_PATTERNS.md`](../../ANTI_PATTERNS.md)
- [`ERROR_LOG.md`](../../ERROR_LOG.md)

---

**Последнее обновление:** 2 марта 2026 г.
