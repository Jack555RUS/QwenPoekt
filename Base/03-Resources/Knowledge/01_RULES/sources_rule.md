---
title: Sources Rule
version: 1.0
date: 2026-03-04
status: draft
---
# 📚 SOURCES RULE — ПРАВИЛО ССЫЛОК НА ИСТОЧНИКИ

**Версия:** 1.0
**Дата:** 2026-03-04
**Статус:** ✅ Активно
**Связь:** ERR-007 (Отсутствие ссылок на источники)

---

## 🎯 НАЗНАЧЕНИЕ

Это правило требует **указания источников** для всех новых файлов.

**Почему это важно:**
- ✅ Проверяемость информации
- ✅ Уважение к авторским правам
- ✅ Возможность углубиться в тему
- ✅ Доверие к документации

---

## 📋 ТРЕБОВАНИЯ

### **Для всех новых файлов (.md):**

**Минимум один раздел с источниками:**

```markdown
## 📚 ИСТОЧНИКИ

- [Название источника](URL)
```

---

## 📖 КАТЕГОРИИ ИСТОЧНИКОВ

### **1. Книги:**

```markdown
## 📖 КНИГА

**Название:** Clean Code
**Автор:** Robert C. Martin
**Глава:** 1-3
**Страницы:** 15-45
```

---

### **2. Документация:**

```markdown
## 📚 ДОКУМЕНТАЦИЯ

- [Unity Documentation](https://docs.unity3d.com/Manual/)
- [C# Documentation](https://docs.microsoft.com/dotnet/csharp/)
```

---

### **3. GitHub репозитории:**

```markdown
## 💻 GITHUB

- [modelcontextprotocol/sdk](https://github.com/modelcontextprotocol/sdk)
- [Unity Technologies/Input](https://github.com/Unity-Technologies/Input)
```

---

### **4. Статьи и блоги:**

```markdown
## 📝 СТАТЬИ

- [Markdown Best Practices 2025](https://medium.com/...)
- [Building a Second Brain](https://tiagoforte.com/...)
```

---

### **5. Видео:**

```markdown
## 🎥 ВИДЕО

- [Unity Learn: Scripting](https://learn.unity.com/...)
```

---

## 🔍 ПРОВЕРКА

### **Перед коммитом:**

```markdown
[✅] 1. Источники указаны
[✅] 2. Ссылки рабочие
[✅] 3. Формат правильный
```

---

### **Скрипт проверки:**

```powershell
# Проверка всех .md файлов
.\scripts\test-documentation.ps1 -Path "Base/" -Recursive

# Проверка конкретных файлов
.\scripts\test-documentation.ps1 -Path "02-Areas/Documentation/"
```

---

## 📊 ПРИМЕРЫ

### **Пример 1: Правило**

```markdown
# 📝 FILE NAMING RULE

...

## 📚 ИСТОЧНИКИ

- [GitHub naming conventions](https://github.com/GoldenbergLab/naming-and-documentation-conventions)
- [Markdown Best Practices 2025](https://medium.com/...)
```

---

### **Пример 2: Отчёт**

```markdown
# 📊 MCP TEST REPORT

...

## 📚 ИСТОЧНИКИ

- [MCP Protocol Documentation](https://modelcontextprotocol.io/)
- [VS Code MCP Extension](https://marketplace.visualstudio.com/...)
```

---

### **Пример 3: Анализ**

```markdown
# 🧠 DEEP SYSTEM ANALYSIS

...

## 📚 ИСТОЧНИКИ

- [PARA Method](https://tiagoforte.com/para-method/)
- [Zettelkasten Method](https://zettelkasten.de/)
- [CODE Framework](https://buildingasecondbrain.com/)
```

---

## ⚠️ НАРУШЕНИЯ

### **ERR-007: Отсутствие ссылок на источники**

**Категория:** Документация
**Серьёзность:** 🟢 Косметика
**Статус:** ✅ Исправлено

**Решение:**
1. Добавить раздел "ИСТОЧНИКИ"
2. Указать минимум 1 источник
3. Проверить ссылки

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`file_naming_rule.md`](./file_naming_rule.md) — Именование файлов
- [`test-documentation.ps1`](../../03-Resources/PowerShell/test-documentation.ps1) — Тест документации
- [`ERROR_LOG.md`](../../ERROR_LOG.md) — Журнал ошибок (ERR-007)

---

**Создано:** 2026-03-04
**На основе:** ERR-007

---

**Правило обязательно для всех новых файлов!** ✅



