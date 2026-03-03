# 🧠 UNITYCSREFERENCE — ГЛУБОКИЙ АНАЛИЗ

**Дата анализа:** 2 марта 2026 г.  
**Репозиторий:** https://github.com/Unity-Technologies/UnityCsReference  
**Версия:** Unity 6000.x

---

## 📊 ОБЗОР

**Проанализировано файлов:**
1. ✅ `UnitySynchronizationContext.cs` — синхронизация потоков
2. ✅ `Coroutines.cs` — управление корутинами
3. ✅ `MonoBehaviour.bindings.cs` — жизненный цикл

**Ключевые инсайты:**
- async/await выполняется на основном потоке через UnitySynchronizationContext
- Корутины используют IEnumerator и SetupCoroutine.InvokeMoveNext
- MonoBehaviour имеет встроенный CancellationToken для уничтожения

---

## 🔧 1. UNITYSYNCHRONIZATIONCONTEXT

### Назначение
**Синхронизация выполнения кода на основном потоке Unity.**

### Устройство

```csharp
internal sealed class UnitySynchronizationContext : SynchronizationContext
{
    private readonly List<WorkRequest> m_AsyncWorkQueue;      // Очередь работ
    private readonly List<WorkRequest> m_CurrentFrameWork;    // Текущий кадр
    private readonly int m_MainThreadID;                       // ID основного потока
}
```

### Ключевые методы

#### 1.1 Post (асинхронное выполнение)

```csharp
public override void Post(SendOrPostCallback callback, object state)
{
    lock (m_AsyncWorkQueue)
    {
        m_AsyncWorkQueue.Add(new WorkRequest(callback, state));
    }
}
```

**Как работает:**
1. Добавляет работу в очередь `m_AsyncWorkQueue`
2. Не блокирует текущий поток
3. Выполнится на основном потоке в следующем кадре

**Пример использования:**
```csharp
// Из фонового потока
var context = SynchronizationContext.Current;
context.Post(_ => {
    // Выполнится на основном потоке
    gameObject.SetActive(true);
}, null);
```

---

#### 1.2 Send (синхронное выполнение)

```csharp
public override void Send(SendOrPostCallback callback, object state)
{
    if (m_MainThreadID == Thread.CurrentThread.ManagedThreadId)
    {
        callback(state);  // Сразу выполняем
    }
    else
    {
        using (var waitHandle = new ManualResetEvent(false))
        {
            lock (m_AsyncWorkQueue)
            {
                m_AsyncWorkQueue.Add(new WorkRequest(callback, state, waitHandle));
            }
            waitHandle.WaitOne();  // Ждём выполнения
        }
    }
}
```

**Как работает:**
1. Если уже на основном потоке → выполняет сразу
2. Если на фоновом → добавляет в очередь и ждёт
3. Блокирует выполнение до завершения

---

#### 1.3 Exec (обработка очереди)

```csharp
public void Exec()
{
    lock (m_AsyncWorkQueue)
    {
        m_CurrentFrameWork.AddRange(m_AsyncWorkQueue);
        m_AsyncWorkQueue.Clear();
    }

    while (m_CurrentFrameWork.Count > 0)
    {
        WorkRequest work = m_CurrentFrameWork[0];
        m_CurrentFrameWork.RemoveAt(0);
        work.Invoke();
    }
}
```

**Когда вызывается:**
- В PlayerLoop (каждый кадр)
- Обработает все отложенные работы

---

#### 1.4 WorkRequest (структура работы)

```csharp
private struct WorkRequest
{
    private readonly SendOrPostCallback m_DelagateCallback;
    private readonly object m_DelagateState;
    private readonly ManualResetEvent m_WaitHandle;

    public void Invoke()
    {
        try
        {
            m_DelagateCallback(m_DelagateState);
        }
        finally
        {
            m_WaitHandle?.Set();  // Сигнал о завершении
        }
    }
}
```

---

### Практическое применение

#### async/await в Unity

```csharp
// Unity автоматически устанавливает UnitySynchronizationContext
// Поэтому продолжения выполняются на основном потоке

public async Task LoadDataAsync()
{
    // Выполняется в фоне
    var data = await File.ReadAllTextAsync("save.json");
    
    // Продолжение на основном потоке (UnitySynchronizationContext)
    // Можно безопасно вызывать Unity API
    playerNameText.text = data;
}
```

**Почему это работает:**
1. `await` возвращает управление
2. `UnitySynchronizationContext` планирует продолжение
3. `Exec()` вызывается в PlayerLoop
4. Продолжение выполняется на основном потоке

---

#### Проблема: Потеря контекста

```csharp
// ❌ НЕПРАВИЛЬНО:
public async Task LoadAsync()
{
    await Task.Run(() => {
        // Фоновый поток
        var data = LoadData();
        
        // Контекст потерян!
        // Продолжение выполнится в фоне
        UpdateUI(data);  // ❌ Ошибка Unity API!
    });
}

// ✅ ПРАВИЛЬНО:
public async Task LoadAsync()
{
    // Фоновый поток
    var data = await Task.Run(() => LoadData());
    
    // Контекст сохранён (основной поток)
    UpdateUI(data);  // ✅ OK
}
```

---

## 🔧 2. COROUTINES

### Устройство

**Файлы:**
- `Coroutines.cs` — управление
- `Coroutine.bindings.cs` — нативная реализация

### SetupCoroutine

```csharp
internal class SetupCoroutine
{
    unsafe static public void InvokeMoveNext(IEnumerator enumerator, IntPtr returnValueAddress)
    {
        (*(bool*)returnValueAddress) = enumerator.MoveNext();
    }
}
```

