---
status: draft
created: 2026-02-28
last_reviewed: 2026-02-28
---

# 📚 SCRIPTABLE OBJECTS — КОНСПЕКТ

**Оригинал:** Create Modular Game Architecture in Unity with ScriptableObjects  
**Издатель:** Unity Technologies  
**Файл:** [`BOOK/create-modular-game-architecture-in-unity-with-scriptableobjects.pdf`](../BOOK/create-modular-game-architecture-in-unity-with-scriptableobjects.pdf)

---

## 📖 Содержание

1. [Что такое ScriptableObjects](#что-такое-scriptableobjects)
2. [Архитектура на ScriptableObjects](#архитектура-на-scriptableobjects)
3. [Примеры использования](#примеры-использования)
4. [Лучшие практики](#лучшие-практики)
5. [Применение в DragRaceUnity](#применение-в-dragraceunity)

---

## 🔷 Что такое ScriptableObjects

**Определение:** ScriptableObject — это контейнер данных, который существует независимо от MonoBehaviour и сцен.

**Преимущества:**
- ✅ Данные хранятся отдельно от логики
- ✅ Переиспользование между сценами
- ✅ Удобство настройки в инспекторе
- ✅ Уменьшение связанности кода

**Создание:**
```csharp
[CreateAssetMenu(fileName = "NewPlayerData", menuName = "Game/Player Data")]
public class PlayerData : ScriptableObject
{
    public string playerName;
    public int maxHealth;
    public float speed;
}
```

---

## 🏗️ Архитектура на ScriptableObjects

### Уровни архитектуры:

```
┌─────────────────────────────────┐
│     Game Events (События)       │  ← Связь между системами
├─────────────────────────────────┤
│     Variables (Переменные)      │  ← Глобальные данные
├─────────────────────────────────┤
│     Game Objects (Объекты)      │  ← Конфигурации объектов
├─────────────────────────────────┤
│     Systems (Системы)           │  ← Логика игры
└─────────────────────────────────┘
```

---

### 1. Game Events (События)

**Назначение:** Связь между системами без прямых ссылок.

**Пример:**
```csharp
[CreateAssetMenu(menuName = "Game Events/GameEvent")]
public class GameEvent : ScriptableObject
{
    private List<Action> listeners = new List<Action>();
    
    public void Raise()
    {
        for (int i = listeners.Count - 1; i >= 0; i--)
            listeners[i]?.Invoke();
    }
    
    public void AddListener(Action listener) => listeners.Add(listener);
    public void RemoveListener(Action listener) => listeners.Remove(listener);
}
```

**Использование:**
```csharp
// В любом месте:
gameEvent.Raise();  // Вызвать событие

// В подписчике:
void OnEnable() => gameEvent.AddListener(OnEvent);
void OnDisable() => gameEvent.RemoveListener(OnEvent);
```

---

### 2. Variables (Переменные)

**Назначение:** Глобальные данные, доступные из любого места.

**Пример:**
```csharp
[CreateAssetMenu(menuName = "Variables/Int Variable")]
public class IntVariable : ScriptableObject
{
    public int value;
    
    public static implicit operator int(IntVariable variable) => variable.value;
}
```

**Использование:**
```csharp
public class HealthSystem : MonoBehaviour
{
    public IntVariable maxHealth;
    public IntVariable currentHealth;
    
    void Start() => currentHealth.value = maxHealth;
}
```

---

### 3. Game Objects (Конфигурации)

**Назначение:** Настройки игровых объектов.

**Пример:**
```csharp
[CreateAssetMenu(menuName = "Game/Car Data")]
public class CarData : ScriptableObject
{
    public string carName;
    public float maxSpeed;
    public float acceleration;
    public float handling;
    public Sprite icon;
    public GameObject model;
}
```

---

## 💻 Примеры использования

### Пример 1: Система здоровья

**Событие:** `OnPlayerDamaged`

**Переменные:**
- `maxHealth` (IntVariable)
- `currentHealth` (IntVariable)

**Код:**
```csharp
public class Health : MonoBehaviour
{
    public IntVariable maxHealth;
    public IntVariable currentHealth;
    public GameEvent onPlayerDamaged;
    public GameEvent onPlayerDied;
    
    public void TakeDamage(int damage)
    {
        currentHealth.value -= damage;
        onPlayerDamaged.Raise();
        
        if (currentHealth.value <= 0)
            onPlayerDied.Raise();
    }
}
```

---

### Пример 2: Инвентарь

**Данные предмета:**
```csharp
[CreateAssetMenu(menuName = "Game/Item Data")]
public class ItemData : ScriptableObject
{
    public string itemName;
    public Sprite icon;
    public int maxStack;
    public ItemType type;
}
```

**Инвентарь:**
```csharp
public class Inventory : MonoBehaviour
{
    public List<ItemData> items = new List<ItemData>();
    public IntVariable itemCount;
    
    public void AddItem(ItemData item)
    {
        items.Add(item);
        itemCount.value = items.Count;
    }
}
```

---

### Пример 3: Волны врагов

**Данные волны:**
```csharp
[CreateAssetMenu(menuName = "Game/Wave Data")]
public class WaveData : ScriptableObject
{
    public List<EnemyData> enemies;
    public float spawnDelay;
    public int waveNumber;
}
```

**Спавнер:**
```csharp
public class WaveSpawner : MonoBehaviour
{
    public WaveData[] waves;
    public GameEvent onWaveComplete;
    
    public IEnumerator SpawnWave(int waveIndex)
    {
        WaveData wave = waves[waveIndex];
        
        foreach (var enemy in wave.enemies)
        {
            SpawnEnemy(enemy);
            yield return new WaitForSeconds(wave.spawnDelay);
        }
        
        onWaveComplete.Raise();
    }
}
```

---

## ✅ Лучшие практики

### 1. Разделяй данные и логику

**❌ Плохо:**
```csharp
public class Player : MonoBehaviour
{
    public int maxHealth = 100;  // Данные в логике
}
```

**✅ Хорошо:**
```csharp
public class Player : MonoBehaviour
{
    public IntVariable maxHealth;  // Данные в ScriptableObject
}
```

---

### 2. Используй события для связи

**❌ Плохо:**
```csharp
// Прямая ссылка
public UIManager uiManager;

void TakeDamage()
{
    uiManager.UpdateHealth();  // Сильная связанность
}
```

**✅ Хорошо:**
```csharp
// Через событие
public GameEvent onHealthChanged;

void TakeDamage()
{
    onHealthChanged.Raise();  // Слабая связанность
}
```

---

### 3. Группируй по темам

**Структура папок:**
```
Assets/
└── ScriptableObjects/
    ├── Events/
    │   ├── OnPlayerDamaged.asset
    │   └── OnWaveComplete.asset
    ├── Variables/
    │   ├── MaxHealth.asset
    │   └── PlayerSpeed.asset
    └── Game/
        ├── CarData/
        └── EnemyData/
```

---

### 4. Создавай базовые классы

**Пример:**
```csharp
// Базовый класс для всех событий
public abstract class BaseGameEvent<T> : ScriptableObject
{
    protected List<Action<T>> listeners = new List<Action<T>>();
    
    public void Raise(T value)
    {
        for (int i = listeners.Count - 1; i >= 0; i--)
            listeners[i]?.Invoke(value);
    }
}

// Конкретная реализация
public class IntEvent : BaseGameEvent<int> { }
public class StringEvent : BaseGameEvent<string> { }
```

---

## 🎯 Применение в DragRaceUnity

### 1. Данные автомобилей

**Файл:** `Assets/ScriptableObjects/CarData.cs`

```csharp
[CreateAssetMenu(menuName = "DragRace/Car Data")]
public class CarData : ScriptableObject
{
    public string carName;
    public float maxSpeed;        // Максимальная скорость
    public float acceleration;    // Ускорение
    public float handling;        // Управление
    public float weight;          // Вес
    public Sprite icon;
    public GameObject model3D;
}
```

**Использование:**
```csharp
public class CarSelector : MonoBehaviour
{
    public CarData[] availableCars;
    public CarData selectedCar;
    
    public void SelectCar(int index)
    {
        selectedCar = availableCars[index];
        // Загрузить настройки автомобиля
    }
}
```

---

### 2. События гонки

**Файл:** `Assets/ScriptableObjects/RaceEvents.cs`

```csharp
[CreateAssetMenu(menuName = "DragRace/Race Events")]
public class RaceEvent : ScriptableObject
{
    private List<Action> listeners = new List<Action>();
    
    public void Raise()
    {
        for (int i = listeners.Count - 1; i >= 0; i--)
            listeners[i]?.Invoke();
    }
    
    public void AddListener(Action listener) => listeners.Add(listener);
    public void RemoveListener(Action listener) => listeners.Remove(listener);
}
```

**События:**
- `OnRaceStart` — начало гонки
- `OnRaceFinish` — финиш
- `OnRecordTime` — новый рекорд
- `OnCarUpgraded` — улучшение автомобиля

---

### 3. Переменные прогресса

**Файл:** `Assets/ScriptableObjects/ProgressVariables.cs`

```csharp
[CreateAssetMenu(menuName = "DragRace/Variables/Int")]
public class IntVariable : ScriptableObject
{
    public int value;
}
```

**Переменные:**
- `PlayerMoney` — деньги игрока
- `PlayerLevel` — уровень
- `TotalRaces` — всего гонок
- `TotalWins` — всего побед
- `BestTime` — лучшее время

---

### 4. Настройки трасс

**Файл:** `Assets/ScriptableObjects/TrackData.cs`

```csharp
[CreateAssetMenu(menuName = "DragRace/Track Data")]
public class TrackData : ScriptableObject
{
    public string trackName;
    public float distance;          // Дистанция (1/4 мили = 402м)
    public float difficulty;        // Сложность
    public WeatherType weather;     // Погода
    public GameObject trackModel;   // Модель трассы
}
```

---

## 🔗 Связанные файлы

- [`03_CSHARP/DESIGN_PATTERNS.md`](./03_CSHARP/DESIGN_PATTERNS.md) — Паттерны проектирования
- [`00_CORE/csharp_standards.md`](./00_CORE/csharp_standards.md) — Стандарты кода
- [`03_PATTERNS/error_solutions.md`](./03_PATTERNS/error_solutions.md) — База ошибок

---

## 📚 Ссылки

- [Официальная документация](https://docs.unity3d.com/Manual/class-ScriptableObject.html)
- [Unity Sample: Scriptable Events](https://github.com/unity-samples/ScriptableEvents)
- [Книга в BOOK/](../BOOK/create-modular-game-architecture-in-unity-with-scriptableobjects.pdf)

---

**Статус:** ⏳ Черновик (требует дополнения после прочтения книги)

**Последнее обновление:** 2026-02-28
