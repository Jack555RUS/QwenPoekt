---
title: CODE STYLE
version: 1.0
date: 2026-03-04
status: draft
---
---
status: draft
created: 2026-03-02
last_reviewed: 2026-03-02
source_book: "Use a C# Style Guide for Clean and Scalable Game Code (Unity 6)"
---

# 📚 C# STYLE GUIDE — КОНСПЕКТ

**Оригинал:** Use a C# Style Guide for Clean and Scalable Game Code (Unity 6 Edition)  
**Издатель:** Unity Technologies  
**Дата:** 2026  
**Файл:** `../../BOOK/Use_a_C__style_guide_for_clean_and_scalable_game_code_Unity_6_edition_e-book.pdf`  
**Размер:** 3.62 MB

---

## 📖 СОДЕРЖАНИЕ

1. [Введение](#введение)
2. [Соглашения об именовании](#именование)
3. [Структура файлов и организация кода](#структура-файлов)
4. [Чистый код и читаемость](#чистый-код)
5. [Производительность](#производительность)
6. [Архитектурные паттерны](#архитектурные-паттерны)
7. [Best Practices для Unity](#best-practices-для-unity)

---

## ВВЕДЕНИЕ

### Зачем нужен style guide?

**Проблемы без стандартов:**
- ❌ Разный стиль в команде → сложно читать
- ❌ inconsistent naming → путаница
- ❌ Сложно поддерживать → технический долг
- ❌ Code review занимает больше времени

**Решения со стандартами:**
- ✅ Единый стиль → быстро читается
- ✅ Предсказуемая структура → легко найти
- ✅ Меньше ошибок → чище код
- ✅ Быстрые code review → фокус на логике

---

## ИМЕНОВАНИЕ

### 1. Классы и структуры

**Правило:** PascalCase, существительные

```csharp
// ✅ ПРАВИЛЬНО:
public class PlayerController { }
public struct GameState { }
public interface IDamageable { }

// ❌ НЕПРАВИЛЬНО:
public class playerController { }  // camelCase
public class Playercontroller { }  // нет разделения
```

### 2. Методы

**Правило:** PascalCase, глаголы

```csharp
// ✅ ПРАВИЛЬНО:
public void MovePlayer() { }
public int CalculateDamage() { }
public bool IsAlive() { }

// ❌ НЕПРАВИЛЬНО:
public void movePlayer() { }  // camelCase
public void PlayerMove() { }  // существительное
```

### 3. Поля (переменные)

**Правило:** camelCase, существительные

```csharp
// ✅ ПРАВИЛЬНО:
private int _health;
private string _playerName;
private List<GameObject> _enemies;

// ❌ НЕПРАВИЛЬНО:
private int Health;  // PascalCase
private int h;       // непонятно
```

### 4. Приватные поля

**Правило:** `_` префикс + camelCase

```csharp
// ✅ ПРАВИЛЬНО:
private Rigidbody2D _rigidbody;
private AudioSource _audioSource;

// ❌ НЕПРАВИЛЬНО:
private Rigidbody2D rigidbody;     // конфликт с property
private Rigidbody2D m_Rigidbody;   // Hungarian notation (устарело)
```

### 5. Свойства (Properties)

**Правило:** PascalCase

```csharp
// ✅ ПРАВИЛЬНО:
public int Health { get; private set; }
public string PlayerName { get; set; }

// ❌ НЕПРАВИЛЬНО:
public int health { get; set; }  // camelCase
```

### 6. Константы

**Правило:** PascalCase (не UPPER_CASE!)

```csharp
// ✅ ПРАВИЛЬНО:
public const int MaxHealth = 100;
public const float Gravity = -9.81f;

// ❌ НЕПРАВИЛЬНО:
public const int MAX_HEALTH = 100;  // C# не Java
```

### 7. Интерфейсы

**Правило:** I + PascalCase

```csharp
// ✅ ПРАВИЛЬНО:
public interface IDamageable { }
public interface IInteractable { }

// ❌ НЕПРАВИЛЬНО:
public interface Damageable { }  // нет префикса
public interface IDamageableInterface { }  // избыточно
```

---

## СТРУКТУРА ФАЙЛОВ

### 1. Порядок членов класса

**Правило:** От публичного к приватному, от данных к методам

```csharp
public class PlayerController : MonoBehaviour
{
    // 1. Константы
    private const int MaxHealth = 100;
    
    // 2. Статические поля
    private static int _playerCount = 0;
    
    // 3. Публичные поля (сериализуемые)
    [SerializeField] private float _speed = 5f;
    [SerializeField] private int _health = 100;
    
    // 4. Приватные поля
    private Rigidbody2D _rigidbody;
    private Animator _animator;
    
    // 5. Публичные свойства
    public int Health => _health;
    public bool IsAlive => _health > 0;
    
    // 6. Unity события (Awake, Start, Update)
    private void Awake() { }
    private void Start() { }
    private void Update() { }
    
    // 7. Публичные методы
    public void TakeDamage(int damage) { }
    public void Heal(int amount) { }
    
    // 8. Приватные методы
    private void ApplyGravity() { }
    private void CheckGrounded() { }
    
    // 9. Вложенные классы
    private class PlayerState { }
}
```

### 2. Размер файла

**Правило:** ≤ 500 строк (идеал), ≤ 1000 строк (максимум)

**Если больше:**
- Выделить подкласс
- Использовать композицию
- Разделить на partial классы

---

## ЧИСТЫЙ КОД

### 1. Принцип единой ответственности (SRP)

**Правило:** Один класс = одна ответственность

```csharp
// ❌ НЕПРАВИЛЬНО: Бог-класс
public class Player : MonoBehaviour
{
    // Движение
    private void Move() { }
    private void Jump() { }
    
    // Бой
    private void Attack() { }
    private void TakeDamage() { }
    
    // Инвентарь
    private void AddItem() { }
    private void RemoveItem() { }
    
    // UI
    private void UpdateHealthBar() { }
    private void ShowDamagePopup() { }
}

// ✅ ПРАВИЛЬНО: Разделение
public class PlayerMovement : MonoBehaviour { }
public class PlayerCombat : MonoBehaviour { }
public class PlayerInventory : MonoBehaviour { }
public class PlayerUI : MonoBehaviour { }
```

### 2. Избегайте магических чисел

```csharp
// ❌ НЕПРАВИЛЬНО:
if (health < 100) { }
speed = 5.5f;

// ✅ ПРАВИЛЬНО:
private const int MaxHealth = 100;
private const float BaseSpeed = 5.5f;

if (health < MaxHealth) { }
speed = BaseSpeed;
```

### 3. Ранний возврат (Early Return)

```csharp
// ❌ НЕПРАВИЛЬНО: Глубокая вложенность
public void ProcessAttack()
{
    if (isAttacking)
    {
        if (hasAmmo)
        {
            if (targetInRange)
            {
                // Атака...
            }
        }
    }
}

// ✅ ПРАВИЛЬНО: Ранний возврат
public void ProcessAttack()
{
    if (!isAttacking) return;
    if (!hasAmmo) return;
    if (!targetInRange) return;
    
    // Атака...
}
```

### 4. Понятные имена переменных

```csharp
// ❌ НЕПРАВИЛЬНО:
int d;  // что это?
List<GameObject> l;

// ✅ ПРАВИЛЬНО:
int damage;
List<GameObject> enemies;
```

---

## ПРОИЗВОДИТЕЛЬНОСТЬ

### 1. Избегайте выделения памяти в Update

```csharp
// ❌ НЕПРАВИЛЬНО:
private void Update()
{
    var list = new List<GameObject>();  // выделение каждый кадр
    string text = "Health: " + health;   // строка каждый кадр
}

// ✅ ПРАВИЛЬНО:
private List<GameObject> _cachedList;
private StringBuilder _healthText;

private void Awake()
{
    _cachedList = new List<GameObject>();
    _healthText = new StringBuilder();
}

private void Update()
{
    _cachedList.Clear();  // переиспользование
    _healthText.Clear();
    _healthText.Append("Health: ");
    _healthText.Append(health);
}
```

### 2. Кэширование компонентов

```csharp
// ❌ НЕПРАВИЛЬНО:
private void Update()
{
    GetComponent<Rigidbody2D>().velocity = Vector2.right * speed;
}

// ✅ ПРАВИЛЬНО:
private Rigidbody2D _rigidbody;

private void Awake()
{
    _rigidbody = GetComponent<Rigidbody2D>();
}

private void Update()
{
    _rigidbody.velocity = Vector2.right * speed;
}
```

### 3. Избегайте string конкатенации

```csharp
// ❌ НЕПРАВИЛЬНО:
string message = "Player " + playerName + " scored " + score + " points!";

// ✅ ПРАВИЛЬНО:
string message = $"Player {playerName} scored {score} points!";

// ✅ ДЛЯ ЧАСТЫХ ОПЕРАЦИЙ:
var sb = new StringBuilder();
sb.Append("Player ");
sb.Append(playerName);
sb.Append(" scored ");
sb.Append(score);
sb.Append(" points!");
```

### 4. Используйте Span<T> для работы с памятью

```csharp
// ✅ Unity 6 / .NET Standard 2.1+:
Span<int> numbers = stackalloc int[100];  // на стеке, не в куче
```

---

## АРХИТЕКТУРНЫЕ ПАТТЕРНЫ

### 1. Dependency Injection

```csharp
// ❌ НЕПРАВИЛЬНО: Жёсткая зависимость
public class Player : MonoBehaviour
{
    private void Start()
    {
        var audioSource = GetComponent<AudioSource>();
        audioSource.Play();
    }
}

// ✅ ПРАВИЛЬНО: Внедрение зависимости
public class Player : MonoBehaviour
{
    [SerializeField] private AudioSource _audioSource;
    
    // Или через конструктор (для не-MonoBehaviour)
    public Player(AudioSource audioSource)
    {
        _audioSource = audioSource;
    }
}
```

### 2. Event-driven архитектура

```csharp
// ❌ НЕПРАВИЛЬНО: Прямые ссылки
public class Enemy : MonoBehaviour
{
    private Player _player;
    
    private void Die()
    {
        _player.AddScore(100);  // жёсткая связь
    }
}

// ✅ ПРАВИЛЬНО: События
public class EnemyDiedEvent
{
    public int Score { get; } = 100;
}

public class Enemy : MonoBehaviour
{
    private void Die()
    {
        EventBus.Raise(new EnemyDiedEvent());  // слабая связь
    }
}

public class ScoreManager : MonoBehaviour
{
    private void OnEnable()
    {
        EventBus.Subscribe<EnemyDiedEvent>(OnEnemyDied);
    }
    
    private void OnEnemyDied(EnemyDiedEvent e)
    {
        AddScore(e.Score);
    }
}
```

### 3. ScriptableObject для данных

```csharp
// ❌ НЕПРАВИЛЬНО: Хардкод в коде
public class Weapon
{
    public int Damage = 25;
    public float FireRate = 0.1f;
}

// ✅ ПРАВИЛЬНО: ScriptableObject
[CreateAssetMenu]
public class WeaponData : ScriptableObject
{
    public int Damage;
    public float FireRate;
    public Sprite Icon;
}

public class Weapon : MonoBehaviour
{
    [SerializeField] private WeaponData _weaponData;
    
    public void Fire()
    {
        DealDamage(_weaponData.Damage);
    }
}
```

---

## BEST PRACTICES ДЛЯ UNITY

### 1. MonoBehaviour vs Обычные классы

```csharp
// ❌ НЕПРАВИЛЬНО: MonoBehaviour без нужды
public class DataManager : MonoBehaviour
{
    public void Calculate() { }  // не использует MonoBehaviour
}

// ✅ ПРАВИЛЬНО: Обычный класс
public class DataManager
{
    public void Calculate() { }
}

// ✅ MonoBehaviour ТОЛЬКО если нужно:
// - Update(), Awake(), Start()
// - GetComponent, StartCoroutine
// - Сериализация в Inspector
```

### 2. Сериализация полей

```csharp
// ✅ ПРАВИЛЬНО:
[SerializeField] private float _speed;  // приватное, видно в Inspector
public float Speed => _speed;           // публичный read-only

// ❌ НЕПРАВИЛЬНО:
public float speed;  // публичное поле (нарушает инкапсуляцию)
```

### 3. CompareTag вместо string

```csharp
// ❌ НЕПРАВИЛЬНО: Выделение строки
if (gameObject.tag == "Enemy") { }

// ✅ ПРАВИЛЬНО:
if (CompareTag("Enemy")) { }

// ✅ ЛУЧШЕ:
if (CompareTag(TagConstants.Enemy)) { }
```

### 4. Физика и Update

```csharp
// ❌ НЕПРАВИЛЬНО: Физика в Update
private void Update()
{
    _rigidbody.velocity = Vector2.right;
}

// ✅ ПРАВИЛЬНО: Физика в FixedUpdate
private void FixedUpdate()
{
    _rigidbody.velocity = Vector2.right;
}
```

---

## ✅ CHECKLIST ВНЕДРЕНИЯ

### Для DragRaceUnity:

- [ ] Переименовать поля с `_` префиксом
- [ ] Вынести константы из кода
- [ ] Кэшировать GetComponent вызовы
- [ ] Избегать выделения памяти в Update
- [ ] Разделить большие классы (>500 строк)
- [ ] Использовать ScriptableObject для данных
- [ ] Внедрить событийную архитектуру
- [ ] Проверить все MonoBehaviour на необходимость

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`../../03-Resources/Knowledge/00_CORE/csharp_standards.md`](../00_CORE/csharp_standards.md) — Стандарты C#
- [`../../03-Resources/Knowledge/01_RULES/file_naming_rule.md`](../01_RULES/file_naming_rule.md) — Именование файлов
- [`../../reports/GITHUB_REPOSITORIES_CATALOG.md`](./GITHUB_REPOSITORIES_CATALOG.md) — GitHub репозитории

---

**Статус:** ⏳ Черновик  
**Последнее обновление:** 2026-03-02  
**Следующее действие:** Применить к PROJECTS/DragRaceUnity



