---
status: stable
created: 2026-02-28
last_reviewed: 2026-02-28
source: Unity Documentation
---
# 📚 UNITY DOCUMENTATION GUIDE

**Версия:** 1.0  
**Дата:** 28 февраля 2026 г.  
**Статус:** ✅ Изучено и систематизировано

---

## 🎯 ПРИОРИТЕТНЫЙ ПУТЬ ОБУЧЕНИЯ

```
1. Unity Building Blocks → 2. Scripting → 3. UI → 4. Physics → 5. Rendering
                              ↓
                    (параллельно: Animation, Audio)
                              ↓
              (после основ: Multiplayer, XR, Unity AI)
```

---

## 📖 UNITY MANUAL

### 🔴 КРИТИЧЕСКИ ВАЖНЫЕ РАЗДЕЛЫ

#### 1. Unity Building Blocks (Начать отсюда!)

**Ссылка:** https://docs.unity3d.com/Manual/GameplaySection.html

**Что изучать:**
- ✅ GameObjects и Components
- ✅ Prefabs
- ✅ Scenes
- ✅ Assets и AssetBundles

**Практика:**
```
Создать сцену → Добавить GameObject → Назначить компоненты → Сохранить как Prefab
```

---

#### 2. Scripting (Фундамент для кода)

**Ссылка:** https://docs.unity3d.com/Manual/ScriptingSection.html

**Что изучать:**
- ✅ MonoBehaviour lifecycle (Awake, Start, Update, FixedUpdate, OnDestroy)
- ✅ Script Compilation Order
- ✅ Coroutines
- ✅ Events и Delegates

**Пример:**
```csharp
public class PlayerController : MonoBehaviour
{
    void Awake() { }      // Инициализация
    void Start() { }      // Первый кадр
    void Update() { }     // Каждый кадр
    void FixedUpdate() { } // Физика (50 раз/сек)
    void OnDestroy() { }  // Уничтожение
}
```

---

#### 3. UI (UI Toolkit)

**Ссылка:** https://docs.unity3d.com/Manual/UISection.html

**Что изучать:**
- ✅ UXML (разметка)
- ✅ USS (стили)
- ✅ C# scripting для UI
- ✅ VisualElement
- ✅ UIDocument

**Пример:**
```csharp
using UnityEngine.UIElements;

public class MainMenu : MonoBehaviour
{
    private Button playButton;
    
    void OnEnable()
    {
        var doc = GetComponent<UIDocument>();
        playButton = doc.rootVisualElement.Q<Button>("PlayButton");
        playButton.clicked += OnPlayClicked;
    }
}
```

---

#### 4. Physics

**Ссылка:** https://docs.unity3d.com/Manual/PhysicsSection.html

**Что изучать:**
- ✅ Rigidbody
- ✅ Colliders
- ✅ Physics Materials
- ✅ Raycasting
- ✅ Triggers

**Пример:**
```csharp
void Update()
{
    // Raycast для проверки видимости
    if (Physics.Raycast(transform.position, transform.forward, out RaycastHit hit, 10f))
    {
        Debug.Log($"Попал в: {hit.collider.name}");
    }
}
```

---

#### 5. Rendering

**Ссылка:** https://docs.unity3d.com/Manual/GraphicsSection.html

**Что изучать:**
- ✅ Universal Render Pipeline (URP)
- ✅ Materials и Shaders
- ✅ Lighting
- ✅ Post-processing
- ✅ Visual Effect Graph

---

### 🟡 ЧАСТО ИСПОЛЬЗУЕМЫЕ РАЗДЕЛЫ

| Раздел | Ссылка | Когда изучать |
|--------|--------|---------------|
| **Animation** | https://docs.unity3d.com/Manual/AnimationSection.html | При создании анимаций |
| **Audio** | https://docs.unity3d.com/Manual/AudioSection.html | При добавлении звука |
| **Input** | https://docs.unity3d.com/Manual/Input.html | При настройке управления |
| **2D Games** | https://docs.unity3d.com/Manual/2dGameDevelopment.html | Для 2D проектов |
| **Tilemap** | https://docs.unity3d.com/Manual/Tilemap.html | Для 2D уровней |

