# 📋 ОТЛОЖЕННЫЕ ЗАДАЧИ — БЭКАП

**Дата создания:** 2 марта 2026 г.
**Статус:** ⏳ Отложено (после реализации автосохранения)

---

## 🔴 ЗАДАЧА: Полная копия Base (автоматически)

**Описание:**
Автосохранение полной копии `Base/` в `_BACKUP/` каждые N минут.

**Проблема:**
- Текущее автосохранение сохраняет только переписку ИИ
- При полном крахе системы переписки недостаточно
- Нужна полная копия всех файлов Base

**Решение (план):**

### Вариант 1: PowerShell (Hidden Window)
```powershell
# auto-full-backup.ps1
$BasePath = "D:\QwenPoekt\Base"
$BackupPath = "D:\QwenPoekt\_BACKUP\Auto_Full\Base_$(Get-Date -Format 'yyyy-MM-dd_HH-mm')"

# Полная копия (исключая временные папки)
robocopy $BasePath $BackupPath /MIR /XF *.tmp /XD _TEMP sessions _LOCAL_ARCHIVE /NFL /NDL /NJH /NJS

# Сжатие старой копии (экономия места)
$oldBackups = Get-ChildItem "D:\QwenPoekt\_BACKUP\Auto_Full\" -Directory | Where-Object { $_.LastWriteTime -lt (Get-Date).AddHours(-1) }
foreach ($backup in $oldBackups) {
    Compress-Archive -Path $backup.FullName -DestinationPath "$($backup.FullName).zip" -Force
    Remove-Item -Path $backup.FullName -Recurse -Force
}
```

**Интервал:**
- ⏳ **Обсуждается** (2 мин? 5 мин? 10 мин?)
- Слишком часто = нагрузка на диск
- Слишком редко = риск потери

**Где запускать:**
- PowerShell Hidden Window
- Или MCP Filesystem напрямую

**Зависимости:**
- ✅ Реализовать автосохранение переписки (текущая задача)
- ⏳ Определить оптимальный интервал
- ⏳ Протестировать нагрузку на диск

---

## 📊 ПРИОРИТЕТЫ

| Задача | Приоритет | Статус |
|--------|-----------|--------|
| Автосохранение переписки (2 мин) | 🔴 Высокий | ✅ В работе |
| Бэкап перед изменением файлов | 🟡 Средний | ⏳ После |
| Полная копия Base (автоматически) | 🟢 Низкий | ⏳ Отложено |

---

**Следующий шаг:** Завершить текущую задачу (автосохранение переписки), затем вернуться к этой.
