# 📦 Установка NuGet пакетов в Unity проект

**Версия:** 1.0
**Дата:** 27 февраля 2026 г.

---

## ⚠️ Важно

Unity автоматически генерирует `.csproj` файлы при открытии проекта. Это означает:

- ❌ Пакеты, установленные через `dotnet add package`, могут быть перезаписаны
- ❌ Прямое редактирование `.csproj` может быть потеряно
- ✅ Используйте `Directory.Build.props` для постоянных настроек
- ✅ Используйте Visual Studio NuGet Manager для установки пакетов

---

## 🚀 Способ 1: Visual Studio NuGet Manager (рекомендуется)

### Шаг 1: Открыть решение в Visual Studio

```
1. Откройте: DragRaceUnity.sln в Visual Studio
2. Дождитесь загрузки проектов
```

### Шаг 2: Открыть NuGet Manager

```
1. Tools → NuGet Package Manager → Manage NuGet Packages for Solution
```

### Шаг 3: Найти пакет

```
1. Вкладка: Browse
2. Поиск: StyleCop.Analyzers
3. Выберите версию: 1.2.0-beta.556
```

### Шаг 4: Установить в проект

```
1. Разверните список проектов
2. Найдите: Assembly-CSharp (игровые скрипты)
3. Поставьте галочку ☑
4. Нажмите Install
5. Примите лицензию
```

### Шаг 5: Проверить установку

```
1. Solution Explorer → Dependencies → Analyzers
2. Должен появиться: StyleCop.Analyzers
```

---

## 🚀 Способ 2: Package Manager Console

### Открыть консоль

```
Tools → NuGet Package Manager → Package Manager Console
```

### Установить StyleCop.Analyzers

```powershell
Install-Package StyleCop.Analyzers -Version 1.2.0-beta.556 -ProjectName Assembly-CSharp
```

### Установить SonarAnalyzer.CSharp

```powershell
Install-Package SonarAnalyzer.CSharp -Version 9.19.0.84067 -ProjectName Assembly-CSharp
```

---

## 🚀 Способ 3: Directory.Build.props (постоянная установка)

### Добавить в Directory.Build.props

Откройте `Directory.Build.props` и добавьте:

```xml
<Project>
  <!-- ... существующие настройки ... -->
  
  <!-- Package References -->
  <ItemGroup>
    <PackageReference Include="StyleCop.Analyzers" Version="1.2.0-beta.556">
      <PrivateAssets>all</PrivateAssets>
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
    </PackageReference>
    <PackageReference Include="SonarAnalyzer.CSharp" Version="9.19.0.84067">
      <PrivateAssets>all</PrivateAssets>
      <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
    </PackageReference>
  </ItemGroup>
</Project>
```

### Перегенерировать проекты Unity

```
1. Unity: Edit → Preferences → External Tools
2. Нажмите: "Regenerate project files"
3. Откройте DragRaceUnity.sln в Visual Studio
4. Дождитесь восстановления пакетов
```

---

## 📦 Популярные пакеты для Unity

| Пакет | Версия | Назначение |
|-------|--------|------------|
| **StyleCop.Analyzers** | 1.2.0-beta.556 | Стиль кода C# |
| **SonarAnalyzer.CSharp** | 9.19.0.84067 | Глубокий анализ |
| **Microsoft.CodeAnalysis.Analyzers** | 3.3.4 | Анализаторы Roslyn |
| **Roslynator.Analyzers** | 4.9.0 | Дополнительные анализаторы |

---

## 🐛 Проблемы и решения

### Проблема: Пакеты исчезают после перезапуска Unity

**Решение:**
```
1. Unity: Edit → Preferences → External Tools
2. Отключите: "Generate .csproj files" (если не нужно)
3. Или используйте Directory.Build.props
```

### Проблема: Ошибка NETSDK1022 (Duplicate items)

**Решение:**
```
1. Откройте .csproj файл
2. Найдите дублирующиеся <PackageReference>
3. Удалите лишние
4. Используйте Directory.Build.props вместо .csproj
```

### Проблема: Анализаторы не работают

**Решение:**
```
1. Build → Rebuild Solution
2. Tools → Options → Text Editor → C# → Advanced
3. Включите: "Enable full solution analysis"
4. Перезапустите Visual Studio
```

---

## ✅ Проверка установки

### В Solution Explorer:

```
Solution 'DragRaceUnity'
└── Projects
    ├── Assembly-CSharp
    │   ├── Dependencies
    │   │   └── Analyzers
    │   │       └── StyleCop.Analyzers  ← Должен быть здесь
    │   └── ...
    └── Assembly-CSharp-Editor
        └── ...
```

### В Error List:

```
1. Откройте любой .cs файл
2. Напишите код с нарушением стиля (например, без this.)
3. Проверьте Error List на предупреждения SA1101
```

---

## 📚 Дополнительные ресурсы

- [NuGet в Visual Studio](https://docs.microsoft.com/en-us/nuget/quickstart/install-and-use-package-visual-studio)
- [Directory.Build.props](https://docs.microsoft.com/en-us/visualstudio/msbuild/customize-your-build)
- [StyleCop.Analyzers](https://github.com/DotNetAnalyzers/StyleCopAnalyzers)

---

**Готово!** Теперь анализаторы работают в вашем проекте Unity! 🎉
