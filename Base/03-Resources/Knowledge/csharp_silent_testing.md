---
title: Csharp Silent Testing
version: 1.0
date: 2026-03-04
status: draft
---
# Инструменты тихой проверки C#

**Версия:** 1.0
**Дата создания:** 2026-03-02
**Последняя проверка:** 2026-03-02
**Статус:** ✅ Активно

**Автор:** Qwen Code

---

## 🎯 НАЗНАЧЕНИЕ

Запуск тестов C# в тихом режиме без вывода консоли.

---

## 🔧 ИНСТРУМЕНТЫ

### 1. xUnit Silent Mode

**Команда:**
```bash
dotnet test --logger "console;verbosity=quiet"
```

**Параметры:**
| Параметр | Описание |
|----------|----------|
| `--logger "console;verbosity=quiet"` | Тихий вывод |
| `--no-build` | Не перестраивать |
| `--filter` | Фильтр тестов |

---

### 2. NUnit Quiet

**Команда:**
```bash
dotnet test --verbosity quiet
```

**Параметры:**
| Параметр | Описание |
|----------|----------|
| `--verbosity quiet` | Минимальный вывод |
| `--logger "console;verbosity=minimal"` | Только важные сообщения |

**Пример:**
```bash
# Тихий запуск NUnit тестов
dotnet test --verbosity quiet

# С минимальным выводом
dotnet test --logger "console;verbosity=minimal" --filter "Category=Unit"
```

---

### 3. MSTest Silent

**Команда:**
```bash
dotnet test --logger trx --results-directory TestResults
```

**Параметры:**
| Параметр | Описание |
|----------|----------|
| `--logger trx` | Формат отчёта TRX |
| `--results-directory` | Папка для результатов |

**Пример:**
```bash
# Запуск с отчётом в TRX формате
dotnet test --logger trx --results-directory TestResults --verbosity quiet

# Просмотр результатов
Get-ChildItem TestResults/*.trx | Select-Xml -XPath "//UnitTestResult" | Select-Object -First 10
```

---

## 📋 ПРИМЕРЫ

### Тихий запуск всех тестов:

```powershell
dotnet test --logger "console;verbosity=quiet" --no-build
```

### Запуск с фильтром:

```powershell
dotnet test --filter "FullyQualifiedName~MyNamespace" --verbosity quiet
```

### Запуск с отчётом:

```powershell
dotnet test --logger trx --results-directory TestResults --verbosity quiet
```

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`unity_silent_tests.md`](../02_UNITY/unity_silent_tests.md) — Unity тесты
- [`qwen_unity_testing.md`](../03_PATTERNS/qwen_unity_testing.md) — Qwen + Unity
- [`RULE_TEST_CASES.md`](../../reports/RULE_TEST_CASES.md) — Тест-кейсы для правил
- [`csharp_standards.md`](csharp_standards.md) — Стандарты кода C#
- [`PROFILES_MATRIX.md`](../../02-Areas/Documentation/PROFILES_MATRIX.md) — Матрица профилей

---

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готово



