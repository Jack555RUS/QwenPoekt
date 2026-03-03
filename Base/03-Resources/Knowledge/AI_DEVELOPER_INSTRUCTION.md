# 📘 ИНСТРУКЦИЯ ДЛЯ ИИ-РАЗРАБОТЧИКА

**Версия:** 2.0
**Дата создания:** 2026-02-27
**Последняя проверка:** 2026-03-02
**Статус:** ✅ Активно

**Автор:** Qwen Code

---

## 📋 ОГЛАВЛЕНИЕ

1. [Назначение](#назначение)
2. [Базовые принципы работы](#базовые-принципы-работы)
3. [Структура проекта](#структура-проекта)
4. [Орфография и стиль](#орфография-и-стиль)
5. [Работа с кодом](#работа-с-кодом)
6. [Тестирование](#тестирование)
7. [Документирование](#документирование)
8. [Автоматизация](#автоматизация)
9. [Связанные файлы](#связанные-файлы)

---

## 🎯 НАЗНАЧЕНИЕ

Этот файл содержит **все знания и навыки**, полученные в ходе работы над проектами. Прочитав его, новый ИИ-ассистент сможет:

- ✅ Выполнять все задачи текущего уровня
- ✅ Самостоятельно обучаться и дополнять документацию
- ✅ Работать с Docker, тестами, логами, сборками
- ✅ Поддерживать чистоту проекта
- ✅ Соблюдать стандарты кода и орфографии
- ✅ **Работать с Unity UI (кнопки, навигация, сцены)**
- ✅ **Писать чистый код (Clean Code, C# стандарты)**

---

## 📋 БАЗОВЫЕ ПРИНЦИПЫ РАБОТЫ

### 1. **Самодокументирование (ВАЖНО!)**

```
ПРАВИЛО: Когда я узнаю что-то новое — я САМ дополняю этот файл.
НЕ ЖДУ команды от пользователя.
```

**Когда обновлять:**
- ✅ Узнал новую команду → Добавь в раздел "Команды"
- ✅ Нашёл лучшую практику → Добавь в "Стандарты"
- ✅ Исправил сложную ошибку → Добавь в "Troubleshooting"
- ✅ Изучил новый инструмент → Добавь в "Инструменты"
- ✅ **Создал новую функцию → Опиши в "Архитектура"**
- ✅ **Нашёл баг → Запиши в "Типичные ошибки"**

**Формат обновления:**
```markdown
### [Дата] — [Что изучил]
**Контекст:** [Где применил]
**Решение:** [Код/команда]
**Почему это важно:** [Объяснение]
```

---

### 2. **Структура проекта (Стандарт)**

#### 2.1. Для .NET / C# проектов:
```
ProjectName/
├── .github/workflows/       # CI/CD пайплайны
├── .vscode/                 # Настройки редактора
├── src/                     # Исходный код
│   ├── Core/               # Ядро (сервисы, интерфейсы)
│   ├── UI/                 # Интерфейсы (WinForms, WPF, Unity UI)
│   ├── Data/               # Модели данных
│   └── Services/           # Бизнес-логика
├── tests/                   # Тесты
│   ├── UnitTests/          # Юнит-тесты
│   └── IntegrationTests/   # Интеграционные
├── docker/                  # Docker конфигурации
├── docs/                    # Документация
├── builds/                  # Билды (игнорируется в git)
├── obj/                     # Временные файлы (игнорируется)
├── bin/                     # Бинарники (игнорируется)
├── .editorconfig            # Настройки стиля кода
├── .gitignore              # Игнор файлы
├── README.md               # Главная документация
└── [PROJECT].csproj        # Файл проекта
```

#### 2.2. Для Unity проектов:
```
UnityProject/
├── Assets/
│   ├── 03-Resources/PowerShell/
│   │   ├── Core/           # Ядро (GameManager, Logger)
│   │   ├── UI/             # Контроллеры меню
│   │   ├── Data/           # Модели данных
│   │   ├── Services/       # Сервисы (SaveManager)
│   │   └── Editor/         # Editor скрипты
│   ├── Scenes/             # Сцены Unity
│   ├── Prefabs/            # Префабы
│   └── Resources/          # Ресурсы
├── ProjectSettings/        # Настройки проекта
└── Packages/               # Unity пакеты
```

---

### 3. **Орфография и стиль**

**Язык сообщений:**
- ✅ **Русский** — для общения с пользователем
- ✅ **Английский** — для кода, комментариев, имён переменных

**Правила:**
```
✅ Правильно: "Сборка успешна", "Ошибка компиляции"
❌ Неправильно: "Сборка успешнаа", "Ошыбка"

✅ Имена переменных: camelCase (counterService)
✅ Имена классов: PascalCase (CounterService)
✅ Имена методов: PascalCase (IncrementCounter)
✅ Константы: UPPER_SNAKE_CASE (MAX_COUNT)
```

**Проверка перед отправкой:**
1. Проверь орфографию в русских текстах
2. Проверь стиль имён в коде
3. Проверь форматирование (отступы, скобки)

---

## 🛠️ ИНСТРУМЕНТЫ И КОМАНДЫ

### .NET / C#

```bash
# Сборка
dotnet build [Project.csproj]
dotnet build -c Release -warnaserror

# Тесты
dotnet test [TestProject.csproj]
dotnet test --verbosity quiet --logger "console;verbosity=minimal"
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura

# Публикация
dotnet publish -c Release -o ./publish --self-contained false
dotnet publish -c Release -r win-x64 --self-contained true

# Анализ
dotnet format --verify-no-changes
roslynator analyze "[Project.csproj]" --severity-level warning

# Очистка
dotnet clean
dotnet restore --force

# NuGet
dotnet add package [PackageName] --version [Version]
dotnet remove package [PackageName]
dotnet add reference [ProjectPath]
```

---

### Docker

```bash
# Сборка образа
docker build -t [image-name]:[tag] .
docker build -f Dockerfile.Unity -t unity-builder:latest .

# Запуск контейнера
docker run --rm -v ${PWD}:/app [image-name]:[tag]
docker run -d -p 8080:80 --name [container-name] [image-name]:[tag]

# Просмотр логов
docker logs [container-name]
docker logs -f [container-name]  # Follow mode
docker logs --tail 100 [container-name]

# Остановка и очистка
docker stop [container-name]
docker rm [container-name]
docker rmi [image-name]

# Очистка всего (для чистого запуска)
docker system prune -a --volumes

# Docker Compose
docker-compose up -d
docker-compose down
docker-compose logs -f [service-name]
docker-compose build --no-cache
```

**Dockerfile шаблон:**
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

# Копируем csproj и восстанавливаем пакеты
COPY *.csproj ./
RUN dotnet restore

# Копируем остальное и билдим
COPY . ./
RUN dotnet build -c Release -o /app/build

# Финальный образ
FROM mcr.microsoft.com/dotnet/runtime:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/build ./
ENTRYPOINT ["dotnet", "YourApp.dll"]
```

---

### Unity

```bash
# Компиляция скриптов (проверка)
Unity.exe -batchmode -nographics -projectPath [Path] -executeMethod UnityEditor.SyncScripts -quit

# Сборка билда
Unity.exe -batchmode -nographics -projectPath [Path] -executeMethod [Method] -quit -logFile build.log

# Пример:
"C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe" ^
  -batchmode -nographics ^
  -projectPath "D:\Projects\MyGame" ^
  -executeMethod "MyEditorScript.BuildWindows" ^
  -quit -logFile build-log.txt
```

**Unity Editor скрипты:**
- Располагать в `Assets/Editor/`
- Использовать `UnityEditor` namespace
- Методы для сборки помечать `[MenuItem("Tools/...")]`

---

### Git

```bash
# Базовые
git init
git add .
git commit -m "Description"
git push origin main

# Ветки
git checkout -b feature/new-feature
git merge main
git branch -d feature/new-feature

# Отмена
git reset --soft HEAD~1
git checkout -- [file]
git revert [commit]

# Очистка
git clean -fdx  # Удалить все неотслеживаемые файлы
git gc --prune=now  # Очистка хранилища
```

**.gitignore шаблон для .NET:**
```gitignore
# Build results
[Dd]ebug/
[Rr]elease/
x64/
x86/
[Ww][Ii][Nn]32/
[Aa][Rr][Mm]/
[Aa][Rr][Mm]64/
bld/
[Bb]in/
[Oo]bj/
[Ll]og/
[Ll]ogs/

# Visual Studio
.vs/
*.user
*.suo
*.userosscache
*.suo.filters
*.userprefs

# Rider
.idea/

# Test results
[Tt]est[Rr]esult*/
[Bb]uild[Ll]og.*

# Docker
docker-compose.override.yml

# Unity
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
[Ll]ogs/
[Uu]ser[Ss]ettings/
*.pidb.meta
*.pdb.meta
*.mdb.meta
sysinfo.txt
*.apk
*.aab
*.unitypackage
```

---

## 🧪 ТЕСТИРОВАНИЕ

### Стандарты написания тестов

**Структура теста (AAA Pattern):**
```csharp
[Fact]
public void MethodName_Scenario_ExpectedResult()
{
    // Arrange (Подготовка)
    var service = new CounterService();
    
    // Act (Действие)
    var result = service.Increment();
    
    // Assert (Проверка)
    Assert.Equal(1, result);
}
```

**Правила имён:**
```
✅ [Class]_[Method]_[Scenario]_[ExpectedResult]
✅ Form1_Button2_Click_ShouldIncrementCounter
✅ CounterService_Increment_MultipleTimes_ShouldAccumulate

❌ Test1
❌ TestMethod
❌ CheckCounter
```

**Типы тестов:**
```csharp
// Юнит-тест (один класс, моки для зависимостей)
[Fact]
public void CounterService_Increment_ShouldIncreaseValue()

// Интеграционный тест (несколько классов вместе)
[Fact]
public void Form1_WithServices_Click_ShouldUpdateUI()

// Тест с теорией (параметризованный)
[Theory]
[InlineData(0, 1)]
[InlineData(1, 2)]
[InlineData(5, 6)]
public void CounterService_Increment_MultipleValues(int start, int expected)
```

**Запуск тестов:**
```bash
# Тихий режим (только ошибки)
dotnet test --verbosity quiet --logger "console;verbosity=minimal"

# Подробный отчёт
dotnet test --verbosity normal --logger "console;verbosity=detailed"

# С покрытием
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=cobertura

# Конкретный тест
dotnet test --filter "FullyQualifiedName~CounterService"

# Исключить тесты
dotnet test --filter "Category!=Integration"
```

---

## 📊 ЛОГИРОВАНИЕ

### Уровни логов

```
ERROR   — Критическая ошибка (требует немедленного действия)
WARN    — Предупреждение (не ломает, но может вызвать проблемы)
INFO    — Информация о нормальном ходе выполнения
DEBUG   — Отладочная информация (детали для разработчика)
TRACE   — Трассировка (максимально подробно)
```

### Чтение логов

**Поиск ошибок:**
```bash
# Windows
findstr /C:"Error" /C:"Exception" /C:"Failed" build-log.txt

# Linux/Mac
grep -E "Error|Exception|Failed" build-log.txt

# PowerShell
Select-String -Pattern "Error|Exception|Failed" -Path build-log.txt
```

**Анализ лога:**
1. Ищи первое вхождение "Error"
2. Смотри контекст (10 строк до и после)
3. Ищи стек вызовов (StackTrace)
4. Определи корневую причину

**Шаблон анализа:**
```
1. Время ошибки: [timestamp]
2. Компонент: [Assembly/Class]
3. Метод: [MethodName]
4. Сообщение: [ErrorMessage]
5. Стек: [StackTrace]
6. Причина: [RootCause]
7. Решение: [Fix]
```

---

## 🧹 ОЧИСТКА ПРОЕКТА

### Автоматическая очистка

```bash
# .NET проект
dotnet clean
dotnet restore --force
rm -rf bin/ obj/

# Docker
docker system prune -a --volumes
docker builder prune -a

# Unity
rm -rf Library/ Temp/ Obj/ Build/ Builds/ Logs/

# Git
git clean -fdx
git gc --prune=now
```

### Скрипт полной очистки (PowerShell)

```powershell
# clean-project.ps1
param([switch]$All)

Write-Host "=== Очистка проекта ===" -ForegroundColor Cyan

# .NET
dotnet clean
Remove-Item -Recurse -Force bin, obj -ErrorAction SilentlyContinue

# Docker
if ($All) {
    docker system prune -f
}

# Временные файлы
Remove-Item -Recurse -Force .vs, .idea, *.user, *.suo -ErrorAction SilentlyContinue

Write-Host "✅ Очистка завершена" -ForegroundColor Green
```

---

## 📦 УСТАНОВКА ПРИЛОЖЕНИЙ

### .NET SDK

```bash
# Проверка версии
dotnet --version

# Установка (Windows)
winget install Microsoft.DotNet.SDK.10

# Установка (Linux)
wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update && sudo apt-get install -y dotnet-sdk-10.0
```

### Unity

```bash
# Unity Hub (Windows)
winget install Unity.UnityHub

# Unity Editor (через Unity Hub)
# 1. Открыть Unity Hub
# 2. Installs → Install Editor
# 3. Выбрать версию (6000.x)
# 4. Выбрать модули (Windows Build Support)
```

### Docker

```bash
# Docker Desktop (Windows)
winget install Docker.DockerDesktop

# Проверка
docker --version
docker run hello-world
```

### Visual Studio

```bash
# Visual Studio 2026 Community
winget install Microsoft.VisualStudio.2026.Community

# Рабочие нагрузки:
# - .NET Desktop
# - Unity Tools (для Unity проектов)
```

---

## 🔧 TROUBLESHOOTING

### Частые ошибки и решения

#### 1. "No such file or directory"
**Причина:** Неправильный путь  
**Решение:** Использовать абсолютные пути или проверить текущую директорию

```bash
# Проверка пути
pwd  # Linux/Mac
cd   # Windows

# Использование кавычек для путей с пробелами
dotnet build "D:\My Projects\Project.csproj"
```

#### 2. "Access denied"
**Причина:** Нет прав доступа  
**Решение:** Запуск от администратора или смена прав

```bash
# Windows (PowerShell от администратора)
Start-Process powershell -Verb RunAs

# Linux
sudo chmod +x script.sh
```

#### 3. "Port already in use"
**Причина:** Порт занят другим процессом  
**Решение:** Найти и убить процесс или сменить порт

```bash
# Найти процесс на порту 8080
netstat -ano | findstr :8080

# Убить процесс
taskkill /PID [PID] /F
```

#### 4. "NuGet package restore failed"
**Причина:** Проблемы с сетью или кэшем  
**Решение:** Очистить кэш и восстановить

```bash
dotnet nuget locals all --clear
dotnet restore --force
```

#### 5. "Unity script compilation failed"
**Причина:** Ошибки в Editor скриптах  
**Решение:** Проверить using директивы и namespace

```csharp
// Правильно для Editor скриптов:
using UnityEngine;
using UnityEditor;  // ← Только для Editor!
using UnityEditor.SceneManagement;
```

---

## 📚 СТАНДАРТЫ КОДА

### C# Code Style

```csharp
// ✅ Правильно
public class CounterService : ICounterService
{
    private readonly ILogger _logger;
    private int _counter;

    public int Value => _counter;

    public CounterService(ILogger logger)
    {
        _logger = logger;
    }

    public int Increment()
    {
        _counter++;
        _logger.LogInformation($"Counter: {_counter}");
        return _counter;
    }
}

// ❌ Неправильно
public class counterService  // ← Имя с маленькой
{
    public int Counter;  // ← Поле публичное
    public counterService() { }  // ← Конструктор без this
}
```

### XML Documentation

```csharp
/// <summary>
/// Сервис для управления счётчиком.
/// </summary>
public interface ICounterService
{
    /// <summary>
    /// Текущее значение счётчика.
    /// </summary>
    int Value { get; }

    /// <summary>
    /// Инкрементирует счётчик на единицу.
    /// </summary>
    /// <returns>Новое значение счётчика.</returns>
    int Increment();
}
```

---

## 🔄 CI/CD (GitHub Actions)

### Шаблон пайплайна

```yaml
name: .NET Build and Test

on:
  push:
    branches: [ "main", "master" ]
  pull_request:
    branches: [ "main", "master" ]

jobs:
  build:
    runs-on: windows-latest

    steps:
    - uses: actions/checkout@v4
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: 10.0.x
    
    - name: Restore dependencies
      run: dotnet restore
    
    - name: Build
      run: dotnet build --no-restore --configuration Release -warnaserror
    
    - name: Test
      run: dotnet test --no-build --configuration Release --verbosity quiet
    
    - name: Publish
      run: dotnet publish -c Release -o ./publish
```

---

## 📖 САМООБУЧЕНИЕ

### Как я учусь новому

1. **Сталкиваюсь с проблемой** → Анализирую
2. **Нахожу решение** → Применяю
3. **Проверяю работу** → Тестирую
4. **Документирую** → Добавляю в этот файл!

### Пример записи нового знания

```markdown
### 27.02.2026 — Unity BuildReport.summary.totalSize
**Контекст:** Сборка Unity билда через CLI
**Проблема:** `report.totalSize` не существует в Unity 6000.x
**Решение:** Использовать `report.summary.totalSize`
**Код:**
```csharp
// Было (не работает):
Debug.Log($"Size: {report.totalSize}");

// Стало (работает):
Debug.Log($"Size: {report.summary.totalSize}");
```
**Почему важно:** API изменился в Unity 6000.x, нужно использовать новый API
```

---

## ✅ ЧЕКЛИСТ ПЕРЕД НАЧАЛОМ РАБОТЫ

### Новый проект

- [ ] Прочитать этот файл
- [ ] Создать структуру проекта по стандарту
- [ ] Настроить .gitignore
- [ ] Создать .editorconfig
- [ ] Настроить CI/CD (GitHub Actions)
- [ ] Создать README.md
- [ ] Настроить Docker (если нужно)
- [ ] Создать тестовый проект
- [ ] Настроить логирование

### Перед коммитом

- [ ] Запустить тесты (`dotnet test`)
- [ ] Проверить форматирование (`dotnet format`)
- [ ] Проверить орфографию
- [ ] Проверить имена переменных
- [ ] Очистить bin/obj
- [ ] Написать осмысленное сообщение коммита

### Перед отправкой пользователю

- [ ] Проверить решение работает
- [ ] Проверить орфографию в сообщении
- [ ] Добавить примеры использования
- [ ] Указать путь к файлам
- [ ] Предложить следующие шаги

---

## 📞 КОНТАКТЫ И РЕСУРСЫ

### Документация

- [.NET Docs](https://docs.microsoft.com/dotnet/)
- [Unity Manual](https://docs.unity3d.com/Manual/)
- [Docker Docs](https://docs.docker.com/)
- [GitHub Actions](https://docs.github.com/actions)

### Инструменты

- [Roslynator](https://github.com/dotnet/roslynator)
- [xUnit](https://xunit.net/)
- [Coverlet](https://github.com/coverlet-coverage/coverlet)

---

## 🎮 UNITY UI — РАБОТА С КНОПКАМИ И СЦЕНАМИ

### 10.1. Создание кнопок в Unity

**ВАЖНО:** Кнопки должны быть созданы ПРАВИЛЬНО!

**Способ 1: Копирование существующей кнопки (РЕКОМЕНДУЕТСЯ)**
```yaml
# 1. Найди рабочую кнопку (например, SettingsButton)
# 2. Скопируй весь блок (от GameObject до CanvasRenderer)
# 3. Измени:
#    - m_Name: ExitButton
#    - m_AnchoredPosition: {x: 0, y: -150}  # Позиция
#    - m_MethodName: OnExit  # Обработчик
#    - m_Text: "\u0412\u042B\u0425\u041E\u0414"  # Текст (Unicode!)
```

**Способ 2: Через префаб (НЕ рекомендуется)**
- ❌ Префабы могут переопределять настройки
- ❌ Навигация может не работать
- ✅ Лучше создавать напрямую в сцене

### 10.2. Настройка навигации

```yaml
m_Navigation:
  m_Mode: 3  # Automatic
  m_SelectOnUp: {fileID: 1300000001}  # Ссылка на кнопку выше
  m_SelectOnDown: {fileID: 1300000001}  # Ссылка на кнопку ниже
```

**ВАЖНО:** Без навигации клавиатура НЕ РАБОТАЕТ!

### 10.3. Цвета кнопок

```yaml
m_Colors:
  m_NormalColor: {r: 0.8, g: 0.8, b: 0.8, a: 1}  # Серый
  m_HighlightedColor: {r: 0.7, g: 0.7, b: 0.7, a: 1}  # Темно-серый
  m_SelectedColor: {r: 1, g: 1, b: 0, a: 1}  # ЯРКО-ЖЁЛТЫЙ (выделение)
  m_PressedColor: {r: 0.6, g: 0.6, b: 0.6, a: 1}  # Нажатие
```

### 10.4. Текст кнопки (Unicode)

```yaml
m_Text: "\u0412\u042B\u0425\u041E\u0414"  # "ВЫХОД" в Unicode
```

**Как конвертировать:**
```csharp
string unicode = System.Text.Encoding.Unicode.GetString(
    System.Text.Encoding.Convert(
        System.Text.Encoding.Default,
        System.Text.Encoding.Unicode,
        System.Text.Encoding.Default.GetBytes("ВЫХОД")
    )
);
```

### 10.5. Проверка кнопок в сцене

**Поиск всех кнопок:**
```bash
grep "m_Name:.*Button" Assets/Scenes/MainMenu.unity
```

**Должно быть:**
```
m_Name: NewGameButton
m_Name: ContinueButton
m_Name: SaveButton
m_Name: LoadButton
m_Name: SettingsButton
m_Name: ExitButton  ← Новая!
```

**Лишние кнопки — УДАЛЯТЬ!**
```bash
# CancelButton, OldButton и т.д. → удалить
```

---

## 📝 CLEAN CODE — ПРАВИЛА ЧИСТОГО КОДА

### 11.1. Именование (C#)

| Элемент | Нотация | Пример |
|---------|---------|--------|
| Класс | PascalCase | `PlayerController` |
| Метод | PascalCase | `CalculateScore()` |
| Приватное поле | _camelCase | `private int _health;` |
| Локальная переменная | camelCase | `int playerScore;` |
| Константа | PascalCase | `public const int MaxPlayers = 4;` |

### 11.2. Комментарии

```csharp
// ❌ Плохо — говорит "ЧТО"
i++; // увеличиваем i

// ✅ Хорошо — говорит "ПОЧЕМУ"
// Пост-инкремент, значение нужно до увеличения
i++;
```

### 11.3. XML-документация

```csharp
/// <summary>
/// Вычисляет итоговый счёт с бонусами.
/// </summary>
/// <param name="baseScore">Базовый счёт.</param>
/// <returns>Итоговый счёт.</returns>
public int CalculateScore(int baseScore) { }
```

### 11.4. Принципы

- **KISS:** Делай проще!
- **DRY:** Не повторяйся!
- **YAGNI:** Не пиши на будущее!
- **SRP:** Одна ответственность!

---

## 🐛 ТИПИЧНЫЕ ОШИБКИ И РЕШЕНИЯ

### 12.1. Кнопка не работает от мыши

**Причина:** Нет ссылки в инспекторе или префаб переопределяет

**Решение:**
1. Удалить префаб
2. Создать кнопку напрямую в сцене
3. Назначить onClick вручную

### 12.2. Клавиатура не работает

**Причина:** Нет навигации (Navigation)

**Решение:**
```yaml
m_Navigation:
  m_SelectOnUp: {fileID: ...}  # Назначить!
  m_SelectOnDown: {fileID: ...}  # Назначить!
```

### 12.3. Две кнопки на одном месте

**Причина:** Старая кнопка не удалена

**Решение:**
```bash
# Найти все кнопки
grep "m_Name:.*Button" scene.unity

# Удалить лишние
# Оставить только 5-6 основных
```

### 12.4. Сборка не работает в batchmode

**Причина:** Editor скрипты требуют GUI

**Решение:**
- Использовать только для тестов
- Для сборок — обычные скрипты

---

## 🔧 КОМАНДЫ ДЛЯ UNITY

### 13.1. Сборка билда

```bash
# Windows
Unity.exe -batchmode -nographics -executeMethod "Editor.AutoBuildScript.BuildWindowsX64" -projectPath "Project" -quit
```

### 13.2. Тесты

```bash
# PlayMode тесты
Unity.exe -batchmode -runTests -testPlatform PlayMode -testResults results.xml -projectPath "Project" -quit
```

### 13.3. Поиск в сцене

```bash
# Найти все кнопки
grep "m_Name:.*Button" Assets/Scenes/MainMenu.unity

# Найти конкретный объект
grep "& 1400000001" Assets/Scenes/MainMenu.unity
```

---

## 📊 ЧЕК-ЛИСТ ПЕРЕД СБОРКОЙ

### 14.1. Код

- [ ] Нет ошибок компиляции
- [ ] Нет предупреждений (warnaserror)
- [ ] Все имена по стандартам
- [ ] XML-комментарии для публичных методов
- [ ] Нет дублирования кода

### 14.2. Unity сцены

- [ ] Все кнопки назначены
- [ ] Навигация работает
- [ ] Нет лишних объектов
- [ ] Тексты правильные (Unicode)

### 14.3. Тесты

- [ ] Юнит-тесты проходят
- [ ] Интеграционные тесты работают
- [ ] Покрытие > 80%

### 14.4. Документация

- [ ] README обновлён
- [ ] CHANGELOG заполнен
- [ ] ИНСТРУКЦИЯ дополнена

---

## 📞 КОНТАКТЫ И РЕСУРСЫ

### Документация

- [.NET Docs](https://docs.microsoft.com/dotnet/)
- [Unity Manual](https://docs.unity3d.com/Manual/)
- [Docker Docs](https://docs.docker.com/)
- [GitHub Actions](https://docs.github.com/actions)
- [Clean Code](https://blog.cleancoder.com/)

### Инструменты

- [Roslynator](https://github.com/dotnet/roslynator)
- [xUnit](https://xunit.net/)
- [Coverlet](https://github.com/coverlet-coverage/coverlet)
- [Unity Test Framework](https://docs.unity3d.com/Manual/testing-ui.html)

---

## 🎯 ЗАКЛЮЧЕНИЕ

**Главное правило:**

> **Учись → Применяй → Документируй → Передавай знания**

Этот файл — **живой документ**. Он растёт с каждым проектом.
Каждое новое знание делает следующего ИИ-ассистента сильнее.

**Помни:** Ты не просто выполняешь задачи. Ты создаёшь наследие для будущих разработчиков.

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`AI_START_HERE.md`](../../AI_START_HERE.md) — Главная инструкция
- [`RULES_AND_TASKS.md`](../../RULES_AND_TASKS.md) — Правила и задачи
- [`ai_programming_tips.md`](ai_programming_tips.md) — Советы ИИ по программированию
- [`qwen_modes.md`](qwen_modes.md) — Режимы Qwen
- [`RULE_TEST_CASES.md`](../../reports/RULE_TEST_CASES.md) — Тест-кейсы для правил
- [`csharp_standards.md`](../00_CORE/csharp_standards.md) — Стандарты кода C#
- [`project_glossary.md`](../00_CORE/project_glossary.md) — Терминология проекта
- [`PROFILES_MATRIX.md`](../../02-Areas/Documentation/PROFILES_MATRIX.md) — Матрица профилей

---

**Последнее обновление:** 27 февраля 2026 г. (Версия 2.0)
**Следующее обновление:** [Автоматически при изучении нового]

---

*«Код — это литература. Пиши так, чтобы другие хотели читать.»*

*«Unity UI требует внимания к деталям. Проверяй навигацию, цвета, тексты!»*

