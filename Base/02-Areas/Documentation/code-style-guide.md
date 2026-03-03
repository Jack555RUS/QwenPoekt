# 📖 ПРАВИЛА ХОРОШЕГО ТОНА (CLEAN CODE) — DRAG RACING PROJECT

**Дата:** 27 февраля 2026 г.  
**Статус:** ✅ Обязательно к исполнению

---

## 1. ОБЩИЕ ПРИНЦИПЫ

### 1.1. Читаемость превыше всего
```csharp
// ❌ Плохо
int d; // дни

// ✅ Хорошо
int daysSinceLastLogin;
```

### 1.2. KISS (Keep It Simple, Stupid)
Не усложняйте без необходимости!

### 1.3. DRY (Don't Repeat Yourself)
Повторяющийся код → выноси в метод!

### 1.4. YAGNI (You Ain't Gonna Need It)
Не пиши код "на будущее"!

### 1.5. Единая ответственность (SRP)
Один класс = одна задача

---

## 2. СОГЛАШЕНИЯ ОБ ИМЕНОВАНИИ (C#)

| Элемент | Нотация | Пример |
|---------|---------|--------|
| Класс, интерфейс | PascalCase | `PlayerController`, `IGameState` |
| Метод | PascalCase | `CalculateScore()` |
| Свойство | PascalCase | `public int Health { get; set; }` |
| Приватное поле | _camelCase | `private int _health;` |
| Локальная переменная | camelCase | `int playerScore;` |
| Константа | PascalCase | `public const int MaxPlayers = 4;` |
| Namespace | PascalCase | `namespace Game.UI` |

### 2.1. Важные нюансы

**Интерфейсы:** начинать с `I`
```csharp
public interface IGameState { }
```

**Булевы переменные:** начинать с `Is`, `Has`, `Can`
```csharp
bool isGameOver;
bool hasKey;
bool canJump;
```

---

## 3. КОММЕНТАРИИ

### 3.1. Комментируй "ПОЧЕМУ", а не "ЧТО"
```csharp
// ❌ Плохо
i++; // увеличиваем i на 1

// ✅ Хорошо
// Используем пост-инкремент, значение нужно до увеличения
i++;
```

### 3.2. XML-комментарии для публичных API
```csharp
/// <summary>
/// Вычисляет итоговый счёт игрока с учётом бонусов.
/// </summary>
/// <param name="baseScore">Базовый счёт до бонусов.</param>
/// <param name="bonusMultiplier">Множитель бонуса (>= 1).</param>
/// <returns>Итоговый счёт.</returns>
public int CalculateFinalScore(int baseScore, float bonusMultiplier)
{
    // ...
}
```

---

## 4. СТРУКТУРА ПРОЕКТА

### 4.1. Организация папок
```
/Assets
    /Scripts
        /UI          ← Интерфейсы
        /Gameplay    ← Игровая логика
        /Data        ← Модели данных
        /Core        ← Ядро
```

### 4.2. Namespace = Путь к папке
```
Assets/03-Resources/PowerShell/UI/MainMenu.cs → namespace Game.UI
```

### 4.3. Один класс — один файл
Исключения: маленькие вспомогательные классы

---

## 5. ФОРМАТИРОВАНИЕ

### 5.1. Фигурные скобки (стиль Allman)
```csharp
if (condition)
{
    // тело
}
```

### 5.2. Использование var
```csharp
var player = new Player(); // ✅ Хорошо, тип очевиден
var result = GetData();    // ❌ Плохо, тип неочевиден
```

### 5.3. Регионы (#region)
Группируй члены класса:
```csharp
#region Fields
private int _health;
#endregion

#region Properties
public int Health { get; set; }
#endregion

#region Methods
public void TakeDamage(int amount) { }
#endregion
```

---

## 6. ИДИОМЫ C#

### 6.1. Свойства вместо публичных полей
```csharp
// ❌ Плохо
public int Health;

// ✅ Хорошо
private int _health;
public int Health 
{ 
    get => _health; 
    private set => _health = Math.Max(value, 0); 
}
```

### 6.2. nameof вместо строк
```csharp
// ❌ Плохо
OnPropertyChanged("Health");

// ✅ Хорошо
OnPropertyChanged(nameof(Health));
```

### 6.3. Null-проверки
```csharp
// ✅ .NET 6+
ArgumentNullException.ThrowIfNull(value);

// ✅ Null-условный оператор
player?.TakeDamage(10);

// ✅ Null-объединение
var name = playerName ?? "Unknown";
```

### 6.4. Избегай магических чисел
```csharp
// ❌ Плохо
if (health > 100) { }

// ✅ Хорошо
private const int MaxHealth = 100;
if (health > MaxHealth) { }
```

---

## 7. ОБРАБОТКА ОШИБОК

### 7.1. Исключения для исключительных ситуаций
```csharp
// ❌ Плохо
try {
    int value = int.Parse(input);
} catch {
    // игнорируем
}

// ✅ Хорошо
if (!int.TryParse(input, out var value)) {
    Logger.W("Неверный ввод");
}
```

### 7.2. Освобождай ресурсы
```csharp
using (var stream = new FileStream(...)) {
    // работа с файлом
}
```

---

## 8. ПРИМЕР ПРАВИЛЬНОГО КЛАССА

```csharp
using System;

namespace Game.Entities
{
    /// <summary>
    /// Представляет игрового персонажа.
    /// </summary>
    public class Player
    {
        private const int DefaultHealth = 100;
        private int _health;

        /// <summary>
        /// Создаёт нового игрока.
        /// </summary>
        public Player(string name)
        {
            if (string.IsNullOrWhiteSpace(name))
                throw new ArgumentException("Name cannot be empty", nameof(name));

            Name = name;
            Health = DefaultHealth;
        }

        /// <summary>
        /// Имя игрока.
        /// </summary>
        public string Name { get; }

        /// <summary>
        /// Текущее здоровье [0, MaxHealth].
        /// </summary>
        public int Health
        {
            get => _health;
            private set => _health = Math.Clamp(value, 0, MaxHealth);
        }

        /// <summary>
        /// Максимальное здоровье.
        /// </summary>
        public int MaxHealth => DefaultHealth;

        /// <summary>
        /// Наносит урон.
        /// </summary>
        public void TakeDamage(int amount)
        {
            if (amount < 0)
                throw new ArgumentOutOfRangeException(nameof(amount));

            Health -= amount;
        }
    }
}
```

---

## 9. НАВИГАЦИЯ В МЕНЮ

### 9.1. Кнопки должны иметь:
- ✅ Правильные имена (PascalCase)
- ✅ Навигацию (Up/Down)
- ✅ Обработчики onClick
- ✅ Комментарии в коде

### 9.2. Пример кнопки в сцене:
```yaml
# КНОПКА ВЫХОД
# Позиция: y: -150 (под Настройками)
# Текст: ВЫХОД
# Обработчик: OnExit
--- !u!1 &1500000000
GameObject:
  m_Name: ExitButton
```

---

## 10. ЧЕК-ЛИСТ ПЕРЕД КОММИТОМ

- [ ] Код отформатирован (скобки, отступы)
- [ ] Имена соответствуют соглашениям
- [ ] Нет дублирования кода
- [ ] Нет магических чисел
- [ ] XML-комментарии для публичных методов
- [ ] Комментарии "почему", а не "что"
- [ ] Нет неиспользуемых using
- [ ] Сборка без ошибок
- [ ] Тесты проходят

---

**Соблюдайте эти правила — код будет понятным и поддерживаемым!** 🎯

