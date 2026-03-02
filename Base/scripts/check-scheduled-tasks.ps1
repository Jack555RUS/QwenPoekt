# Проверка задач Task Scheduler

**Запуск:** Дважды кликните на файл или через PowerShell

```powershell
.\scripts\check-scheduled-tasks.ps1
```

---

## 📋 ПРОВЕРКА

```powershell
# Получить все задачи QwenPoekt
Get-ScheduledTask -TaskName "QwenPoekt-*" -ErrorAction SilentlyContinue | 
    Select-Object TaskName, State, LastRunTime, NextRunTime | 
    Format-Table -AutoSize

# Если задач нет → настройка не удалась
```

---

## ✅ РЕЗУЛЬТАТ

**Ожидается:**

```
TaskName                        State  LastRunTime NextRunTime
--------                        -----  ----------- -----------
QwenPoekt-Daily-Git-Commit      Ready            3/3/2026 18:00
QwenPoekt-Weekly-Dedup-Audit    Ready            3/9/2026 09:00
QwenPoekt-Monthly-Backup-Clea.. Ready            4/1/2026 10:00
```

---

## ❌ ЕСЛИ ЗАДАЧ НЕТ

**Вариант 1: Повторить настройку**

```powershell
# Запустить от имени администратора
Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -File .\scripts\schedule-backup-tasks.ps1'
```

**Вариант 2: Ручная настройка**

См. [`_docs/TASK_SCHEDULER_SETUP.md`](_docs/TASK_SCHEDULER_SETUP.md)

---

## 🔧 УПРАВЛЕНИЕ

```powershell
# Запустить задачу вручную
Start-ScheduledTask -TaskName "QwenPoekt-Daily-Git-Commit"

# Проверить результат выполнения
Get-ScheduledTaskInfo -TaskName "QwenPoekt-Daily-Git-Commit" | 
    Select-Object LastRunTime, LastTaskResult

# Отключить задачу
Disable-ScheduledTask -TaskName "QwenPoekt-Daily-Git-Commit"

# Включить задачу
Enable-ScheduledTask -TaskName "QwenPoekt-Daily-Git-Commit"

# Удалить задачу
Unregister-ScheduledTask -TaskName "QwenPoekt-Daily-Git-Commit" -Confirm:$false
```

---

**Проверьте задачи и убедитесь, что они настроены!** ✅
