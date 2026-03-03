# 📁 FILE PID SYSTEM

**Версия:** 1.0
**Дата:** 2026-03-03
**Статус:** ✅ Активно

---

## 🎯 НАЗНАЧЕНИЕ

Уникальные идентификаторы (PID) для каждого файла в системе.

---

## 🔧 ИСПОЛЬЗОВАНИЕ

### Генерация PID для файла:

```powershell
.\scripts\generate-file-pid.ps1 -Path "mcp.json" -UpdateRegistry
```

### Генерация PID для папки (рекурсивно):

```powershell
.\scripts\generate-file-pid.ps1 -Path ".\scripts\" -Recursive -UpdateRegistry -Verbose
```

### Параметры:

| Параметр | Тип | Описание |
|----------|-----|----------|
| `-Path` | string | Путь к файлу/папке |
| `-Type` | string | Тип: FILE, DIR, DOC, SCRIPT (по умолчанию: FILE) |
| `-Recursive` | switch | Рекурсивно для папок |
| `-UpdateRegistry` | switch | Обновить реестр PID |
| `-Verbose` | switch | Подробный вывод |

---

## 📊 ФОРМАТ PID

```
TYPE_HASH8_TIMESTAMP

Примеры:
  FILE_e3b0c442_20260303200833
  DIR_a1b2c3d4_20260303200834
  DOC_12345678_20260303200835
```

**Где:**
- `TYPE` — тип файла (FILE, DIR, DOC, SCRIPT)
- `HASH8` — первые 8 символов SHA-256 хэша (путь+время)
- `TIMESTAMP` — время генерации (yyyyMMddHHmmss)

---

## 📁 ХРАНЕНИЕ

### 1. Реестр PID

**Файл:** `reports/FILE_PID_REGISTRY.md`

**Формат:**
```markdown
| PID | Путь | Тип | Дата |
|-----|------|-----|------|
| FILE_e3b0c442_20260303200833 | D:\QwenPoekt\Base\mcp.json | FILE | 2026-03-03 20:08:33 |
```

### 2. .pid файлы

**Формат:** `<имя_файла>.pid`

**Пример:** `mcp.json.pid`

**Содержимое:**
```json
{
  "PID": "FILE_e3b0c442_20260303200833",
  "OriginalPath": "D:\\QwenPoekt\\Base\\mcp.json",
  "Type": "FILE",
  "GeneratedAt": "2026-03-03 20:08:33"
}
```

---

## 🔍 ПРИМЕРЫ

### Пример 1: Один файл

```powershell
# Сгенерировать PID для файла
.\scripts\generate-file-pid.ps1 -Path "package.json" -UpdateRegistry

# Результат:
# ✅ PID: FILE_abc12345_20260303201000
# ✅ Реестр обновлён
# ✅ Создан: package.json.pid
```

---

### Пример 2: Папка рекурсивно

```powershell
# Сгенерировать PID для всех файлов в папке
.\scripts\generate-file-pid.ps1 -Path ".\scripts\" -Recursive -UpdateRegistry -Verbose

# Результат:
# 📊 Найдено файлов: 78
# ✅ Сгенерировано PID: 78
# ✅ Реестр обновлён
# ✅ 78 .pid файлов создано
```

---

### Пример 3: Документы

```powershell
# Сгенерировать PID для документов с типом DOC
.\scripts\generate-file-pid.ps1 -Path "README.md" -Type "DOC" -UpdateRegistry
```

---

## 🎯 СЦЕНАРИИ ИСПОЛЬЗОВАНИЯ

### Сценарий 1: Отслеживание перемещений

**Проблема:** Файл перемещён, ссылки битые

**Решение:**
```powershell
# Найти файл по PID
Get-Content "reports/FILE_PID_REGISTRY.md" | Select-String "FILE_abc12345"

# Результат: Новый путь файла
```

---

### Сценарий 2: Поиск дубликатов

**Проблема:** Одинаковые файлы в разных местах

**Решение:**
```powershell
# Найти файлы с одинаковым хэшем
Get-Content "reports/FILE_PID_REGISTRY.md" | Select-String "_e3b0c442_"
```

---

### Сценарий 3: Аудит изменений

**Проблема:** Нужно знать, когда файл создан

**Решение:**
```powershell
# Прочитать .pid файл
Get-Content "mcp.json.pid" | ConvertFrom-Json

# Результат:
# PID: FILE_e3b0c442_20260303200833
# GeneratedAt: 2026-03-03 20:08:33
```

---

## 📊 СТАТИСТИКА

| Метрика | Значение |
|---------|----------|
| **Формат** | TYPE_HASH8_TIMESTAMP |
| **Уникальность** | 99.99% (SHA-256 первые 8 символов) |
| **Длина** | ~25 символов |
| **Читаемость** | Средняя |
| **Коллизии** | ~1 на 4 миллиарда |

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`scripts/generate-file-pid.ps1`](../../scripts/generate-file-pid.ps1) — Скрипт генерации
- [`reports/FILE_PID_REGISTRY.md`](./FILE_PID_REGISTRY.md) — Реестр PID

---

**Создано:** 2026-03-03
**Обновлено:** 2026-03-03
