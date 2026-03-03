---
title: Project Glossary
version: 1.0
date: 2026-03-04
status: draft
---
---
status: stable
created: 2026-02-28
last_reviewed: 2026-03-02
source: Project Core
author: Project Core
version: 1.0
---
# 📖 PROJECT GLOSSARY — ТЕРМИНОЛОГИЯ ПРОЕКТА

**Версия:** 1.0  
**Дата:** 28 февраля 2026 г.  
**Проект:** DragRaceUnity

---

## 🎯 НАЗНАЧЕНИЕ

Этот файл описывает **терминологию проекта**. Что есть что, как называются системы и компоненты.

---

## 🏗️ АРХИТЕКТУРА ПРОЕКТА

### Уровни (Layers):

```
┌─────────────────────────────────┐
│  UI Layer (Presentation)        │  ← Интерфейсы, меню, HUD
├─────────────────────────────────┤
│  Game Logic Layer               │  ← Игровая логика, правила
├─────────────────────────────────┤
│  Data Layer                     │  ← Данные, сохранения
├─────────────────────────────────┤
│  Core Layer                     │  ← Ядро, сервисы, утилиты
└─────────────────────────────────┘
```

---

## 📁 СТРУКТУРА ПАПКОК

### Assets/Scripts:

| Папка | Назначение | Примеры |
|-------|------------|---------|
| **UI/** | Интерфейсы | `MainMenuController.cs`, `GarageView.cs` |
| **Core/** | Ядро системы | `Logger.cs`, `GameInitializer.cs` |
| **Data/** | Модели данных | `PlayerData.cs`, `CarData.cs` |
| **SaveSystem/** | Сохранения | `SaveSystem.cs`, `SaveSlot.cs` |
| **Gameplay/** | Игровая логика | `RaceController.cs`, `CarPhysics.cs` |
| **Editor/** | Editor скрипты | `BuildScript.cs`, `ProjectSettings.cs` |

---

## 🎮 КЛЮЧЕВЫЕ КОМПОНЕНТЫ

### MainMenuController

**Что это:** Контроллер главного меню.

**Где:** `Assets/03-Resources/PowerShell/UI/MainMenuController.cs`

**Ответственность:**
- Обработка нажатий кнопок
- Навигация по меню
- Загрузка/сохранение настроек

**Кнопки:**
1. `NewGameButton` — Новая игра
2. `ContinueButton` — Продолжить
3. `SaveButton` — Сохранить
4. `LoadButton` — Загрузить
5. `SettingsButton` — Настройки
6. `ExitButton` — Выход

---

### SaveSystem

**Что это:** Система сохранений.

**Где:** `Assets/03-Resources/PowerShell/SaveSystem/SaveSystem.cs`

**Ответственность:**
- Сериализация данных в JSON
- Управление слотами сохранений (5 слотов)
- Чтение/запись файлов

**Структура файла сохранения:**

```json
{
  "playerName": "Player1",
  "level": 5,
  "experience": 1500,
  "money": 5000,
  "cars": [...],
  "settings": {...}
}
```

---

### PlayerData

**Что это:** Модель данных игрока.

**Где:** `Assets/03-Resources/PowerShell/Data/PlayerData.cs`

**Поля:**
- `playerName` (string) — Имя игрока
- `level` (int) — Уровень
- `experience` (int) — Опыт
- `money` (int) — Деньги
- `cars` (List<CarData>) — Автомобили
- `currentCarId` (int) — Текущий автомобиль

---

### Logger

**Что это:** Система логирования.

**Где:** `Assets/03-Resources/PowerShell/Core/Logger.cs`

**Уровни логов:**
- `Debug` — Отладочные
- `Info` — Информационные
- `Warning` — Предупреждения
- `Error` — Ошибки
- `Critical` — Критические ошибки

**Пример:**
```csharp
Logger.Info("Игра загружена");
Logger.Warning("Сохранение не найдено");
Logger.Error("Критическая ошибка", exception);
```

---

### GameInitializer

**Что это:** Инициализатор игры.

**Где:** `Assets/03-Resources/PowerShell/Core/GameInitializer.cs`

**Ответственность:**
- Настройка оконного режима (1920x1080)
- Загрузка настроек
- Инициализация систем

---

## 🏷️ ТЕРМИНЫ

### Drag Racing

**Определение:** Гонки на дистанции 1/4 мили (402 метра).

**Особенности:**
- Разгон с места
- Переключение передач (1-2-3-4)
- Финиш на время

---

### Player

**Определение:** Игрок, управляющий автомобилем.

**Данные:**
- Имя
- Уровень
- Опыт
- Деньги
- Гараж автомобилей

---

### Car

**Определение:** Автомобиль игрока.

**Характеристики:**
- Скорость
- Ускорение
- Передачи
- Тюнинг (апгрейды)

---

### Save Slot

**Определение:** Слот сохранения (всего 5 слотов).

**Данные:**
- PlayerData
- Timestamp (время сохранения)
- Скриншот (опционально)

---

### UI Toolkit

**Определение:** Система интерфейсов Unity.

**Компоненты:**
- `VisualElement` — базовый элемент
- `Button` — кнопка
- `Label` — текст
- `Image` — изображение

**Форматы:**
- `.uxml` — разметка
- `.uss` — стили
- `.cs` — логика

---

### Build

**Определение:** Скомпилированная версия игры.

**Типы:**
- **Editor Build** — для тестирования в Unity
- **Standalone Build** — EXE файл для Windows

**Путь:** `D:\QwenPoekt\PROJECTS\DragRaceUnity\Build\`

---

## 🔧 ИНСТРУМЕНТЫ

### auto-build-exe.ps1

**Что это:** Скрипт автоматической сборки EXE.

**Где:** `PROJECTS/DragRaceUnity/auto-build-exe.ps1`

**Что делает:**
1. Очищает логи
2. Запускает Unity в режиме батча
3. Создаёт билд в `Build/DragRace.exe`
4. Логирует процесс

---

### check-environment.ps1

**Что это:** Скрипт проверки окружения.

**Где:** `D:\QwenPoekt\check-environment.ps1`

**Что проверяет:**
- Unity установлен
- Visual Studio установлен
- .NET SDK установлен
- Расширения VS Code
- Анализаторы кода
- Incredibuild

---

### clean-logs.ps1

**Что это:** Скрипт очистки логов.

**Где:** `D:\QwenPoekt\clean-logs.ps1`

**Что делает:**
- Удаляет `*.log` из корня
- Удаляет логи из проекта
- Очищает `Library/`, `Temp/`, `obj/`

---

## 📊 СТАТИСТИКА ПРОЕКТА

| Компонент | Количество | Файл |
|-----------|------------|------|
| UI Контроллеры | 1 | `MainMenuController.cs` |
| Систем | 3 | `SaveSystem`, `Logger`, `GameInitializer` |
| Моделей данных | 2 | `PlayerData`, `CarData` |
| Сцен | 1 | `MainMenu.unity` |
| Тестов | 22 | `Assets/Tests/` |

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`AI_START_HERE.md`](../../AI_START_HERE.md) — Главная инструкция
- [`STRUCTURE_GUIDE.md`](../../02-Areas/Documentation/STRUCTURE_GUIDE.md) — Структура проекта
- [`FOR_AI_READ_HERE.md`](FOR_AI_READ_HERE.md) — Контекст для ИИ
- [`csharp_standards.md`](csharp_standards.md) — Стандарты кода C#
- [`RULES_INDEX.md`](../../02-Areas/Documentation/RULES_INDEX.md) — Индекс всех правил

---

**Правило:** Используй термины из этого файла! ✅

**Последнее обновление:** 28 февраля 2026 г.



