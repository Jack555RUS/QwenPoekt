---
topic: UI Toolkit ListView
status: draft
review_date: 2026-03-01
---

# 📋 UI Toolkit: ListView

**Версия:** 1.0  
**Статус:** ⏳ Черновик  
**Обновлено:** 2026-03-01

---

## 🎯 Назначение

**ListView** — это переиспользуемый элемент UI для отображения списков данных с виртуализацией.

**Когда использовать:**
- ✅ Длинные списки (10+ элементов)
- ✅ Динамические данные (добавление/удаление)
- ✅ Выбор одного или нескольких элементов
- ✅ Табличные данные

**Когда НЕ использовать:**
- ❌ Короткие статические списки (используй `ScrollView` + `VisualElement`)
- ❌ Сложные кастомные layouts

---

## 🔧 Основные компоненты

### 1. ListView

```csharp
using UnityEngine.UIElements;

public class MyListView : MonoBehaviour
{
    private ListView listView;

    private void Awake()
    {
        var root = GetComponent<UIDocument>().rootVisualElement;
        listView = root.Q<ListView>("my-list");

        // Настройка источника данных
        var items = new List<string> { "Item 1", "Item 2", "Item 3" };
        listView.itemsSource = items;

        // Настройка фабрики элементов
        listView.makeItem = () => new Label();

        // Настройка привязки данных
        listView.bindItem = (element, index) =>
        {
            var label = (Label)element;
            label.text = items[index];
        };

        // Обработка выбора
        listView.selectionChanged += OnSelectionChanged;
    }

    private void OnSelectionChanged(IEnumerable<object> selected)
    {
        foreach (var item in selected)
        {
            Debug.Log($"Выбрано: {item}");
        }
    }
}
```

### 2. Основные свойства

| Свойство | Тип | Описание |
|----------|-----|----------|
| `itemsSource` | IList | Источник данных |
| `makeItem` | Func<VisualElement> | Фабрика создания элементов |
| `bindItem` | Action<VisualElement, int> | Привязка данных к элементу |
| `selectionType` | SelectionType | Тип выбора (Single/Multiple) |
| `showAlternatingRowBackgrounds` | bool | Чередование фона строк |
| `showBorder` | bool | Показывать границу |
| `showBoundCollectionSize` | bool | Показывать размер коллекции |

---

## 📖 Примеры использования

### Пример 1: Простой список строк

```csharp
var listView = new ListView
{
    itemsSource = new List<string> { "Apple", "Banana", "Cherry" },
    makeItem = () => new Label(),
    bindItem = (element, index) =>
    {
        var label = (Label)element;
        label.text = ((List<string>)listView.itemsSource)[index];
    }
};
```

### Пример 2: Список сложных объектов

```csharp
public class CarItem
{
    public string Name { get; set; }
    public int Speed { get; set; }
}

var cars = new List<CarItem>
{
    new CarItem { Name = "Ferrari", Speed = 350 },
    new CarItem { Name = "Lamborghini", Speed = 340 }
};

var listView = new ListView
{
    itemsSource = cars,
    makeItem = () =>
    {
        var container = new HorizontalGroup();
        container.Add(new Label { name = "NameLabel" });
        container.Add(new Label { name = "SpeedLabel" });
        return container;
    },
    bindItem = (element, index) =>
    {
        var car = cars[index];
        element.Q<Label>("NameLabel").text = car.Name;
        element.Q<Label>("SpeedLabel").text = car.Speed.ToString();
    }
};
```

### Пример 3: С выбором нескольких элементов

```csharp
var listView = new ListView
{
    itemsSource = Enumerable.Range(1, 100).Select(i => $"Item {i}").ToList(),
    makeItem = () => new Label(),
    bindItem = (element, index) =>
    {
        var label = (Label)element;
        label.text = ((List<string>)listView.itemsSource)[index];
    },
    selectionType = SelectionType.Multiple,
    showAlternatingRowBackgrounds = true
};
```

---

## 🎨 Стилизация через USS

```css
/* ListView.uss */

ListView {
    -unity-font-style: bold;
}

ListView .unity-list-view__line {
    background-color: white;
}

ListView .unity-list-view__line:nth-child(odd) {
    background-color: rgb(240, 240, 240);
}

ListView .unity-list-view__line:selected {
    background-color: rgb(0, 120, 215);
    color: white;
}
```

---

## ⚠️ Распространённые ошибки

### Ошибка 1: NullReferenceException при bindItem

**Проблема:**
```csharp
listView.bindItem = (element, index) =>
{
    element.Q<Label>().text = items[index]; // ❌ NullReferenceException
};
```

**Решение:**
```csharp
listView.bindItem = (element, index) =>
{
    var label = element.Q<Label>("my-label"); // ✅ С именем
    label.text = items[index];
};
```

### Ошибка 2: Элементы не обновляются

**Проблема:** Изменение `itemsSource` не обновляет UI.

**Решение:**
```csharp
// После изменения данных
listView.Rebuild();

// Или используйте ObservableCollection
var observableItems = new ObservableCollection<string>();
listView.itemsSource = observableItems;
```

---

## 🔗 Связанные файлы

- [`UI_TOOLKIT_GUIDE.md`](./UI_TOOLKIT_GUIDE.md) — Основное руководство
- [`ScrollView.md`](./ScrollView.md) — ScrollView для простых списков
- [`DataBinding.md`](./DataBinding.md) — Привязка данных

---

**Дата создания:** 2026-03-01  
**Статус:** ⏳ Черновик
