# 🧪 РУКОВОДСТВО ПО ТЕСТИРОВАНИЮ БАЗЫ ЗНАНИЙ

**Версия:** 1.0  
**Дата:** 4 марта 2026 г.  
**Статус:** ✅ Активно

**На основе:**
- Руководства пользователя "Тестирование Базы Знаний (Ядра) для обучения ИИ"
- Нашего опыта тестирования (before-action-checklist-v2.ps1)

---

## 📖 1. ЗАЧЕМ НУЖНО ТЕСТИРОВАНИЕ?

**Проблемы которые решает:**

| Проблема | Решение |
|----------|---------|
| Битые ссылки | `check-links.ps1` |
| Дубликаты файлов | `find-duplicates.ps1` |
| Непроверенные изменения | `before-action-checklist-v2.ps1` |
| Отсутствие метрик | `TEST_REPORT.md` (Pass/Fail) |

**Наши цели:**

1. ✅ Обнаружение ошибок до пользователей
2. ✅ Регрессионная надёжность (после изменений)
3. ✅ Измерение качества (метрики Pass/Fail)
4. ✅ Доверие к системе

---

## 📋 2. ВИДЫ ТЕСТИРОВАНИЯ (адаптировано)

### 2.1 Unit Testing (Модульное)

**Проверка отдельных компонентов:**

| Тест | Скрипт | Статус |
|------|--------|--------|
| Существование файлов | `Test-Path` | ✅ |
| Синтаксис Markdown | `check-links.ps1` | ✅ |
| Ссылки (битые) | `check-links.ps1` | ✅ |
| Дубликаты | `find-duplicates.ps1` | ✅ |

---

### 2.2 Integration Testing (Интеграционное)

**Проверка взаимодействия:**

| Тест | Скрипт | Статус |
|------|--------|--------|
| RAG поиск | `rag-search-simple.py` | ✅ |
| Векторизация | `vectorize-kb-simple.py` | ✅ |
| Before-action анализ | `before-action-checklist-v2.ps1` | ✅ |

---

### 2.3 Regression Testing (Регрессионное)

**Golden Set — набор тестовых вопросов:**

```json
// _TEST_ENV/GoldenSet.json
[
  {
    "id": "test_001",
    "question": "Как создать правило?",
    "expected_answer_contains": ["_drafts/", "_TEST_ENV/", "Base/"],
    "source_docs": ["02-workflow.md"],
    "topic": "rules"
  }
]
```

**Статус:** ⏳ В разработке

---

### 2.4 Data Quality Testing (Качество данных)

| Метрика | Скрипт | Статус |
|---------|--------|--------|
| Полнота | `full-kb-audit.ps1` | ✅ |
| Актуальность | `weekly-knowledge-audit.ps1` | ✅ |
| Непротиворечивость | — | ❌ |
| Дубликаты | `find-duplicates.ps1` | ✅ |

---

## 🛠️ 3. СОЗДАНИЕ ТЕСТОВЫХ УСЛОВИЙ

### 3.1 Golden Set (Золотой набор)

**Структура:**

```json
{
  "id": "test_001",              // Уникальный ID
  "question": "Вопрос",          // Тестовый запрос
  "expected_answer_contains": ["фраза1", "фраза2"],  // Ключевые фразы
  "source_docs": ["файл.md"],    // Ожидаемые источники
  "topic": "тема",               // Категория
  "critical": true               // Критичность
}
```

**Принципы:**
- Покрытие всех ключевых тем
- Граничные случаи (edge cases)
- Негативные тесты (вне компетенции)

---

### 3.2 Изоляция тестовой среды (Песочница)

**Наша реализация:**

```
_TEST_ENV/
├── Base/              # Копия Base для тестов
├── PROJECTS/          # Копия PROJECTS для тестов
└── GoldenSet.json     # Золотой набор тестов
```

**Преимущества:**
- ✅ Полная копия структуры
- ✅ Можно удалять/создавать без риска
- ✅ Многократный прогон тестов

---

### 3.3 Test Assertions (Проверки)

**Функции проверок:**

```powershell
# scripts/test-assertions.ps1

# Проверка: Файл удалён
Test-FileDeleted -Path "file.md"

# Проверка: Файл существует
Test-FileExists -Path "file.md"

# Проверка: Найдено зависимостей
Test-DependenciesFound -Expected 3 -Actual 3

# Проверка: Дубликатов нет
Test-NoDuplicates -Found 0
```

---

## 📊 4. КОНТРОЛЬ ПРАВИЛЬНОСТИ (Верификация)

### 4.1 Уровни проверки

| Уровень | Метод | Когда |
|---------|-------|-------|
| **Точное сравнение** | Строка в строку | Факты, числа |
| **Ключевые слова** | expected_answer_contains | Тексты |
| **NLP метрики** | BERTScore, MoverScore | Сложные тексты |
| **LLM-as-a-judge** | Другая LLM оценивает | Критичные тесты |
| **Человек** | Expert review | Продакшен |

