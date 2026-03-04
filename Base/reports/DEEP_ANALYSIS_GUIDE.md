# 📖 РУКОВОДСТВО ПО ГЛУБОКОМУ АНАЛИЗУ

**Версия:** 1.0  
**Дата:** 4 марта 2026 г.  
**Статус:** ✅ Активно

**На основе:**
- DEEP_ANALYSIS_TEMPLATE.md
- before-action-checklist-v2.ps1
- test-assertions.ps1

---

## 📖 1. ЗАЧЕМ НУЖЕН ГЛУБОКИЙ АНАЛИЗ?

**Проблемы которые решает:**

| Проблема | Решение |
|----------|---------|
| Поверхностные решения | Глубокий анализ причин |
| Повторение ошибок | Анализ первопричин (RCA) |
| Непроверенные изменения | before-action-checklist-v2.ps1 |
| Отсутствие метрик | test-assertions.ps1 |

**Наши цели:**
1. ✅ Понимать корневые причины
2. ✅ Предотвращать повторение
3. ✅ Проверять изменения до внедрения
4. ✅ Измерять качество

---

## 📋 2. КОМПОНЕНТЫ ГЛУБОКОГО АНАЛИЗА

### 2.1: before-action-checklist-v2.ps1

**Назначение:** Проверка перед действием

**Уровни проверки:**
| Уровень | Время | Когда |
|---------|-------|-------|
| **Fast** | 5 минут | Простые действия |
| **Medium** | 15 минут | Стандартные действия |
| **Full** | 30 минут | Критичные действия |

**7 шагов проверки:**
1. Проверка достаточности знаний
2. СТОП (пауза)
3. Анализ контекста + оценка риска
4. Глубокий анализ (дубликаты, функция)
5. Проверка документации
6. Проверка гипотез (Full уровень)
7. Проверка тестовой среды
8. Анализ последствий
9. Финальное подтверждение

**Использование:**
```powershell
.\scripts\before-action-checklist-v2.ps1 `
  -Action <delete/rename/move/modify> `
  -Target <путь/к/файлу> `
  -Level <Fast/Medium/Full> `
  -CheckDuplicates `
  -Verbose `
  -Log
```

---

### 2.2: test-assertions.ps1

**Назначение:** Функции проверок для тестирования

**9 функций:**
| Функция | Назначение |
|---------|------------|
| `Test-FileDeleted` | Проверка удаления файла |
| `Test-FileExists` | Проверка существования файла |
| `Test-DependenciesFound` | Проверка зависимостей |
| `Test-NoDuplicates` | Проверка дубликатов |
| `Test-ContentContains` | Проверка содержимого |
| `Test-RiskScore` | Проверка оценки риска |
| `Test-LogCreated` | Проверка логов |
| `Test-ReportGenerated` | Проверка отчётов |
| `Write-TestSummary` | Итоговая сводка |

**Использование:**
```powershell
# Загрузить функции
. .\scripts\test-assertions.ps1

# Проверить что файл удалён
Test-FileDeleted -Path "file.md" -Verbose

# Проверить что зависимости найдены
Test-DependenciesFound -Expected 2 -Actual 2 -Verbose
```

---

### 2.3: find-duplicates.ps1

**Назначение:** Поиск дубликатов файлов

**Типы дубликатов:**
| Тип | Описание | Метод |
|-----|----------|-------|
| **Функциональные** | Файлы с одинаковой функцией | Анализ имени и расположения |
| **По хэшу** | Полные копии (байт в байт) | MD5 хэш |

**Использование:**
```powershell
.\scripts\find-duplicates.ps1 `
  -Path "D:\QwenPoekt\Base" `
  -ByHash `
  -ByFunction `
  -Verbose
```

**Результат:**
- Отчёт: `reports\duplicates-report.md`
- Статистика: Количество групп дубликатов

---

### 2.4: Golden Set

**Назначение:** Тестовые вопросы для регрессионного тестирования

