# 🎮 DragRaceUnity — Быстрый старт

**Версия:** 1.0  
**Дата:** 27 февраля 2026 г.  
**Статус:** ✅ Чистый проект, начало разработки

---

## 📋 Шаг 1: Открытие проекта в Unity

1. Откройте **Unity Hub**
2. Нажмите **Add** → **Add project from disk**
3. Выберите папку: `D:\QwenPoekt\PROJECTS\DragRaceUnity`
4. Проект появится в списке
5. Нажмите на проект для открытия

---

## 🎯 Шаг 2: Создание сцены MainMenu

### 2.1. Создать сцену
1. `File` → `New Scene` → `2D (URP)` или `2D Core`
2. Сохраните сцену: `File` → `Save As`
3. Путь: `Assets/Scenes/MainMenu.unity`

### 2.2. Добавить Canvas
1. `GameObject` → `UI` → `Canvas`
2. В инспекторе Canvas Scaler:
   - **UI Scale Mode:** Scale With Screen Size
   - **Reference Resolution:** 1920 x 1080
   - **Screen Match Mode:** Match Width or Height (0.5)

### 2.3. Добавить EventSystem
1. `GameObject` → `UI` → `Event System`
2. Должен создаться автоматически с Canvas

---

## 🔘 Шаг 3: Создание 6 кнопок

### 3.1. Создать первую кнопку (Новая игра)
1. `GameObject` → `UI` → `Button - TextMeshPro`
2. Переименуйте в `NewGameButton`
3. Настройте Rect Transform:
   - **Pos X:** 0
   - **Pos Y:** 250
   - **Width:** 300
   - **Height:** 60

### 3.2. Настроить текст кнопки
1. Разверните `NewGameButton` → выберите `Text (TMP)`
2. В инспекторе TextMeshPro:
   - **Text:** НОВАЯ ИГРА
   - **Font Size:** 24
   - **Alignment:** Center

### 3.3. Настроить цвета кнопки
В компоненте `Button`:
- **Normal Color:** Серый (R:128, G:128, B:128, A:255)
- **Highlighted Color:** Светло-серый (R:160, G:160, B:160, A:255)
- **Pressed Color:** Тёмный (R:100, G:100, B:100, A:255)
- **Selected Color:** Ярко-жёлтый (R:255, G:255, B:0, A:255)

### 3.4. Создать остальные 5 кнопок
Скопируйте `NewGameButton` (Ctrl+D) и разместите:

| Кнопка | Имя | Pos Y | Текст |
|--------|-----|-------|-------|
| 1 | NewGameButton | 250 | НОВАЯ ИГРА |
| 2 | ContinueButton | 170 | ПРОДОЛЖИТЬ |
| 3 | SaveButton | 90 | СОХРАНИТЬ |
| 4 | LoadButton | 10 | ЗАГРУЗИТЬ |
| 5 | SettingsButton | -70 | НАСТРОЙКИ |
| 6 | ExitButton | -150 | ВЫХОД |

---

## 🧠 Шаг 4: Добавить контроллер меню

### 4.1. Создать пустой GameObject
1. `GameObject` → `Create Empty`
2. Переименуйте в `MainMenuManager`

### 4.2. Добавить скрипт
1. Перетащите `Assets/03-Resources/PowerShell/UI/MainMenuController.cs` на `MainMenuManager`
2. Или: `Add Component` → `MainMenuController`

### 4.3. Настроить onClick для кнопок
Для каждой кнопки:
1. Выберите кнопку (например, `NewGameButton`)
2. В инспекторе, компонент `Button`
3. Найдите секцию **On Click ()**
4. Нажмите **+**
5. Перетащите `MainMenuManager` в поле объекта
6. Выберите функцию: `MainMenuController.OnNewGame()`

Повторите для всех кнопок:

| Кнопка | Функция |
|--------|---------|
| NewGameButton | MainMenuController.OnNewGame |
| ContinueButton | MainMenuController.OnContinue |
| SaveButton | MainMenuController.OnSave |
| LoadButton | MainMenuController.OnLoad |
| SettingsButton | MainMenuController.OnSettings |
| ExitButton | MainMenuController.OnExit |

---

## ⌨️ Шаг 5: Настроить навигацию (клавиатура)

Для каждой кнопки настройте **Navigation**:

1. Выберите кнопку (например, `NewGameButton`)
2. В инспекторе, компонент `Button`
3. Разверните секцию **Navigation**
4. **Navigation Mode:** Automatic
5. Заполните ссылки:

**NewGameButton:**
- Select On Up: `ExitButton` (зацикливание)
- Select On Down: `ContinueButton`

**ContinueButton:**
- Select On Up: `NewGameButton`
- Select On Down: `SaveButton`

**SaveButton:**
- Select On Up: `ContinueButton`
- Select On Down: `LoadButton`

**LoadButton:**
- Select On Up: `SaveButton`
- Select On Down: `SettingsButton`

**SettingsButton:**
- Select On Up: `LoadButton`
- Select On Down: `ExitButton`

**ExitButton:**
- Select On Up: `SettingsButton`
- Select On Down: `NewGameButton` (зацикливание)

---

## ▶️ Шаг 6: Добавить сцену в Build Settings

1. `File` → `Build Settings`
2. Нажмите **Add Open Scenes**
3. MainMenu.unity появится в списке
4. Убедитесь, что сцена имеет индекс **0**

---

## 🧪 Шаг 7: Тестирование

### 7.1. Запуск в Editor
1. Нажмите **Play** (треугольник вверху)
2. Проверьте:
   - ✅ Кнопки подсвечиваются при наведении мыши
   - ✅ Кнопки реагируют на клик
   - ✅ Клавиатура (↑↓Enter) работает
   - ✅ В Console видны логи нажатий

### 7.2. Проверка логов
Откройте `Window` → `General` → `Console`

При нажатии кнопок должно выводиться:
```
[MainMenu] Главное меню загружено. Ожидание ввода...
[MainMenu] Нажата кнопка: НОВАЯ ИГРА
```

---

## 🐛 Типичные проблемы

### Кнопка не работает от мыши
**Причина:** Нет ссылки в onClick  
**Решение:** Проверьте On Click () в инспекторе кнопки

### Клавиатура не работает
**Причина:** Нет навигации (Navigation)  
**Решение:** Настройте Select On Up/Down для каждой кнопки

### Текст не отображается
**Причина:** Не установлен TextMeshPro Essentials  
**Решение:** `Window` → `TextMeshPro` → `Import TMP Essentials`

### Кнопки не видны
**Причина:** Неправильный Z-order или Camera  
**Решение:** Убедитесь, что Canvas в режиме `Screen Space - Overlay`

---

## 📊 Чек-лист готовности

- [ ] Unity проект открыт
- [ ] Создана сцена MainMenu.unity
- [ ] Добавлен Canvas с настройками
- [ ] Добавлен EventSystem
- [ ] Создано 6 кнопок с правильными именами
- [ ] Текст кнопок настроен (русский текст)
- [ ] Цвета кнопок настроены
- [ ] Добавлен MainMenuManager со скриптом
- [ ] Все кнопки имеют onClick обработчики
- [ ] Навигация (клавиатура) настроена
- [ ] Сцена добавлена в Build Settings
- [ ] Тест в Editor пройден

---

## 🚀 Следующие шаги

После успешного создания меню:

1. ✅ Добавить логику для кнопок
2. ✅ Создать систему сохранений
3. ✅ Добавить другие сцены (GameMenu, Garage, etc.)
4. ✅ Добавить графику и звуки

---

**Удачи в разработке!** 🎯

