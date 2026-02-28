---
status: draft
created: 2026-02-28
last_reviewed: 2026-02-28
---

# 📚 DESIGN PATTERNS & SOLID — КОНСПЕКТ

**Оригинал:** Level Up Your Code with Design Patterns and SOLID  
**Издатель:** Unity Technologies  
**Файл:** [`BOOK/Level_up_your_code_with_design_patterns_and_SOLID_e-book.pdf`](../BOOK/Level_up_your_code_with_design_patterns_and_SOLID_e-book.pdf)

---

## 📖 Содержание

1. [SOLID принципы](#solid-принципы)
2. [Паттерны проектирования](#паттерны-проектирования)
3. [Примеры в Unity](#примеры-в-unity)
4. [Применение в DragRaceUnity](#применение-в-dragraceunity)

---

## 🏛️ SOLID Принципы

### S — Single Responsibility Principle (SRP)

**Принцип:** Один класс — одна ответственность.

**❌ Плохо:**
```csharp
public class Player : MonoBehaviour
{
    void Update()
    {
        // Движение
        transform.position += velocity * Time.deltaTime;
        
        // Здоровье
        if (health <= 0) Die();
        
        // Сохранение
        SaveSystem.Save(this);
        
        // UI
        uiManager.UpdateHealth(health);
    }
}
```

**✅ Хорошо:**
```csharp
public class PlayerMovement : MonoBehaviour { /* Движение */ }
public class PlayerHealth : MonoBehaviour { /* Здоровье */ }
public class PlayerSave : MonoBehaviour { /* Сохранение */ }
public class PlayerUI : MonoBehaviour { /* UI */ }
```

---

### O — Open/Closed Principle (OCP)

**Принцип:** Открыто для расширения, закрыто для изменений.

**❌ Плохо:**
```csharp
public class Enemy : MonoBehaviour
{
    public string enemyType;  // Придётся менять код для нового типа
    
    void Update()
    {
        if (enemyType == "Melee") MeleeAttack();
        else if (enemyType == "Ranged") RangedAttack();
        else if (enemyType == "Magic") MagicAttack();
    }
}
```

**✅ Хорошо:**
```csharp
public abstract class Enemy : MonoBehaviour
{
    public abstract void Attack();
}

public class MeleeEnemy : Enemy
{
    public override void Attack() => MeleeAttack();
}

public class RangedEnemy : Enemy
{
    public override void Attack() => RangedAttack();
}
```

---

### L — Liskov Substitution Principle (LSP)

**Принцип:** Подклассы должны заменять базовые классы.

**❌ Плохо:**
```csharp
public class Bird : MonoBehaviour
{
    public virtual void Move() { }
}

public class Penguin : Bird
{
    public override void Move()
    {
        throw new System.NotImplementedException();  // Пингвины не летают!
    }
}
```

**✅ Хорошо:**
```csharp
public abstract class Animal : MonoBehaviour { }

public class FlyingAnimal : Animal
{
    public virtual void Fly() { }
}

public class Bird : FlyingAnimal { }
public class Penguin : Animal { /* Не летает */ }
```

---

### I — Interface Segregation Principle (ISP)

**Принцип:** Много маленьких интерфейсов лучше одного большого.

**❌ Плохо:**
```csharp
public interface ICharacter
{
    void Attack();
    void CastSpell();
    void UseItem();
    void Trade();
}

// У воина нет магии, но вынужден реализовывать!
public class Warrior : ICharacter
{
    public void CastSpell() => throw new NotImplementedException();
}
```

**✅ Хорошо:**
```csharp
public interface IAttacker { void Attack(); }
public interface IMagicUser { void CastSpell(); }
public interface ITrader { void Trade(); }

public class Warrior : IAttacker, ITrader { }
public class Mage : IMagicUser, ITrader { }
```

---

### C — Dependency Inversion Principle (DIP)

**Принцип:** Зависимость от абстракций, а не от деталей.

**❌ Плохо:**
```csharp
public class Player : MonoBehaviour
{
    private MySQLDatabase db;  // Конкретная реализация
    
    void Save() => db.Save();
}
```

**✅ Хорошо:**
```csharp
public interface IDatabase
{
    void Save();
}

public class Player : MonoBehaviour
{
    private IDatabase db;  // Абстракция
    
    public Player(IDatabase database)
    {
        db = database;
    }
    
    void Save() => db.Save();
}
```

---

## 🎯 Паттерны проектирования

### 1. Observer (Наблюдатель)

**Назначение:** События и подписчики.

**Реализация через C# events:**
```csharp
public class HealthSystem : MonoBehaviour
{
    public event Action<int> OnHealthChanged;
    public event Action OnDied;
    
    public void TakeDamage(int damage)
    {
        health -= damage;
        OnHealthChanged?.Invoke(health);
        
        if (health <= 0)
            OnDied?.Invoke();
    }
}

// Подписка:
void OnEnable() => healthSystem.OnHealthChanged += UpdateUI;
void OnDisable() => healthSystem.OnHealthChanged -= UpdateUI;
```

**Реализация через ScriptableObject:**
```csharp
[CreateAssetMenu(menuName = "Events/GameEvent")]
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

---

### 2. Singleton (Одиночка)

**Назначение:** Единственный экземпляр.

**❌ Плохо (не потокобезопасно):**
```csharp
public class GameManager : MonoBehaviour
{
    public static GameManager Instance;
    
    void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
            Destroy(gameObject);
    }
}
```

**✅ Хорошо (ленивая инициализация):**
```csharp
public class GameManager : MonoBehaviour
{
    private static GameManager _instance;
    private static readonly object padlock = new object();
    
    public static GameManager Instance
    {
        get
        {
            lock (padlock)
            {
                if (_instance == null)
                {
                    _instance = FindObjectOfType<GameManager>();
                }
                return _instance;
            }
        }
    }
}
```

---

### 3. Factory (Фабрика)

**Назначение:** Создание объектов без указания конкретного класса.

**Пример:**
```csharp
public abstract class Enemy : MonoBehaviour
{
    public abstract void Attack();
}

public class EnemyFactory : MonoBehaviour
{
    public Enemy CreateEnemy(EnemyType type)
    {
        switch (type)
        {
            case EnemyType.Melee:
                return Instantiate(meleePrefab);
            case EnemyType.Ranged:
                return Instantiate(rangedPrefab);
            case EnemyType.Boss:
                return Instantiate(bossPrefab);
            default:
                throw new ArgumentException("Unknown enemy type");
        }
    }
}
```

---

### 4. State (Состояние)

**Назначение:** Изменение поведения при изменении состояния.

**Пример:**
```csharp
public interface IState
{
    void Enter();
    void Update();
    void Exit();
}

public class PlayerStateMachine : MonoBehaviour
{
    private IState currentState;
    
    public void ChangeState(IState newState)
    {
        currentState?.Exit();
        currentState = newState;
        currentState?.Enter();
    }
    
    void Update() => currentState?.Update();
}

// Конкретные состояния
public class IdleState : IState { /* ... */ }
public class RunningState : IState { /* ... */ }
public class JumpingState : IState { /* ... */ }
```

---

### 5. Command (Команда)

**Назначение:** Инкапсуляция запросов.

**Пример:**
```csharp
public interface ICommand
{
    void Execute();
    void Undo();
}

public class MoveCommand : ICommand
{
    private Transform transform;
    private Vector3 oldPosition;
    private Vector3 newPosition;
    
    public MoveCommand(Transform transform, Vector3 newPosition)
    {
        this.transform = transform;
        this.newPosition = newPosition;
    }
    
    public void Execute()
    {
        oldPosition = transform.position;
        transform.position = newPosition;
    }
    
    public void Undo()
    {
        transform.position = oldPosition;
    }
}

// Использование:
var command = new MoveCommand(player.transform, newPos);
command.Execute();
// При необходимости:
command.Undo();
```

---

### 6. Object Pool (Пул объектов)

**Назначение:** Переиспользование объектов вместо создания/удаления.

**Пример:**
```csharp
public class ObjectPool<T> : MonoBehaviour where T : MonoBehaviour
{
    private Queue<T> pool = new Queue<T>();
    public T prefab;
    public int initialSize = 10;
    
    void Start()
    {
        for (int i = 0; i < initialSize; i++)
        {
            T obj = Instantiate(prefab);
            obj.gameObject.SetActive(false);
            pool.Enqueue(obj);
        }
    }
    
    public T Get()
    {
        if (pool.Count > 0)
        {
            T obj = pool.Dequeue();
            obj.gameObject.SetActive(true);
            return obj;
        }
        return Instantiate(prefab);
    }
    
    public void Return(T obj)
    {
        obj.gameObject.SetActive(false);
        pool.Enqueue(obj);
    }
}
```

---

### 7. Strategy (Стратегия)

**Назначение:** Выбор алгоритма во время выполнения.

**Пример:**
```csharp
public interface IMovementStrategy
{
    void Move(Transform transform);
}

public class WalkMovement : IMovementStrategy
{
    public void Move(Transform transform)
    {
        transform.position += Vector3.forward * 5 * Time.deltaTime;
    }
}

public class RunMovement : IMovementStrategy
{
    public void Move(Transform transform)
    {
        transform.position += Vector3.forward * 10 * Time.deltaTime;
    }
}

public class Player : MonoBehaviour
{
    private IMovementStrategy movementStrategy;
    
    public void SetMovement(IMovementStrategy strategy)
    {
        movementStrategy = strategy;
    }
    
    void Update()
    {
        movementStrategy?.Move(transform);
    }
}
```

---

## 🎯 Применение в DragRaceUnity

### 1. Observer для UI

**Файл:** `Assets/Scripts/UI/UIObserver.cs`

```csharp
public class RaceUI : MonoBehaviour
{
    [SerializeField] private FloatVariable currentSpeed;
    [SerializeField] private FloatVariable maxSpeed;
    [SerializeField] private GameEvent onRaceFinish;
    
    void OnEnable()
    {
        currentSpeed.OnValueChanged += UpdateSpeedUI;
        onRaceFinish.AddListener(ShowFinishScreen);
    }
    
    void OnDisable()
    {
        currentSpeed.OnValueChanged -= UpdateSpeedUI;
        onRaceFinish.RemoveListener(ShowFinishScreen);
    }
}
```

---

### 2. State для гонок

**Файл:** `Assets/Scripts/Gameplay/RaceState.cs`

```csharp
public interface IRaceState
{
    void Start();
    void Update();
    void Finish();
}

public class RaceWaitingState : IRaceState { /* ... */ }
public class RaceCountdownState : IRaceState { /* ... */ }
public class RaceActiveState : IRaceState { /* ... */ }
public class RaceFinishedState : IRaceState { /* ... */ }

public class RaceController : MonoBehaviour
{
    private IRaceState currentState;
    
    public void ChangeState(IRaceState newState)
    {
        currentState?.Finish();
        currentState = newState;
        currentState?.Start();
    }
}
```

---

### 3. Factory для автомобилей

**Файл:** `Assets/Scripts/Gameplay/CarFactory.cs`

```csharp
public class CarFactory : MonoBehaviour
{
    [SerializeField] private CarData[] carDatas;
    [SerializeField] private GameObject[] carPrefabs;
    
    public GameObject CreateCar(CarData data)
    {
        int index = Array.IndexOf(carDatas, data);
        if (index >= 0)
        {
            return Instantiate(carPrefabs[index]);
        }
        throw new ArgumentException("Car data not found");
    }
}
```

---

### 4. Object Pool для частиц

**Файл:** `Assets/Scripts/VFX/ParticlePool.cs`

```csharp
public class ParticlePool : MonoBehaviour
{
    private Queue<ParticleSystem> pool = new Queue<ParticleSystem>();
    public ParticleSystem prefab;
    public int size = 20;
    
    void Start()
    {
        for (int i = 0; i < size; i++)
        {
            var ps = Instantiate(prefab);
            ps.Stop();
            pool.Enqueue(ps);
        }
    }
    
    public void PlayAt(Vector3 position)
    {
        if (pool.Count > 0)
        {
            var ps = pool.Dequeue();
            ps.transform.position = position;
            ps.Play();
            
            // Возврат в пул после завершения
            Invoke(nameof(ReturnToPool), ps.main.duration, ps);
        }
    }
    
    private void ReturnToPool(ParticleSystem ps)
    {
        ps.Stop();
        pool.Enqueue(ps);
    }
}
```

---

## ✅ Лучшие практики

### 1. Используй события вместо прямых ссылок

**❌ Плохо:**
```csharp
public class Player : MonoBehaviour
{
    public UIManager uiManager;  // Прямая ссылка
    
    void TakeDamage()
    {
        uiManager.UpdateHealth(health);  // Сильная связанность
    }
}
```

**✅ Хорошо:**
```csharp
public class Player : MonoBehaviour
{
    public GameEvent onHealthChanged;  // Событие
    
    void TakeDamage()
    {
        onHealthChanged.Raise();  // Слабая связанность
    }
}
```

---

### 2. Внедряй зависимости через конструктор

**❌ Плохо:**
```csharp
public class Player : MonoBehaviour
{
    private SaveSystem saveSystem = new SaveSystem();  // Жёсткая зависимость
}
```

**✅ Хорошо:**
```csharp
public class Player : MonoBehaviour
{
    private ISaveSystem saveSystem;
    
    public Player(ISaveSystem saveSystem)
    {
        this.saveSystem = saveSystem;
    }
}
```

---

### 3. Компонуй, а не наследуй

**❌ Плохо:**
```csharp
public class Enemy : MonoBehaviour { }
public class MeleeEnemy : Enemy { }
public class RangedEnemy : Enemy { }
public class BossEnemy : Enemy { }
```

**✅ Хорошо:**
```csharp
public class Health : MonoBehaviour { }
public class Attack : MonoBehaviour { }
public class MeleeAttack : Attack { }
public class RangedAttack : Attack { }

// Композиция:
// Enemy GameObject:
//   - Health
//   - MeleeAttack (или RangedAttack)
```

---

## 🔗 Связанные файлы

- [`02_UNITY/SCRIPTABLE_OBJECTS.md`](./02_UNITY/SCRIPTABLE_OBJECTS.md) — ScriptableObjects
- [`00_CORE/csharp_standards.md`](./00_CORE/csharp_standards.md) — Стандарты кода
- [`03_CSHARP/CSHARP_UNITY_TOOLS.md`](./03_CSHARP/CSHARP_UNITY_TOOLS.md) — Инструменты C#

---

## 📚 Ссылки

- [Официальная документация](https://docs.unity3d.com/Manual/BestPractice.html)
- [Unity Design Patterns](https://github.com/mikefarmer/unity-design-patterns)
- [Книга в BOOK/](../BOOK/Level_up_your_code_with_design_patterns_and_SOLID_e-book.pdf)

---

**Статус:** ⏳ Черновик (требует дополнения после прочтения книги)

**Последнее обновление:** 2026-02-28
