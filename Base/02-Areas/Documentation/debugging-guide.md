# 🐛 DRAGRACEUNITY DEBUGGING GUIDE

**Версия:** 1.0  
**Дата:** 28 февраля 2026 г.  
**Статус:** ✅ Готово к использованию

---

## 📋 СОДЕРЖАНИЕ

1. [Настройка окружения](#настройка-окружения)
2. [Точки останова](#точки-останова)
3. [Отладочные скрипты](#отладочные-скрипты)
4. [Чек-лист отладки](#чек-лист-отладки)
5. [Частые проблемы](#частые-проблемы)

---

## 🔧 НАСТРОЙКА ОКРУЖЕНИЯ

### Требуется:

- ✅ Visual Studio 2022 (с компонентом .NET desktop development)
- ✅ Unity 6000.3.10f1
- ✅ DragRaceUnity проект

### Настройка Visual Studio:

1. Открыть `PROJECTS/DragRaceUnity/DragRaceUnity.sln`
2. Убедиться, что конфигурация **Debug**
3. Проверить, что символы отладки включены

---

## 🎯 ТОЧКИ ОСТАНОВКИ

### Ключевые методы для отладки:

#### 1. Инициализация игры

**Файл:** `Assets/03-Resources/PowerShell/Core/GameInitializer.cs`

```csharp
void Awake()
{
    // 🔴 BREAKPOINT: Проверка инициализации
    Logger.Info("[GameInitializer] Игра инициализируется");
}
```

**Зачем:** Проверить, что игра правильно инициализируется

---

#### 2. Главное меню

**Файл:** `Assets/03-Resources/PowerShell/UI/MainMenuController.cs`

```csharp
public void OnNewGame()
{
    // 🔴 BREAKPOINT: Старт новой игры
    Logger.Info("[MainMenu] Новая игра начата");
    
    // 🔴 WATCH: SceneManager.activeSceneCount
    SceneManager.LoadScene("GameScene");
}
```

**Зачем:** Проверить переход к игровой сцене

---

#### 3. Система сохранений

**Файл:** `Assets/03-Resources/PowerShell/SaveSystem/SaveSystem.cs`

```csharp
public void Save(int slot)
{
    // 🔴 BREAKPOINT: Проверка данных перед сохранением
    // 🔴 WATCH: playerData.money, playerData.level
    string json = JsonUtility.ToJson(playerData);
    File.WriteAllText(path, json);
}
```

**Зачем:** Проверить корректность сохранения данных

---

#### 4. Логирование

**Файл:** `Assets/03-Resources/PowerShell/Core/Logger.cs`

```csharp
public static void Info(string message)
{
    // 🔴 BREAKPOINT: Отладка логирования
    // 🔴 WATCH: message, DateTime.Now
    Console.WriteLine($"[INFO] {message}");
}
```

**Зачем:** Проверить, что логи записываются правильно

---

## 🛠️ ОТЛАДОЧНЫЕ СКРИПТЫ

### 1. Запуск Unity в режиме отладки

**Файл:** `03-Resources/PowerShell/debug-unity.ps1`

```powershell
# ============================================
# Debug Unity — Запуск Unity в режиме отладки
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🐛 ЗАПУСК UNITY В РЕЖИМЕ ОТЛАДКИ" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$unityPath = "C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe"
$projectPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity"

Write-Host "📁 Проект: $projectPath" -ForegroundColor Yellow
Write-Host "🎮 Unity: $unityPath" -ForegroundColor Yellow
Write-Host ""

Write-Host "🔄 Запуск Unity..." -ForegroundColor Yellow

Start-Process $unityPath -ArgumentList "-projectPath", $projectPath, "-debugMode"

Write-Host "✅ Unity запущен в режиме отладки!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 В Visual Studio:" -ForegroundColor Cyan
Write-Host "  1. Откройте DragRaceUnity.sln" -ForegroundColor White
Write-Host "  2. Unity → Attach to Unity" -ForegroundColor White
Write-Host "  3. Установите точки останова" -ForegroundColor White
Write-Host "  4. Нажмите Play в Unity" -ForegroundColor White
Write-Host ""
```

---

### 2. Открытие Visual Studio с отладкой

**Файл:** `03-Resources/PowerShell/debug-vs.ps1`

```powershell
# ============================================
# Debug Visual Studio — Открытие решения
# ============================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "🐛 ОТКРЫТИЕ VISUAL STUDIO С ОТЛАДКОЙ" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$slnPath = "D:\QwenPoekt\PROJECTS\DragRaceUnity\DragRaceUnity.sln"
$vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\IDE\devenv.exe"

Write-Host "📁 Решение: $slnPath" -ForegroundColor Yellow
Write-Host "💻 Visual Studio: $vsPath" -ForegroundColor Yellow
Write-Host ""

Write-Host "🔄 Открытие Visual Studio..." -ForegroundColor Yellow

Start-Process $vsPath -ArgumentList $slnPath, "/debug"

Write-Host "✅ Visual Studio открыт!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Следующие шаги:" -ForegroundColor Cyan
Write-Host "  1. Unity → Attach to Unity" -ForegroundColor White
Write-Host "  2. Установите точки останова" -ForegroundColor White
Write-Host "  3. Нажмите Play в Unity" -ForegroundColor White
Write-Host ""
```

---

## ✅ ЧЕК-ЛИСТ ОТЛАДКИ

### Перед отладкой:

- [ ] Установлен Visual Studio 2022
- [ ] Установлен компонент ".NET desktop development"
- [ ] Открыто решение `DragRaceUnity.sln`
- [ ] Конфигурация установлена в **Debug**
- [ ] Unity подключён к Visual Studio

### Точки останова:

- [ ] `GameInitializer.Awake()` — инициализация
- [ ] `MainMenuController.OnNewGame()` — старт игры
- [ ] `SaveSystem.Save()` — сохранение
- [ ] `SaveSystem.Load()` — загрузка
- [ ] `Logger.Log()` — логирование

### Переменные для мониторинга:

- [ ] `PlayerData.money` — деньги игрока
- [ ] `PlayerData.level` — уровень
- [ ] `PlayerData.experience` — опыт
- [ ] `CarData.maxSpeed` — скорость автомобиля
- [ ] `CarData.acceleration` — ускорение

### Окна отладки:

- [ ] **Autos** — переменные текущей строки
- [ ] **Locals** — локальные переменные
- [ ] **Watch** — отслеживаемые переменные
- [ ] **Call Stack** — стек вызовов

---

## 🐛 ЧАСТЫЕ ПРОБЛЕМЫ

### 1. Отладчик не подключается к Unity

**Проблема:** Visual Studio не видит Unity

**Решение:**
1. В Unity: `Edit` → `Preferences` → `External Tools`
2. Убедиться, что выбран Visual Studio 2022
3. В Visual Studio: `Debug` → `Attach to Unity`
4. Нажать Play в Unity

---

### 2. Точки останова не срабатывают

**Проблема:** Код выполняется, но точки останова игнорируются

**Решение:**
1. Проверить, что конфигурация **Debug**
2. Проверить, что символы отладки включены
3. Пересобрать проект
4. Проверить, что точки останова активны (красный круг)

---

### 3. Переменные не отображаются

**Проблема:** Окна Autos/Locals пустые

**Решение:**
1. Убедиться, что отладчик приостановлен (не запущен)
2. Проверить, что переменные в области видимости
3. Использовать Watch окно для конкретных переменных

---

### 4. Сохранение не работает

**Проблема:** `SaveSystem.Save()` не сохраняет

**Решение:**
1. Поставить точку останова в `SaveSystem.Save()`
2. Проверить переменную `path` (путь к файлу)
3. Проверить `playerData` (данные)
4. Проверить исключения в окне Exception Settings

---

### 5. Меню не работает

**Проблема:** Кнопки не реагируют

**Решение:**
1. Поставить точку останова в `MainMenuController.OnNewGame()`
2. Нажать кнопку в Unity
3. Проверить, срабатывает ли точка останова
4. Проверить EventSystem на сцене

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

| Файл | Назначение |
|------|------------|
| [`03-Resources/PowerShell/debug-unity.ps1`](./03-Resources/PowerShell/debug-unity.ps1) | Запуск Unity в режиме отладки |
| [`03-Resources/PowerShell/debug-vs.ps1`](./03-Resources/PowerShell/debug-vs.ps1) | Открытие Visual Studio |
| [`VISUAL_STUDIO_DEBUGGING_ANALYSIS.md`](./VISUAL_STUDIO_DEBUGGING_ANALYSIS.md) | Анализ отладки |

---

## 📚 РЕСУРСЫ

### Microsoft Docs:
- [Отладка в Visual Studio](https://docs.microsoft.com/visualstudio/debugger/)
- [Точки останова](https://docs.microsoft.com/visualstudio/debugger/using-breakpoints)
- [Окно Watch](https://docs.microsoft.com/visualstudio/debugger/watch-window)

### Unity Docs:
- [Отладка в Unity](https://docs.unity3d.com/Manual/ManagedCodeDebugging.html)
- [Профилирование](https://docs.unity3d.com/Manual/Profiler.html)

---

**Готово к отладке!** 🐛

**Последнее обновление:** 28 февраля 2026 г.

