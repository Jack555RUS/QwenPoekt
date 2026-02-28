# 🎨 MENU CREATION — ПАТТЕРН СОЗДАНИЯ МЕНЮ

**Версия:** 1.0  
**Дата:** 28 февраля 2026 г.

---

## 🎯 НАЗНАЧЕНИЕ

Этот файл описывает **паттерн создания меню** в проекте DragRaceUnity.

**Пример:** Главное меню (MainMenu)

---

## 📋 ШАБЛОН СОЗДАНИЯ

### Шаг 1: Создать сцену

```
1. File → New Scene → 2D (URP)
2. Сохранить: Assets/Scenes/MainMenu.unity
3. Добавить в Build Settings (File → Build Settings → Add Open Scenes)
```

---

### Шаг 2: Добавить Canvas

```
1. GameObject → UI → Canvas
2. Canvas Scaler:
   - UI Scale Mode: Scale With Screen Size
   - Reference Resolution: 1920 x 1080
   - Screen Match Mode: Match Width or Height (0.5)
```

---

### Шаг 3: Добавить EventSystem

```
1. GameObject → UI → Event System
2. Создаётся автоматически с Canvas
```

---

### Шаг 4: Создать кнопки

**Шаблон кнопки:**

```
GameObject: Button - TextMeshPro
Имя: [Action]Button (например, NewGameButton)
Rect Transform:
  - Pos X: 0
  - Pos Y: [смещение]
  - Width: 300
  - Height: 60
Text:
  - Текст: [НАЗВАНИЕ]
  - Font Size: 24
  - Alignment: Center
Colors:
  - Normal: RGB(128, 128, 128)
  - Highlighted: RGB(160, 160, 160)
  - Pressed: RGB(100, 100, 100)
```

**Пример для 6 кнопок:**

| Имя | Pos Y | Текст |
|-----|-------|-------|
| NewGameButton | 250 | НОВАЯ ИГРА |
| ContinueButton | 170 | ПРОДОЛЖИТЬ |
| SaveButton | 90 | СОХРАНИТЬ |
| LoadButton | 10 | ЗАГРУЗИТЬ |
| SettingsButton | -70 | НАСТРОЙКИ |
| ExitButton | -150 | ВЫХОД |

---

### Шаг 5: Добавить контроллер

```
1. GameObject → Create Empty
2. Имя: MainMenuManager
3. Добавить компонент: MainMenuController
```

**Код контроллера:**

```csharp
using UnityEngine;
using UnityEngine.UIElements;

public class MainMenuController : MonoBehaviour
{
    private void OnEnable()
    {
        Logger.Info("[MainMenu] Главное меню загружено");
    }
    
    public void OnNewGame() => Logger.Info("[MainMenu] Новая игра");
    public void OnContinue() => Logger.Info("[MainMenu] Продолжить");
    public void OnSave() => Logger.Info("[MainMenu] Сохранить");
    public void OnLoad() => Logger.Info("[MainMenu] Загрузить");
    public void OnSettings() => Logger.Info("[MainMenu] Настройки");
    public void OnExit() => Logger.Info("[MainMenu] Выход");
}
```

---

### Шаг 6: Настроить onClick

**Для каждой кнопки:**

```
1. Выбрать кнопку
2. В инспекторе, компонент Button
3. Развернуть On Click ()
4. Нажать +
5. Перетащить MainMenuManager
6. Выбрать функцию: MainMenuController.OnNewGame
```

**Таблица соответствий:**

| Кнопка | Функция |
|--------|---------|
| NewGameButton | MainMenuController.OnNewGame |
| ContinueButton | MainMenuController.OnContinue |
| SaveButton | MainMenuController.OnSave |
| LoadButton | MainMenuController.OnLoad |
| SettingsButton | MainMenuController.OnSettings |
| ExitButton | MainMenuController.OnExit |

---

### Шаг 7: Настроить навигацию

**Для каждой кнопки:**

```
1. Выбрать кнопку
2. В инспекторе, компонент Button
3. Развернуть Navigation
4. Режим: Automatic
5. Заполнить Select On Up/Down
```

**Пример зацикливания:**

```csharp
// NewGameButton:
Select On Up: ExitButton (зацикливание)
Select On Down: ContinueButton

// ExitButton:
Select On Up: SettingsButton
Select On Down: NewGameButton (зацикливание)
```

---

## 📝 ЧЕК-ЛИСТ ПРОВЕРКИ

Перед тестом:

- [ ] Сцена добавлена в Build Settings
- [ ] Canvas в режиме Screen Space - Overlay
- [ ] Все кнопки имеют имена
- [ ] Текст кнопок настроен
- [ ] Colors кнопок настроены
- [ ] onClick настроен для всех кнопок
- [ ] Navigation настроен для всех кнопок
- [ ] TextMeshPro Essentials импортирован
- [ ] MainMenuManager со скриптом на сцене

---

## 🐛 ТИПИЧНЫЕ ОШИБОКИ

### Ошибка: Кнопка не подсвечивается

**Причина:** Не настроен Navigation

**Решение:** См. [`03_PATTERNS/error_solutions.md`](./03_PATTERNS/error_solutions.md) (раздел "UI/Кнопки")

---

### Ошибка: Текст не отображается

**Причина:** Не импортирован TextMeshPro Essentials

**Решение:** `Window` → `TextMeshPro` → `Import TMP Essentials`

---

### Ошибка: onClick не работает

**Причина:** Нет ссылки в On Click ()

**Решение:** Добавить ссылку на MainMenuManager, выбрать функцию

---

## 🔗 ПРИМЕРЫ

### Готовое меню:

**Сцена:** `Assets/Scenes/MainMenu.unity`

**Контроллер:** `Assets/Scripts/UI/MainMenuController.cs`

**Префаб:** `Assets/Prefabs/MainMenu/` (если есть)

---

## 📊 СТАТИСТИКА

| Параметр | Значение |
|----------|----------|
| Кнопок | 6 |
| Время создания | 15 минут |
| Скриптов | 1 (MainMenuController.cs) |
| Тестов | 10 (MainMenuControllerTests.cs) |

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`01_RULES/ui_toolkit_rules.md`](./01_RULES/ui_toolkit_rules.md) — Правила UI
- [`03_PATTERNS/error_solutions.md`](./03_PATTERNS/error_solutions.md) — База ошибок
- [`02_TOOLS/powershell_scripts.md`](./02_TOOLS/powershell_scripts.md) — Сборка

---

**Правило:** Все меню создаются по этому паттерну! ✅

**Последнее обновление:** 28 февраля 2026 г.
