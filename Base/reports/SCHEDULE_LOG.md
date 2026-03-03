# Отчёт установки расписания

**Дата:** 2026-03-03 23:19:44
**Пользователь:** Jackal
**Администратор:** Да

---

## Задачи

### ✅ Ежедневный Git коммит

**Статус:** Установлена
**Описание:** Ежедневный Git коммит в 18:00
**Скрипт:** ```D:\QwenPoekt\Base\03-Resources\PowerShell\auto-commit-daily.ps1```
**Состояние:** Ready
**Последний запуск:** 
**Следующий запуск:** 

### ✅ Еженедельный аудит Базы

**Статус:** Установлена
**Описание:** Еженедельный аудит Базы Знаний (пятница 18:00)
**Скрипт:** ```D:\QwenPoekt\Base\scripts\weekly-knowledge-audit.ps1```
**Состояние:** Ready
**Последний запуск:** 
**Следующий запуск:** 

---

## Команды управления

```powershell
# Проверить статус задач
Get-ScheduledTask -TaskName "QwenPoekt-*"

# Запустить задачу вручную
Start-ScheduledTask -TaskName "QwenPoekt-Daily-Git-Commit"

# Удалить все задачи
.\scripts\schedule-backup-tasks.ps1 -Uninstall
```

---

**Отчёт сгенерирован:** 2026-03-03 23:19:44
**Скрипт:** schedule-backup-tasks.ps1
