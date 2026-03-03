# 🧪 Тестирование в DragRaceUnity

**Версия:** 1.0
**Дата:** 27 февраля 2026 г.

---

## 📖 Описание

В проекте настроена система тестирования через **Unity Test Framework** (UTF) на основе NUnit.

---

## 🎯 Типы тестов

### 1. Edit Mode Tests
Запускаются в редакторе Unity без входа в режим Play.

**Расположение:** `Assets/Tests/Editor/`

**Примеры:**
- `LoggerTests.cs` — тесты системы логирования
- `MainMenuControllerTests.cs` — тесты контроллера меню

### 2. Play Mode Tests
Запускаются в режиме Play (в разработке).

**Расположение:** `Assets/Tests/PlayMode/` (будет создано)

---

## 🚀 Запуск тестов

### Через Unity Editor:

```
1. Window → General → Test Runner
2. Выберите вкладку: Edit Mode или Play Mode
3. Нажмите: Run All или выберите конкретный тест
```

### Через командную строку:

```bash
# Запуск всех Edit Mode тестов
Unity.exe -batchmode -quit -projectPath "D:\QwenPoekt\PROJECTS\DragRaceUnity" -runTests -testPlatform EditMode

# Запуск всех Play Mode тестов
Unity.exe -batchmode -quit -projectPath "D:\QwenPoekt\PROJECTS\DragRaceUnity" -runTests -testPlatform PlayMode
```

---

## 📁 Структура тестов

```
Assets/Tests/
├── Editor/
│   ├── LoggerTests.cs              # Тесты Logger
│   ├── LoggerTests.cs.meta
│   ├── MainMenuControllerTests.cs  # Тесты MainMenuController
│   └── MainMenuControllerTests.cs.meta
├── Editor.meta
├── PlayMode/                       # Будет создано
└── Tests.meta
```

---

## 🧪 Описание тестов

### LoggerTests.cs

Тестирует систему логирования:

| Тест | Описание |
|------|----------|
| `Debug_WhenCalled_AddsToHistory` | Проверка добавления Debug логов |
| `Info_WhenCalled_AddsToHistory` | Проверка добавления Info логов |
| `Warning_WhenCalled_AddsToHistory` | Проверка добавления Warning логов |
| `Error_WhenCalled_AddsToHistory` | Проверка добавления Error логов |
| `Log_WhenLevelBelowThreshold_DoesNotAddToHistory` | Фильтрация по уровню |
| `Log_WhenDisabled_DoesNotAddToHistory` | Отключение логирования |
| `GetHistory_WithCount_ReturnsCorrectNumberOfItems` | Получение истории |
| `ClearHistory_WhenCalled_RemovesAllEntries` | Очистка истории |
| `GetHistory_WhenExceedsMaxSize_RemovesOldestEntries` | Ограничение размера истории |
| `Log_WhenCalled_TriggersOnLogAddedEvent` | Событие OnLogAdded |
| `Log_WithCustomPrefix_UsesCorrectPrefix` | Кастомный префикс |
| `Log_IncludesTimestamp` | Наличие временной метки |

### MainMenuControllerTests.cs

Тестирует контроллер главного меню:

| Тест | Описание |
|------|----------|
| `OnNewGame_WhenCalled_LogsCorrectMessage` | Кнопка "Новая игра" |
| `OnContinue_WhenCalled_LogsCorrectMessage` | Кнопка "Продолжить" |
| `OnSave_WhenCalled_LogsCorrectMessage` | Кнопка "Сохранить" |
| `OnLoad_WhenCalled_LogsCorrectMessage` | Кнопка "Загрузить" |
| `OnSettings_WhenCalled_LogsCorrectMessage` | Кнопка "Настройки" |
| `OnExit_WhenCalled_LogsCorrectMessage` | Кнопка "Выход" |
| `Start_WhenCalled_LogsInitializationMessage` | Инициализация меню |
| `ButtonHandlers_UseInfoLevel_ForUserActions` | Уровень логов для действий |
| `PrivateHandlers_UseDebugLevel_ForInternalLogic` | Уровень логов для внутренней логики |
| `MultipleButtonClicks_LogAllActions` | Серия нажатий кнопок |
| `Controller_WhenCreated_HasValidReference` | Проверка создания контроллера |

---

## 📊 Покрытие тестами

### Покрыто тестами:

| Компонент | Статус | Файл теста |
|-----------|--------|------------|
| **Logger** | ✅ 100% | LoggerTests.cs |
| **MainMenuController** | ✅ 100% | MainMenuControllerTests.cs |

### В планах:

| Компонент | Статус | Файл теста |
|-----------|--------|------------|
| **SaveSystem** | ⏸️ В планах | SaveSystemTests.cs |
| **GameManager** | ⏸️ В планах | GameManagerTests.cs |
| **CarController** | ⏸️ В планах | CarControllerTests.cs |

---

## 🔧 Настройка тестов

### Edit Mode Tests

Тесты для логики, не требующей игрового контекста:

```csharp
using NUnit.Framework;

[TestFixture]
public class MyTests
{
    [SetUp]
    public void SetUp()
    {
        // Инициализация перед каждым тестом
    }

    [TearDown]
    public void TearDown()
    {
        // Очистка после каждого теста
    }

    [Test]
    public void Test_WhenCalled_ReturnsExpectedResult()
    {
        // Arrange
        // Act
        // Assert
    }
}
```

### Play Mode Tests

Тесты для игровой логики:

```csharp
using NUnit.Framework;
using UnityEngine.TestTools;
using System.Collections;

[TestFixture]
public class MyPlayModeTests
{
    [UnityTest]
    public IEnumerator Test_WithWait_ReturnsExpectedResult()
    {
        // Arrange
        yield return null; // Пропуск кадра
        // Act
        yield return null;
        // Assert
    }
}
```

---

## 🐛 Отладка тестов

### Логи в тестах

Используйте Logger для отладки:

```csharp
[Test]
public void MyTest()
{
    Logger.Debug("Начало теста");
    // ... код теста
    Logger.Info("Тест завершён");
}
```

### Проверка логов в тестах

```csharp
[Test]
public void Test_LogsCorrectMessage()
{
    // Arrange
    Logger.ClearHistory();

    // Act
    Logger.Info("Test message");

    // Assert
    var history = Logger.GetHistory();
    Assert.That(history[0], Does.Contain("Test message"));
}
```

---

## 📈 Метрики качества

### Требования к тестам:

- ✅ Все тесты должны проходить (100% pass rate)
- ✅ Время выполнения одного теста < 1 секунды
- ✅ Покрытие критического кода > 80%
- ✅ Тесты должны быть независимыми
- ✅ Тесты должны быть повторяемыми

### Запуск перед коммитом:

```
1. Window → General → Test Runner
2. Run All
3. Убедитесь, что все тесты прошли
```

---

## 📚 Дополнительные ресурсы

- [Unity Test Framework Documentation](https://docs.unity3d.com/Packages/com.unity.test-framework@1.1/manual/index.html)
- [NUnit Documentation](https://docs.nunit.org/articles/nunit/intro.html)
- [Test-Driven Development in Unity](https://learn.unity.com/project/unit-testing-in-unity)

---

**Запустите тесты перед коммитом!** 🎯
