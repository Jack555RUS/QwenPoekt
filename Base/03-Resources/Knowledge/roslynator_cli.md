---
title: Roslynator Cli
version: 1.0
date: 2026-03-04
status: draft
---
# Roslynator CLI — Анализ C# кода

**Версия:** 1.0
**Дата создания:** 2026-03-02
**Последняя проверка:** 2026-03-02
**Статус:** ✅ Активно

**Автор:** Qwen Code

---

## 🎯 НАЗНАЧЕНИЕ

Автоматический анализ и исправление C# кода в командной строке.

---

## 🚀 УСТАНОВКА

### Базовая установка:

```powershell
dotnet tool install -g roslynator.dotnet.cli
```

**Требования:**
- ✅ .NET SDK 6.0/7.0/8.0/9.0
- ✅ Добавить в PATH: `/root/.dotnet/tools`

### Проверка установки:

```powershell
# Проверить версию
roslynator --version

# Показать справку
roslynator --help
```

### Обновление:

```powershell
dotnet tool update -g roslynator.dotnet.cli
```

### Удаление:

```powershell
dotnet tool uninstall -g roslynator.dotnet.cli
```

---

## 🐛 ТИПИЧНЫЕ ОШИБКИ ПРИ УСТАНОВКЕ

### Ошибка 1: "tool already installed"

**Решение:**
```powershell
# Обновить существующую
dotnet tool update -g roslynator.dotnet.cli
```

### Ошибка 2: "not found in NuGet package"

**Решение:**
```powershell
# Проверить .NET SDK
dotnet --version

# Если < 6.0 — обновить
# https://dotnet.microsoft.com/download
```

### Ошибка 3: "command not found" после установки

**Решение:**
```powershell
# Добавить в PATH
$env:PATH += ";$env:USERPROFILE\.dotnet\tools"

# Или добавить в профиль PowerShell
Add-Content -Path $PROFILE -Value '$env:PATH += ";$env:USERPROFILE\.dotnet\tools"'
```

---

## 🔧 ОСНОВНЫЕ КОМАНДЫ

| Команда | Назначение | Пример |
|---------|------------|--------|
| **analyze** | Анализ кода | `roslynator analyze Solution.sln` |
| **fix** | Исправление проблем | `roslynator fix Solution.sln` |
| **format** | Форматирование | `roslynator format Project.csproj` |
| **loc** | Физические строки | `roslynator loc Solution.sln` |
| **lloc** | Логические строки | `roslynator lloc Solution.sln` |

---

## 📊 КОДЫ ВОЗВРАТА

| Код | Значение |
|-----|----------|
| **0** | Успех (диагностик не найдено) |
| **1** | Найдены диагностики |
| **2** | Ошибка выполнения |

---

## 🐳 ИНТЕГРАЦИЯ В DOCKER

### Пример для Unity проекта:

```bash
# Анализ и исправление
cd /project && roslynator fix YourProject.sln

# Проверка результата
if [ $? -eq 0 ]; then
    echo "Код чист"
else
    echo "Найдены проблемы"
fi

# Сборка Unity
unity-editor -batchmode -projectPath /project -buildWindows64Player /project/builds/game.exe -quit
```

---

## 📋 СЛОЖНЫЕ ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ

### Пример 1: Анализ с фильтрацией

```powershell
# Анализировать только определённые диагностики
roslynator analyze Solution.sln --diagnostics CS0168,CS0219

# Исключить определённые диагностики
roslynator analyze Solution.sln --exclude-diagnostics CS0618
```

### Пример 2: Массовое исправление

```powershell
# Исправить всё в решении
roslynator fix Solution.sln

# Исправить только определённые проблемы
roslynator fix Solution.sln --diagnostics CS0168,CS0219

# Исправить с предварительным просмотром
roslynator fix Solution.sln --dry-run
```

### Пример 3: Форматирование с настройками

```powershell
# Форматировать проект
roslynator format Project.csproj

# Форматировать с настройками
roslynator format Project.csproj --use-tabs --indent-width 4
```

### Пример 4: Интеграция в CI/CD

```yaml
# GitHub Actions пример
- name: Install Roslynator
  run: dotnet tool install -g roslynator.dotnet.cli

- name: Analyze code
  run: roslynator analyze Solution.sln
  continue-on-error: true

- name: Fix code
  run: roslynator fix Solution.sln
```

---

## ⚠️ ВАЖНЫЕ НЮАНСЫ

### 1. Анализаторы не встроены

**Решение:**
```powershell
# Добавить NuGet пакет в проект
dotnet add package Roslynator.Analyzers
```

### 2. Работа с решениями и проектами

**Можно:**
- ✅ `Solution.sln` — всё решение
- ✅ `Project.csproj` — отдельный проект

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`unity_docker_builder.md`](../02_UNITY/unity_docker_builder.md) — Unity в Docker
- [`csharp_silent_testing.md`](csharp_silent_testing.md) — Тесты C#
- [`csharp_standards.md`](csharp_standards.md) — Стандарты кода
- [`csharp_fast_learning.md`](csharp_fast_learning.md) — Быстрое изучение C#
- [`ai_programming_tips.md`](../05_METHODOLOGY/ai_programming_tips.md) — Советы ИИ
- [`RULE_TEST_CASES.md`](../../reports/RULE_TEST_CASES.md) — Тест-кейсы
- [`RULES_INDEX.md`](../../02-Areas/Documentation/RULES_INDEX.md) — Индекс правил

---

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готово



