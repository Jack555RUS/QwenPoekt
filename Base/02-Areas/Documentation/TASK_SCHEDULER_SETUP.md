# Настройка Task Scheduler

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Проект:** QwenPoekt\Base

---

## 🎯 НАЗНАЧЕНИЕ

Автоматическое выполнение задач бэкапа и аудита по расписанию.

---

## 📋 ЗАДАЧИ

| Задача | Расписание | Скрипт |
|--------|------------|--------|
| **Ежедневный Git коммит** | 18:00 ежедневно | `auto-commit-daily.ps1` |
| **Еженедельный аудит** | 09:00 воскресенье | `weekly-dedup-audit.ps1` |
| **Ежемесячная очистка** | 10:00 1-е число | `old-backup-cleanup.ps1` |

---

## 🔧 АВТОМАТИЧЕСКАЯ НАСТРОЙКА

### Вариант 1: Запуск от администратора

**Команда:**

```powershell
# Запустить от имени администратора
.\scripts\schedule-backup-tasks.ps1
```

**Или через .bat файл:**

```cmd
.\scripts\run-schedule-backup.bat
```

---

### Вариант 2: Ручная настройка (Task Scheduler)

**Шаг 1: Открыть Task Scheduler**

```
Пуск → Task Scheduler
```

**Или команда:**

```cmd
taskschd.msc
```

---

**Шаг 2: Создать задачу**

1. **Action** → **Create Task...**
2. **General:**
   - Name: `QwenPoekt-Daily-Git-Commit`
   - ✅ **Run with highest privileges**
   - Configure for: **Windows 10**

---

**Шаг 3: Настроить триггер**

1. **Triggers** → **New...**
2. **Begin the task:** On a schedule
3. **Settings:**
   - Daily
   - Recur every: 1 days
   - Start: 18:00:00
4. **OK**

---

**Шаг 4: Настроить действие**

1. **Actions** → **New...**
2. **Action:** Start a program
3. **Settings:**
   - Program/script: `PowerShell.exe`
   - Add arguments: `-ExecutionPolicy Bypass -File "D:\QwenPoekt\Base\scripts\auto-commit-daily.ps1"`
   - Start in: `D:\QwenPoekt\Base\scripts`
4. **OK**

---

**Шаг 5: Настроить условия**

1. **Conditions** → Снять галочки:
   - ❌ Start the task only if computer is on AC power
   - ✅ Start only if network available
2. **OK**

---

**Шаг 6: Настроить параметры**

1. **Settings:**
   - ✅ Allow task to be run on demand
   - ✅ Run task as soon as possible after scheduled start is missed
   - ✅ Stop task if runs longer than: 2 hours
2. **OK**

---

## 📋 ПРОВЕРКА ЗАДАЧ

### PowerShell

```powershell
# Проверить все задачи QwenPoekt
Get-ScheduledTask -TaskName "QwenPoekt-*" | 
    Select-Object TaskName, State, LastRunTime, NextRunTime | 
    Format-Table -AutoSize

# Проверить конкретную задачу
Get-ScheduledTask -TaskName "QwenPoekt-Daily-Git-Commit" | 
    Select-Object TaskName, State, LastRunTime, NextRunTime

# Запустить задачу вручную
Start-ScheduledTask -TaskName "QwenPoekt-Daily-Git-Commit"

# Проверить историю
Get-ScheduledTaskInfo -TaskName "QwenPoekt-Daily-Git-Commit"
```

---

### Task Scheduler GUI

1. Откройте **Task Scheduler**
2. Перейдите в **Task Scheduler Library**
3. Найдите задачи **QwenPoekt-***
4. Проверьте колонки **Last Run Time**, **Next Run Time**, **Status**

---

## 🗑️ УДАЛЕНИЕ ЗАДАЧ

### PowerShell

```powershell
# Удалить все задачи
Unregister-ScheduledTask -TaskName "QwenPoekt-*" -Confirm:$false

# Удалить конкретную задачу
Unregister-ScheduledTask -TaskName "QwenPoekt-Daily-Git-Commit" -Confirm:$false
```

### Task Scheduler GUI

1. Найдите задачу в списке
2. **Right-click** → **Delete**
3. **Yes**

---

## 📊 МОНИТОРИНГ

### Еженедельная проверка

```powershell
# Статус всех задач
Get-ScheduledTask -TaskName "QwenPoekt-*" | 
    Format-Table TaskName, State, LastRunTime, NextRunTime -AutoSize

# История выполнений
Get-ScheduledTaskInfo -TaskName "QwenPoekt-Weekly-Dedup-Audit" | 
    Select-Object LastRunTime, LastTaskResult
```

### Интерпретация результатов

| State | Значение |
|-------|----------|
| **Ready** | Готов к выполнению |
| **Running** | Выполняется |
| **Disabled** | Отключено |

| LastTaskResult | Значение |
|----------------|----------|
| **0** | Успешно |
| **1** | Ошибка |
| **0x1** | Выполнено с предупреждениями |

---

## ⚠️ ПРЕДУПРЕЖДЕНИЯ

### Проблема: Задача не выполняется

**Решение:**

1. Проверить права администратора:
   - ✅ **Run with highest privileges**

2. Проверить путь к скрипту:
   - Убедиться, что путь существует
   - Проверить кавычки в аргументах

3. Проверить Execution Policy:
   ```powershell
   Get-ExecutionPolicy
   # Должно быть: RemoteSigned или Bypass
   ```

---

### Проблема: Задача выполняется с ошибкой

**Решение:**

1. Проверить лог задачи:
   - Task Scheduler → История задачи
   - Или: `Get-WinEvent -LogName "Microsoft-Windows-TaskScheduler/Operational"`

2. Проверить зависимости:
   - Git установлен?
   - PowerShell 7+?
   - Скрипт существует?

3. Запустить вручную:
   ```powershell
   .\scripts\auto-commit-daily.ps1
   ```

---

## 🔗 СВЯЗАННЫЕ РЕСУРСЫ

| Файл | Описание |
|------|----------|
| [BACKUP_STRATEGY.md](BACKUP_STRATEGY.md) | Стратегия резервирования |
| [schedule-backup-tasks.ps1](../../scripts/schedule-backup-tasks.ps1) | Скрипт настройки |

---

## 💡 СОВЕТЫ

### Быстрая проверка

```powershell
# Все задачи QwenPoekt
Get-ScheduledTask -TaskName "QwenPoekt-*"

# Запустить задачу
Start-ScheduledTask -TaskName "QwenPoekt-Daily-Git-Commit"

# Проверить результат
Get-ScheduledTaskInfo -TaskName "QwenPoekt-Daily-Git-Commit"
```

### Экспорт задач

```powershell
# Экспортировать задачу в XML
Export-ScheduledTask -TaskName "QwenPoekt-Daily-Git-Commit" | 
    Out-File "QwenPoekt-Daily-Git-Commit.xml"

# Импортировать задачу
Register-ScheduledTask -Xml (Get-Content "QwenPoekt-Daily-Git-Commit.xml" | Out-String) `
    -TaskName "QwenPoekt-Daily-Git-Commit"
```

---

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готов к использованию

---

**Настройте расписание и забудьте о рутине!** 🚀
