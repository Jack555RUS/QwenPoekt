---
status: stable
created: 2026-02-28
last_reviewed: 2026-02-28
source: Project Rules
---
# 🎨 UI TOOLKIT — ПРАВИЛА И СТАНДАРТЫ

**Версия:** 1.0  
**Дата:** 28 февраля 2026 г.

---

## 🎯 НАЗНАЧЕНИЕ

Этот файл описывает **правила создания интерфейсов** в проекте DragRaceUnity.

**Приоритет:** UI Toolkit (UXML, USS, C#)

---

## 📋 ОСНОВНЫЕ ПРИНЦИПЫ

### 1. Разделение ответственности

```
UXML → Разметка (как HTML)
USS  → Стили (как CSS)
C#   → Логика (события)
```

### 2. Структура файлов

```
Assets/
└── UI/
    ├── MainMenu/
    │   ├── MainMenu.uxml      # Разметка
    │   ├── MainMenu.uss       # Стили
    │   └── MainMenuController.cs  # Логика
```

---

## 🔘 СОЗДАНИЕ КНОПКИ

### Пример (C#):

```csharp
using UnityEngine.UIElements;

public class MainMenuController : MonoBehaviour
{
    private Button newGameButton;
    
    private void OnEnable()
    {
        // Находим кнопку
        newGameButton = rootVisualElement.Q<Button>("NewGameButton");
        
        // Подписываемся на событие
        newGameButton.clicked += OnNewGameClicked;
    }
    
    private void OnDisable()
    {
        // ⚠️ ВАЖНО: Отписываемся!
        newGameButton.clicked -= OnNewGameClicked;
    }
    
    private void OnNewGameClicked()
    {
        Debug.Log("[MainMenu] Новая игра нажата");
        // Логика...
    }
}
```

### Пример (UXML):

```xml
<ui:UXML xmlns:ui="UnityEngine.UIElements">
    <Button name="NewGameButton" text="НОВАЯ ИГРА" />
</ui:UXML>
```

### Пример (USS):

```css
#NewGameButton {
    width: 300px;
    height: 60px;
    background-color: rgb(128, 128, 128);
}

#NewGameButton:hover {
    background-color: rgb(160, 160, 160);
}

#NewGameButton:active {
    background-color: rgb(100, 100, 100);
}
```

---

## 📝 ПРАВИЛА ПОДПИСКИ НА СОБЫТИЯ

### ✅ ПРАВИЛЬНО:

```csharp
private void OnEnable()
{
    button.clicked += HandleClick;
}

private void OnDisable()
{
    button.clicked -= HandleClick;  // ← Отписка!
}
```

### ❌ НЕПРАВИЛЬНО:

```csharp
// ❌ Без отписки (утечка памяти!)
private void Start()
{
    button.clicked += HandleClick;
}
```

---

## 🎯 НАВИГАЦИЯ КЛАВИАТУРОЙ

### Настройка (в инспекторе Unity):

1. Выбрать кнопку
2. Компонент `Button`
3. Развернуть `Navigation`
4. Режим: `Automatic`
5. Заполнить:
   - `Select On Up` → кнопка выше
   - `Select On Down` → кнопка ниже
   - `Select On Left` → кнопка слева
   - `Select On Right` → кнопка справа

### Зацикливание:

```
Кнопка 1 (верх)
  ↑
Кнопка 6 (низ)
```

Для зацикливания:
- У первой кнопки: `Select On Up` → последняя кнопка
- У последней кнопки: `Select On Down` → первая кнопка

---

## 🐛 ПРОВЕРКА ОШИБОК

### Чек-лист перед тестом:

- [ ] Все кнопки имеют имена (`name` attribute)
- [ ] События подписаны в `OnEnable`
- [ ] События отписаны в `OnDisable`
- [ ] Navigation настроен для всех кнопок
- [ ] TextMeshPro Essentials импортирован
- [ ] Шрифты выбраны в кнопках

### Если кнопка не работает:

1. Проверь `On Click ()` в инспекторе
2. Проверь Navigation
3. Проверь, видна ли кнопка (Canvas, Camera)
4. Смотри [`03_PATTERNS/error_solutions.md`](./03_PATTERNS/error_solutions.md)

---

## 📊 СТАТИСТИКА UI

| Элемент | Количество | Файл |
|---------|------------|------|
| Кнопки | 6 | `MainMenu.unity` |
| Сцены UI | 1 | `MainMenu` |
| Контроллеров | 1 | `MainMenuController.cs` |

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`00_CORE/csharp_standards.md`](./00_CORE/csharp_standards.md) — Стандарты кода
- [`03_PATTERNS/menu_creation.md`](./03_PATTERNS/menu_creation.md) — Примеры создания меню
- [`03_PATTERNS/error_solutions.md`](./03_PATTERNS/error_solutions.md) — База ошибок UI

---

**Правило:** Все UI создаются через UI Toolkit! ✅

**Последнее обновление:** 28 февраля 2026 г.
