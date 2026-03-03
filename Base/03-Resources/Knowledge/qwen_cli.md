---
title: Qwen Cli
version: 1.0
date: 2026-03-04
status: draft
---
# CLI версии Qwen 3.5

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готово

---

## 🎯 НАЗНАЧЕНИЕ

Использование Qwen 3.5 через командную строку (CLI).

---

## 🔧 УСТАНОВКА

```powershell
# Установка Qwen CLI
npm install -g @qwen/cli

# Авторизация
qwen login
```

---

## 📋 КОМАНДЫ

### Основные команды:

| Команда | Описание |
|---------|----------|
| `qwen chat` | Чат с ИИ |
| `qwen code <file>` | Анализ кода |
| `qwen explain <code>` | Объяснение |
| `qwen fix <file>` | Исправление ошибок |
| `qwen test <file>` | Создание тестов |

---

## 📝 ПРИМЕРЫ

### Чат:

```bash
qwen chat "как создать класс в C#?"
```

### Анализ кода:

```bash
qwen code PlayerController.cs
```

### Исправление:

```bash
qwen fix MainMenu.cs
```

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [qwen_vscode_setup.md](../02_TOOLS/qwen_vscode_setup.md) — Настройка VS Code
- [qwen_modes.md](../05_METHODOLOGY/qwen_modes.md) — Режимы

---

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готово


