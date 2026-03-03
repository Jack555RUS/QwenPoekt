# 📦 GITHUB РЕПОЗИТОРИИ — КАТАЛОГ

**Версия:** 1.0  
**Дата создания:** 2 марта 2026 г.  
**Источник:** Анализ папки `BOOK/` (12 PDF книг + документация Unity)

---

## 🎯 НАЗНАЧЕНИЕ

Этот файл — **каталог официальных GitHub репозиториев Unity Technologies**, упомянутых в книгах и документации проекта.

**Использовать для:**
- Поиска примеров кода
- Изучения лучших практик
- Интеграции готовых решений
- Отладки и понимания API

---

## 📊 СТАТИСТИКА

| Категория | Репозиториев | Приоритет для DragRaceUnity |
|-----------|--------------|-----------------------------|
| **UI** | 2 | 🔴 Высокий |
| **Audio** | 2 | 🟡 Средний |
| **Asset Management** | 2 | 🟡 Средний |
| **Physics 2D** | 1 | 🟢 Низкий |
| **AR** | 1 | 🟢 Низкий |
| **Accessibility** | 1 | 🟢 Низкий |
| **Graphics** | 1 | 🟡 Средний |
| **Platform** | 1 | 🟢 Низкий |
| **Reference** | 1 | 🔴 Высокий |
| **ВСЕГО** | **12** | — |

---

## 🎨 UI (USER INTERFACE)

### 1. ui-toolkit-dragon-crashers

**Ссылка:** https://github.com/unity-samples/ui-toolkit-dragon-crashers

**Описание:** Пример UI из книги "Create Scalable and Performant UI with UI Toolkit in Unity 6"

**Что содержит:**
- ✅ Полная игра с UI на UI Toolkit
- ✅ Data Binding примеры
- ✅ Локализация
- ✅ Кастомные элементы управления
- ✅ Оптимизация производительности

**Приоритет:** 🔴 Высокий (создаём меню на UI Toolkit)

**Интеграция:**
```
1. Изучить структуру проекта
2. Извлечь паттерны Data Binding
3. Адаптировать для DragRaceUnity
```

---

### 2. QuizU

**Ссылка:** https://github.com/unity-samples/QuizU

**Описание:** Викторина на UI Toolkit — образец архитектуры UI

**Что содержит:**
- ✅ Модульная архитектура UI
- ✅ MVVM паттерн
- ✅ Тесты для UI логики
- ✅ Примеры переходов между экранами

**Приоритет:** 🟡 Средний (архитектурные паттерны)

**Интеграция:**
```
1. Изучить MVVM реализацию
2. Адаптировать для меню DragRaceUnity
3. Внедрить в KNOWLEDGE_BASE
```

---

## 🔊 AUDIO (АУДИО)

### 3. NativeAudioPlugins

**Ссылка:** https://github.com/Unity-Technologies/NativeAudioPlugins

**Описание:** Audio Plug-in SDK — нативные DSP плагины

**Что содержит:**
- ✅ SDK для создания аудио плагинов
- ✅ Примеры DSP эффектов
- ✅ Плагины с кастомным GUI
- ✅ Spatializer примеры
- ✅ Код в общественном достоянии

**Приоритет:** 🟡 Средний (для будущей аудио системы)

---

### 4. AudioDemos

**Ссылка:** https://github.com/Unity-Technologies/AudioDemos

**Описание:** Музыкальные демо и примеры Audio Mixer

**Что содержит:**
- ✅ Примеры работы с Audio Mixer
- ✅ Музыкальные системы
- ✅ Аудио эффекты
- ✅ Динамический саундтрек

**Приоритет:** 🟢 Низкий (пока не нужно)

---

## 📦 ASSET MANAGEMENT (УПРАВЛЕНИЕ АССЕТАМИ)

### 5. UnityDataTools

**Ссылка:** https://github.com/Unity-Technologies/UnityDataTools

