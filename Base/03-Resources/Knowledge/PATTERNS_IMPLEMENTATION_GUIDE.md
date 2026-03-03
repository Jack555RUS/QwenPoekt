# 🛠️ РУКОВОДСТВО ПО ВНЕДРЕНИЮ ПАТТЕРНОВ

**Версия:** 1.0  
**Дата:** 2 марта 2026 г.  
**Статус:** ✅ Готово к применению

---

## 🎯 НАЗНАЧЕНИЕ

Это руководство описывает **внедрение паттернов из книг A1+B2+C2** в проект DragRaceUnity.

**Источники:**
- [`03-Resources/Knowledge/03_CSHARP/CODE_STYLE.md`](../03-Resources/Knowledge/03_CSHARP/CODE_STYLE.md) — C# Style Guide
- [`03-Resources/Knowledge/03_CSHARP/DESIGN_PATTERNS_UNITY.md`](../03-Resources/Knowledge/03_CSHARP/DESIGN_PATTERNS_UNITY.md) — Design Patterns
- [`03-Resources/Knowledge/00_CORE/UNITY_CS_REFERENCE_ANALYSIS.md`](../03-Resources/Knowledge/00_CORE/UNITY_CS_REFERENCE_ANALYSIS.md) — Unity Internals

---

## 📋 СОДЕРЖАНИЕ

