---
status: stable
created: 2026-02-28
last_reviewed: 2026-02-28
source: Unity Documentation
---
# 🔧 РУКОВОДСТВО ПО КНОПКАМ UNITY — Текст не отображается

**Версия:** 1.0  
**Дата:** 28 февраля 2026 г.  
**Статус:** ✅ Обязательно к применению

---

## ❌ ВОЗМОЖНЫЕ ПРИЧИНЫ

### 1. Нет компонента для отображения текста

**Проблема:**
На кнопке нет дочернего объекта с Text или TextMeshPro

**Решение:**
```
ПКМ на кнопке → UI → Text - TextMeshPro
Или создать вручную дочерний объект с Text компонентом
```

---

### 2. Шрифт не назначен

**Проблема:**
Font Asset пустое

**Решение:**
```
1. Выбрать Text (TMP)
2. В Inspector → Font Asset → Выбрать любой шрифт
3. Или: Window → TextMeshPro → Import TMP Essential Resources
```

---

### 3. Цвет текста = цвету фона

**Проблема:**
Текст сливается с фоном или alpha = 0

**Решение:**
```
1. Выбрать Text
2. В Inspector → Color → Белый (R:255, G:255, B:255, A:255)
```

---

### 4. Canvas настроен неправильно

**Проблема:**
Render Mode не подходит

**Решение:**
```
1. Выбрать Canvas
2. В Inspector → Render Mode: Screen Space - Overlay
3. Для 2D меню это оптимально
```

---

### 5. Кнопка за пределами экрана

**Проблема:**
Rect Transform вне видимой области

**Решение:**
```
1. Выбрать кнопку
2. Проверить Rect Transform → Position
3. Должен быть в пределах 1920x1080
```

---

### 6. Отсутствует EventSystem

**Проблема:**
Нет обработки ввода

**Решение:**
```
GameObject → UI → Event System
Или создать вручную компонент EventSystem
```

---

### 7. Не та система UI

**Проблема:**
Legacy Text без пакета

**Решение:**
```
Использовать TextMeshPro (рекомендуется)
Или импортировать Legacy UI пакет
```

---

### 8. Порядок сортировки

**Проблема:**
Canvas перекрывается

**Решение:**
```
1. Выбрать Canvas
2. В Inspector → Sorting Layer → Выше других
3. Order in Layer → Больше
```

---

## ✅ ПРИМЕР КОДА: SimpleMenu

```csharp
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using TMPro;

public class SimpleMenu : MonoBehaviour
{
    // Ссылки на кнопки
    public Button playButton;
    public Button exitButton;

    void Start()
    {
        // Подписываемся на события
        if (playButton != null)
            playButton.onClick.AddListener(PlayGame);
        else
            Debug.LogError("Play button not assigned!");

        if (exitButton != null)
            exitButton.onClick.AddListener(ExitGame);
        else
            Debug.LogError("Exit button not assigned!");
    }

    void PlayGame()
    {
        Debug.Log("Play button clicked");
        SceneManager.LoadScene("GameScene");
    }

    void ExitGame()
    {
        Debug.Log("Exit button clicked");
        Application.Quit();
    }
}
```

---

## 🔧 НАСТРОЙКА В СЦЕНЕ

### Шаг 1: Создать Canvas

```
ПКМ в Hierarchy → UI → Canvas
Render Mode: Screen Space - Overlay
```

### Шаг 2: Добавить EventSystem

```
GameObject → UI → Event System
(обычно создаётся автоматически)
```

### Шаг 3: Создать кнопки

```
ПКМ на Canvas → UI → Button - TextMeshPro
Так создастся кнопка с Text (TMP)
```

### Шаг 4: Настроить текст

```
1. Выбрать дочерний Text (TMP)
2. В Inspector → Text: "Играть"
3. Font Asset: LiberationSans SDF
4. Color: Белый
5. Font Size: 24
6. Alignment: Center
```

### Шаг 5: Настроить кнопку

```
1. Выбрать кнопку
2. В Inspector → Button → Colors:
   - Normal: Серый
   - Highlighted: Светло-серый
   - Pressed: Тёмный
   - Selected: Жёлтый
```

### Шаг 6: Назначить скрипт

```
1. Создать пустой GameObject "MenuManager"
2. Добавить скрипт SimpleMenu
3. Перетащить кнопки в поля скрипта
```

---

## 🧪 ДИНАМИЧЕСКОЕ СОЗДАНИЕ (из кода)

```csharp
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.SceneManagement;

public class DynamicMenu : MonoBehaviour
{
    public Canvas canvas;

    void Start()
    {
        CreateButton("Играть", new Vector2(0, 50), PlayGame);
        CreateButton("Выход", new Vector2(0, -50), ExitGame);
    }

    void CreateButton(string buttonText, Vector2 position, UnityEngine.Events.UnityAction action)
    {
        // Кнопка
        GameObject buttonObj = new GameObject(buttonText + "Button", typeof(RectTransform), typeof(Button));
        buttonObj.transform.SetParent(canvas.transform, false);

        RectTransform rect = buttonObj.GetComponent<RectTransform>();
        rect.sizeDelta = new Vector2(200, 50);
        rect.anchoredPosition = position;

        // Текст
        GameObject textObj = new GameObject("Text", typeof(RectTransform), typeof(TextMeshProUGUI));
        textObj.transform.SetParent(buttonObj.transform, false);

        TextMeshProUGUI tmp = textObj.GetComponent<TextMeshProUGUI>();
        tmp.text = buttonText;
        tmp.fontSize = 24;
        tmp.alignment = TextAlignmentOptions.Center;
        tmp.color = Color.white;

        RectTransform textRect = textObj.GetComponent<RectTransform>();
        textRect.anchorMin = Vector2.zero;
        textRect.anchorMax = Vector2.one;
        textRect.sizeDelta = Vector2.zero;

        // Обработчик
        Button btn = buttonObj.GetComponent<Button>();
        btn.onClick.AddListener(action);
    }

    void PlayGame()
    {
        SceneManager.LoadScene("GameScene");
    }

    void ExitGame()
    {
        Application.Quit();
    }
}
```

---

## 📊 ЧЕКЛИСТ ПРОВЕРКИ

- [ ] Canvas есть в сцене
- [ ] Render Mode: Screen Space - Overlay
- [ ] EventSystem есть
- [ ] Кнопки имеют дочерний Text (TMP)
- [ ] Font Asset назначен
- [ ] Цвет текста: Белый (A:255)
- [ ] Rect Transform в пределах экрана
- [ ] Sorting Layer правильный
- [ ] onClick события назначены

---

## 🐛 ОТЛАДКА

### UI Debugger:

```
Window → Analysis → UI Debugger
Показывает визуальное дерево Canvas
```

### Проверка перекрытий:

```
1. Открыть UI Debugger
2. Проверить что кнопки видны в дереве
3. Проверить что нет перекрывающих объектов
```

### Консоль:

```
Проверить Debug.LogError сообщения
Если кнопка не назначена → будет ошибка
```

---

## 📚 БАЗА ЗНАНИЙ

### Обязательные файлы:

| Файл | Назначение |
|------|------------|
| **`UNITY_BUTTONS_GUIDE.md`** | Этот файл |
| **`LOG_ANALYSIS_METHODOLOGY.md`** | Анализ ошибок |
| **`UNITY_DOCUMENTATION_GUIDE.md`** | Документация |

---

**Руководство сохранено!** 🔧

**Применять для всех кнопок!** 📋
