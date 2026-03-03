---
status: draft
created: 2026-03-02
last_reviewed: 2026-03-02
source_repository: "https://github.com/Unity-Technologies/UnityCsReference"
---

# 🔧 UNITY CS REFERENCE — АНАЛИЗ РЕПОЗИТОРИЯ

**Репозиторий:** https://github.com/Unity-Technologies/UnityCsReference  
**Владелец:** Unity Technologies  
**Звёзды:** 12.7k | **Форки:** 2.6k  
**Язык:** C# (100%)  
**Версия:** Unity 6000.2.0b4  
**Лицензия:** Unity Reference Only License

---

## 🎯 НАЗНАЧЕНИЕ

**UnityCsReference** — референсный исходный код C# части движка Unity и редактора.

**Для чего использовать:**
- ✅ Изучение внутренней архитектуры Unity
- ✅ Понимание работы API (Coroutine, SendMessage, etc.)
- ✅ Отладка сложных проблем (многопоточность, сериализация)
- ✅ Обучение best practices от Unity Technologies

**Ограничения:**
- ❌ Нельзя модифицировать или распространять код
- ❌ Pull requests не принимаются
- ⚠️ Код предоставляется «AS IS» без гарантий
- 🔒 Для коммерческого использования нужна отдельная лицензия

---

## 📁 СТРУКТУРА РЕПОЗИТОРИЯ

```
UnityCsReference/
├── Editor/                    # Код редактора Unity
│   ├── Inspector/             # Инспектор объектов
│   ├── Scene/                 # Сцена и иерархия
│   ├── Project/               # Проектное окно
│   └── ...                    # Другие окна редактора
│
├── External/                  # Внешние зависимости
│   ├── Newtonsoft.Json/       # JSON сериализация
│   ├── Mono.Cecil/            # IL манипуляции
│   └── ...                    # Другие библиотеки
│
├── Modules/                   # Модули движка
│   ├── CoreModule/            # Ядро (MonoBehaviour, Coroutine)
│   ├── PhysicsModule/         # Физика
│   ├── AnimationModule/       # Анимация
│   ├── UIModule/              # UI система
│   ├── SerializationModule/   # Сериализация
│   └── ...                    # Другие модули
│
├── Projects/CSharp/           # C# решение
│   └── UnityReferenceSource.sln
│
├── Runtime/                   # Runtime-код движка
│   ├── Export/                # Export API (Scripting)
│   │   └── Scripting/
│   │       ├── UnitySynchronizationContext.cs
│   │       ├── Coroutine.cs
│   │       ├── AsyncOperation.cs
│   │       └── ...
│   └── ...                    # Другие runtime компоненты
│
├── Tools/                     # Инструменты сборки
├── artifacts/                 # Артефакты сборки
├── README.md                  # Документация
├── LICENSE.md                 # Лицензия
└── third-party-notices.txt    # Уведомления сторонних библиотек
```

---

## 🔑 КЛЮЧЕВЫЕ ФАЙЛЫ И API

### 1. Ядро системы (Core)

| Файл | Назначение | Для чего полезен |
|------|------------|------------------|
| `Runtime/Export/Scripting/UnitySynchronizationContext.cs` | Синхронизация потоков | Понимание async/await в Unity |
| `Runtime/Export/Scripting/Coroutine.cs` | Coroutine машина | Как работают yield return |
| `Runtime/Export/Scripting/MonoBehaviour.cs` | Базовый класс скриптов | Жизненный цикл MonoBehaviour |
| `Runtime/Export/Scripting/AsyncOperation.cs` | Асинхронные операции | Загрузка сцен, ассетов |

---

### 2. Система сообщений

| Файл | Назначение | Для чего полезен |
|------|------------|------------------|
| `Runtime/Export/Scripting/MonoBehaviour.cs` | SendMessage, BroadcastMessage | Рефлексивные вызовы |
| `Modules/CoreModule/` | Внутренняя реализация | Оптимизация сообщений |

---

### 3. Сериализация

| Файл | Назначение | Для чего полезен |
|------|------------|------------------|
| `Modules/SerializationModule/` | Сериализация данных | Как Unity сохраняет поля |
| `Editor/Serialization/` | Редактор сериализации | CustomPropertyDrawer |

---

### 4. UI система

| Файл | Назначение | Для чего полезен |
|------|------------|------------------|
| `Modules/UIModule/` | UI Toolkit / uGUI | Создание UI элементов |
| `Editor/UIModule/` | UI Builder | Визуальный редактор |

---

### 5. Физика

