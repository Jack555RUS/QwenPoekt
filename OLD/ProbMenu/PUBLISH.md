# 📦 Публикация ProbMenu

## 🚀 Быстрая публикация

### Windows

```bash
# Публикация в папку publish (требуется .NET 10)
dotnet publish ProbMenu.csproj -c Release -o publish --self-contained false

# Запуск
start publish\ProbMenu.exe
```

### Кроссплатформенная публикация

```bash
# Windows x64
dotnet publish ProbMenu.csproj -c Release -o publish-win-x64 -r win-x64 --self-contained true

# Windows x86
dotnet publish ProbMenu.csproj -c Release -o publish-win-x86 -r win-x86 --self-contained true

# Windows ARM64
dotnet publish ProbMenu.csproj -c Release -o publish-win-arm64 -r win-arm64 --self-contained true
```

## 📋 Варианты публикации

### Framework-dependent (требуется .NET 10)

```bash
dotnet publish ProbMenu.csproj -c Release -o publish --self-contained false
```

**Размер:** ~1.3 MB  
**Требования:** .NET 10 Runtime на целевой машине

### Self-contained (автономный)

```bash
dotnet publish ProbMenu.csproj -c Release -o publish --self-contained true
```

**Размер:** ~70 MB  
**Требования:** Нет (всё включено)

### Single File (один файл)

```bash
dotnet publish ProbMenu.csproj -c Release -o publish -r win-x64 --self-contained true -p:PublishSingleFile=true
```

**Размер:** ~70 MB (один .exe файл)  
**Требования:** Нет

### ReadyToRun (оптимизированный)

```bash
dotnet publish ProbMenu.csproj -c Release -o publish -r win-x64 --self-contained true -p:PublishReadyToRun=true
```

**Размер:** ~75 MB  
**Требования:** Нет  
**Преимущество:** Быстрый запуск

## 📊 Сравнение размеров

| Режим | Размер | Требования |
|-------|--------|------------|
| Framework-dependent | ~1.3 MB | .NET 10 Runtime |
| Self-contained | ~70 MB | Нет |
| Single File | ~70 MB | Нет |
| ReadyToRun | ~75 MB | Нет |

## 🎯 Рекомендации

- **Для разработки:** `--self-contained false` (быстро, мало места)
- **Для клиентов:** `--self-contained true -r win-x64` (работает везде)
- **Для портативной версии:** `-p:PublishSingleFile=true` (один файл)

## 📁 Структура после публикации

```
publish/
├── ProbMenu.exe          # Главный исполняемый файл
├── ProbMenu.dll          # Основной ассембли
├── ProbMenu.deps.json    # Зависимости
├── ProbMenu.runtimeconfig.json  # Конфигурация runtime
├── Microsoft.*.dll       # Библиотеки Microsoft.Extensions
└── ...
```

## 🔧 Скрипт сборки

Запустите `build.bat` для автоматической сборки:

```bash
build.bat
```

## ✅ Проверка после сборки

```bash
# Запуск
start publish\ProbMenu.exe

# Или из командной строки
publish\ProbMenu.exe
```
