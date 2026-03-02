# ⚠️ Task Scheduler: Требуется ручная настройка

**Дата:** 2026-03-02  
**Статус:** ⚠️ Задачи не установлены

---

## ❌ ПРОБЛЕМА

Задачи **QwenPoekt-*** не найдены в Task Scheduler.

**Возможные причины:**

1. ⏳ Окно администратора ещё выполняется
2. ❌ Пользователь не подтвердил UAC (Control Account)
3. ❌ Скрипт не выполнен из-за ошибки

---

## 🔍 ПРОВЕРКА

### Шаг 1: Проверить задачи

```powershell
# Выполнить команду
Get-ScheduledTask -TaskName "QwenPoekt-*" -ErrorAction SilentlyContinue

# Если результат пустой → задачи не установлены
```

---

### Шаг 2: Проверить запущенные процессы

```powershell
# Проверить, запущен ли PowerShell от администратора
Get-Process powershell | Where-Object {$_.StartTime -gt (Get-Date).AddMinutes(-5)}
```

---

## ✅ РЕШЕНИЕ

### Вариант 1: Повторить настройку (автоматически)

**Команда:**

```powershell
# Запустить от имени администратора
.\scripts\run-schedule-backup.bat
```

**Или:**

1. Правый клик на `.\scripts\schedule-backup-tasks.ps1`
2. **Run with PowerShell**
3. Подтвердить UAC (Yes)

---

### Вариант 2: Ручная настройка (пошагово)

**Шаг 1: Открыть Task Scheduler**

```
Пуск → введите "Task Scheduler" → Откройте
```

**Или команда:**

```cmd
taskschd.msc
```

---

**Шаг 2: Создать задачу "QwenPoekt-Daily-Git-Commit"**

1. **Action** → **Create Task...**
2. **General:**
   - Name: `QwenPoekt-Daily-Git-Commit`
   - ✅ **Run with highest privileges**
   - Configure for: **Windows 10**

3. **Triggers** → **New...**
   - Begin the task: **On a schedule**
   - **Daily**
   - Start: **18:00**
   - OK

4. **Actions** → **New...**
   - Action: **Start a program**
   - Program/script: `PowerShell.exe`
   - Add arguments: `-ExecutionPolicy Bypass -File "D:\QwenPoekt\Base\scripts\auto-commit-daily.ps1"`
   - Start in: `D:\QwenPoekt\Base\scripts`
   - OK

5. **Conditions:**
   - ❌ Снять: "Start the task only if computer is on AC power"
   - ✅ Оставить: "Start only if network available"

6. **Settings:**
   - ✅ "Allow task to be run on demand"
   - ✅ "Run task as soon as possible after scheduled start is missed"
   - ✅ "Stop task if runs longer than: 2 hours"

7. **OK** → Готово!

---

**Шаг 3: Создать задачу "QwenPoekt-Weekly-Dedup-Audit"**

Повторите Шаг 2 с изменениями:

- Name: `QwenPoekt-Weekly-Dedup-Audit`
- Triggers:
  - **Weekly**
  - Sunday (воскресенье)
  - Start: **09:00**
- Actions:
  - Arguments: `-ExecutionPolicy Bypass -File "D:\QwenPoekt\Base\scripts\weekly-dedup-audit.ps1"`

---

**Шаг 4: Создать задачу "QwenPoekt-Monthly-Backup-Cleanup"**

Повторите Шаг 2 с изменениями:

- Name: `QwenPoekt-Monthly-Backup-Cleanup`
- Triggers:
  - **Monthly**
  - Months: **All months**
  - Day: **1**
  - Start: **10:00**
- Actions:
  - Arguments: `-ExecutionPolicy Bypass -File "D:\QwenPoekt\Base\scripts\old-backup-cleanup.ps1"`

---

## ✅ ПРОВЕРКА РЕЗУЛЬТАТА

**Команда:**

```powershell
Get-ScheduledTask -TaskName "QwenPoekt-*" | 
    Select-Object TaskName, State, LastRunTime, NextRunTime | 
    Format-Table -AutoSize
```

**Ожидается:**

```
TaskName                        State  LastRunTime NextRunTime
--------                        -----  ----------- -----------
QwenPoekt-Daily-Git-Commit      Ready            3/3/2026 18:00
QwenPoekt-Weekly-Dedup-Audit    Ready            3/9/2026 09:00
QwenPoekt-Monthly-Backup-Clea.. Ready            4/1/2026 10:00
```

---

## 📝 ЗАПИСЬ В ЖУРНАЛ

**Файл:** `reports/OPERATION_LOG.md`

```markdown
## 2026-03-02 05:30 Task Scheduler — ручная настройка

**Тип:** Ручная настройка задач

**Причина:** Автоматическая настройка не удалась

**Задачи:**
- QwenPoekt-Daily-Git-Commit ✅
- QwenPoekt-Weekly-Dedup-Audit ✅
- QwenPoekt-Monthly-Backup-Cleanup ✅

**Статус:** ✅ Настроено вручную

---
```

---

## 🆘 ПОМОЩЬ

**Если задачи всё ещё не устанавливаются:**

1. Проверьте логи Task Scheduler:
   - Task Scheduler → **History**
   - Или: `Get-WinEvent -LogName "Microsoft-Windows-TaskScheduler/Operational"`

2. Проверьте права доступа:
   - Вы должны быть в группе **Administrators**

3. Попробуйте создать задачу вручную (см. выше)

---

**Настройте задачи вручную и проверьте результат!** 🚀