---

### 🟢 СПЕЦИАЛИЗИРОВАННЫЕ РАЗДЕЛЫ

| Раздел | Ссылка | Когда изучать |
|--------|--------|---------------|
| **Multiplayer** | https://docs.unity3d.com/Manual/MultiplayerSection.html | Для сетевой игры |
| **XR (VR/AR)** | https://docs.unity3d.com/Manual/XR.html | Для VR/AR проектов |
| **Unity AI** | https://docs.unity3d.com/Manual/UnityAI.html | Для AI-инструментов |
| **Addressables** | https://docs.unity3d.com/Manual/Addressables.html | Для загрузки ассетов |

---

## 📖 SCRIPTING API

### 🔴 КРИТИЧЕСКИ ВАЖНЫЕ КЛАССЫ

#### 1. Базовые классы

**MonoBehaviour** — основа всех скриптов-компонентов  
**Ссылка:** https://docs.unity3d.com/ScriptReference/MonoBehaviour.html

```csharp
public class Player : MonoBehaviour
{
    // Lifecycle методы
    void Awake() { }
    void Start() { }
    void Update() { }
    void FixedUpdate() { }
    void OnDestroy() { }
    
    // Коллизии
    void OnCollisionEnter(Collision collision) { }
    void OnTriggerEnter(Collider other) { }
}
```

---

**ScriptableObject** — данные вне инстансов  
**Ссылка:** https://docs.unity3d.com/ScriptReference/ScriptableObject.html

```csharp
[CreateAssetMenu(fileName = "NewCar", menuName = "Cars/Car")]
public class CarData : ScriptableObject
{
    public string carName;
    public float speed;
    public float acceleration;
}
```

---

**GameObject** — игровые объекты  
**Ссылка:** https://docs.unity3d.com/ScriptReference/GameObject.html

```csharp
// Создание
GameObject obj = new GameObject("Player");

// Поиск
GameObject player = GameObject.Find("Player");
GameObject[] enemies = GameObject.FindGameObjectsWithTag("Enemy");

// Активация
obj.SetActive(true);
```

---

**Transform** — позиция, вращение, масштаб  
**Ссылка:** https://docs.unity3d.com/ScriptReference/Transform.html

```csharp
// Позиция
transform.position = new Vector3(0, 0, 0);
transform.Translate(Vector3.forward * speed * Time.deltaTime);

// Вращение
transform.rotation = Quaternion.Euler(0, 90, 0);
transform.Rotate(0, 10 * Time.deltaTime, 0);

// Масштаб
transform.localScale = new Vector3(2, 2, 2);

// Иерархия
transform.SetParent(parent);
transform.GetChild(0);
```

---

#### 2. Математика

**Vector3** — 3D векторы  
**Ссылка:** https://docs.unity3d.com/ScriptReference/Vector3.html

```csharp
Vector3 position = new Vector3(1, 2, 3);
Vector3 direction = (target.position - transform.position).normalized;
float distance = Vector3.Distance(a, b);
Vector3.Lerp(start, end, t);
```

---

**Quaternion** — вращение  
**Ссылка:** https://docs.unity3d.com/ScriptReference/Quaternion.html

```csharp
Quaternion rotation = Quaternion.Euler(0, 90, 0);
Quaternion targetRotation = Quaternion.LookRotation(direction);
transform.rotation = Quaternion.Slerp(from, to, t);
```

---

#### 3. Физика

**Rigidbody** — физическое тело  
**Ссылка:** https://docs.unity3d.com/ScriptReference/Rigidbody.html

```csharp
Rigidbody rb = GetComponent<Rigidbody>();

// Сила
rb.AddForce(Vector3.up * 10f);

// Скорость
rb.velocity = new Vector3(1, 0, 0);

// Импульс
rb.AddImpulse(Vector3.forward * 5f);
```

---

**Physics** — статические методы  
**Ссылка:** https://docs.unity3d.com/ScriptReference/Physics.html

