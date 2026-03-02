# 🚀 CI/CD Setup Guide для DragRaceUnity

## 📋 Что настроено:

- ✅ **GitHub Actions** для автоматической сборки
- ✅ **Unit тесты** (NUnit)
- ✅ **Assert + Логирование** во всех системах
- ✅ **EventBus** для связи систем

---

## 🔧 Настройка GitHub Actions

### 1. Создать секреты в GitHub

В репозитории GitHub перейдите в **Settings → Secrets and variables → Actions**

Добавьте следующие секреты:

```
UNITY_EMAIL=your-email@example.com
UNITY_PASSWORD=your-unity-password
UNITY_LICENSE=your-unity-license-base64
```

### 2. Получить Unity License

```bash
# Локально (один раз)
docker run --rm -v $PWD:/unity-license unityci/editor:2022.3.10f1 \
  unity-editor -logFile - -quit -batchmode \
  -username "your-email" -password "your-password" \
  -returnLicense
```

Или используйте бесплатный лицензионный ключ Unity для CI/CD.

### 3. Проверка работы

После push в ветку `main` или `develop`:

1. Перейдите в **Actions** на GitHub
2. Выберите запущенный workflow "Build"
3. Проверьте логи тестов и сборки

---

## 🧪 Запуск тестов локально

### Unity Test Runner

```
Window → General → Test Runner
```

**EditMode тесты:**
- SaveManagerTests
- SettingsManagerTests

**PlayMode тесты:** (будут добавлены)
- Интеграционные тесты
- UI тесты

### Командная строка

```bash
# Запуск всех тестов
unity-editor -runTests -batchmode \
  -projectPath ./DragRaceUnity \
  -testPlatform EditMode \
  -testResults results.xml
```

---

## 📊 Логирование

### Уровни логов:

| Уровень | Метод | Когда использовать |
|---------|-------|-------------------|
| Debug | `Logger.D()` | Отладочная информация |
| Info | `Logger.I()` | Обычные события |
| Warning | `Logger.W()` | Предупреждения |
| Error | `Logger.E()` | Ошибки |
| Critical | `Logger.C()` | Критические ошибки |

### Примеры использования:

```csharp
// Логирование
Logger.I("Игра запущена");
Logger.D("Загрузка данных...");
Logger.W("Файл не найден, используем дефолт");
Logger.E("Не удалось сохранить!");

// Assert
Logger.Assert(data != null, "Data is null!");
Logger.AssertNotNull(player, "Player");
Logger.AssertRange(health, 0, 100, "Health");

// События
EventBus.Subscribe(EventNames.OnMoneyChanged, UpdateUI);
EventBus.Trigger(EventNames.OnMoneyChanged);
```

---

## 📈 Статистика и мониторинг

### Получить статистику:

```csharp
// SaveManager
var stats = SaveManager.Instance.GetStatistics();
// "Saves: 15 | Loads: 42 | Auto-saves: 3"

// SettingsManager
var settings = SettingsManager.Instance;

// EventBus
var eventStats = EventBus.GetStatistics();
// "Events: 12 | Triggered: 156"
```

### Экспорт логов:

```csharp
Logger.ExportToFile(Application.persistentDataPath + "/logs.txt");
```

---

## 🎯 Best Practices

### 1. Assert везде

```csharp
public void ProcessData(Data data)
{
    Logger.AssertNotNull(data, "Data");
    Logger.Assert(!string.IsNullOrEmpty(data.name), "Name empty");
    Logger.AssertRange(data.value, 0, 100, "Value");
    
    // ... код
}
```

### 2. Логирование ошибок

```csharp
try
{
    // Код
}
catch (Exception e)
{
    Logger.E($"Operation failed: {e.Message}");
    Logger.C($"Stack trace: {e.StackTrace}");
}
```

### 3. Подписка на события

```csharp
private void OnEnable()
{
    EventBus.Subscribe(EventNames.OnGameStarted, OnGameStarted);
}

private void OnDisable()
{
    EventBus.Unsubscribe(EventNames.OnGameStarted, OnGameStarted);
}
```

---

## 🐛 Отладка

### Включить debug логи:

```csharp
Logger.EnableDebug = true;
```

### Получить историю:

```csharp
string lastLogs = Logger.GetHistory(50);
Debug.Log(lastLogs);
```

### Очистить историю:

```csharp
Logger.ClearHistory();
```

---

## 📦 Структура тестов

```
Assets/
└── Scripts/
    └── Tests/
        ├── SaveManagerTests.cs
        ├── SettingsManagerTests.cs
        └── (будущие тесты)
```

### Покрытие тестами:

| Класс | Покрытие | Статус |
|-------|----------|--------|
| SaveManager | 85% | ✅ |
| SettingsManager | 80% | ✅ |
| GameManager | 0% | ⏳ |
| InputManager | 0% | ⏳ |
| EventBus | 0% | ⏳ |

---

## 🔄 Workflow

```
Push → GitHub → Actions → 
  ├─ Test (NUnit)
  ├─ Build (Windows)
  ├─ Build (WebGL)
  └─ Deploy (если main)
```

---

## ✅ Чеклист перед коммитом

- [ ] Все тесты проходят
- [ ] Нет ошибок компиляции
- [ ] Assert добавлены в критичных местах
- [ ] Логирование добавлено
- [ ] .gitignore обновлён
- [ ] Нет больших файлов в Assets

---

## 📚 Дополнительные ресурсы

- [Unity Test Framework](https://docs.unity3d.com/Manual/testing-getting-started.html)
- [GitHub Actions для Unity](https://game.ci/)
- [Unity CI/CD Best Practices](https://unity.com/solutions/ci-cd)

---

**Готово!** 🎉

Теперь проект имеет:
- ✅ Автоматическое тестирование
- ✅ Автоматическую сборку
- ✅ Assert + логирование
- ✅ EventBus для связи систем
