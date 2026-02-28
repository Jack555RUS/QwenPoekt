---
status: stable
created: 2026-02-28
last_reviewed: 2026-02-28
source: Unity Documentation
---
# 🎨 UI Toolkit — База знаний по Unity UI

**Сохранено:** 28 февраля 2026 г.
**Источник:** Unity Documentation, Manual, ScriptReference

---

## 📖 Основные принципы UI Toolkit

### Три кита UI Toolkit:

| Компонент | Назначение | Аналог |
|-----------|------------|--------|
| **UXML** | Разметка интерфейса | HTML |
| **USS** | Стили элементов | CSS |
| **C#** | Логика и события | JavaScript |

---

## 🧱 Построение меню

### 1. Создание кнопки (C#)

```csharp
using UnityEngine;
using UnityEngine.UIElements;

public class SimpleMenu : MonoBehaviour
{
    private VisualElement root;
    
    private void OnEnable()
    {
        // Получаем корневой элемент
        var uiDocument = GetComponent<UIDocument>();
        root = uiDocument.rootVisualElement;

        // Создаём кнопку
        var myButton = new Button(() => { 
            Debug.Log("Кнопка нажата!"); 
        }) 
        { 
            text = "Нажми меня" 
        };

        // Добавляем в корень
        root.Add(myButton);
    }
    
    private void OnDisable()
    {
        // Обязательно отписываемся!
        var button = root.Q<Button>("MyButton");
        if (button != null)
            button.clicked -= OnButtonClicked;
    }
}
```

---

### 2. Иерархия элементов

```csharp
// Создаём контейнер меню
var mainMenu = new VisualElement();
mainMenu.name = "MainMenu";

// Создаём кнопки
var buttonPlay = new Button() { text = "Играть" };
var buttonSettings = new Button() { text = "Настройки" };
var buttonExit = new Button() { text = "Выход" };

// Добавляем кнопки в контейнер
mainMenu.Add(buttonPlay);
mainMenu.Add(buttonSettings);
mainMenu.Add(buttonExit);

// Добавляем контейнер в корень
root.Add(mainMenu);
```

---

### 3. Поиск элементов (Query)

```csharp
// Найти по имени
var playButton = root.Q<Button>("PlayButton");

// Найти по классу
var buttons = root.Query<Button>("menu-button").ToList();

// Найти все текстовые поля
var labels = root.Query<Label>().ToList();
```

**Важно:** Всегда проверяйте на null!

```csharp
var button = root.Q<Button>("ButtonName");
if (button != null)
{
    button.clicked += MyMethod;
}
else
{
    Debug.LogError("Кнопка не найдена!");
}
```

---

## 🎭 События (Events)

### Правильная подписка:

```csharp
public class MenuManager : MonoBehaviour
{
    private VisualElement root;
    
    void OnEnable()
    {
        root = GetComponent<UIDocument>().rootVisualElement;
        
        var button = root.Q<Button>("PlayButton");
        if (button != null)
        {
            button.clicked += OnPlayClicked; // Подписка
        }
    }
    
    void OnDisable()
    {
        var button = root.Q<Button>("PlayButton");
        if (button != null)
        {
            button.clicked -= OnPlayClicked; // Отписка!
        }
    }
    
    void OnPlayClicked()
    {
        Debug.Log("Игра запущена!");
    }
}
```

---

## 🎨 USS Стили (CSS для Unity)

### Базовый пример:

```css
/* MainMenu.uss */
.main-menu {
    align-items: center;
    justify-content: center;
    flex-direction: column;
}

.menu-button {
    width: 300px;
    height: 60px;
    margin-top: 10px;
    background-color: rgb(128, 128, 128);
    transition: background-color 0.2s;
}

.menu-button:hover {
    background-color: rgb(160, 160, 160);
}

.menu-button:active {
    background-color: rgb(100, 100, 100);
}
```

### Применение стилей:

```csharp
// В C# коде
button.AddToClassList("menu-button");
```

---

## 🎬 Анимации

### CSS Transitions:

```css
.animated-button {
    scale: 1.0;
    transition: scale 0.2s ease-in-out;
}

.animated-button:hover {
    scale: 1.1;
}
```

### Зацикленная анимация (C#):

```csharp
// Пульсация
myLabel.RegisterCallback<TransitionEndEvent>(evt => 
    myLabel.ToggleInClassList("enlarge-scale")
);

myLabel.schedule.Execute(() => 
    myLabel.ToggleInClassList("enlarge-scale")
).StartingIn(100);
```

---

## 🏗️ Архитектура сложных меню

### Менеджер меню:

```csharp
public class MenuManager : MonoBehaviour
{
    [SerializeField] private UIDocument document;
    private VisualElement root;
    private VisualElement mainMenuPanel;
    private VisualElement settingsPanel;

    void OnEnable()
    {
        root = document.rootVisualElement;
        
        // Находим панели
        mainMenuPanel = root.Q<VisualElement>("MainMenu");
        settingsPanel = root.Q<VisualElement>("SettingsPanel");

        // Подписываем кнопки
        root.Q<Button>("SettingsButton").clicked += ShowSettings;
        root.Q<Button>("BackButton").clicked += ShowMainMenu;
        
        ShowMainMenu();
    }

    void ShowMainMenu()
    {
        mainMenuPanel.style.display = DisplayStyle.Flex;
        settingsPanel.style.display = DisplayStyle.None;
    }

    void ShowSettings()
    {
        mainMenuPanel.style.display = DisplayStyle.None;
        settingsPanel.style.display = DisplayStyle.Flex;
    }
    
    void OnDisable()
    {
        root.Q<Button>("SettingsButton").clicked -= ShowSettings;
        root.Q<Button>("BackButton").clicked -= ShowMainMenu;
    }
}
```

---

## 🛠️ Инструменты отладки

### UI Toolkit Debugger:
```
Window → UI Toolkit → Debugger
```

**Что показывает:**
- Визуальное дерево в реальном времени
- Применяемые стили
- Matching Selectors (источник стилей)

### Preview Mode:
```
UI Builder → Preview Mode
```

**Что даёт:**
- Тестирование без запуска игры
- Проверка :hover, :active состояний
- Ввод текста в поля

---

## 📋 Чек-лист правильного UI

- [ ] Использовать UIDocument для rootVisualElement
- [ ] Подписываться на события в OnEnable
- [ ] Отписываться от событий в OnDisable
- [ ] Проверять элементы на null
- [ ] Использовать Q<T>() для поиска
- [ ] Разделять логику и представление
- [ ] Использовать USS для стилей
- [ ] Применять transitions для анимаций

---

## 📚 Источники

1. [Unity UI Toolkit Documentation](https://docs.unity3d.com/Manual/UIElements.html)
2. [UIElements Namespace](https://docs.unity3d.com/ScriptReference/UnityEngine.UIElements.html)
3. [Button Class](https://docs.unity3d.com/ScriptReference/UnityEngine.UIElements.Button.html)
4. [VisualElement Class](https://docs.unity3d.com/ScriptReference/UnityEngine.UIElements.VisualElement.html)
5. [UI Builder](https://docs.unity3d.com/Manual/UIBuilder.html)
6. [USS Styles](https://docs.unity3d.com/Manual/UIE-USS.html)
7. [UXML](https://docs.unity3d.com/Manual/UIE-UXML.html)
8. [Dragon Crashers Demo](https://github.com/Unity-Technologies/DragonCrashers)
9. [QuizU Demo](https://github.com/Unity-Technologies/QuizU)

---

**Применение:** Меню можно создавать на UGUI или UI Toolkit в зависимости от требований проекта.
