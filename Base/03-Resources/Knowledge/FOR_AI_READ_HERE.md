# 📘 Контекст проекта для ИИ-ассистента

**Версия:** 2.0
**Дата создания:** 2026-02-27
**Последняя проверка:** 2026-03-02
**Статус:** ✅ Активно

**Автор:** Qwen Code

---

## 🎯 ГЛАВНОЕ

Это **ДВА проекта в одном**:

1. **ProbMenu (WinForms)** — тестовое приложение-шаблон
   - Путь: `D:\QwenPoekt\ProbMenu\ProbMenu.csproj`
   - Статус: ✅ Завершён (рефакторинг, DI, тесты, CI/CD)
   - **Используется как шаблон**

2. **DragRaceUnity (Unity)** — Drag Racing игра
   - Путь: `D:\QwenPoekt\ProbMenu\DragRaceUnity\`
   - Статус: ✅ **ГОТОВО К ИГРЕ**
   - **ЭТО ОСНОВНОЙ ПРОЕКТ!**

---

## 📁 Структура

```
D:\QwenPoekt\ProbMenu\
├── README.md                    # Главная документация
├── ИИ_ИНСТРУКЦИЯ_ДЛЯ_БУДУЩИХ_ПРОЕКТОВ.md  ← ПУТЕВОДИТЕЛЬ!
├── CODE_STYLE_GUIDE.md          # Правила чистого кода
├── ДЛЯ_ИИ_ЧИТАТЬ_СЮДА.md        # Этот файл
├── ProbMenu.csproj              # WinForms шаблон
├── Form1.cs                     # Рефакторная форма
├── Interfaces/                  # Сервисы (интерфейсы)
├── Services/                    # Сервисы (реализации)
├── ProbMenu.Tests/              # Тесты (23 теста)
├── .github/workflows/dotnet.yml # CI/CD пайплайн
└── DragRaceUnity/               # ← UNITY ИГРА
    ├── Assets/
    │   ├── 03-Resources/PowerShell/
    │   │   ├── Core/            # GameManager, Logger
    │   │   ├── UI/              # MainMenu (6 кнопок)
    │   │   ├── Data/            # PlayerData, CarData
    │   │   ├── SaveSystem/      # SaveManager (5 слотов)
    │   │   └── Racing/          # RaceManager
    │   ├── Scenes/              # MainMenu.unity, GameMenu.unity
    │   └── Builds/              # Билды
    └── CODE_STYLE_GUIDE.md      # Clean Code для Unity
```

---

## 🛠️ Установленные инструменты

| Инструмент | Версия | Назначение |
|------------|--------|------------|
| **Unity** | 6000.3.10f1 | Игровой движок |
| **.NET SDK** | 10.0.103 | Компиляция C# |
| **Roslynator CLI** | 0.12.0 | Анализ кода |
| **Visual Studio 2026** | — | IDE |

---

## 🎮 Drag Racing — ФУНКЦИОНАЛ

### Главное меню (6 кнопок)
1. **Новая игра** → Создание игрока ($50000)
2. **Продолжить** → Загрузка автосейва
3. **Сохранить** → 5 слотов
4. **Загрузить** → 5 слотов + даты
5. **Настройки** → Графика, звук, управление
6. **Выход** → Автосохранение + выход

### Меню игры (5 кнопок)
1. **Заезд** → 1/4, 1/2, 1, 2 мили
2. **Гараж** → Выбор авто
3. **Тюнинг** → Апгрейды
4. **Магазин** → Покупка авто
5. **Меню** → Возврат в главное

### Управление
- **Клавиатура:** ↑↓ навигация, Enter выбор, Esc назад
- **Мышь:** Клик по кнопкам

---

## 🔧 Команды

### Сборка билда
```bash
# Unity билд
Unity.exe -batchmode -nographics -executeMethod "Editor.AutoBuildScript.BuildWindowsX64" -projectPath "D:\QwenPoekt\ProbMenu\DragRaceUnity" -quit
```

### Тесты
```bash
# .NET тесты
dotnet test ProbMenu.Tests/ProbMenu.Tests.csproj

# Unity тесты (в Editor)
Window → General → Test Runner → PlayMode → Run All
```

### Анализ кода
```bash
# Roslynator
roslynator analyze "ProbMenu.csproj"