**Структура:**
```json
{
  "id": "test_001",
  "question": "Как создать правило?",
  "expected_answer_contains": ["_drafts/", "_TEST_ENV/", "Base/"],
  "source_docs": ["02-workflow.md"],
  "topic": "rules",
  "critical": true
}
```

**Где:**
- `_TEST_ENV/GoldenSet.json`

**Использование:**
```powershell
# Запустить Golden Set тесты
python 03-Resources/AI/rag-search-simple.py "Как создать правило?"
```

---

## 🔍 3. ПРОЦЕСС ГЛУБОКОГО АНАЛИЗА

### 3.1: Перед действием

**Шаг 1: Запустить before-action-checklist-v2.ps1**

```powershell
.\scripts\before-action-checklist-v2.ps1 `
  -Action delete `
  -Target "file.md" `
  -Level Full `
  -CheckDuplicates `
  -Verbose
```

**Результат:**
- ✅ Оценка риска (0-25)
- ✅ Количество зависимостей
- ✅ Найденные дубликаты
- ✅ Рекомендации

---

### 3.2: Во время действия

**Шаг 2: Выполнить действие**

```powershell
# После успешного анализа
Remove-Item "file.md" -Force
```

**Важно:**
- before-action-checklist-v2.ps1 только АНАЛИЗИРУЕТ
- Действие выполняется отдельно
- После анализа получить подтверждение

---

### 3.3: После действия

**Шаг 3: Запустить test-assertions.ps1**

```powershell
# Загрузить функции
. .\scripts\test-assertions.ps1

# Проверить что файл удалён
Test-FileDeleted -Path "file.md" -Verbose

# Проверить что лог создан
Test-LogCreated -LogPath "logs\before-action-v2-*.log" -Verbose

# Итоговая сводка
Write-TestSummary -TestResults $testResults -TestName "Удаление файла"
```

**Результат:**
- ✅ Pass Rate: X%
- ✅ Все проверки пройдены/не пройдены

---

## 📊 4. ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ

### Пример 1: Удаление файла

**Сценарий:** Удалить устаревший файл

```powershell
# Arrange
New-Item "test-file.md" -Value "TEST" -Force
New-Item "dep1.md" -Value "[link](test-file.md)" -Force

# Act (Анализ)
.\scripts\before-action-checklist-v2.ps1 `
  -Action delete `
  -Target "test-file.md" `
  -Level Full `
  -CheckDuplicates `
  -Verbose

# Execute (Действие)
Remove-Item "test-file.md" -Force

# Assert (Проверка)
. .\scripts\test-assertions.ps1
$testResults = @()
$testResults += Test-FileDeleted -Path "test-file.md" -Verbose
$testResults += Test-LogCreated -LogPath "logs\before-action-v2-*.log" -Verbose

# Cleanup
Remove-Item "dep1.md" -Force

# Summary
Write-TestSummary -TestResults $testResults -TestName "Удаление файла"
```

**Ожидаемый результат:**
- ✅ Все 7 шагов before-action-checklist-v2.ps1 выполнены
- ✅ Файл удалён
- ✅ Лог создан
- ✅ Pass Rate: 100%

---

### Пример 2: Переименование файла

**Сценарий:** Переименовать файл с обновлением ссылок

```powershell
# Arrange
New-Item "old-name.md" -Value "TEST" -Force
New-Item "dep1.md" -Value "[link](old-name.md)" -Force

# Act (Анализ)
.\scripts\before-action-checklist-v2.ps1 `
  -Action rename `
  -Target "old-name.md" `
  -NewTarget "new-name.md" `
  -Level Full `
  -CheckDuplicates `
  -Verbose

# Execute (Действие)
Rename-Item "old-name.md" -NewName "new-name.md"

# Assert (Проверка)
. .\scripts\test-assertions.ps1
$testResults = @()
$testResults += Test-FileDeleted -Path "old-name.md" -Verbose
$testResults += Test-FileExists -Path "new-name.md" -Verbose
$testResults += Test-LogCreated -LogPath "logs\before-action-v2-*.log" -Verbose

# Cleanup
Remove-Item "dep1.md" -Force

# Summary
Write-TestSummary -TestResults $testResults -TestName "Переименование файла"
```

