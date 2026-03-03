# 📊 TASK DAG SYSTEM

**Версия:** 1.0
**Дата:** 2026-03-03
**Статус:** ✅ Активно

---

## 🎯 НАЗНАЧЕНИЕ

Управление зависимостями между задачами через DAG (Directed Acyclic Graph).

---

## 🔧 ИСПОЛЬЗОВАНИЕ

### Показать все задачи:

```powershell
.\scripts\manage-tasks-dag.ps1 -Action list
```

### Добавить задачу:

```powershell
.\scripts\manage-tasks-dag.ps1 -Action add -TaskName "New_Task" -DependsOn "PID_Files"
```

### Обновить статус:

```powershell
.\scripts\manage-tasks-dag.ps1 -Action update -TaskName "DAG_Tasks" -Status "completed"
```

### Проверить зависимости:

```powershell
.\scripts\manage-tasks-dag.ps1 -Action check
```

### Визуализировать граф:

```powershell
.\scripts\manage-tasks-dag.ps1 -Action visualize
```

---

## 📋 ДЕЙСТВИЯ

| Действие | Команда | Описание |
|----------|---------|----------|
| **list** | `-Action list` | Показать все задачи |
| **add** | `-Action add -TaskName "Name"` | Добавить задачу |
| **update** | `-Action update -TaskName "Name" -Status "completed"` | Обновить статус |
| **check** | `-Action check` | Проверить зависимости |
| **visualize** | `-Action visualize` | Визуализировать граф |

---

## 📊 СТАТУСЫ ЗАДАЧ

| Статус | Значок | Описание |
|--------|--------|----------|
| **pending** | ⏸️ | Ожидает выполнения |
| **in_progress** | ⏳ | В работе |
| **completed** | ✅ | Завершено |

---

## 🔗 ЗАВИСИМОСТИ

### Формат:

```json
{
  "DAG_Tasks": {
    "title": "DAG задач",
    "status": "in_progress",
    "depends_on": ["PID_Files"],
    "order": 3
  }
}
```

**Поля:**
- `title` — Описание задачи
- `status` — Статус (pending/in_progress/completed)
- `depends_on` — Массив зависимостей (имена задач)
- `order` — Порядок выполнения

---

## 🎯 ПРИМЕРЫ

### Пример 1: Добавление задачи

```powershell
# Добавить новую задачу
.\scripts\manage-tasks-dag.ps1 -Action add -TaskName "Test_System" -Status "pending"

# Результат:
# ✅ Задача добавлена: Test_System
```

---

### Пример 2: Обновление статуса

```powershell
# Завершить задачу
.\scripts\manage-tasks-dag.ps1 -Action update -TaskName "DAG_Tasks" -Status "completed"

# Результат:
# ✅ Статус обновлён: DAG_Tasks → completed
```

---

### Пример 3: Проверка зависимостей

```powershell
# Проверить все зависимости
.\scripts\manage-tasks-dag.ps1 -Action check

# Результат:
# ✅ Зависимости в порядке
# 📊 Итого: 0 ошибок, 0 предупреждений
```

---

### Пример 4: Визуализация

```powershell
# Показать граф
.\scripts\manage-tasks-dag.ps1 -Action visualize

# Результат:
# ✅ DAG_Tasks → PID_Files
# ⏸️ Link_Graph → DAG_Tasks
# ...
```

---

## 📁 ФАЙЛЫ

| Файл | Назначение |
|------|------------|
| **`tasks-dag.json`** | Граф задач (основной) |
| **`manage-tasks-dag.ps1`** | Скрипт управления |
| **`TASK_DAG_GUIDE.md`** | Документация |

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`tasks-dag.json`](../../tasks-dag.json) — Граф задач
- [`03-Resources/PowerShell/manage-tasks-dag.ps1`](../../03-Resources/PowerShell/manage-tasks-dag.ps1) — Скрипт
- [`FILE_PID_SYSTEM.md`](./FILE_PID_SYSTEM.md) — PID система

---

**Создано:** 2026-03-03
**Обновлено:** 2026-03-03

