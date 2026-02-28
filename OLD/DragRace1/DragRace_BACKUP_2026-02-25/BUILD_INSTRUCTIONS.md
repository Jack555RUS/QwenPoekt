# Drag Race - Инструкция по сборке

## Требования

- **Unity**: 2021.3.15f1 LTS или новее
- **Платформа**: Windows 64-bit
- **Scripting Backend**: IL2CPP
- **API Compatibility**: .NET Standard 2.1

## Установка проекта

### Шаг 1: Создание проекта Unity

1. Откройте Unity Hub
2. Нажмите "New Project"
3. Выберите шаблон "2D Core"
4. Укажите имя проекта: `DragRace`
5. Выберите папку: `D:\QwenPoekt\DragRace\DragRace`
6. Нажмите "Create Project"

### Шаг 2: Импорт скриптов

Скопируйте все файлы из папки `Assets/Scripts` в соответствующие папки проекта Unity.

Структура папок:
```
Assets/
├── Scripts/
│   ├── Core/
│   │   ├── GameConfig.cs
│   │   ├── GameManager.cs
│   │   └── Bootstrap.cs
│   ├── Data/
│   │   ├── GameData.cs
│   │   ├── VehicleParts.cs
│   │   ├── CarDatabase.cs
│   │   └── DatabaseInitializer.cs
│   ├── Managers/
│   │   └── GameManager.cs
│   ├── SaveSystem/
│   │   └── SaveManager.cs
│   ├── InputSystem/
│   │   └── InputManager.cs
│   ├── Vehicles/
│   │   └── VehiclePhysics.cs
│   ├── Racing/
│   │   ├── RaceManager.cs
│   │   └── TrafficLight.cs
│   ├── UI/
│   │   ├── Menus/
│   │   │   ├── MainMenuUI.cs
│   │   │   └── GameMenuUI.cs
│   │   ├── DashboardUI.cs
│   │   ├── SettingsUI.cs
│   │   ├── KeyBindingsUI.cs
│   │   ├── GarageUI.cs
│   │   ├── TuningUI.cs
│   │   ├── ShopUI.cs
│   │   ├── RaceResultsUI.cs
│   │   └── CharacterScreenUI.cs
│   ├── Audio/
│   │   └── AudioManager.cs
│   ├── Effects/
│   │   └── RaceEffects.cs
│   └── Utils/
│       └── MathUtils.cs
```

### Шаг 3: Создание ScriptableObject конфигураций

1. В Project окне: `Assets → Create → DragRace → Game Config`
2. Назовите файл: `GameConfig`
3. Поместите в папку `Assets/Resources/`

4. `Assets → Create → DragRace → Car Database`
5. Назовите файл: `CarDatabase`
6. Поместите в папку `Assets/Resources/`

7. `Assets → Create → DragRace → Parts Database`
8. Назовите файл: `PartsDatabase`
9. Поместите в папку `Assets/Resources/`

### Шаг 4: Настройка GameConfig

В Inspector для GameConfig:

**Настройки разрешения:**
- Добавьте 6 записей в `Supported Resolutions`:
  - 640x480
  - 800x600
  - 1024x768
  - 1280x720 (HD)
  - 1920x1080 (Full HD)
  - 2560x1440 (2K)

**Автосохранение:**
- Auto Save Interval Minutes: 5
- Max Auto Save Slots: 5

**Сохранения:**
- Max Save Slots: 5

**Звук:**
- Default Master Volume: 80
- Default Music Volume: 60
- Default SFX Volume: 70

**Геймплей:**
- Start Money: 10000
- XP Multiplier: 1
- Money Multiplier: 1

**Дистанции заездов:**
- 1/8 мили: 201 м
- 1/4 мили: 402 м
- 1/2 мили: 804 м
- 1 миля: 1609 м

### Шаг 5: Создание сцен

#### Boot Scene (Boot.unity)
1. Создайте сцену: `File → New Scene → 2D`
2. Создайте пустой GameObject: `Bootstrap`
3. Добавьте компонент `Bootstrap` из скрипта
4. Сохраните сцену в `Assets/Scenes/Boot.unity`

#### Main Menu Scene (MainMenu.unity)
1. Создайте новую сцену
2. Добавьте Canvas для UI
3. Создайте панели для:
   - Главного меню
   - Новой игры
   - Загрузки
   - Настроек
4. Добавьте компоненты UI скриптов
5. Сохраните в `Assets/Scenes/MainMenu.unity`

#### Game Menu Scene (GameMenu.unity)
1. Создайте новую сцену
2. Добавьте Canvas для UI
3. Создайте панели для:
   - Меню игры
   - Гаража
   - Тюнинга
   - Магазина
4. Сохраните в `Assets/Scenes/GameMenu.unity`

#### Race Scene (Race.unity)
1. Создайте новую сцену
2. Добавьте:
   - Camera с RaceCamera компонентом
   - Дорогу (Sprite)
   - Префаб игрока с VehiclePhysics
   - Префаб соперника с VehiclePhysics
   - UI для приборной панели
3. Сохраните в `Assets/Scenes/Race.unity`

### Шаг 6: Настройка Build Settings

1. `File → Build Settings`
2. Добавьте сцены в порядке:
   - Boot
   - MainMenu
   - GameMenu
   - Race
3. Платформа: Windows, Mac, Linux
4. Architecture: x86_64
5. Scripting Backend: IL2CPP
6. Нажмите "Build"

## Создание префабов

### Vehicle Prefab
1. Создайте GameObject с 2D Sprite автомобиля
2. Добавьте компоненты:
   - `VehiclePhysics`
   - `Rigidbody2D` (опционально для физики)
   - `TireSmokeEffect`
   - `NitroEffect`
3. Настройте ссылки на данные
4. Перетащите в папку Prefabs

### UI Prefabs
Создайте префабы для:
- Элемента списка автомобилей
- Элемента списка запчастей
- Кнопки
- Ползунка настроек

## Тестирование

### Запуск в редакторе
1. Откройте сцену `Boot`
2. Нажмите Play
3. Проверьте:
   - Загрузку главного меню
   - Создание новой игры
   - Сохранение/загрузку
   - Настройки
   - Гараж
   - Магазин

### Проверка заезда
1. Выберите автомобиль в гараже
2. Начните заезд
3. Проверьте:
   - Управление (W, A, D, Shift)
   - Приборную панель
   - Физику автомобиля
   - ИИ соперника
   - Финиш и результаты

## Сборка релизной версии

1. `File → Build Settings`
2. Выберите платформу Windows
3. Настройте параметры:
   - Development Build: OFF
   - Compression: LZ4
   - Strip Engine Code: ON
4. Нажмите "Build and Run"

## Возможные проблемы и решения

### Ошибка: "GameManager.Instance is null"
**Решение:** Убедитесь, что Bootstrap инициализируется первым. Проверьте порядок сцен в Build Settings.

### Ошибка: "ScriptableObject not found"
**Решение:** Поместите GameConfig, CarDatabase, PartsDatabase в папку `Resources/`.

### Ошибка компиляции IL2CPP
**Решение:** Проверьте совместимость кода с IL2CPP. Избегайте динамической генерации кода.

### Автосохранение не работает
**Решение:** Проверьте путь к папке сохранений. Убедитесь, что есть права на запись.

## Оптимизация

### Для мобильных устройств
- Уменьшите количество частиц
- Используйте атласы спрайтов
- Оптимизируйте физику

### Для ПК
- Добавьте сглаживание
- Увеличьте качество текстур
- Добавьте эффекты пост-обработки

## Контакты и поддержка

Для вопросов по проекту обращайтесь к документации в `README.md`.