---

### 4.2 Наша реализация

**Сейчас:**
```powershell
# Простое сравнение
if ($Expected -eq $Actual) {
    Write-Host "✅ PASS" -ForegroundColor Green
} else {
    Write-Host "❌ FAIL" -ForegroundColor Red
}
```

**План:**
```powershell
# LLM-as-a-judge (будущее)
$llmEvaluation = Invoke-LLMJudge -Question $q -Expected $e -Actual $a
if ($llmEvaluation -eq "correct") {
    Write-Host "✅ PASS" -ForegroundColor Green
}
```

---

## 🔄 5. ИНТЕГРАЦИЯ В CI/CD

### 5.1 Pre-commit hook

**Проверка изменённых файлов:**

```powershell
# .git/hooks/pre-commit
$changedFiles = git diff --cached --name-only
foreach ($file in $changedFiles) {
    # Проверка синтаксиса
    # Проверка ссылок
    # Проверка дубликатов
}
```

---

### 5.2 CI пайплайн (GitHub Actions)

**План:**

```yaml
# .github/workflows/test-kb.yml
name: Test Knowledge Base

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Run link check
        run: .\scripts\check-links.ps1
      
      - name: Run duplicate check
        run: .\scripts\find-duplicates.ps1
      
      - name: Run Golden Set tests
        run: .\scripts\run-golden-set.ps1
```

**Статус:** ⏳ В плане

---

## 📝 6. ШАБЛОН ОТЧЁТА О ТЕСТИРОВАНИИ

**Формат:**

```markdown
# ОТЧЁТ О ТЕСТИРОВАНИИ

**Дата:** YYYY-MM-DD  
**Версия:** X.X.X  
**Статус:** ✅ PASS / ❌ FAIL

---

## Тест 1: [Название]

### Arrange (Подготовка)
- [ ] Файлы созданы
- [ ] Данные подготовлены

### Act (Действие)
- [ ] Скрипт запущен
- [ ] Результат получен

### Assert (Проверка)
- ✅ Ожидаемо: [описание]
- ✅ Фактически: [описание]
- ✅ Результат: PASS

### Cleanup (Очистка)
- [ ] Файлы удалены
- [ ] Среда очищена

---

## ИТОГИ

| Тест | Результат |
|------|-----------|
| Тест 1 | ✅ PASS |
| Тест 2 | ❌ FAIL |

**Общий статус:** ✅ PASS (1/2 тестов)
```

---

## 🎯 7. ПРИМЕРЫ ТЕСТОВ

### Тест 1: Удаление файла с зависимостями

```powershell
# Arrange
New-Item "target.md" -Value "TEST"
New-Item "dep1.md" -Value "[link](target.md)"
New-Item "dep2.md" -Value "[link](target.md)"

# Act
.\before-action-checklist-v2.ps1 -Action delete -Target "target.md" -Force

# Assert
Test-FileDeleted -Path "target.md"           # ✅
Test-DependenciesFound -Expected 2 -Actual 2 # ✅

# Cleanup
Remove-Item "dep1.md", "dep2.md" -Force
```

---

### Тест 2: RAG поиск

```powershell
# Arrange
$question = "Как создать правило?"
$expected = "_drafts/", "_TEST_ENV/"

# Act
$result = python rag-search-simple.py $question

# Assert
foreach ($exp in $expected) {
    $result -contains $exp  # ✅
}
```

---

## 📚 8. РЕКОМЕНДУЕМАЯ ЛИТЕРАТУРА

### Книги:
- "Software Testing: A Craftsman's Approach" (Paul Jorgensen)
- "The Art of Software Testing" (Glenford Myers)
- "Machine Learning Engineering" (Andriy Burkov)

### Инструменты:
- **Great Expectations** — валидация данных
- **RAGAS** — метрики для RAG
- **Promptfoo** — тестирование промптов

### Статьи:
- "RAGAS: Automated Evaluation of Retrieval Augmented Generation"
- "ARES: Automated Evaluation Framework for RAG"

---

## 📊 9. МЕТРИКИ ТЕСТИРОВАНИЯ

| Метрика | Формула | Цель |
|---------|---------|------|
| **Pass Rate** | (Pass / Total) × 100 | >95% |
| **Coverage** | (Tested / Total) × 100 | >80% |
| **Regression** | (Same as before) × 100 | 100% |
| **Data Quality** | (Valid / Total) × 100 | >90% |

---

**Создано:** 4 марта 2026 г.  
**Следующий пересмотр:** 11 марта 2026 г.

---

**РУКОВОДСТВО ГОТОВО К ИСПОЛЬЗОВАНИЮ!** ✅