**Описание:** Инструменты для анализа AssetBundles и Addressables

**Что содержит:**
- ✅ Сравнение бинарных данных ассетов
- ✅ Анализ различий в сериализации
- ✅ WebExtract и Binary2Text утилиты
- ✅ GUI для анализа

**Приоритет:** 🟡 Средний (для оптимизации сборки)

---

### 6. Addressables-Sample

**Ссылка:** https://github.com/Unity-Technologies/Addressables-Sample

**Описание:** Примеры Addressable Asset System

**Что содержит:**
- ✅ Загрузка ассетов локально
- ✅ Загрузка ассетов удалённо
- ✅ Управление памятью
- ✅ DLC системы

**Приоритет:** 🟢 Низкий (пока не нужно)

---

## ♿ ACCESSIBILITY (ДОСТУПНОСТЬ)

### 7. a11y-public-sample

**Ссылка:** https://github.com/Unity-Technologies/a11y-public-sample

**Описание:** Sample project using Accessibility APIs

**Что содержит:**
- ✅ Accessibility API примеры
- ✅ Screen reader поддержка
- ✅ Навигация с клавиатуры
- ✅ Цветовая доступность

**Приоритет:** 🟢 Низкий (для будущей доступности)

---

## 🎮 PHYSICS 2D (ФИЗИКА)

### 8. PhysicsExamples2D

**Ссылка:** https://github.com/Unity-Technologies/PhysicsExamples2D

**Описание:** Примеры LowLevelPhysics2D API

**Что содержит:**
- ✅ PhysicsCore2D подкаталог
- ✅ Создание объектов
- ✅ Соединения (Joints)
- ✅ Коллизии
- ✅ Отладка (Debug Drawing)
- ✅ Кастомные данные

**Приоритет:** 🟢 Низкий (2D гонки не требуют сложной физики)

---

## 🥽 AR (ДОПОЛНЕННАЯ РЕАЛЬНОСТЬ)

### 9. arfoundation-samples

**Ссылка:** https://github.com/Unity-Technologies/arfoundation-samples

**Описание:** AR Foundation Samples

**Что содержит:**
- ✅ Трекинг изображений
- ✅ Обнаружение плоскостей
- ✅ Якоря (Anchors)
- ✅ Освещение (Light Estimation)
- ✅ Оклюзия

**Приоритет:** 🟢 Низкий (не для гоночной игры)

---

## 🎬 GRAPHICS (ГРАФИКА)

### 10. Graphics

**Ссылка:** https://github.com/Unity-Technologies/Graphics

**Описание:** Исходный код URP и HDRP

**Что содержит:**
- ✅ URP исходный код
- ✅ HDRP исходный код
- ✅ Примеры кастомных рендереров
- ✅ Shader Graph интеграция

**Приоритет:** 🟡 Средний (для будущей оптимизации графики)

---

## 📱 PLATFORM (ПЛАТФОРМЫ)

### 11. iOSNativeCodeSamples

**Ссылка:** https://github.com/Unity-Technologies/iOSNativeCodeSamples

**Описание:** Примеры нативной интеграции на iOS

**Что содержит:**
- ✅ Background Tasks
- ✅ BackgroundFetch
- ✅ Нативные плагины
- ✅ Интеграция с iOS SDK

**Приоритет:** 🟢 Низкий (PC платформа в приоритете)

---

## 🔧 REFERENCE (СПРАВОЧНИК)

### 12. UnityCsReference

**Ссылка:** https://github.com/Unity-Technologies/UnityCsReference

**Описание:** Исходный код C# API Unity

**Что содержит:**
- ✅ UnitySynchronizationContext реализация
- ✅ Все C# скрипты Unity API
- ✅ Export Scripting
- ✅ Runtime Export

**Приоритет:** 🔴 Высокий (понимание внутреннего устройства)