```csharp
// Raycast
if (Physics.Raycast(origin, direction, out RaycastHit hit, maxDistance))
{
    Debug.Log($"Попал в: {hit.collider.name}");
}

// SphereCast
if (Physics.SphereCast(origin, radius, direction, out RaycastHit hit))
{
    // Проверка области
}

// Overlap
Collider[] colliders = Physics.OverlapSphere(position, radius);
```

---

#### 4. Ввод

**Input (старая система)**  
**Ссылка:** https://docs.unity3d.com/ScriptReference/Input.html

```csharp
// Клавиатура
if (Input.GetKey(KeyCode.W)) { }
if (Input.GetKeyDown(KeyCode.Space)) { }

// Мышь
float mouseX = Input.GetAxis("Mouse X");
if (Input.GetMouseButtonDown(0)) { }

// Ввод
string text = Input.inputString;
```

---

**InputSystem (новая система)**  
**Ссылка:** https://docs.unity3d.com/Packages/com.unity.inputsystem@1.18/manual/index.html

```csharp
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    private PlayerInput playerInput;
    private InputAction gasAction;
    
    void OnEnable()
    {
        playerInput = new PlayerInput();
        gasAction = playerInput.Car.Gas;
        gasAction.Enable();
    }
    
    void Update()
    {
        float gas = gasAction.ReadValue<float>();
    }
}
```

---

#### 5. UI (UI Toolkit)

**VisualElement** — базовый элемент UI  
**Ссылка:** https://docs.unity3d.com/ScriptReference/UIElements.VisualElement.html

```csharp
using UnityEngine.UIElements;

public class MainMenu : MonoBehaviour
{
    private UIDocument doc;
    private VisualElement root;
    private Button playButton;
    
    void OnEnable()
    {
        doc = GetComponent<UIDocument>();
        root = doc.rootVisualElement;
        
        playButton = root.Q<Button>("PlayButton");
        playButton.clicked += OnPlayClicked;
    }
}
```

---

**UIDocument** — связь UXML с кодом  
**Ссылка:** https://docs.unity3d.com/ScriptReference/UIElements.UIDocument.html

```csharp
// Загрузка UXML
var doc = GetComponent<UIDocument>();
var root = doc.rootVisualElement;

// Query элементов
var button = root.Q<Button>("MyButton");
var label = root.Q<Label>("ScoreLabel");
```

---

#### 6. Утилиты

**Object.Instantiate/Destroy**  
**Ссылка:** https://docs.unity3d.com/ScriptReference/Object.Instantiate.html

```csharp
// Создание
GameObject clone = Instantiate(prefab, position, rotation);

// Уничтожение
Destroy(gameObject);
Destroy(gameObject, 2f); // Через 2 секунды
```

---

**SceneManager** — управление сценами  
**Ссылка:** https://docs.unity3d.com/ScriptReference/SceneManagement.SceneManager.html

```csharp
using UnityEngine.SceneManagement;

// Загрузка
SceneManager.LoadScene("Level1");
SceneManager.LoadSceneAsync("Level1");

// Перезагрузка
SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
```

---

**Debug** — логирование  
**Ссылка:** https://docs.unity3d.com/ScriptReference/Debug.html

```csharp
// Логи
Debug.Log("Информация");
Debug.LogWarning("Предупреждение");
Debug.LogError("Ошибка");

// Визуализация
Debug.DrawLine(start, end, Color.red, duration);
Debug.DrawRay(origin, direction, Color.green, duration);
```

---

### 🟡 ЧАСТО ИСПОЛЬЗУЕМЫЕ КЛАССЫ

| Класс | Ссылка | Назначение |
|-------|--------|------------|
| **Animator** | https://docs.unity3d.com/ScriptReference/Animator.html | Управление анимациями |
| **AudioSource** | https://docs.unity3d.com/ScriptReference/AudioSource.html | Воспроизведение звука |
| **Camera** | https://docs.unity3d.com/ScriptReference/Camera.html | Настройки камеры |
| **Renderer** | https://docs.unity3d.com/ScriptReference/Renderer.html | Рендеринг объекта |
| **Collider** | https://docs.unity3d.com/ScriptReference/Collider.html | Коллайдеры |

---

### 🟢 СПЕЦИАЛИЗИРОВАННЫЕ КЛАССЫ