| Файл | Назначение | Для чего полезен |
|------|------------|------------------|
| `Modules/PhysicsModule/` | Физический движок | Rigidbody, Collider |
| `Modules/Physics2DModule/` | 2D физика | Rigidbody2D, Collider2D |

---

## 🧠 КАК ИСПОЛЬЗОВАТЬ ДЛЯ ИЗУЧЕНИЯ

### Цель 1: Понимание архитектуры

**Что изучать:**
```
1. Открыть Modules/
2. Посмотреть структуру модулей
3. Найти зависимости между модулями
4. Понять, как CoreModule связан с другими
```

**Выводы:**
- Модули изолированы (минимальные зависимости)
- CoreModule — базовый, от него зависят все
- Каждый модуль — отдельная библиотека

---

### Цель 2: Работа с Coroutine

**Что изучать:**
```
1. Найти Runtime/Export/Scripting/Coroutine.cs
2. Изучить реализацию IEnumerator
3. Понять yield-машину
4. Найти обработку yield return null, WaitForEndOfFrame
```

**Ключевые инсайты:**
```csharp
// Внутренняя структура Coroutine
internal class Coroutine : YieldInstruction
{
    internal IEnumerator m_Routine;  // Сама корутина
    internal bool m_IsRunning;       // Флаг выполнения
}

// Обработка yield return null (ожидание 1 кадра)
if (current == null)
{
    m_CurrentCoroutineFrame = yieldFrame;
    return false;  // Продолжить в следующем кадре
}
```

**Применение в DragRaceUnity:**
- Понимать, когда Coroutine завершается
- Избегать утечек Coroutine (StartCoroutine без StopCoroutine)
- Использовать CancellationToken для отмены

---

### Цель 3: Синхронизация потоков

**Что изучать:**
```
1. Найти Runtime/Export/Scripting/UnitySynchronizationContext.cs
2. Изучить Post/Send методы
3. Понять, как async/await работает в Unity
```

**Ключевые инсайты:**
```csharp
// UnitySynchronizationContext обеспечивает выполнение
// продолжений (continuations) на основном потоке

public override void Post(SendOrPostCallback d, object state)
{
    // Добавляет вызов в очередь основного потока
    lock (m_QueueLock)
    {
        m_Queue.Enqueue(new WorkRequest(d, state));
    }
}

// При вызове из основного потока:
// Продолжение выполняется на следующем Update()
```

**Применение в DragRaceUnity:**
```csharp
// ✅ ПРАВИЛЬНО: async/await в Unity
public async Task LoadDataAsync()
{
    // Выполняется в фоне
    var data = await File.ReadAllTextAsync("save.json");
    
    // Продолжение на основном потоке (UnitySynchronizationContext)
    // Можно безопасно вызывать Unity API
    playerNameText.text = data;
}
```

---

### Цель 4: Система сообщений (SendMessage)

**Что изучать:**
```
1. Найти MonoBehaviour.SendMessage
2. Изучить реализацию через рефлексию
3. Понять производительность
```

**Ключевые инсайты:**
```csharp
// SendMessage использует рефлексию → медленно!
// Избегать в производительность-критичном коде

// ❌ МЕДЛЕННО:
gameObject.SendMessage("TakeDamage", 10);

// ✅ БЫСТРО:
var health = GetComponent<Health>();
health?.TakeDamage(10);

// ✅ ЕЩЁ БЫСТРЕЕ:
// Использовать события (event Action<int>)
```

---

### Цель 5: Сериализация полей

**Что изучать:**
```
1. Найти SerializeField атрибут
2. Изучить, как Unity сохраняет поля
3. Понять, какие типы поддерживаются
```

**Ключевые инсайты:**
```csharp
// Unity сериализует только:
// - Публичные поля
// - Приватные с [SerializeField]
// - Типы: int, float, string, Vector2, Vector3, etc.
// - UnityEngine.Object наследники
// - Serializable классы/структуры

// ❌ НЕ СЕРИАЛИЗУЕТСЯ:
private int _health;  // Приватное без атрибута

// ✅ СЕРИАЛИЗУЕТСЯ:
[SerializeField] private int _health;
public int Health;
```

---

## 💻 ПРАКТИЧЕСКОЕ ПРИМЕНЕНИЕ

### 1. Отладка async/await проблем

**Проблема:**
```csharp
// Код не работает, continuation не выполняется
public async Task StartGameAsync()
{
    await LoadSceneAsync();
    // Этот код никогда не выполняется!
    InitializeGame();
}
```

