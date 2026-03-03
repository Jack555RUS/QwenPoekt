---
title: UNITY ATTRIBUTES GUIDE
version: 1.0
date: 2026-03-04
status: draft
---
# 📚 UNITY ATTRIBUTES — ПОЛНЫЙ СПРАВОЧНИК

**Дата:** 2 марта 2026 г.  
**Источник:** UnityCsReference (Unity 6000.2.0b4)  
**Статус:** ✅ Анализ завершён

---

## 🎯 НАЗНАЧЕНИЕ

Этот справочник описывает **все атрибуты Unity** для управления поведением скриптов, сериализацией, порядком выполнения и другими аспектами.

---

## 📋 КАТЕГОРИИ АТРИБУТОВ

### 1. АТРИБУТЫ КОМПОНЕНТОВ

#### DisallowMultipleComponent

**Назначение:** Запрещает добавлять несколько экземпляров компонента на один GameObject.

**Использование:**
```csharp
[DisallowMultipleComponent]
public class PlayerController : MonoBehaviour { }
```

**Результат:**
- ✅ Нельзя добавить второй PlayerController
- ⚠️ Unity покажет предупреждение при попытке

---

#### RequireComponent

**Назначение:** Автоматически добавляет требуемые компоненты.

**Использование:**
```csharp
[RequireComponent(typeof(Rigidbody2D))]
[RequireComponent(typeof(BoxCollider2D), typeof(AudioSource))]
public class CarController : MonoBehaviour { }
```

**Результат:**
- ✅ При добавлении CarController автоматически добавляются Rigidbody2D, BoxCollider2D, AudioSource
- ⚠️ Нельзя удалить требуемые компоненты через Inspector

---

#### AddComponentMenu

**Назначение:** Размещает скрипт в меню Component.

**Использование:**
```csharp
[AddComponentMenu("DragRace/Car Controller")]
public class CarController : MonoBehaviour { }

[AddComponentMenu("DragRace/UI/Speedometer", 10)] // Порядок 10
public class SpeedometerUI : MonoBehaviour { }
```

**Результат:**
- ✅ Скрипт появляется в меню Component → DragRace → Car Controller
- ✅ Порядок сортировки в меню

---

#### ExecuteInEditMode / ExecuteAlways

**Назначение:** Выполнение скрипта в режиме редактора.

**Использование:**
```csharp
// Только edit mode
[ExecuteInEditMode]
public class EditorOnlyScript : MonoBehaviour { }

// Всегда (edit + play mode)
[ExecuteAlways]
public class AlwaysRunningScript : MonoBehaviour { }
```

**Результат:**
- ✅ `Update()` вызывается в редакторе
- ⚠️ Нельзя использовать `FindGameObjectWithTag` в edit mode

---

#### DefaultExecutionOrder

**Назначение:** Установка порядка выполнения скриптов.

**Использование:**
```csharp
// Выполнить раньше всех (-100)
[DefaultExecutionOrder(-100)]
public class GameManager : MonoBehaviour { }

// Выполнить позже всех (+100)
[DefaultExecutionOrder(100)]
public class UILateUpdate : MonoBehaviour { }
```

**Порядок:**
- Меньшее число → раньше
- 0 → стандартный порядок
- Диапазон: -32000 до +32000

---

### 2. АТРИБУТЫ СЕРИАЛИЗАЦИИ

#### CreateAssetMenu

**Назначение:** Создание ScriptableObject через контекстное меню.

**Использование:**
```csharp
[CreateAssetMenu(menuName = "DragRace/Car Data", fileName = "NewCar", order = 1)]
public class CarData : ScriptableObject { }
```

**Результат:**
- ✅ ПКМ в Project → Create → DragRace → Car Data
- ✅ Файл: NewCar.asset

---

#### HideInInspector

**Назначение:** Скрыть поле из Inspector, но сериализовать.

**Использование:**
```csharp
public class Player : MonoBehaviour
{
    [SerializeField]
    [HideInInspector]
    private int _hiddenValue = 10;
}
```