**Ожидаемый результат:**
- ✅ Все 7 шагов выполнены
- ✅ Старый файл не существует
- ✅ Новый файл существует
- ✅ Pass Rate: 100%

---

### Пример 3: Перемещение папки

**Сценарий:** Переместить папку с файлами

```powershell
# Arrange
New-Item "source-folder" -ItemType Directory -Force
New-Item "source-folder\file1.md" -Value "TEST 1" -Force
New-Item "source-folder\file2.md" -Value "TEST 2" -Force

# Act (Анализ)
.\scripts\before-action-checklist-v2.ps1 `
  -Action move `
  -Target "source-folder" `
  -NewTarget "destination-folder" `
  -Level Full `
  -CheckDuplicates `
  -Verbose

# Execute (Действие)
if (-not (Test-Path "destination-folder")) {
    New-Item "destination-folder" -ItemType Directory -Force
}
Move-Item "source-folder" -Destination "destination-folder" -Force

# Assert (Проверка)
. .\scripts\test-assertions.ps1
$testResults = @()
$testResults += Test-FileDeleted -Path "source-folder" -Verbose
$testResults += Test-FileExists -Path "destination-folder" -Verbose
$testResults += Test-FileExists -Path "destination-folder\file1.md" -Verbose
$testResults += Test-FileExists -Path "destination-folder\file2.md" -Verbose
$testResults += Test-LogCreated -LogPath "logs\before-action-v2-*.log" -Verbose

# Cleanup
Remove-Item "destination-folder" -Recurse -Force

# Summary
Write-TestSummary -TestResults $testResults -TestName "Перемещение папки"
```

**Ожидаемый результат:**
- ✅ Все 7 шагов выполнены
- ✅ Старая папка не существует
- ✅ Новая папка существует
- ✅ Файлы в папке существуют
- ✅ Pass Rate: 100%

---

## 📈 5. МЕТРИКИ ГЛУБОКОГО АНАЛИЗА

| Метрика | Формула | Цель | Текущее |
|---------|---------|------|---------|
| **Pass Rate тестов** | (Pass / Total) × 100 | 100% | 100% |
| **Средняя оценка риска** | Avg risk score | <10 | — |
| **Предотвращено ошибок** | Caught before action | >80% | — |
| **Время анализа** | Avg minutes | <30 мин | — |

---

## 🔗 6. СВЯЗАННЫЕ ФАЙЛЫ

| Файл | Назначение |
|------|------------|
| [`before-action-checklist-v2.ps1`](../scripts/before-action-checklist-v2.ps1) | Проверка перед действием |
| [`test-assertions.ps1`](../scripts/test-assertions.ps1) | Функции проверок |
| [`find-duplicates.ps1`](../scripts/find-duplicates.ps1) | Поиск дубликатов |
| [`DEEP_ANALYSIS_TEMPLATE.md`](./DEEP_ANALYSIS_TEMPLATE.md) | Шаблон анализа |
| [`TEST_REPORT.md`](./TEST_REPORT.md) | Отчёт о тестировании |
| [`ERROR_LOG.md`](./ERROR_LOG.md) | Журнал ошибок |
| [`ERROR_LEARNING_GUIDE.md`](./ERROR_LEARNING_GUIDE.md) | Обучение на ошибках |

---

## 📚 7. РЕКОМЕНДУЕМАЯ ЛИТЕРАТУРА

### Книги:
- "Software Testing: A Craftsman's Approach" (Paul Jorgensen)
- "The Art of Software Testing" (Glenford Myers)
- "Machine Learning Engineering" (Andriy Burkov)

### Инструменты:
- **Great Expectations** — валидация данных
- **RAGAS** — метрики для RAG
- **Promptfoo** — тестирование промптов

---

**Создано:** 4 марта 2026 г.  
**Следующий пересмотр:** 11 марта 2026 г.

---

**РУКОВОДСТВО ГОТОВО К ИСПОЛЬЗОВАНИЮ!** ✅
