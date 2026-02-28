---
status: stable
created: 2026-02-28
last_reviewed: 2026-02-28
source: https://habr.com/ru/articles/unity-menu-evolution
author: Habr / Unity Community
---

# 📚 ТРИ ПОДХОДА К СОЗДАНИЮ МЕНЮ В UNITY — КОНСПЕКТ

**Оригинал:** Создание меню в Unity: три подхода с примерами  
**Тип:** Сравнительное руководство  
**Дата:** 2024-2025

---

## 📖 Содержание

1. [Три пути создания меню](#три-пути-создания-меню)
2. [UI Toolkit (Современный стандарт)](#ui-toolkit-современный-стандарт)
3. [uGUI (Классический подход)](#ugui-классический-подход)
4. [IMGUI (Старый метод)](#imgui-старый-метод)
5. [Сравнение подходов](#сравнение-подходов)
6. [Частые проблемы и решения](#частые-проблемы-и-решения)
7. [Применение в DragRaceUnity](#применение-в-dragraceunity)

---

## 🏗️ ТРИ ПУТИ СОЗДАНИЯ МЕНЮ

### Эволюция UI в Unity:

```
IMGUI (OnGUI) → uGUI (Canvas) → UI Toolkit (UXML/USS)
   2005           2013              2021+
```

---

## 1️⃣ UI TOOLKIT (СОВРЕМЕННЫЙ СТАНДАРТ)

**Рекомендация:** ✅ Использовать для всех новых проектов!

### Архитектура:

```
UXML (разметка как HTML)
   ↓
USS (стили как CSS)
   ↓
C# (логика)
```

### Преимущества:

| Преимущество | Описание |
|--------------|----------|
| **Гибкость** | Максимальный контроль над UI |
| **Производительность** | Оптимизирован для сложных интерфейсов |
| **Поддержка** | Разделение логики и стилей |
| **Кроссплатформенность** | Работает везде |

---

### Пример 1: Создание кнопки из C#

**Файл:** `DynamicMenu.cs`

```csharp
using UnityEngine;
using UnityEngine.UIElements;

public class DynamicMenu : MonoBehaviour
{
    private void OnEnable()
    {
        var root = GetComponent<UIDocument>().rootVisualElement;
        
        // Создаём кнопку с действием прямо в конструкторе
        var myButton = new Button(() => Debug.Log("Кнопка нажата!")) 
        { 
            text = "Нажми меня" 
        };
        
        // Добавляем иконку (текстуру из папки Resources)
        var icon = Resources.Load<Texture2D>("Icons/play");
        myButton.iconImage = icon; // Иконка появится слева от текста
        
        root.Add(myButton);
    }
}
```

**Ключевые моменты:**
- ✅ `new Button(() => action)` — лямбда-выражение для события
- ✅ `text` — текст кнопки
- ✅ `iconImage` — иконка слева от текста

---

### Пример 2: Кнопка с кастомным фоном и стилями

**Файл:** `StyledButton.cs`

```csharp
using UnityEngine;
using UnityEngine.UIElements;

public class StyledButton : MonoBehaviour
{
    public void CreateStyledButton(string buttonId, Texture2D icon)
    {
        var root = GetComponent<UIDocument>().rootVisualElement;
        
        var button = new Button(() => HandleButtonClick(buttonId));
        button.name = buttonId;
        button.text = "Играть";
        
        // Устанавливаем фоновое изображение
        button.style.backgroundImage = new StyleBackground(icon);
        
        // Добавляем отступы и цвета через стили
        button.style.margin = new Length(10, LengthUnit.Pixel);
        button.style.backgroundColor = new StyleColor(new Color(0.2f, 0.6f, 1f));
        
        root.Add(button);
    }

    private void HandleButtonClick(string id)
    {
        Debug.Log($"Нажата кнопка с ID: {id}");
        // Здесь логика загрузки сцены или других действий
    }
}
```

**Ключевые моменты:**
- ✅ `style.backgroundImage` — фоновое изображение
- ✅ `style.margin` — отступы
- ✅ `style.backgroundColor` — цвет фона

---

### Пример 3: Табулированное меню (с вкладками)

**Файл:** `TabbedMenu.cs`

```csharp
using UnityEngine;
using UnityEngine.UIElements;

public class TabbedMenu : MonoBehaviour
{
    [SerializeField] private UIDocument document;
    
    private void OnEnable()
    {
        var root = document.rootVisualElement;
        
        // Контейнер для вкладок
        var tabContainer = new VisualElement();
        tabContainer.style.flexDirection = FlexDirection.Row;
        
        // Создаём вкладки
        var tab1 = new Button(() => ShowContent("tab1Content")) { text = "Игра" };
        var tab2 = new Button(() => ShowContent("tab2Content")) { text = "Настройки" };
        var tab3 = new Button(() => ShowContent("tab3Content")) { text = "Выход" };
        
        tabContainer.Add(tab1);
        tabContainer.Add(tab2);
        tabContainer.Add(tab3);
        
        // Контейнеры для контента (изначально скрыты)
        var content1 = new Label("Здесь будет окно игры");
        var content2 = new Label("Настройки графики и звука");
        var content3 = new Button(() => Application.Quit()) { text = "Подтвердить выход" };
        
        content1.name = "tab1Content";
        content2.name = "tab2Content";
        content3.name = "tab3Content";
        
        content2.style.display = DisplayStyle.None;
        content3.style.display = DisplayStyle.None;
        
        root.Add(tabContainer);
        root.Add(content1);
        root.Add(content2);
        root.Add(content3);
    }
    
    private void ShowContent(string contentName)
    {
        var root = document.rootVisualElement;
        
        // Скрываем весь контент
        root.Q<VisualElement>("tab1Content").style.display = DisplayStyle.None;
        root.Q<VisualElement>("tab2Content").style.display = DisplayStyle.None;
        root.Q<VisualElement>("tab3Content").style.display = DisplayStyle.None;
        
        // Показываем нужный
        root.Q<VisualElement>(contentName).style.display = DisplayStyle.Flex;
    }
}
```

**Ключевые моменты:**
- ✅ `FlexDirection.Row` — горизонтальное расположение вкладок
- ✅ `DisplayStyle.None` — скрыть элемент
- ✅ `DisplayStyle.Flex` — показать элемент
- ✅ `root.Q<T>("name")` — поиск элемента по имени

---

## 2️⃣ uGUI (КЛАССИЧЕСКИЙ ПОДХОД)

**Основа:** GameObject + Canvas + Components

### Архитектура:

```
Canvas (холст)
   ↓
GameObject (кнопка, текст, изображение)
   ↓
Components (Button, TextMeshPro, Image)
```

### Преимущества:

| Преимущество | Описание |
|--------------|----------|
| **Визуальный редактор** | Всё настраивается в Inspector |
| **Много туториалов** | Огромное сообщество |
| **Простота** | Легко начать |

---

### Пример: Простое меню с обработчиками

**Файл:** `UGUIMenu.cs`

```csharp
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.SceneManagement;

public class UGUIMenu : MonoBehaviour
{
    [SerializeField] private Button playButton;
    [SerializeField] private Button exitButton;
    [SerializeField] private TMP_Text statusText; // TextMeshPro текст
    
    private void Start()
    {
        // Подписываемся на события
        playButton.onClick.AddListener(StartGame);
        exitButton.onClick.AddListener(QuitGame);
        
        // Альтернативный способ через Find (менее надёжный)
        // playButton = GameObject.Find("PlayButton").GetComponent<Button>();
    }
    
    private void StartGame()
    {
        statusText.text = "Загрузка...";
        SceneManager.LoadScene("GameLevel");
    }
    
    private void QuitGame()
    {
        Debug.Log("Выход из игры");
        Application.Quit();
    }
}
```

**Ключевые моменты:**
- ✅ `onClick.AddListener()` — подписка на событие
- ✅ `TMP_Text` — TextMeshPro для текста
- ✅ `SceneManager.LoadScene()` — загрузка сцены

---

## 3️⃣ IMGUI (СТАРЫЙ МЕТОД)

**Основа:** `OnGUI()` метод

### Архитектура:

```
OnGUI() → GUI.Button → Обработка
```

### Преимущества:

| Преимущество | Описание |
|--------------|----------|
| **Быстро** | Не требует настройки сцены |
| **Просто** | Пишется "на коленке" |
| **Для прототипов** | Идеально для тестов |

### Недостатки:

| Недостаток | Описание |
|------------|----------|
| **Нет редактора** | Всё в коде |
| **Низкая производительность** | Перерисовка каждый кадр |
| **Некрасиво** | Ограниченные возможности стилизации |

---

### Пример: Простое меню в старом стиле

**Файл:** `OldSchoolMenu.cs`

```csharp
using UnityEngine;

public class OldSchoolMenu : MonoBehaviour
{
    private void OnGUI()
    {
        // Создаём область для кнопок
        float buttonWidth = 200;
        float buttonHeight = 50;
        float startX = (Screen.width - buttonWidth) / 2;
        float startY = (Screen.height - 3 * buttonHeight) / 2;
        
        if (GUI.Button(new Rect(startX, startY, buttonWidth, buttonHeight), "Новая игра"))
        {
            Debug.Log("Новая игра");
            // Здесь загрузка сцены
        }
        
        if (GUI.Button(new Rect(startX, startY + buttonHeight + 10, buttonWidth, buttonHeight), "Настройки"))
        {
            Debug.Log("Открыть настройки");
        }
        
        if (GUI.Button(new Rect(startX, startY + 2 * (buttonHeight + 10), buttonWidth, buttonHeight), "Выход"))
        {
            Debug.Log("Выход");
            Application.Quit();
        }
    }
}
```

**Ключевые моменты:**
- ✅ `OnGUI()` — вызывается каждый кадр
- ✅ `GUI.Button(Rect, text)` — создание кнопки
- ✅ `Rect(x, y, width, height)` — позиция и размер

---

## 📊 СРАВНЕНИЕ ПОДХОДОВ

| Подход | Когда использовать | Плюсы | Минусы |
|--------|-------------------|-------|--------|
| **UI Toolkit** | Новые проекты, сложные интерфейсы, кроссплатформенность | Современный, гибкий, производительный, разделение логики и стилей | Требует изучения новых концепций (UXML/USS) |
| **uGUI** | Существующие проекты, быстрое визуальное прототипирование | Визуальный редактор, огромное количество туториалов, простота | Может быть медленным при тысячах элементов |
| **IMGUI (OnGUI)** | Прототипы, отладочные инструменты, очень простые меню | Не требует настройки сцены, пишется "на коленке" | Нет визуального редактора, тормозит, некрасиво |

---

## 🎯 РЕКОМЕНДАЦИИ

### Для DragRaceUnity:

| Система | Применение |
|---------|------------|
| **UI Toolkit** | ✅ Главное меню, HUD, настройки |
| **uGUI** | ❌ Не использовать (устарело) |
| **IMGUI** | ⚠️ Только для отладочных панелей |

---

## 🧐 ЧАСТЫЕ ПРОБЛЕМЫ И РЕШЕНИЯ

### Проблема 1: Текст на кнопке не виден (UI Toolkit)

**Причина:** Цвет текста сливается с фоном

**Решение:**
```csharp
// Убедитесь, что цвет текста не сливается с фоном
myButton.style.color = new StyleColor(Color.white);

// Или проверьте, есть ли у кнопки текст
myButton.text = "Видимый текст";
```

---

### Проблема 2: Иконка не отображается или не на своём месте

**Причина:** Неправильное направление flex

**Решение:**
```csharp
// Для изменения позиции иконки используйте USS-свойство flex-direction
// В коде это делается так:
myButton.style.flexDirection = FlexDirection.RowReverse; // Иконка справа

// Или
myButton.style.flexDirection = FlexDirection.Column; // Иконка сверху
```

---

### Проблема 3: Кнопка не генерируется внутри ScrollView

**Причина:** Добавление в корень вместо contentContainer

**Решение:**
```csharp
// Всегда проверяйте, что нашли правильный корневой элемент
var scrollView = GetComponent<UIDocument>().rootVisualElement.Q<ScrollView>("MyScrollView");

// Добавляйте не в корень, а в contentContainer ScrollView
scrollView.contentContainer.Add(new Button() { text = "Новый элемент" });
```

---

## 🚀 ГОТОВЫЕ ПРИМЕРЫ ДЛЯ ВДОХНОВЕНИЯ

### 1. Табулированное меню

**Основа:** Официальная документация Unity

**Применение:** Настройки, инвентарь, характеристики

**Ссылка:** [Unity UI Toolkit Tabs](https://docs.unity3d.com/Manual/UIElements-UXML.html)

---

### 2. Контекстное круговое меню

**Основа:** Unity Learning Materials

**Применение:** Radial menu для инвентаря

**Ссылка:** [Unity Radial Menu](https://learn.unity.com/)

---

### 3. Меню с состояниями

**Основа:** Туториалы по сетевым играм

**Применение:** Загрузка, ошибка, успех

**Пример:**
```csharp
public enum MenuState { Loading, Error, Success }

public void SetState(MenuState state)
{
    switch (state)
    {
        case MenuState.Loading:
            loadingPanel.style.display = DisplayStyle.Flex;
            break;
        case MenuState.Error:
            errorPanel.style.display = DisplayStyle.Flex;
            break;
        case MenuState.Success:
            successPanel.style.display = DisplayStyle.Flex;
            break;
    }
}
```

---

## 🎯 ПРИМЕНЕНИЕ В DRAGRACEUNITY

### Главное меню (UI Toolkit)

**Файл:** `Assets/UI/MainMenuManager.cs`

```csharp
using UnityEngine;
using UnityEngine.UIElements;
using UnityEngine.SceneManagement;

public class MainMenuManager : MonoBehaviour
{
    private UIDocument document;
    
    private void OnEnable()
    {
        document = GetComponent<UIDocument>();
        var root = document.rootVisualElement;
        
        // Находим кнопки из UXML
        var newGameButton = root.Q<Button>("NewGameButton");
        var exitButton = root.Q<Button>("ExitButton");
        
        // Подписываемся на события
        newGameButton?.RegisterCallback<ClickEvent>(StartNewGame);
        exitButton?.RegisterCallback<ClickEvent>(QuitGame);
    }
    
    private void StartNewGame(ClickEvent evt)
    {
        Debug.Log("Новая игра");
        SceneManager.LoadScene("GameScene");
    }
    
    private void QuitGame(ClickEvent evt)
    {
        Debug.Log("Выход");
        Application.Quit();
    }
}
```

---

### HUD гонки (UI Toolkit)

**Файл:** `Assets/UI/RaceHUDManager.cs`

```csharp
using UnityEngine;
using UnityEngine.UIElements;

public class RaceHUDManager : MonoBehaviour
{
    public UIDocument hudDocument;
    private Label speedLabel;
    private Label timeLabel;
    private Label positionLabel;

    void Start()
    {
        var root = hudDocument.rootVisualElement;
        speedLabel = root.Q<Label>("speedLabel");
        timeLabel = root.Q<Label>("timeLabel");
        positionLabel = root.Q<Label>("positionLabel");
    }

    public void UpdateSpeed(float speed)
    {
        speedLabel.text = $"{speed:F0} km/h";
    }

    public void UpdateTime(float time)
    {
        timeLabel.text = $"{time:F2} s";
    }

    public void UpdatePosition(int position)
    {
        positionLabel.text = $"Pos: {position}/8";
    }
}
```

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`02_UNITY/UI_TOOLKIT_BASIC_MENUS.md`](./02_UNITY/UI_TOOLKIT_BASIC_MENUS.md) — Базовые меню
- [`02_UNITY/UI_TOOLKIT_UNITY6_BOOK.md`](./02_UNITY/UI_TOOLKIT_UNITY6_BOOK.md) — Книга UI Toolkit
- [`01_RULES/ui_toolkit_rules.md`](./01_RULES/ui_toolkit_rules.md) — Правила UI Toolkit

---

## 📚 ССЫЛКИ

- [Официальная документация UI Toolkit](https://docs.unity3d.com/Manual/UIElements.html)
- [Unity UI Toolkit Samples](https://github.com/unity-samples/ui-toolkit-samples)
- [Habr: Эволюция UI в Unity](https://habr.com/ru/articles/unity-menu-evolution)

---

**Статус:** ✅ Stable (готово к применению)

**Последнее обновление:** 2026-02-28