**Результат:**
- ✅ Поле сериализуется
- ❌ Не видно в Inspector

---

#### SerializeField (не в этом файле, но важно)

**Назначение:** Сериализовать приватное поле.

**Использование:**
```csharp
[SerializeField] private float _speed = 5f;
```

---

### 3. АТРИБУТЫ МЕТОДОВ

#### ContextMenu

**Назначение:** Добавить команду в контекстное меню компонента.

**Использование:**
```csharp
public class CarController : MonoBehaviour
{
    [ContextMenu("Reset Car")]
    private void ResetCar()
    {
        _speed = 0;
        _health = 100;
    }
    
    [ContextMenu("Reset Car", true)] // validate
    private bool ValidateResetCar()
    {
        return _health < 100; // Показывать только если ранен
    }
    
    [ContextMenu("Debug/Print Stats", false, 1000)] // priority
    private void PrintStats()
    {
        Debug.Log($"Speed: {_speed}, Health: {_health}");
    }
}
```

**Результат:**
- ✅ ПКМ на компоненте → Reset Car
- ✅ Validate функция определяет доступность
- ✅ Priority определяет порядок в меню

---

#### RuntimeInitializeOnLoadMethod

**Назначение:** Автоматический вызов метода при загрузке.

**Использование:**
```csharp
public static class GameInitializer
{
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
    private static void AfterSceneLoad()
    {
        Debug.Log("Сцена загружена!");
    }
    
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    private static void BeforeSceneLoad()
    {
        Debug.Log("Перед загрузкой сцены!");
    }
    
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterAssembliesLoaded)]
    private static void AfterAssembliesLoaded()
    {
        Debug.Log("Сборки загружены!");
    }
    
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSplashScreen)]
    private static void BeforeSplashScreen()
    {
        Debug.Log("Перед заставкой Unity!");
    }
    
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
    private static void SubsystemRegistration()
    {
        Debug.Log("Регистрация подсистем!");
    }
}
```

**Типы загрузки:**
| Тип | Когда вызывается |
|-----|------------------|
| **BeforeSplashScreen** | Перед заставкой Unity |
| **AfterAssembliesLoaded** | После загрузки сборок |
| **BeforeSceneLoad** | Перед загрузкой первой сцены |
| **AfterSceneLoad** | После загрузки первой сцены |
| **SubsystemRegistration** | При регистрации подсистем (XR, etc.) |

---

#### PreserveAttribute

**Назначение:** Предотвратить вырезание кода при сборке (code stripping).

**Использование:**
```csharp
using UnityEngine.Scripting;

public class ReflectionHelper
{
    [Preserve]
    public static void CalledViaReflection()
    {
        // Этот метод не будет вырезан
    }
}

[Preserve]
public class NeverStrippedClass { }
```

**Результат:**
- ✅ Код не вырезается при IL2CPP build
- ✅ Критично для reflection вызовов

---

### 4. АТРИБУТЫ КЛАССОВ

#### HelpURL

**Назначение:** Custom справка для компонента.

**Использование:**
```csharp
[HelpURL("https://docs.dragraceunity.com/car-controller")]
public class CarController : MonoBehaviour { }
```

**Результат:**
- ✅ В Inspector появляется кнопка "?"
- ✅ Открывает указанную URL

---

#### ExcludeFromPreset

**Назначение:** Исключить из Preset.

**Использование:**
```csharp
[ExcludeFromPreset]
public class SingletonManager : MonoBehaviour { }
```

**Результат:**
- ✅ Нельзя создать Preset с этим компонентом

---

### 5. АТРИБУТЫ СБОРКИ

#### AssemblyIsEditorAssembly

**Назначение:** Пометить сборку как Editor-only.

**Использование:**
```csharp
// В Assembly-CSharp-Editor.cs
[assembly: AssemblyIsEditorAssembly]
```

**Результат:**
- ✅ Сборка не включается в билд

---

### 6. АТРИБУТЫ ИНТЕРФЕЙСОВ

#### RequireInterfaceAttribute

**Назначение:** Требовать реализацию интерфейса.

