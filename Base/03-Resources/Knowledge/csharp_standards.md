---
title: Csharp Standards
version: 1.0
date: 2026-03-04
status: draft
---
---
status: stable
created: 2026-02-28
last_reviewed: 2026-03-02
source: Project Core
author: Project Core
version: 1.0
---
# 📝 C# STANDARDS — СТАНДАРТЫ КОДА

**Версия:** 1.0  
**Дата:** 28 февраля 2026 г.

---

## 🎯 НАЗНАЧЕНИЕ

Этот файл описывает **стандарты написания кода C#** в проекте DragRaceUnity.

**Основа:** Clean Code, SOLID, .editorconfig

---

## 📋 ОБЯЗАТЕЛЬНЫЕ ПРАВИЛА

### 1. Использование var

**Правило:** Используй `var` для явных типов.

```csharp
// ✅ ПРАВИЛЬНО:
var myList = new List<string>();
var player = GetPlayer();

// ❌ НЕПРАВИЛЬНО:
List<string> myList = new List<string>();
```

**Исключение:** Когда тип не очевиден:
```csharp
// ✅ Явный тип для читаемости:
int playerId = GetPlayerId();  // Не var, т.к. int не очевиден
```

---

### 2. Expression Body

**Правило:** Используй expression body для простых методов.

```csharp
// ✅ ПРАВИЛЬНО:
public int GetHealth() => _health;

// ❌ НЕПРАВИЛЬНО:
public int GetHealth()
{
    return _health;
}
```

---

### 3. Collection Initializers

**Правило:** Используй инициализаторы коллекций.

```csharp
// ✅ ПРАВИЛЬНО:
var numbers = new List<int> { 1, 2, 3 };

// ❌ НЕПРАВИЛЬНО:
var numbers = new List<int>();
numbers.Add(1);
numbers.Add(2);
numbers.Add(3);
```

---

### 4. Nullable Reference Types

**Правило:** Всегда указывай nullability.

```csharp
// ✅ ПРАВИЛЬНО:
public string? GetPlayerName() => _name;  // Может быть null
public string GetPlayerId() => _id;       // Не может быть null

// ❌ НЕПРАВИЛЬНО:
public string GetPlayerName() => _name;  // Неясно, может ли быть null
```

---

### 5. Async/Await

**Правило:** Используй асинхронность для I/O операций.

```csharp
// ✅ ПРАВИЛЬНО:
public async Task SaveAsync()
{
    await File.WriteAllTextAsync(path, data);
}

// ❌ НЕПРАВИЛЬНО:
public void Save()
{
    File.WriteAllText(path, data);  // Блокирует поток!
}
```

---

## 📝 ДОКУМЕНТИРОВАНИЕ

### 1. Public методы

**Правило:** Все public методы должны иметь `<summary>`.

```csharp
/// <summary>
/// Сохраняет данные игрока в файл.
/// </summary>
/// <param name="data">Данные для сохранения.</param>
/// <returns>Путь к сохранённому файлу.</returns>
public async Task<string> SaveAsync(PlayerData data)
{
    // ...
}
```

---

### 2. Private методы

**Правило:** Private методы документируются, если логика сложная.

```csharp
/// <summary>
/// Вычисляет урон с учётом брони, баффов и критического удара.
/// Формула: (baseDamage * multiplier) - armor + critBonus
/// </summary>
private int CalculateDamage() => ...;
```

---

## 🎯 НАЗВАНИЯ

### 1. Переменные

```csharp
// ✅ ПРАВИЛЬНО:
var playerHealth = 100;
var isAlive = true;
var enemies = new List<Enemy>();

// ❌ НЕПРАВИЛЬНО:
var ph = 100;      // Непонятно
var e = true;      // Непонятно
var list = ...;    // Что в списке?
```

---

### 2. Методы

```csharp
// ✅ Глагол + существительное:
public void SaveGame() { }
public Player GetPlayer() { }
public bool IsAlive() { }

// ❌ Непонятно:
public void Game() { }
public Player Player() { }
```

---

### 3. Классы

```csharp
// ✅ Существительное:
public class PlayerController { }
public class SaveSystem { }

// ❌ Не глагол:
public class Save() { }  // Класс, не метод!
```

---

## 🐛 ОБРАБОТКА ОШИБОК

### 1. Try-Catch

**Правило:** Лови конкретные исключения.

```csharp
// ✅ ПРАВИЛЬНО:
try
{
    await File.ReadAllTextAsync(path);
}
catch (FileNotFoundException ex)
{
    Debug.LogError($"Файл не найден: {path}");
}
catch (IOException ex)
{
    Debug.LogError($"Ошибка I/O: {ex.Message}");
}

// ❌ НЕПРАВИЛЬНО:
try
{
    // ...
}
catch (Exception)
{
    // Игнорируем все ошибки!
}
```

---

### 2. Логирование

**Правило:** Используй Logger.cs для единого стиля.

```csharp
// ✅ ПРАВИЛЬНО:
Logger.Info("Игра загружена");
Logger.Warning("Сохранение не найдено");
Logger.Error("Критическая ошибка", exception);

// ❌ НЕПРАВИЛЬНО:
Debug.Log("Игра загружена");
print("Ошибка");
```

---

## 📊 МЕТРИКИ КОДА

| Метрика | Значение |
|---------|----------|
| Макс. длина метода | 25 строк |
| Макс. длина класса | 500 строк |
| Макс. вложенность | 3 уровня |
| Мин. покрытие тестами | 80% |

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`csharp_fast_learning.md`](csharp_fast_learning.md) — Быстрое изучение C#
- [`ai_programming_tips.md`](../05_METHODOLOGY/ai_programming_tips.md) — Советы ИИ по программированию
- [`roslynator_cli.md`](roslynator_cli.md) — Анализ кода через CLI
- [`csharp_silent_testing.md`](csharp_silent_testing.md) — Тихие тесты C#
- [`project_glossary.md`](project_glossary.md) — Терминология проекта

---

**Правило:** Весь код следует этим стандартам! ✅

**Последнее обновление:** 28 февраля 2026 г.