**Ключевые файлы:**
```
/Runtime/Export/Scripting/UnitySynchronizationContext.cs
/Runtime/Export/Scripting/Coroutine.cs
/Runtime/Export/Scripting/AsyncOperation.cs
```

---

## 🔄 ПРОЦЕСС ИНТЕГРАЦИИ

### Шаг 1: Выбор репозитория

```
Приоритет: 🔴 Высокий
→ ui-toolkit-dragon-crashers
→ UnityCsReference
```

### Шаг 2: Клонирование

```powershell
cd D:\QwenPoekt\_EXTERNAL
git clone https://github.com/unity-samples/ui-toolkit-dragon-crashers
git clone https://github.com/Unity-Technologies/UnityCsReference
```

### Шаг 3: Анализ

```
1. Изучить структуру
2. Выделить паттерны
3. Найти применимый код
```

### Шаг 4: Конспект

```
Создать файл в KNOWLEDGE_BASE/:
- 03-Resources/Knowledge/02_UNITY/UI_TOOLKIT_DRAGON_CRASHERS_ANALYSIS.md
- 03-Resources/Knowledge/00_CORE/UNITY_CS_REFERENCE_GUIDE.md
```

### Шаг 5: Внедрение

```
Адаптировать для DragRaceUnity:
- Data Binding паттерны
- Архитектура меню
- Оптимизация UI
```

---

## 📊 ПРИОРИТЕТЫ ДЛЯ DRAGRACEUNITY

| # | Репозиторий | Приоритет | Причина | Срок |
|---|-------------|-----------|---------|------|
| 1 | **ui-toolkit-dragon-crashers** | 🔴 | Создаём меню на UI Toolkit | Сейчас |
| 2 | **UnityCsReference** | 🔴 | Понимание API Unity | Сейчас |
| 3 | **QuizU** | 🟡 | MVVM для UI | 1 неделя |
| 4 | **Graphics** | 🟡 | URP оптимизация | 2 недели |
| 5 | **NativeAudioPlugins** | 🟡 | Аудио система | 1 месяц |
| 6 | **UnityDataTools** | 🟡 | Анализ ассетов | 1 месяц |
| 7 | **AudioDemos** | 🟢 | Музыка | Позже |
| 8 | **Addressables-Sample** | 🟢 | DLC | Позже |
| 9 | **a11y-public-sample** | 🟢 | Доступность | Позже |
| 10 | **PhysicsExamples2D** | 🟢 | 2D физика | Позже |
| 11 | **arfoundation-samples** | 🟢 | AR | Не нужно |
| 12 | **iOSNativeCodeSamples** | 🟢 | iOS | Не нужно |

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`BOOK/00_README.md`](../BOOK/00_README.md) — Каталог книг
- [`BOOK/UI_TOOLKIT_BOOK_DOWNLOAD.md`](../BOOK/UI_TOOLKIT_BOOK_DOWNLOAD.md) — UI Toolkit книга
- [`03-Resources/Knowledge/02_UNITY/UI_TOOLKIT_UNITY6_BOOK.md`](../03-Resources/Knowledge/02_UNITY/UI_TOOLKIT_UNITY6_BOOK.md) — Конспект UI Toolkit книги

---

## 📝 СЛЕДУЮЩИЕ ШАГИ

1. **Скачать приоритетные репозитории:**
   ```powershell
   git clone https://github.com/unity-samples/ui-toolkit-dragon-crashers
   git clone https://github.com/Unity-Technologies/UnityCsReference
   ```

2. **Создать анализ:**
   - `03-Resources/Knowledge/02_UNITY/DRAGON_CRASHERS_ANALYSIS.md`
   - `03-Resources/Knowledge/00_CORE/UNITY_CS_REFERENCE_GUIDE.md`

3. **Внедрить паттерны:**
   - Data Binding для меню
   - MVVM архитектура
   - Оптимизация UI

---

**Файл создан:** 2 марта 2026 г.  
**Следующее обновление:** По мере анализа репозиториев