# Форматирование
dotnet format ProbMenu.csproj
```

---

## 📚 Документация

### Основная
- **`ИИ_ИНСТРУКЦИЯ_ДЛЯ_БУДУЩИХ_ПРОЕКТОВ.md`** — ПУТЕВОДИТЕЛЬ (Версия 2.0)
- **`CODE_STYLE_GUIDE.md`** — Правила чистого кода
- **`README.md`** — Главная страница

### Unity
- **`DragRaceUnity/CODE_STYLE_GUIDE.md`** — Clean Code для Unity
- **`DragRaceUnity/UNITY_BUILD_GUIDE.md`** — Сборка билда
- **`DragRaceUnity/БЫСТРЫЙ_СТАРТ.md`** — Быстрый старт

### ProbMenu
- **`PUBLISH.md`** — Публикация EXE
- **`DRAG_RACING_STATUS.md`** — Статус проекта

---

## 🐛 Типичные проблемы

### 1. Кнопка не работает от мыши
**Решение:** Удалить префаб, создать кнопку напрямую в сцене

### 2. Клавиатура не работает
**Решение:** Проверить навигацию (Navigation) у кнопки

### 3. Две кнопки на одном месте
**Решение:** 
```bash
grep "m_Name:.*Button" Assets/Scenes/MainMenu.unity
# Удалить лишние
```

### 4. Сборка не работает
**Решение:** Проверить логи в `unity-*.txt`

---

## ✅ Чек-лист перед сборкой

- [ ] Нет ошибок компиляции
- [ ] Все кнопки назначены
- [ ] Навигация работает
- [ ] Нет лишних объектов в сцене
- [ ] Тексты правильные (Unicode)
- [ ] Документация обновлена

---

## 📞 Контакты

### Файлы для чтения
1. **`ИИ_ИНСТРУКЦИЯ_ДЛЯ_БУДУЩИХ_ПРОЕКТОВ.md`** — ВСЕ ЗНАНИЯ!
2. **`CODE_STYLE_GUIDE.md`** — Правила кода
3. **`README.md`** — Обзор проекта

### Ресурсы
- [.NET Docs](https://docs.microsoft.com/dotnet/)
- [Unity Manual](https://docs.unity3d.com/Manual/)
- [Clean Code](https://blog.cleancoder.com/)

---

**Прочитай `ИИ_ИНСТРУКЦИЯ_ДЛЯ_БУДУЩИХ_ПРОЕКТОВ.md` перед началом работы!** 📚

---

## 📁 Структура

```
D:\QwenPoekt\ProbMenu\
├── ProbMenu.csproj              # WinForms шаблон
├── Program.cs                   # С DI контейнером
├── Form1.cs                     # Рефакторная форма
├── Interfaces/                  # Сервисы (интерфейсы)
├── Services/                    # Сервисы (реализации)
├── ProbMenu.Tests/              # Тесты (23 теста)
├── .github/workflows/dotnet.yml # CI/CD пайплайн
├── README.md                    # Документация WinForms
├── DRAG_RACING_STATUS.md        # Статус Unity проекта
├── PUBLISH.md                   # Как собрать EXE
└── DragRaceUnity/               # ← UNITY ИГРА
    └── Assets/03-Resources/PowerShell/
        ├── Core/                # GameManager, Logger
        ├── Data/                # CarData, PlayerData
        ├── UI/                  # MainMenu, GameMenu, Garage, Tuning, Shop
        ├── Racing/              # RaceManager, CarPhysics
        ├── SaveSystem/          # SaveManager (5 слотов)
        └── Settings/            # SettingsManager
```

---

## 🛠️ Установленные инструменты

| Инструмент | Версия | Назначение |
|------------|--------|------------|
| .NET SDK | 10.0.103 | Компиляция C# |
| Visual Studio 2026 | — | IDE |
| Roslynator CLI | 0.12.0 | Анализ кода |
| Unity 6000.x | — | Игровой движок |

---

## 📦 NuGet пакеты (ProbMenu)

```xml
Microsoft.Extensions.Hosting          8.0.0
Microsoft.Extensions.DependencyInjection  8.0.0
Roslynator.Analyzers                4.12.0
Roslynator.CodeAnalysis.Analyzers   4.12.0
Roslynator.Formatting.Analyzers     4.12.0
xunit                               2.9.3
Microsoft.NET.Test.Sdk             17.14.1
```

---

## ✅ Что уже сделано

### ProbMenu (WinForms)
- [x] Рефакторинг с выделением сервисов
- [x] DI через Microsoft.Extensions.Hosting
- [x] 23 юнит-теста (100% покрытие сервисов)
- [x] CI/CD пайплайн (GitHub Actions)
- [x] Roslynator анализ (0 предупреждений)
- [x] .editorconfig настройки
- [x] README документация
- [x] Публикация в EXE

### DragRaceUnity (Unity)
- [x] Главное меню (6 кнопок)
- [x] Меню игры (5 кнопок)
- [x] Система сохранений (5 слотов)
- [x] Гонки (4 дистанции: 1/4, 1/2, 1, 2 мили)
- [x] Гараж (выбор авто + характеристики)
- [x] Тюнинг (сравнение ДО/ПОСЛЕ)
- [x] Магазин (авто + запчасти)
- [x] Настройки (графика/звук/управление)
- [x] Физика автомобиля
- [x] ИИ соперник

---

## 🚀 Полезные команды

### ProbMenu
```bash
# Сборка
dotnet build ProbMenu.csproj

# Тесты
dotnet test ProbMenu.Tests/ProbMenu.Tests.csproj

# Анализ
roslynator analyze "ProbMenu.csproj"

# Публикация EXE
dotnet publish ProbMenu.csproj -c Release -o publish

# Быстрая сборка
build.bat
```

### DragRaceUnity
```bash
# Открыть в Unity
unity-open.ps1

# Сборка
unity-build.ps1
```

---

## 🎯 Следующие шаги

### Для DragRaceUnity:
1. Добавить больше автомобилей (ScriptableObject)
2. Добавить больше апгрейдов
3. Создать префабы сцен
4. Финальная сборка билда

### Для ProbMenu:
- Использовать как шаблон для будущих WinForms утилит

---

## 📞 Контакты

Если что-то непонятно — смотри:
- `README.md` — документация WinForms
- `DRAG_RACING_STATUS.md` — полный статус Unity проекта
- `PUBLISH.md` — как публиковать EXE

---

## ⚠️ Важно!

**ProbMenu ≠ DragRaceUnity**

- ProbMenu — тестовый WinForms шаблон (3 кнопки → рефактор)
- DragRaceUnity — полноценная Unity игра (Drag Racing)

**Не путать!**

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`AI_START_HERE.md`](../../AI_START_HERE.md) — Главная инструкция
- [`RULES_AND_TASKS.md`](../../RULES_AND_TASKS.md) — Правила и задачи
- [`README.md`](../../README.md) — Навигатор по проекту
- [`AI_DEVELOPER_INSTRUCTION.md`](../05_METHODOLOGY/AI_DEVELOPER_INSTRUCTION.md) — Инструкция ИИ-разработчика
- [`project_glossary.md`](project_glossary.md) — Терминология проекта