1. [Внедрённые паттерны](#внедрённые-паттерны)
2. [План внедрения](#план-внедрения)
3. [Checklist](#checklist)

---

## ✅ ВНЕДРЁННЫЕ ПАТТЕРНЫ

### 1. Object Pool (Пул объектов)

**Файл:** [`PROJECTS/DragRaceUnity/Assets/03-Resources/PowerShell/Core/ObjectPool.cs`](../PROJECTS/DragRaceUnity/Assets/03-Resources/PowerShell/Core/ObjectPool.cs)

**Назначение:** Переиспользование объектов вместо создания/уничтожения.

**Применение в DragRaceUnity:**
- ✅ Машины на старте
- ✅ Эффекты (частицы, дым)
- ✅ UI элементы (уведомления)

**Использование:**
```csharp
// Создать пул
var pool = gameObject.AddComponent<ObjectPool<CarController>>();
pool._prefab = carPrefab;
pool._poolSize = 5;

// Получить машину
var car = pool.Get(startPosition, startRotation);

// Вернуть машину
pool.Return(car);
```

**Выгоды:**
- 🚀 Нет выделения памяти в runtime
- 🚀 Нет сборки мусора (GC)
- 🚀 Высокая производительность

---

### 2. Observer / Event System

**Файл:** [`PROJECTS/DragRaceUnity/Assets/03-Resources/PowerShell/Core/EventBus.cs`](../PROJECTS/DragRaceUnity/Assets/03-Resources/PowerShell/Core/EventBus.cs)

**Назначение:** Слабая связанность компонентов через события.

**Применение в DragRaceUnity:**
- ✅ UI обновляется при изменении скорости
- ✅ Финиш гонки → показать результат
- ✅ Уведомления об событиях

**Использование:**
```csharp
// Подписка (в OnEnable)
private void OnEnable()
{
    EventBus.OnSpeedChanged += UpdateSpeedBar;
    EventBus.OnRaceFinished += ShowResult;
}

// Отписка (в OnDisable)
private void OnDisable()
{
    EventBus.OnSpeedChanged -= UpdateSpeedBar;
    EventBus.OnRaceFinished -= ShowResult;
}

// Публикация
EventBus.RaiseSpeedChanged(120f);
EventBus.RaiseRaceFinished(result);
```

**Выгоды:**
- 🔗 Нет прямых ссылок между объектами
- 🔗 Легко расширять
- 🔗 Чище архитектура

---

### 3. Command (Команда)

**Файл:** [`PROJECTS/DragRaceUnity/Assets/03-Resources/PowerShell/Core/Commands.cs`](../PROJECTS/DragRaceUnity/Assets/03-Resources/PowerShell/Core/Commands.cs)

**Назначение:** Инкапсуляция запросов как объектов.

**Применение в DragRaceUnity:**
- ✅ Управление машиной (газ, тормоз, передачи)
- ✅ Поддержка Undo/Redo (для будущего)
- ✅ Запись replay гонки

**Использование:**
```csharp
// Создать команду
var command = new AccelerateCommand(car);

// Выполнить
command.Execute();

// Через CommandManager (автоматически из Update)
commandManager.SetControllable(car);
// Ввод обрабатывается автоматически
```

**Выгоды:**
- 🎮 Инкапсуляция ввода
- 🎮 Легко добавить AI
- 🎮 Поддержка replay

---

## 📋 ПЛАН ВНЕДРЕНИЯ

### Этап 1: Базовая архитектура (✅ Сделано)

- [x] Создать ObjectPool.cs
- [x] Создать EventBus.cs
- [x] Создать Commands.cs
- [x] Создать структуру папок (Core, UI, Gameplay)

---

### Этап 2: Внедрение в существующий код

#### 2.1 Обновить MainMenuController

**Файл:** `PROJECTS/DragRaceUnity/Assets/03-Resources/PowerShell/UI/MainMenuController.cs`

**Изменения:**
```csharp
// ❌ БЫЛО: Прямые ссылки
public class MainMenuController : MonoBehaviour
{
    public void OnNewGame()
    {
        // Прямой вызов сцены
        SceneManager.LoadScene("Game");
    }
}

// ✅ СТАЛО: Через события
public class MainMenuController : MonoBehaviour
{
    public void OnNewGame()
    {
        // Событие → другие объекты реагируют
        EventBus.RaiseShowNotification("Загрузка...", 1f);
        SceneManager.LoadScene("Game");
    }
}
```

---

#### 2.2 Создать CarController с IControllable

**Файл:** `PROJECTS/DragRaceUnity/Assets/03-Resources/PowerShell/Gameplay/CarController.cs`

**Код:**
```csharp
using UnityEngine;
using DragRace.Core;

namespace DragRace.Gameplay
{
    /// <summary>
    /// Контроллер машины с поддержкой команд
    /// </summary>
    public class CarController : MonoBehaviour, IControllable
    {
        [Header("Car Settings")]
        [SerializeField] private float _acceleration = 10f;
        [SerializeField] private float _maxSpeed = 200f;
        [SerializeField] private int _gearsCount = 4;
        
        private float _currentSpeed;
        private int _currentGear = 1;
        private bool _isBraking;
        
        // IControllable implementation
        public void Accelerate()
        {
            _currentSpeed += _acceleration * Time.deltaTime;
            _currentSpeed = Mathf.Min(_currentSpeed, GetMaxSpeedForGear());
            
            EventBus.RaiseSpeedChanged(_currentSpeed);
        }
        
        public void Brake()
        {
            _isBraking = true;
            _currentSpeed -= _acceleration * 2f * Time.deltaTime;
            _currentSpeed = Mathf.Max(_currentSpeed, 0f);
            
            EventBus.RaiseSpeedChanged(_currentSpeed);
        }
        
        public void ShiftUp()
        {
            if (_currentGear < _gearsCount)
            {
                _currentGear++;
                EventBus.RaiseShowNotification($"Передача {_currentGear}", 1f);
            }
        }
        
        public void ShiftDown()
        {
            if (_currentGear > 1)
            {
                _currentGear--;
                EventBus.RaiseShowNotification($"Передача {_currentGear}", 1f);
            }
        }
        
        private float GetMaxSpeedForGear()
        {
            return _maxSpeed * ((float)_currentGear / _gearsCount);
        }
        
        private void Update()
        {
            // Публикация событий
            EventBus.RaiseSpeedChanged(_currentSpeed);
        }
    }
}
```

---

#### 2.3 Создать UI для гонки

**Файл:** `PROJECTS/DragRaceUnity/Assets/03-Resources/PowerShell/UI/RaceUI.cs`

**Код:**
```csharp
using UnityEngine;
using UnityEngine.UI;
using DragRace.Core;

namespace DragRace.UI
{
    /// <summary>
    /// UI гонки (спидометр, передачи, позиция)
    /// </summary>
    public class RaceUI : MonoBehaviour
    {
        [Header("References")]
        [SerializeField] private Slider _speedBar;
        [SerializeField] private Text _gearText;
        [SerializeField] private Text _positionText;
        
        private void OnEnable()
        {
            // Подписка на события
            EventBus.OnSpeedChanged += UpdateSpeedBar;
            EventBus.OnRaceFinished += ShowFinishScreen;
        }
        
        private void OnDisable()
        {
            // Отписка
            EventBus.OnSpeedChanged -= UpdateSpeedBar;
            EventBus.OnRaceFinished -= ShowFinishScreen;
        }
        
        private void UpdateSpeedBar(float speed)
        {
            if (_speedBar != null)
            {
                _speedBar.value = speed;
            }
        }
        
        private void ShowFinishScreen(RaceResult result)
        {
            // Показать результат
            Debug.Log($"Финиш! Позиция: {result.Position}, Время: {result.Time:F2}");
        }
    }
}
```

---

### Этап 3: C# Style Guide применение

#### 3.1 Именование

**Правила из CODE_STYLE.md:**

```csharp
// ✅ ПРАВИЛЬНО:
public class PlayerController : MonoBehaviour
{
    [SerializeField] private float _speed;  // _ префикс для приватных
    public int Health { get; private set; } // PascalCase для свойств
}

// ❌ НЕПРАВИЛЬНО:
public class playerController : MonoBehaviour  // camelCase
{
    public float speed;  // публичное поле
    private int Health;  // PascalCase для приватного
}
```

---

#### 3.2 Структура файла

**Правила:**

```csharp
public class ClassName : MonoBehaviour
{
    // 1. Константы
    private const int MaxHealth = 100;
    
    // 2. Статические поля
    private static int _count;
    
    // 3. Публичные поля (сериализуемые)
    [SerializeField] private float _speed;
    
    // 4. Приватные поля
    private Rigidbody2D _rigidbody;
    
    // 5. Публичные свойства
    public int Health => _health;
    
    // 6. Unity события
    private void Awake() { }
    private void Start() { }
    private void Update() { }
    
    // 7. Публичные методы
    public void TakeDamage(int damage) { }
    
    // 8. Приватные методы
    private void ApplyGravity() { }
}
```

---

#### 3.3 Производительность

**Правила:**

```csharp
// ✅ Кэширование компонентов
private Rigidbody2D _rigidbody;

private void Awake()
{
    _rigidbody = GetComponent<Rigidbody2D>();
}

private void Update()
{
    _rigidbody.velocity = Vector2.right;  // Используем кэш
}

// ❌ Каждый кадр:
private void Update()
{
    GetComponent<Rigidbody2D>().velocity = Vector2.right;
}
```

---

## ✅ CHECKLIST

### Базовая настройка:

- [x] Создать ObjectPool.cs
- [x] Создать EventBus.cs
- [x] Создать Commands.cs
- [x] Создать структуру папок

### Внедрение:

- [ ] Создать CarController.cs с IControllable
- [ ] Создать RaceUI.cs с подпиской на события
- [ ] Обновить MainMenuController.cs
- [ ] Создать GameManager.cs (Singleton)

### C# Style Guide:

- [ ] Проверить именование всех файлов
- [ ] Проверить структуру файлов
- [ ] Проверить кэширование GetComponent
- [ ] Удалить магические числа

### Тестирование:

- [ ] Протестировать ObjectPool
- [ ] Протестировать EventBus
- [ ] Протестировать Commands
- [ ] Проверить производительность

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`03-Resources/Knowledge/03_CSHARP/CODE_STYLE.md`](../03-Resources/Knowledge/03_CSHARP/CODE_STYLE.md) — C# Style Guide
- [`03-Resources/Knowledge/03_CSHARP/DESIGN_PATTERNS_UNITY.md`](../03-Resources/Knowledge/03_CSHARP/DESIGN_PATTERNS_UNITY.md) — Design Patterns
- [`PROJECTS/DragRaceUnity/README.md`](../PROJECTS/DragRaceUnity/README.md) — Главный README проекта
- [`PROJECTS/DragRaceUnity/STATUS.md`](../PROJECTS/DragRaceUnity/STATUS.md) — Текущий статус

---

## 📝 СЛЕДУЮЩИЕ ШАГИ

1. **Создать CarController:**
   ```
   Файл: PROJECTS/DragRaceUnity/Assets/03-Resources/PowerShell/Gameplay/CarController.cs
   ```

2. **Создать RaceUI:**
   ```
   Файл: PROJECTS/DragRaceUnity/Assets/03-Resources/PowerShell/UI/RaceUI.cs
   ```

3. **Протестировать:**
   ```
   1. Создать сцену с машиной
   2. Добавить CarController
   3. Добавить CommandManager
   4. Проверить управление
   ```

---

**Файл создан:** 2 марта 2026 г.  
**Следующее обновление:** После тестирования паттернов