**Решение через понимание UnitySynchronizationContext:**
```csharp
// Проверить, что SynchronizationContext установлен
// Unity автоматически устанавливает UnitySynchronizationContext
// Но если используется Task.Run() без await → контекст теряется

// ✅ ПРАВИЛЬНО:
public async Task StartGameAsync()
{
    await LoadSceneAsync();  // Контекст сохраняется
    InitializeGame();        // Выполняется на основном потоке
}
```

---

### 2. Оптимизация Coroutine

**Проблема:**
```csharp
// Утечка Coroutine → память растёт
private void Start()
{
    StartCoroutine(DoSomething());  // Забыли остановить
}

private IEnumerator DoSomething()
{
    while (true)
    {
        yield return null;
    }
}
```

**Решение через понимание Coroutine internals:**
```csharp
// ✅ ПРАВИЛЬНО: Хранить ссылку и останавливать
private Coroutine _routine;

private void Start()
{
    _routine = StartCoroutine(DoSomething());
}

private void OnDestroy()
{
    if (_routine != null)
        StopCoroutine(_routine);
}

// ✅ ЛУЧШЕ: Использовать CancellationToken
private CancellationTokenSource _cts;

private void Start()
{
    _cts = new CancellationTokenSource();
    DoSomethingAsync(_cts.Token);
}

private void OnDestroy()
{
    _cts?.Cancel();
}
```

---

### 3. Понимание порядка выполнения

**Проблема:**
```csharp
// Код выполняется не в том порядке
private void Start()
{
    otherScript.DoSomething();  // otherScript ещё не инициализирован!
}
```

**Решение через понимание Script Execution Order:**
```csharp
// Изучить в UnityCsReference, как Unity вызывает:
// Awake() → OnEnable() → Start() → Update()

// ✅ ПРАВИЛЬНО: Использовать [DefaultExecutionOrder]
[DefaultExecutionOrder(-100)]  // Выполнить раньше других
public class GameManager : MonoBehaviour
{
    private void Awake()
    {
        // Инициализироваться первым
    }
}
```

---

## 📊 ТАБЛИЦА КЛЮЧЕВЫХ КЛАССОВ

| Класс | Файл | Назначение | Приоритет изучения |
|-------|------|------------|-------------------|
| **UnitySynchronizationContext** | `Runtime/Export/Scripting/` | Синхронизация потоков | 🔴 Высокий |
| **Coroutine** | `Runtime/Export/Scripting/` | Coroutine машина | 🔴 Высокий |
| **MonoBehaviour** | `Runtime/Export/Scripting/` | Базовый класс скриптов | 🔴 Высокий |
| **AsyncOperation** | `Runtime/Export/Scripting/` | Асинхронные операции | 🟡 Средний |
| **ScriptableObject** | `Runtime/` | Данные вне MonoBehaviour | 🟡 Средний |
| **SerializeField** | `Runtime/` + `Editor/` | Атрибут сериализации | 🟡 Средний |
| **SendMessage** | `Runtime/` | Рефлексивные вызовы | 🟢 Низкий |
| **Events** | `Runtime/` | Система событий | 🟡 Средний |

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`../../reports/GITHUB_REPOSITORIES_CATALOG.md`](../reports/GITHUB_REPOSITORIES_CATALOG.md) — Каталог GitHub
- [`../../03-Resources/Knowledge/00_CORE/csharp_standards.md`](../00_CORE/csharp_standards.md) — Стандарты C#
- [`../../03-Resources/Knowledge/03_CSHARP/CODE_STYLE.md`](./CODE_STYLE.md) — C# Style Guide конспект

---

## 📝 СЛЕДУЮЩИЕ ШАГИ

1. **Клонировать репозиторий:**
   ```powershell
   git clone https://github.com/Unity-Technologies/UnityCsReference
   cd UnityCsReference
   ```

2. **Открыть решение:**
   ```
   Projects/CSharp/UnityReferenceSource.sln
   ```

3. **Изучить файлы:**
   - `Runtime/Export/Scripting/UnitySynchronizationContext.cs`
   - `Runtime/Export/Scripting/Coroutine.cs`
   - `Runtime/Export/Scripting/MonoBehaviour.cs`

4. **Создать заметки:**
   - Добавить инсайты в этот файл
   - Обновить `csharp_standards.md`
   - Применить к PROJECTS/DragRaceUnity

---

**Статус:** ⏳ Черновик  
**Последнее обновление:** 2026-03-02  
**Следующее действие:** Клонировать репозиторий и изучить файлы

