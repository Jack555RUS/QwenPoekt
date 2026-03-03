---
title: Unity Silent Tests
version: 1.0
date: 2026-03-04
status: draft
---
# Unity тесты тихий режим запуск

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готово

---

## 🎯 НАЗНАЧЕНИЕ

Запуск Unity тестов в тихом режиме без вывода Unity Editor.

---

## 🔧 КОМАНДЫ

### Тихий запуск тестов:

```bash
# Unity Test Runner CLI
Unity -batchmode -runTests -testPlatform PlayMode -silent-crashes
```

### Параметры:

| Параметр | Описание |
|----------|----------|
| `-batchmode` | Без GUI |
| `-runTests` | Запустить тесты |
| `-testPlatform PlayMode` | Play Mode тесты |
| `-silent-crashes` | Тихие падения |
| `-logFile test-results.xml` | Вывод в файл |

---

## 📋 ПРИМЕРЫ

### Запуск в тихом режиме:

```powershell
Unity -batchmode -runTests -testPlatform PlayMode -silent-crashes -logFile test-results.xml
```

### Запуск с фильтром:

```powershell
Unity -batchmode -runTests -testFilter "MyNamespace.MyTests" -logFile results.xml
```

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [csharp_silent_testing.md](../00_CORE/csharp_silent_testing.md) — C# тесты
- [qwen_unity_testing.md](../03_PATTERNS/qwen_unity_testing.md) — Qwen + Unity

---

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готово


