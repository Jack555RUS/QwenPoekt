# =============================================================================
# ИНСТРУКЦИЯ ПО УСТАНОВКЕ МОДУЛЕЙ UNITY
# =============================================================================

## ПРОБЛЕМА
Сборка не удаётся из-за отсутствующих модулей:
- UnityEngine.UI (Text, Button, Slider, Image)
- UnityEngine.Audio (AudioSource, AudioClip)
- UnityEngine.ParticleSystem
- UnityEngine.InputSystem

## РЕШЕНИЕ

### Шаг 1: Откройте проект в Unity Editor

**Вариант А: Через Unity Hub**
1. Откройте Unity Hub
2. Нажмите "Open" → "Add project from disk"
3. Выберите папку: `D:\QwenPoekt\ProbMenu\DragRaceUnity`
4. Нажмите "Open"

**Вариант Б: Через скрипт**
```powershell
.\unity-open.ps1
```

### Шаг 2: Дождитесь импорта пакетов

После открытия проекта Unity начнёт импортировать пакеты.
Это займёт 1-3 минуты.

### Шаг 3: Откройте Package Manager

```
Window → Package Manager
```

### Шаг 4: Установите пакеты из Unity Registry

1. В Package Manager выберите **"Packages: Unity Registry"** (вверху слева)

2. Найдите и установите:

   | Поиск | Пакет | Версия | Кнопка |
   |-------|-------|--------|--------|
   | `UI Toolkit` | UI Toolkit | любая | **Install** |
   | `Input System` | Input System | 1.7.0 | **Install** |

3. Дождитесь установки каждого пакета

### Шаг 5: Проверьте Built-in пакеты

1. В Package Manager выберите **"Packages: In Project"**

2. Убедитесь, что включены:
   - ✅ **Audio** (встроен)
   - ✅ **Particle System** (встроен)
   - ✅ **Physics** (встроен)
   - ✅ **UI** (встроен)

### Шаг 6: Настройте Input System

1. Откройте:
   ```
   Edit → Project Settings → Player
   ```

2. Найдите **"Active Input Handling"**

3. Выберите: **"Both"** (или "Input System Package (New)")

### Шаг 7: Сохраните и закройте

```
File → Exit
```

### Шаг 8: Запустите сборку

```powershell
.\unity-build-fix.ps1
```

Или напрямую:

```powershell
powershell -Command "& 'C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe' -batchmode -nographics -quit -projectPath 'D:\QwenPoekt\ProbMenu\DragRaceUnity' -executeMethod BuildScript.PerformBuild -logFile 'D:\QwenPoekt\ProbMenu\Builds\unity-build.log'"
```

## ПРОВЕРКА РЕЗУЛЬТАТА

После сборки проверьте:

1. Лог файл: `D:\QwenPoekt\ProbMenu\Builds\unity-build.log`
2. Собранный файл: `D:\QwenPoekt\ProbMenu\Builds\DragRace\DragRace.exe`

Если видите "Build completed successfully" — всё получилось! 🎉

## ВОЗМОЖНЫЕ ОШИБКИ

### "error CS0246: The type or namespace name 'Text' could not be found"
**Решение:** Установите пакет "UI Toolkit" или "TextMeshPro"

### "error CS1069: The type name 'AudioSource' could not be found"
**Решение:** Включите Audio модуль (Built-in)

### "error CS1069: The type name 'ParticleSystem' could not be found"
**Решение:** Включите Particle System модуль (Built-in)

### "The type or namespace name 'InputSystem' could not be found"
**Решение:** Установите пакет "Input System" из Unity Registry

## ПОДДЕРЖКА

Если возникли проблемы:
1. Проверьте лог: `D:\QwenPoekt\ProbMenu\Builds\unity-build.log`
2. Откройте проект в Unity Editor
3. Проверьте Console на ошибки (Window → General → Console)