**Как работает:**
1. Вызывает `enumerator.MoveNext()`
2. Возвращает `true` если есть следующий yield
3. Native код решает, когда продолжить

---

### MonoBehaviour.StartCoroutine

```csharp
public Coroutine StartCoroutine(IEnumerator routine)
{
    if (routine == null)
        throw new NullReferenceException("routine is null");
    
    if (!IsObjectMonoBehaviour(this))
        throw new ArgumentException("Coroutines can only be stopped on a MonoBehaviour");
    
    return StartCoroutineManaged2(routine);
}
```

**Требования:**
- Только на MonoBehaviour
- IEnumerator не может быть null
- Возвращает `Coroutine` объект

---

### yield return обработка

**Что происходит:**

```csharp
IEnumerator MyCoroutine()
{
    yield return null;           // Ждать конца кадра
    yield return 1;              // Ждать 1 секунду
    yield return new WaitForEndOfFrame();  // Ждать конца кадра
}
```

**Внутренне:**
1. `MoveNext()` вызывается каждый кадр
2. Возвращаемое значение проверяется
3. Native код решает, когда продолжить

---

### Практическое применение

#### Оптимизация корутин

```csharp
// ❌ НЕПРАВИЛЬНО: Новая корутина каждый кадр
void Update()
{
    StartCoroutine(DoSomething());  // ❌ Утечка!
}

// ✅ ПРАВИЛЬНО: Одна корутина
private Coroutine _routine;

void Start()
{
    _routine = StartCoroutine(DoSomething());
}

void OnDestroy()
{
    if (_routine != null)
        StopCoroutine(_routine);
}
```

---

#### CancellationToken для корутин

```csharp
// MonoBehaviour имеет встроенный CancellationToken
public MonoBehaviour()
{
    m_CancellationTokenSource = new CancellationTokenSource();
}

// При уничтожении объекта
private void RaiseCancellation()
{
    m_CancellationTokenSource?.Cancel();
}

// Использование
public async Task LoadAsync()
{
    try
    {
        await LoadDataAsync(destroyCancellationToken);
    }
    catch (OperationCanceledException)
    {
        // Объект уничтожен, отмена
    }
}
```

---

## 🔧 3. MONOBEHAVIOUR

### Жизненный цикл

**Файл:** `MonoBehaviour.bindings.cs`

```csharp
public class MonoBehaviour : Behaviour
{
    public extern bool didStart { get; }  // Вызван ли Start
    public extern bool didAwake { get; }  // Вызван ли Awake
    
    // CancellationToken для уничтожения
    private CancellationTokenSource m_CancellationTokenSource;
    public CancellationToken destroyCancellationToken { get; }
}
```

### Порядок выполнения

```
1. ConstructorCheck()  ← Конструктор
2. Awake()             ← didAwake = true
3. Start()             ← didStart = true
4. Update()            ← Каждый кадр
5. OnDestroy()         ← destroyCancellationToken.Cancel()
```

---

### Invoke (отложенный вызов)

```csharp
public void Invoke(string methodName, float time)
{
    InvokeDelayed(this, methodName, time, 0.0f);
}

public void InvokeRepeating(string methodName, float time, float repeatRate)
{
    InvokeDelayed(this, methodName, time, repeatRate);
}
```

**Внутренне:**
- Добавляет в очередь отложенных вызовов
- Выполняется в PlayerLoop

---

### CancelInvoke

```csharp
public void CancelInvoke(string methodName)
{
    CancelInvoke(this, methodName);
}

public void CancelInvoke()
{
    Internal_CancelInvokeAll(this);
}
```

**Использование:**
```csharp
// Отменить все Invoke
CancelInvoke();

// Отменить конкретный
CancelInvoke("Shoot");
```

---

## 📊 ИТОГОВАЯ ТАБЛИЦА

| Компонент | Назначение | Ключевой метод |
|-----------|------------|----------------|
| **UnitySynchronizationContext** | Синхронизация потоков | `Post()`, `Exec()` |
| **Coroutine** | Асинхронные операции | `StartCoroutine()` |
| **MonoBehaviour** | Жизненный цикл | `Invoke()`, `CancelInvoke()` |

---

## ✅ РЕКОМЕНДАЦИИ ДЛЯ DRAGRACEUNITY

### 1. async/await

```csharp
// ✅ Использовать для загрузки
public async Task SaveGameAsync()
{
    var data = await SerializeDataAsync();
    await File.WriteAllTextAsync("save.json", data);
    // Продолжение на основном потоке
    SaveCompleteUI.Show();
}
```

### 2. Корутины

```csharp
// ✅ Использовать для таймеров
private IEnumerator DamageOverTime(float damage, float duration)
{
    float elapsed = 0;
    while (elapsed < duration)
    {
        ApplyDamage(damage * Time.deltaTime);
        elapsed += Time.deltaTime;
        yield return null;
    }
}
```

### 3. CancellationToken

```csharp
// ✅ Отмена при уничтожении
public async Task LoadAsync()
{
    try
    {
        await LoadDataAsync(destroyCancellationToken);
    }
    catch (OperationCanceledException)
    {
        // Нормально при уничтожении
    }
}
```

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`KNOWLEDGE_BASE/00_CORE/UNITY_CS_REFERENCE_ANALYSIS.md`](../KNOWLEDGE_BASE/00_CORE/UNITY_CS_REFERENCE_ANALYSIS.md) — Предыдущий анализ
- [`TEMP/UnityCsReference/`](./) — Исходный код

---

**Анализ завершён:** 2 марта 2026 г.  
**Следующее действие:** Исправить AI_START_HERE.md