**Использование:**
```csharp
[RequireInterface(typeof(IDamageable))]
public class Health : MonoBehaviour { }

public interface IDamageable
{
    void TakeDamage(int damage);
}
```

**Результат:**
- ✅ Inspector показывает только компоненты с IDamageable

---

#### RequireDerivedAttribute

**Назначение:** Требовать наследования.

**Использование:**
```csharp
[RequireDerived(typeof(BaseWeapon))]
public class WeaponData : ScriptableObject { }
```

---

#### RequireImplementorsAttribute

**Назначение:** Требовать реализацию.

**Использование:**
```csharp
[RequireImplementors(typeof(IInteractable))]
public class InteractionSystem : MonoBehaviour { }
```

---

### 7. АТРИБУТЫ INSPECTOR

#### InspectorOrderAttribute

**Назначение:** Управление порядком полей.

**Использование:**
```csharp
[InspectorOrder("speed", "health", "name")]
public class CarData : ScriptableObject { }
```

---

### 8. АТРИБУТЫ IL2CPP

#### Il2CppEagerStaticClassConstruction

**Назначение:** Жадная инициализация статических классов.

**Использование:**
```csharp
[Il2CppEagerStaticClassConstruction]
public static class GameConstants
{
    public static readonly float MaxSpeed = 200f;
}
```

**Результат:**
- ✅ Класс инициализируется при старте
- ✅ Нет задержки при первом обращении

---

#### NativeConditional

**Назначение:** Условная компиляция для native кода.

**Использование:**
```csharp
[NativeConditional("ENABLE_MONO")]
public extern void SetDirty();
```

---

## 📊 СВОДНАЯ ТАБЛИЦА

| Атрибут | На что | Назначение |
|---------|--------|------------|
| **DisallowMultipleComponent** | Class | Запрет множественных экземпляров |
| **RequireComponent** | Class | Авто-добавление компонентов |
| **AddComponentMenu** | Class | Размещение в меню Component |
| **ExecuteInEditMode** | Class | Выполнение в edit mode |
| **ExecuteAlways** | Class | Выполнение всегда |
| **DefaultExecutionOrder** | Class | Порядок выполнения |
| **CreateAssetMenu** | Class | Создание ScriptableObject |
| **HideInInspector** | Field | Скрыть из Inspector |
| **ContextMenu** | Method | Команда в контекстное меню |
| **RuntimeInitializeOnLoadMethod** | Method | Авто-вызов при загрузке |
| **PreserveAttribute** | Any | Предотвратить вырезание кода |
| **HelpURL** | Class | Custom справка |
| **ExcludeFromPreset** | Class | Исключить из Preset |
| **AssemblyIsEditorAssembly** | Assembly | Editor-only сборка |
| **Il2CppEagerStaticClassConstruction** | Class | Жадная инициализация |

---

## ✅ РЕКОМЕНДАЦИИ ДЛЯ DRAGRACEUNITY

### 1. Используйте RequireComponent

```csharp
[RequireComponent(typeof(Rigidbody2D))]
[RequireComponent(typeof(BoxCollider2D))]
public class CarController : MonoBehaviour { }
```

### 2. Используйте DefaultExecutionOrder

```csharp
[DefaultExecutionOrder(-100)] // Раньше всех
public class GameInitializer : MonoBehaviour { }

[DefaultExecutionOrder(100)] // Позже всех
public class UILateUpdate : MonoBehaviour { }
```

### 3. Используйте RuntimeInitializeOnLoadMethod

```csharp
public static class GameBootstrap
{
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    private static void Bootstrap()
    {
        // Инициализация до загрузки сцены
        DontDestroyOnLoad(FindObjectOfType<AudioListener>());
    }
}
```

### 4. Используйте PreserveAttribute

```csharp
[Preserve]
public static class ReflectionHelper
{
    [Preserve]
    public static void CalledViaReflection() { }
}
```

---

**Справочник создан:** 2 марта 2026 г.  
**Следующее действие:** Применить атрибуты в DragRaceUnity


