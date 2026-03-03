---
title: DESIGN PATTERNS UNITY
version: 1.0
date: 2026-03-04
status: draft
---
---
status: draft
created: 2026-03-02
last_reviewed: 2026-03-02
source_book: "Level Up Your Code with Design Patterns and SOLID (Unity 6)"
---

# 📚 DESIGN PATTERNS & SOLID — КОНСПЕКТ

**Оригинал:** Level Up Your Code with Design Patterns and SOLID  
**Издатель:** Unity Technologies  
**Дата:** 2026  
**Файл:** `../../BOOK/Level_up_your_code_with_design_patterns_and_SOLID_e-book.pdf`  
**Размер:** 6.52 MB

---

## 📖 СОДЕРЖАНИЕ

1. [SOLID принципы](#solid-принципы)
2. [Порождающие паттерны](#порождающие-паттерны)
3. [Структурные паттерны](#структурные-паттерны)
4. [Поведенческие паттерны](#поведенческие-паттерны)
5. [Unity-специфичные паттерны](#unity-специфичные-паттерны)
6. [Применение в DragRaceUnity](#применение-в-dragraceunity)

---

## SOLID ПРИНЦИПЫ

### S — Single Responsibility Principle

**Принцип единственной ответственности**

**Правило:** Класс должен иметь только одну причину для изменения.

```csharp
// ❌ НЕПРАВИЛЬНО: Бог-класс
public class Player : MonoBehaviour
{
    // Движение
    public void Move() { }
    public void Jump() { }
    
    // Бой
    public void Attack() { }
    public void TakeDamage() { }
    
    // Инвентарь
    public void AddItem() { }
    public void SaveInventory() { }
    
    // UI
    public void UpdateHealthBar() { }
}

// ✅ ПРАВИЛЬНО: Разделение ответственности
public class PlayerMovement : MonoBehaviour
{
    public void Move() { }
    public void Jump() { }
}

public class PlayerCombat : MonoBehaviour
{
    public void Attack() { }
    public void TakeDamage() { }
}

public class PlayerInventory : MonoBehaviour
{
    public void AddItem() { }
    public void SaveInventory() { }
}

public class PlayerUI : MonoBehaviour
{
    public void UpdateHealthBar() { }
}
```

**Выгоды:**
- ✅ Легче тестировать
- ✅ Меньше багов при изменениях
- ✅ Понятнее код

---

### O — Open/Closed Principle

**Принцип открытости/закрытости**

**Правило:** Классы должны быть открыты для расширения, но закрыты для модификации.

```csharp
// ❌ НЕПРАВИЛЬНО: Модификация при добавлении
public class DamageCalculator
{
    public float CalculateDamage(string type, float baseDamage)
    {
        if (type == "Fire")
            return baseDamage * 1.5f;
        else if (type == "Ice")
            return baseDamage * 1.2f;
        // Нужно менять код при добавлении нового типа!
        return baseDamage;
    }
}

// ✅ ПРАВИЛЬНО: Расширение через наследование
public interface IDamageType
{
    float ModifyDamage(float baseDamage);
}

public class FireDamage : IDamageType
{
    public float ModifyDamage(float baseDamage) => baseDamage * 1.5f;
}

public class IceDamage : IDamageType
{
    public float ModifyDamage(float baseDamage) => baseDamage * 1.2f;
}

public class DamageCalculator
{
    public float CalculateDamage(IDamageType damageType, float baseDamage)
    {
        return damageType.ModifyDamage(baseDamage);
        // Можно добавлять новые типы без изменения кода!
    }
}
```

**Выгоды:**
- ✅ Не нужно менять существующий код
- ✅ Меньше регрессионных багов
- ✅ Легко добавлять новое

---

### L — Liskov Substitution Principle

**Принцип подстановки Барбары Лисков**

**Правило:** Подклассы должны заменять базовые классы без нарушения работы программы.

```csharp
// ❌ НЕПРАВИЛЬНО: Нарушение LSP
public class Bird
{
    public virtual void Fly() { }
}

public class Penguin : Bird
{
    public override void Fly()
    {
        throw new NotImplementedException("Пингвины не летают!");
    }
}

// ✅ ПРАВИЛЬНО: Разделение интерфейсов
public interface IFlyable
{
    void Fly();
}

public interface IWalkable
{
    void Walk();
}

public class Sparrow : Bird, IFlyable, IWalkable
{
    public void Fly() { /* летает */ }
    public void Walk() { /* ходит */ }
}

public class Penguin : Bird, IWalkable
{
    public void Walk() { /* ходит */ }
    // Нет метода Fly() — пингвины не летают
}
```

**Выгоды:**
- ✅ Нет неожиданных исключений
- ✅ Предсказуемое поведение
- ✅ Правильная иерархия

---

### I — Interface Segregation Principle

**Принцип разделения интерфейса**

**Правило:** Много маленьких специализированных интерфейсов лучше одного большого.

```csharp
// ❌ НЕПРАВИЛЬНО: "Жирный" интерфейс
public interface ICharacter
{
    void Move();
    void Attack();
    void UseItem();
    void Trade();
    void Craft();
    void Fish();
    // Все должны реализовывать всё!
}

public class NPC : ICharacter
{
    public void Move() { }
    public void Attack() { }
    public void UseItem() { }
    public void Trade() { }
    public void Craft() 
    { 
        throw new NotImplementedException(); 
    }
    public void Fish() 
    { 
        throw new NotImplementedException(); 
    }
}

// ✅ ПРАВИЛЬНО: Маленькие интерфейсы
public interface IMovable
{
    void Move();
}

public interface IAttacker
{
    void Attack();
}

public interface ITrader
{
    void Trade();
}

public interface ICrafter
{
    void Craft();
}

public class Player : IMovable, IAttacker, ITrader, ICrafter
{
    public void Move() { }
    public void Attack() { }
    public void Trade() { }
    public void Craft() { }
}

public class NPC : IMovable, IAttacker, ITrader
{
    public void Move() { }
    public void Attack() { }
    public void Trade() { }
    // Нет Craft() — NPC не крафтят
}
```

**Выгоды:**
- ✅ Классы реализуют только нужное
- ✅ Нет пустых реализаций
- ✅ Легче понимать

---

### D — Dependency Inversion Principle

**Принцип инверсии зависимостей**

**Правило:** Зависимость от абстракций, а не от конкретных классов.

```csharp
// ❌ НЕПРАВИЛЬНО: Зависимость от конкретики
public class Player : MonoBehaviour
{
    private MySQLDatabase _db;  // Конкретная реализация
    
    public void SaveGame()
    {
        _db.Save();  // Жёсткая зависимость
    }
}

// ✅ ПРАВИЛЬНО: Зависимость от абстракции
public interface IDatabase
{
    void Save();
    void Load();
}

public class Player : MonoBehaviour
{
    private IDatabase _db;  // Абстракция
    
    public Player(IDatabase database)
    {
        _db = database;  // Внедрение зависимости
    }
    
    public void SaveGame()
    {
        _db.Save();
    }
}

// Можно легко заменить базу данных:
public class MySQLDatabase : IDatabase { }
public class JsonDatabase : IDatabase { }
public class BinaryDatabase : IDatabase { }
```

**Выгоды:**
- ✅ Легко менять реализацию
- ✅ Легко тестировать (мок-объекты)
- ✅ Слабая связанность

---

## ПОРОЖДАЮЩИЕ ПАТТЕРНЫ

### 1. Singleton (Одиночка)

**Назначение:** Гарантирует единственный экземпляр класса.

```csharp
public class GameManager : MonoBehaviour
{
    private static GameManager _instance;
    public static GameManager Instance => _instance;
    
    private void Awake()
    {
        if (_instance != null && _instance != this)
        {
            Destroy(gameObject);
            return;
        }
        
        _instance = this;
        DontDestroyOnLoad(gameObject);
    }
}

// Использование:
GameManager.Instance.StartGame();
```

**⚠️ Предостережение:**
- Не злоупотреблять (глобальное состояние)
- Лучше использовать Dependency Injection

---

### 2. Factory Method (Фабричный метод)

**Назначение:** Создание объектов без указания конкретного класса.

```csharp
public interface IEnemy
{
    void Attack();
}

public class Goblin : IEnemy
{
    public void Attack() { /* Атака гоблина */ }
}

public class Orc : IEnemy
{
    public void Attack() { /* Атака орка */ }
}

public class EnemyFactory
{
    public IEnemy CreateEnemy(string type)
    {
        return type switch
        {
            "Goblin" => new Goblin(),
            "Orc" => new Orc(),
            _ => throw new ArgumentException($"Unknown enemy: {type}")
        };
    }
}

// Использование:
var factory = new EnemyFactory();
var enemy = factory.CreateEnemy("Goblin");
enemy.Attack();
```

---

### 3. Object Pool (Пул объектов)

**Назначение:** Переиспользование объектов вместо создания/уничтожения.

```csharp
public class ObjectPool<T> : MonoBehaviour where T : MonoBehaviour
{
    [SerializeField] private T prefab;
    [SerializeField] private int poolSize = 10;
    
    private Queue<T> _pool = new Queue<T>();
    
    private void Awake()
    {
        for (int i = 0; i < poolSize; i++)
        {
            var obj = Instantiate(prefab);
            obj.gameObject.SetActive(false);
            _pool.Enqueue(obj);
        }
    }
    
    public T Get()
    {
        if (_pool.Count > 0)
        {
            var obj = _pool.Dequeue();
            obj.gameObject.SetActive(true);
            return obj;
        }
        return Instantiate(prefab);
    }
    
    public void Return(T obj)
    {
        obj.gameObject.SetActive(false);
        _pool.Enqueue(obj);
    }
}

// Использование:
var bullet = bulletPool.Get();
bullet.Fire();
// При попадании:
bulletPool.Return(bullet);
```

**Выгоды:**
- ✅ Нет выделения памяти в runtime
- ✅ Нет сборки мусора
- ✅ Высокая производительность

---

## СТРУКТУРНЫЕ ПАТТЕРНЫ

### 1. Adapter (Адаптер)

**Назначение:** Совмещение несовместимых интерфейсов.

```csharp
// Старый API
public class OldAudioSystem
{
    public void PlaySoundOld(string soundId) { }
}

// Новый API
public interface IAudioSystem
{
    void PlaySound(string soundId);
}

// Адаптер
public class AudioAdapter : IAudioSystem
{
    private OldAudioSystem _oldSystem;
    
    public AudioAdapter(OldAudioSystem oldSystem)
    {
        _oldSystem = oldSystem;
    }
    
    public void PlaySound(string soundId)
    {
        _oldSystem.PlaySoundOld(soundId);
    }
}
```

---

### 2. Decorator (Декоратор)

**Назначение:** Динамическое добавление поведения.

```csharp
public interface IDamageable
{
    int Health { get; }
    void TakeDamage(int damage);
}

public class Player : IDamageable
{
    public int Health { get; private set; } = 100;
    
    public void TakeDamage(int damage)
    {
        Health -= damage;
    }
}

// Декоратор: Броня
public class ArmorDecorator : IDamageable
{
    private IDamageable _damageable;
    public int Armor { get; } = 50;
    
    public ArmorDecorator(IDamageable damageable)
    {
        _damageable = damageable;
    }
    
    public int Health => _damageable.Health;
    
    public void TakeDamage(int damage)
    {
        int reducedDamage = damage - Armor;
        _damageable.TakeDamage(reducedDamage);
    }
}

// Использование:
IDamageable player = new Player();
player = new ArmorDecorator(player);
player.TakeDamage(100);  // Броня уменьшит урон
```

---

### 3. Facade (Фасад)

**Назначение:** Упрощение сложной системы.

```csharp
// Сложная подсистема
public class AudioEngine { }
public class VideoEngine { }
public class NetworkEngine { }
public class SaveSystem { }

// Фасад
public class GameFacade
{
    private AudioEngine _audio;
    private VideoEngine _video;
    private NetworkEngine _network;
    private SaveSystem _save;
    
    public void StartGame()
    {
        _audio.Initialize();
        _video.Initialize();
        _network.Connect();
        _save.Load();
    }
    
    public void QuitGame()
    {
        _save.Save();
        _network.Disconnect();
        _audio.Shutdown();
        _video.Shutdown();
    }
}

// Использование:
var game = new GameFacade();
game.StartGame();  // Один вызов вместо пяти
```

---

## ПОВЕДЕНЧЕСКИЕ ПАТТЕРНЫ

### 1. Observer (Наблюдатель) / Event System

**Назначение:** Уведомление объектов об изменениях.

```csharp
// ✅ ПРАВИЛЬНО: C# события
public class Health : MonoBehaviour
{
    public event Action<int> OnHealthChanged;
    public event Action OnDied;
    
    private int _currentHealth;
    
    public void TakeDamage(int damage)
    {
        _currentHealth -= damage;
        OnHealthChanged?.Invoke(_currentHealth);
        
        if (_currentHealth <= 0)
        {
            OnDied?.Invoke();
        }
    }
}

// Подписка:
health.OnHealthChanged += UpdateHealthBar;
health.OnDied += ShowDeathScreen;
```

---

### 2. Command (Команда)

**Назначение:** Инкапсуляция запроса как объекта.

```csharp
public interface ICommand
{
    void Execute();
    void Undo();
}

public class MoveCommand : ICommand
{
    private Transform _transform;
    private Vector3 _from;
    private Vector3 _to;
    
    public MoveCommand(Transform transform, Vector3 to)
    {
        _transform = transform;
        _from = transform.position;
        _to = to;
    }
    
    public void Execute()
    {
        _transform.position = _to;
    }
    
    public void Undo()
    {
        _transform.position = _from;
    }
}

// Использование:
var command = new MoveCommand(transform, newPosition);
command.Execute();
// При необходимости:
command.Undo();
```

**Применение:**
- ✅ Система отмены (Undo/Redo)
- ✅ Очередь команд
- ✅ Повтор действий (Replay)

---

### 3. State (Состояние)

**Назначение:** Изменение поведения при изменении состояния.

```csharp
public interface IPlayerState
{
    void Move();
    void Jump();
    void Attack();
}

public class IdleState : IPlayerState
{
    public void Move() { /* Запуск анимации бега */ }
    public void Jump() { /* Прыжок */ }
    public void Attack() { /* Атака */ }
}

public class RunningState : IPlayerState
{
    public void Move() { /* Продолжение бега */ }
    public void Jump() { /* Прыжок в беге */ }
    public void Attack() { /* Атака в беге */ }
}

public class Player : MonoBehaviour
{
    private IPlayerState _state;
    
    public void SetState(IPlayerState state)
    {
        _state = state;
    }
    
    public void HandleInput()
    {
        if (Input.GetKey("w"))
            _state.Move();
        if (Input.GetKeyDown("space"))
            _state.Jump();
    }
}
```

---

## UNITY-СПЕЦИФИЧНЫЕ ПАТТЕРНЫ

### 1. Component Pattern (Компонентный паттерн)

**Назначение:** Композиция вместо наследования.

```csharp
// ❌ НЕПРАВИЛЬНО: Глубокая иерархия
public class Character : MonoBehaviour { }
public class Player : Character { }
public class Warrior : Player { }
public class Mage : Player { }

// ✅ ПРАВИЛЬНО: Компоненты
public class Health : MonoBehaviour { }
public class Movement : MonoBehaviour { }
public class Attack : MonoBehaviour { }
public class Inventory : MonoBehaviour { }

// Сборка персонажа:
var player = new GameObject("Player");
player.AddComponent<Health>();
player.AddComponent<Movement>();
player.AddComponent<Attack>();
player.AddComponent<Inventory>();
```

---

### 2. ScriptableObject Data Pattern

**Назначение:** Хранение данных вне MonoBehaviour.

```csharp
[CreateAssetMenu(fileName = "NewWeapon", menuName = "Game/Weapon")]
public class WeaponData : ScriptableObject
{
    public string weaponName;
    public int damage;
    public float attackSpeed;
    public Sprite icon;
}

public class Weapon : MonoBehaviour
{
    [SerializeField] private WeaponData _data;
    
    public void Attack()
    {
        DealDamage(_data.damage);
    }
}
```

**Выгоды:**
- ✅ Данные в Asset, не в коде
- ✅ Легко балансировать
- ✅ Переиспользование данных

---

### 3. Dependency Injection в Unity

**Назначение:** Внедрение зависимостей без Service Locator.

```csharp
// ❌ НЕПРАВИЛЬНО: Service Locator (скрытая зависимость)
public class Player : MonoBehaviour
{
    private void Start()
    {
        var audio = ServiceLocator.Get<AudioService>();
        audio.Play("jump");
    }
}

// ✅ ПРАВИЛЬНО: Constructor Injection
public class Player
{
    private readonly IAudioService _audio;
    
    public Player(IAudioService audio)
    {
        _audio = audio;
    }
    
    public void Jump()
    {
        _audio.Play("jump");
    }
}

// ✅ ПРАВИЛЬНО: Method Injection для MonoBehaviour
public class Player : MonoBehaviour
{
    private IAudioService _audio;
    
    public void Initialize(IAudioService audio)
    {
        _audio = audio;
    }
}
```

---

## ПРИМЕНЕНИЕ В DRAGRACEUNITY

### 1. Object Pool для машин

```csharp
// Создать пул для переиспользования машин
var carPool = new ObjectPool<CarController>(carPrefab, 5);

// При старте гонки:
var car = carPool.Get();
car.StartRace();

// При финише:
carPool.Return(car);
```

---

### 2. Observer для UI

```csharp
// События для UI
public class RaceManager : MonoBehaviour
{
    public event Action<float> OnSpeedChanged;
    public event Action<int> OnPositionChanged;
    public event Action OnRaceFinished;
    
    private void Update()
    {
        OnSpeedChanged?.Invoke(currentSpeed);
        OnPositionChanged?.Invoke(currentPosition);
    }
}

// UI подписывается:
raceManager.OnSpeedChanged += speedBar.SetValue;
raceManager.OnPositionChanged += positionText.SetText;
```

---

### 3. Command для управления

```csharp
// Команды для ввода
public interface ICarCommand
{
    void Execute(CarController car);
}

public class AccelerateCommand : ICarCommand
{
    public void Execute(CarController car) => car.Accelerate();
}

public class BrakeCommand : ICarCommand
{
    public void Execute(CarController car) => car.Brake();
}

// Менеджер ввода:
private ICarCommand _currentCommand;

private void Update()
{
    if (Input.GetKey("w"))
        _currentCommand = new AccelerateCommand();
    
    _currentCommand?.Execute(car);
}
```

---

### 4. State для ИИ противников

```csharp
// Состояния ИИ
public interface IOpponentState
{
    void Update(OpponentController opponent);
}

public class RacingState : IOpponentState
{
    public void Update(OpponentController o) => o.FollowTrack();
}

public class AttackingState : IOpponentState
{
    public void Update(OpponentController o) => o.ChasePlayer();
}

public class DamagedState : IOpponentState
{
    public void Update(OpponentController o) => o.SlowDown();
}
```

---

## ✅ CHECKLIST ВНЕДРЕНИЯ

### Для DragRaceUnity:

- [ ] Применить SOLID к существующим классам
- [ ] Создать ObjectPool для машин/префабов
- [ ] Внедрить Observer для UI событий
- [ ] Использовать Command для ввода
- [ ] Создать State для ИИ
- [ ] Использовать ScriptableObject для данных машин
- [ ] Внедрить Dependency Injection

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`../../03-Resources/Knowledge/03_CSHARP/CODE_STYLE.md`](./CODE_STYLE.md) — C# Style Guide
- [`../../03-Resources/Knowledge/00_CORE/csharp_standards.md`](../00_CORE/csharp_standards.md) — Стандарты C#
- [`../../reports/GITHUB_REPOSITORIES_CATALOG.md`](../reports/GITHUB_REPOSITORIES_CATALOG.md) — GitHub репозитории

---

**Статус:** ⏳ Черновик  
**Последнее обновление:** 2026-03-02  
**Следующее действие:** Применить паттерны к PROJECTS/DragRaceUnity



