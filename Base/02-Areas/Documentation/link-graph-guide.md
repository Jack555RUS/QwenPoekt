# 🔗 LINK CHECK SYSTEM

**Версия:** 1.0
**Дата:** 2026-03-03
**Статус:** ✅ Активно

---

## 🎯 НАЗНАЧЕНИЕ

Проверка битых ссылок и построение графа связей в Markdown файлах.

---

## 🔧 ИСПОЛЬЗОВАНИЕ

### Проверка ссылок:

```powershell
.\scripts\check-links.ps1 -Path "." -Recursive
```

### Построение графа связей:

```powershell
.\scripts\build-link-graph.ps1 -Path "." -Recursive
```

---

## 📋 ПАРАМЕТРЫ

### check-links.ps1

| Параметр | Тип | Описание |
|----------|-----|----------|
| `-Path` | string | Путь для сканирования (по умолчанию: ".") |
| `-Pattern` | string | Шаблон файлов (по умолчанию: "*.md") |
| `-Recursive` | switch | Рекурсивное сканирование |
| `-Verbose` | switch | Подробный вывод |

### build-link-graph.ps1

| Параметр | Тип | Описание |
|----------|-----|----------|
| `-Path` | string | Путь для сканирования |
| `-Recursive` | switch | Рекурсивное сканирование |
| `-OutputFormat` | string | Формат: markdown, graphviz, json |

---

## 📊 ОТЧЁТЫ

### LINK_CHECK_REPORT.md

**Содержит:**
- Статистику (всего/рабочих/битых)
- Список битых ссылок по файлам
- Процент рабочих ссылок

### LINK_GRAPH.md

**Содержит:**
- Узлы графа (файлы со ссылками)
- Рёбра (связи между файлами)
- Статистику графа

---

## 🎯 ПРИМЕРЫ

### Пример 1: Проверка всех файлов

```powershell
.\scripts\check-links.ps1 -Path "." -Recursive

# Результат:
# 📊 Статистика:
#   • Всего ссылок: 1131
#   • Рабочих: 283
#   • Битых: 848
#   • Процент: 25.02%
```

---

### Пример 2: Проверка одной папки

```powershell
.\scripts\check-links.ps1 -Path ".\KNOWLEDGE_BASE\" -Recursive
```

---

### Пример 3: Построение графа

```powershell
.\scripts\build-link-graph.ps1 -Path "." -Recursive

# Результат:
# ✅ Граф построен
# 📁 Отчёт: reports/LINK_GRAPH.md
```

---

## 📁 ФАЙЛЫ

| Файл | Назначение |
|------|------------|
| **`check-links.ps1`** | Проверка битых ссылок |
| **`build-link-graph.ps1`** | Построение графа связей |
| **`reports/LINK_CHECK_REPORT.md`** | Отчёт о проверке |
| **`reports/LINK_GRAPH.md`** | Граф связей |

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`scripts/check-links.ps1`](../scripts/check-links.ps1)
- [`scripts/build-link-graph.ps1`](../scripts/build-link-graph.ps1)
- [`reports/LINK_CHECK_REPORT.md`](../reports/LINK_CHECK_REPORT.md)

---

**Создано:** 2026-03-03
**Обновлено:** 2026-03-03
