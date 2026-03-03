# 📝 FILE NAMING RULE — ПРАВИЛА ИМЕНОВАНИЯ ФАЙЛОВ

**Версия:** 1.0
**Дата:** 3 марта 2026 г.
**Статус:** ✅ Активно
**Приоритет:** 🔴 Критично (обязательно к выполнению)

---

## 🎯 НАЗНАЧЕНИЕ

Это правило описывает **единый стандарт именования файлов** в проекте QwenPoekt\Base.

**Почему это важно:**
- ✅ Быстрый поиск файлов
- ✅ Консистентность в документации
- ✅ Автоматизация (скрипты предполагают единый формат)
- ✅ Избегание проблем с кодировкой (пробелы, кириллица)

---

## 📋 ОСНОВНЫЕ ПРАВИЛА

### **1. Латиница (обязательно)**

**✅ ПРАВИЛЬНО:**
- `backup-strategy.md`
- `check-links.ps1`
- `seamless-start.md`

**❌ НЕПРАВИЛЬНО:**
- `резервное-копирование.md` (кириллица)
- `стратегия-бэкапа.md` (кириллица)

---

### **2. Нижний регистр (обязательно)**

**✅ ПРАВИЛЬНО:**
- `backup-strategy.md`
- `check-kernel-integrity.ps1`

**❌ НЕПРАВИЛЬНО:**
- `Backup-Strategy.md` (верхний регистр)
- `CHECK_KERNEL_INTEGRITY.ps1` (UPPER_CASE)

---

### **3. Разделители: дефисы (kebab-case)**

**✅ ПРАВИЛЬНО:**
- `backup-strategy.md` (дефисы)
- `check-kernel-integrity.ps1` (дефисы)

**❌ НЕПРАВИЛЬНО:**
- `backup_strategy.md` (подчёркивания)
- `backupStrategy.md` (camelCase)
- `backup strategy.md` (пробелы)

---

### **4. Длина имени**

**Рекомендуется:** ≤50 символов

**✅ ПРАВИЛЬНО:**
- `check-kernel-integrity.ps1` (26 символов)
- `test-seamless-launch.ps1` (24 символа)

**❌ НЕПРАВИЛЬНО:**
- `this-is-a-very-long-filename-that-is-hard-to-read-and-should-be-avoided.md` (80+ символов)

---

### **5. Даты в формате ISO 8601**

**Формат:** `YYYY-MM-DD`

**✅ ПРАВИЛЬНО:**
- `2026-03-03-session-report.md`
- `meeting-notes-2026-03-03.md`

**❌ НЕПРАВИЛЬНО:**
- `03-03-2026-session-report.md` (американский формат)
- `20260303-session-report.md` (без разделителей)

---

## 📁 СПЕЦИФИКА ПО КАТЕГОРИЯМ

### **Документы (.md)**

**Формат:** `kebab-case.md`

**Примеры:**
- `backup-strategy.md`
- `file-naming-rule.md`
- `seamless-start.md`

---

### **Скрипты PowerShell (.ps1)**

**Формат:** `kebab-case.ps1`

**Примеры:**
- `check-links.ps1`
- `test-seamless-launch.ps1`
- `generate-file-pid.ps1`

---

### **Папки**

**Формат:** `PascalCase` (исключение!)

**Примеры:**
- `01-Projects/`
- `02-Areas/`
- `03-Resources/`
- `04-Archives/`

**Почему:** Визуальное отличие папок от файлов

---

### **Конфигурационные файлы (.json)**

**Формат:** `kebab-case.json` или точечный

**Примеры:**
- `mcp.json`
- `package.json`
- `.resume_marker.json`

---

## 🏷️ FRONT MATTER (метаданные в файлах)

**Обязательно для документов (.md):**

```markdown
---
title: Название файла на русском
version: 1.0
date: 2026-03-03
status: active | draft | archived
tags: [тег1, тег2, тег3]
---
```

**Поля:**

| Поле | Формат | Обязательно | Пример |
|------|--------|-------------|--------|
| **title** | Текст (русский) | ✅ | `Правила именования файлов` |
| **version** | Число (X.Y) | ✅ | `1.0` |
| **date** | YYYY-MM-DD | ✅ | `2026-03-03` |
| **status** | active/draft/archived | ✅ | `active` |
| **tags** | Список | ⚠️ | `[правила, имена, файлы]` |