| Класс | Ссылка | Назначение |
|-------|--------|------------|
| **NavMeshAgent** | https://docs.unity3d.com/ScriptReference/AI.NavMeshAgent.html | AI навигация |
| **ParticleSystem** | https://docs.unity3d.com/ScriptReference/ParticleSystem.html | Частицы |
| **TrailRenderer** | https://docs.unity3d.com/ScriptReference/TrailRenderer.html | Следы |
| **LineRenderer** | https://docs.unity3d.com/ScriptReference/LineRenderer.html | Линии |

---

## 📁 GITHUB: UNITY-PRACTICE

**Репозиторий:** https://github.com/mopsicus/unity-practice

### Структура проекта

| Лекция | Тема | Файлы |
|--------|------|-------|
| **Lection1** | Устройство сцены | Scene setup, GameObjects |
| **Lection2** | Классы и наследование | C# classes, inheritance |
| **Lection3** | Архитектура и паттерны | MVP, Observer, Command |
| **Lection4** | UI и компоненты | UI Toolkit, UXML, USS |
| **Lection5** | Input System, камеры, звуки | Input, Camera, Audio |
| **Lection6** | Тестирование, дебаг, оптимизация | Tests, Debug, Profiling |

### Конфигурационные файлы

**`.editorconfig`** — правила оформления кода:
```ini
[*.cs]
indent_style = space
indent_size = 4
csharp_style_var_for_built_in_types = false
```

**`extensions.json`** — рекомендованные расширения VS Code:
```json
{
    "recommendations": [
        "ms-dotnettools.csharp",
        "visualstudiotoolsforunity.vstuc"
    ]
}
```

---

## 🎯 ПЛАН ИЗУЧЕНИЯ

### Неделя 1: Основы

**Unity Manual:**
- ✅ Unity Building Blocks
- ✅ GameObjects и Components
- ✅ Prefabs и Scenes

**Scripting API:**
- ✅ MonoBehaviour
- ✅ Transform
- ✅ GameObject

**Практика:**
```
Создать сцену → Добавить объекты → Написать скрипт движения
```

---

### Неделя 2: Scripting

**Unity Manual:**
- ✅ Scripting Section
- ✅ Lifecycle methods
- ✅ Coroutines

**Scripting API:**
- ✅ Vector3, Quaternion
- ✅ Input
- ✅ Debug

**Практика:**
```
Написать контроллер игрока → Добавить ввод → Отладка
```

---

### Неделя 3: UI

**Unity Manual:**
- ✅ UI Section
- ✅ UI Toolkit

**Scripting API:**
- ✅ VisualElement
- ✅ UIDocument
- ✅ Button, Label

**Практика:**
```
Создать меню → UXML разметка → USS стили → C# логика
```

---

### Неделя 4: Физика

**Unity Manual:**
- ✅ Physics Section
- ✅ Rigidbody, Colliders

**Scripting API:**
- ✅ Rigidbody
- ✅ Physics.Raycast
- ✅ Collider

**Практика:**
```
Добавить физику → Raycast для стрельбы → Коллизии
```

---

## 📚 РЕСУРСЫ

### Официальная документация:

| Ресурс | Ссылка |
|--------|--------|
| **Unity Manual** | https://docs.unity3d.com/Manual/ |
| **Scripting API** | https://docs.unity3d.com/ScriptReference/ |
| **UI Toolkit** | https://docs.unity3d.com/Manual/UIElements.html |
| **Input System** | https://docs.unity3d.com/Packages/com.unity.inputsystem@1.18/manual/index.html |

### GitHub примеры:

| Репозиторий | Ссылка |
|-------------|--------|
| **unity-practice** | https://github.com/mopsicus/unity-practice |
| **Unity UI Samples** | https://github.com/Unity-Technologies/uGUI |
| **Unity Samples** | https://github.com/Unity-Technologies/ |

### Дополнительно:

- [Unity Learn Tutorials](https://learn.unity.com/)
- [Unity Discussions](https://discussions.unity.com/)
- [Unity Support](https://support.unity.com/)

---

**Документация изучена и систематизирована!** 📚

**Следующий шаг: Применять на практике!** 🎯