---

## 📊 ПРИМЕРЫ

### **Пример 1: Документ**

**Файл:** `backup-strategy.md`

```markdown
---
title: Стратегия резервного копирования
version: 1.0
date: 2026-03-03
status: active
tags: [бэкап, стратегия, безопасность]
---

# 📊 BACKUP STRATEGY

**Версия:** 1.0
**Дата:** 3 марта 2026 г.

---

## 🎯 НАЗНАЧЕНИЕ
...
```

---

### **Пример 2: Скрипт**

**Файл:** `check-links.ps1`

```powershell
# check-links.ps1 — Проверка битых ссылок
# Версия: 1.0
# Дата: 2026-03-03
# Назначение: Поиск и проверка битых ссылок в Markdown

param(
    [string]$Path = ".",
    [switch]$Recursive
)

# ... код ...
```

---

### **Пример 3: Отчёт**

**Файл:** `2026-03-03-session-report.md`

```markdown
---
title: Отчёт о сессии за 3 марта 2026
version: 1.0
date: 2026-03-03
status: archived
tags: [отчёт, сессия, 2026-03-03]
---

# 📋 SESSION REPORT

**Дата:** 2026-03-03
**Сессия:** 2026-03-03_17-00

---

## ✅ ВЫПОЛНЕНО
...
```

---

## ❌ ТИПИЧНЫЕ ОШИБКИ

### **Ошибка 1: Кириллица в имени**

**❌ НЕПРАВИЛЬНО:**
- `правила-именования.md`

**✅ ПРАВИЛЬНО:**
- `file-naming-rule.md`

---

### **Ошибка 2: Пробелы**

**❌ НЕПРАВИЛЬНО:**
- `backup strategy.md`

**✅ ПРАВИЛЬНО:**
- `backup-strategy.md`

---

### **Ошибка 3: Смешанный регистр**

**❌ НЕПРАВИЛЬНО:**
- `BackupStrategy.md`
- `BACKUP_STRATEGY.md`

**✅ ПРАВИЛЬНО:**
- `backup-strategy.md`

---

### **Ошибка 4: Отсутствие front matter**

**❌ НЕПРАВИЛЬНО:**
```markdown
# Заголовок

Текст документа...
```

**✅ ПРАВИЛЬНО:**
```markdown
---
title: Заголовок на русском
version: 1.0
date: 2026-03-03
status: active
---

# Заголовок

Текст документа...
```

---

## 🛠️ ПРОВЕРКА СОБЛЮДЕНИЯ

### **Скрипт проверки:**

```powershell
# 03-Resources/PowerShell/check-file-naming.ps1
.\scripts\check-file-naming.ps1 -Path "Base/" -Recursive
```

**Что проверяет:**
- Кириллица в именах
- Пробелы в именах
- Неправильный регистр
- Отсутствие front matter

---

### **Перед коммитом:**

```powershell
# Проверка новых файлов
.\scripts\check-file-naming.ps1 -Path "." -CheckFrontMatter
```

---

## 📈 МЕТРИКИ

| Метрика | Цель | Текущее | Статус |
|---------|------|---------|--------|
| **Файлы с кириллицей** | 0 | 0 | ✅ |
| **Файлы с пробелами** | 0 | 0 | ✅ |
| **Файлы с front matter** | 100% | 0% | ❌ |
| **Единый стиль имён** | 100% | 50% | ⚠️ |

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`03-Resources/PowerShell/check-file-naming.ps1`](../03-Resources/PowerShell/check-file-naming.ps1) — Скрипт проверки
- [`PRE_ACTION_CHECKLIST.md`](../PRE_ACTION_CHECKLIST.md) — Чек-лист перед действиями
- [`08-mass-operations.md`](../.qwen/rules/08-mass-operations.md) — Массовые операции

---

**Создано:** 3 марта 2026 г.
**На основе:**
- GitHub naming conventions (GoldenLab)
- Markdown documentation best practices (2025)
- Google Developer Documentation Style Guide

---

**Правило обязательно к выполнению для всех новых файлов!** ✅

