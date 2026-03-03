# 🔧 ФУНКЦИИ ДЛЯ ИИ-АССИСТЕНТА

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Активно

---

## 🎯 НАЗНАЧЕНИЕ

Этот файл описывает **функции для вызова ИИ-ассистентом** для логического вывода, анализа и работы с базой знаний.

**Используйте для:**
- Вызова внешних инструментов (Function Calling)
- Логического вывода
- Поиска и анализа правил

---

## 📋 КАТАЛОГ ФУНКЦИЙ

### Раздел 1: Работа с базой знаний

#### 1.1 query_knowledge_base(query)

**Назначение:** Поиск правил и знаний по запросу.

**Параметры:**
```json
{
  "query": "строка поиска",
  "category": "правила|скрипты|руководства",
  "limit": 10
}
```

**Возвращает:**
```json
{
  "results": [
    {
      "file": "csharp_standards.md",
      "relevance": 0.95,
      "excerpt": "Стандарты кода C#...",
      "path": "03-Resources/Knowledge/00_CORE/"
    }
  ],
  "total": 5
}
```

**Пример вызова:**
```
query_knowledge_base(
  query: "стандарты кода C#",
  category: "правила",
  limit: 5
)
```

---

#### 1.2 get_rule_metadata(rule_name)

**Назначение:** Получение метаданных правила.

**Параметры:**
```json
{
  "rule_name": "имя файла.md"
}
```

**Возвращает:**
```json
{
  "version": "1.0",
  "created": "2026-02-28",
  "last_reviewed": "2026-03-02",
  "status": "active",
  "author": "Qwen Code",
  "level": 2,
  "class": "Стандарт"
}
```

**Пример вызова:**
```
get_rule_metadata(rule_name: "csharp_standards.md")
```

---

#### 1.3 get_rule_relations(rule_name)

**Назначение:** Получение связей правила (зависимости, влияния).

**Параметры:**
```json
{
  "rule_name": "имя файла.md"
}
```

**Возвращает:**
```json
{
  "depends_on": ["FOR_AI_READ_HERE.md"],
  "affects": ["csharp_fast_learning.md", "csharp_silent_testing.md"],
  "includes": [],
  "used_by": ["roslynator_cli.md"]
}
```

**Пример вызова:**
```
get_rule_relations(rule_name: "csharp_standards.md")
```

---

### Раздел 2: Логический вывод

#### 2.1 run_logical_inference(facts, goal)

**Назначение:** Логический вывод от фактов к цели.

**Параметры:**
```json
{
  "facts": ["факт1", "факт2"],
  "goal": "цель вывода"
}
```

**Возвращает:**
```json
{
  "success": true,
  "chain": [
    {"rule": "Правило 1", "from": ["факт1"], "to": "промежуточный1"},
    {"rule": "Правило 2", "from": ["промежуточный1", "факт2"], "to": "цель"}
  ],
  "result": "Вывод достигнут"
}
```

**Пример вызова:**
```
run_logical_inference(
  facts: ["тесты провалены", "88% успеха"],
  goal: "найти причину"
)
```

---

#### 2.2 get_causal_chain(effect)

**Назначение:** Поиск причинно-следственной цепочки.

**Параметры:**
```json
{
  "effect": "следствие"
}
```

**Возвращает:**
```json
{
  "chain": [
    {"cause": "скрипты используют Base", "effect": "тесты провалены"},
    {"cause": "пути неверные", "effect": "скрипты используют Base"}
  ],
  "root_cause": "пути неверные"
}
```

**Пример вызова:**
```
get_causal_chain(effect: "тесты провалены (88%)")
```

---

#### 2.3 check_rule_conflicts(rule1, rule2)

**Назначение:** Проверка двух правил на конфликт.

**Параметры:**
```json
{
  "rule1": "правило1.md",
  "rule2": "правило2.md"
}
```

**Возвращает:**
```json
{
  "has_conflict": true,
  "type": "priority_conflict",
  "description": "Разные уровни решений",
  "resolution": "Правило 1 побеждает (Красный > Зелёный)"
}
```

**Пример вызова:**
```
check_rule_conflicts(
  rule1: "Правило 1 (Красный уровень)",
  rule2: "Правило 2 (Зелёный уровень)"
)
```

---

#### 2.4 get_rule_metadata(rule_name)

**Назначение:** Получение мета-данных правила (мета-рассуждения).

**Параметры:**
```json
{
  "rule_name": "имя файла.md"
}
```

**Возвращает:**
```json
{
  "version": "1.0",
  "created": "2026-02-28",
  "last_reviewed": "2026-03-02",
  "status": "active",
  "author": "Qwen Code",
  "level": 2,
  "class": "Стандарт",
  "dependencies": ["file1.md", "file2.md"],
  "used_by": ["file3.md", "file4.md"]
}
```

**Пример вызова:**
```
get_rule_metadata(rule_name: "csharp_standards.md")
```

---

#### 2.5 get_inference_chain(query)

**Назначение:** Получение цепочки правил, использованных для вывода (мета-рассуждения).

**Параметры:**
```json
{
  "query": "запрос"
}
```

**Возвращает:**
```json
{
  "chain": [
    {"rule": "Правило 1", "from": ["факт1"], "to": "промежуточный1"},
    {"rule": "Правило 2", "from": ["промежуточный1", "факт2"], "to": "цель"}
  ],
  "total_rules": 2,
  "inference_time_ms": 150
}
```

**Пример вызова:**
```
get_inference_chain(query: "почему тесты провалены?")
```

---

#### 2.6 check_consistency()

**Назначение:** Проверка базы знаний на противоречия (мета-рассуждения).

**Параметры:** Нет

**Возвращает:**
```json
{
  "is_consistent": true,
  "conflicts": [],
  "warnings": [
    {"rule": "Правило 1", "issue": "Устарело (>90 дней)"}
  ]
}
```

**Пример вызова:**
```
check_consistency()
```

---

### Раздел 2A: Нейросимволический подход

#### 3.1 llm_to_logical_query(natural_language_query)

**Назначение:** Преобразование естественного языка в логический запрос (LLM как преобразователь).

**Параметры:**
```json
{
  "natural_language_query": "Почему тесты провалены?"
}
```

**Возвращает:**
```json
{
  "logical_function": "get_causal_chain",
  "arguments": {
    "effect": "тесты провалены"
  },
  "confidence": 0.95
}
```

**Пример вызова:**
```
llm_to_logical_query(natural_language_query: "Почему тесты провалены?")
```

**Процесс:**
```
1. LLM анализирует вопрос
2. LLM определяет тип (причинность)
3. LLM выбирает функцию (get_causal_chain)
4. LLM генерирует аргументы
```

---

#### 3.2 llm_generate_hypothesis(context)

**Назначение:** Генерация гипотез/правил на основе контекста (LLM как генератор гипотез).

**Параметры:**
```json
{
  "context": "Замечено: все правила имеют last_reviewed"
}
```

**Возвращает:**
```json
{
  "hypothesis": "Правило: Все правила должны иметь last_reviewed",
  "confidence": 0.85,
  "supporting_facts": [
    "csharp_standards.md имеет last_reviewed",
    "project_glossary.md имеет last_reviewed"
  ]
}
```

**Пример вызова:**
```
llm_generate_hypothesis(context: "Замечено: все правила имеют last_reviewed")
```

**Процесс:**
```
1. LLM анализирует базу знаний
2. LLM находит закономерность
3. LLM формулирует правило
4. check_consistency() → Проверка на противоречия
5. Если OK → Предложить Пользователю
```

---

#### 3.3 llm_explain_inference(chain)

**Назначение:** Преобразование цепочки правил в понятное объяснение (LLM для объяснения выводов).

**Параметры:**
```json
{
  "chain": [
    {"rule": "Правило 13", "description": "Красный уровень"},
    {"rule": "Правило 3", "description": "Создание файла"}
  ]
}
```

**Возвращает:**
```json
{
  "explanation": "При создании нового правила необходимо:\n1. Спросить пользователя (Красный уровень)\n2. Создать черновик в _drafts/\n3. Протестировать в _TEST_ENV\n4. Если 100% → Внедрить в Base",
  "readability_score": 0.9
}
```

**Пример вызова:**
```
llm_explain_inference(chain: [{"rule": "Правило 13"}, {"rule": "Правило 3"}])
```

---

#### 3.4 hybrid_rag_query(query)

**Назначение:** Гибридный запрос: векторный поиск + логический вывод.

**Параметры:**
```json
{
  "query": "Какие правила относятся к тестированию?"
}
```

**Возвращает:**
```json
{
  "vector_search": [
    {"file": "test-all-changes.ps1", "relevance": 0.95},
    {"file": "RULE_TEST_CASES.md", "relevance": 0.90}
  ],
  "logical_inference": {
    "function": "check_rule_relations",
    "argument": "тестирование",
    "result": ["test-all-changes.ps1", "RULE_TEST_CASES.md", "_TEST_ENV"]
  },
  "combined_answer": "К тестированию относятся 5 правил: test-all-changes.ps1, RULE_TEST_CASES.md, _TEST_ENV, ..."
}
```

**Пример вызова:**
```
hybrid_rag_query(query: "Какие правила относятся к тестированию?")
```

**Процесс:**
```
1. Векторный поиск → релевантные документы
2. Логический вывод → check_rule_relations("тестирование")
3. LLM формулирует итоговый ответ
```

---

### Раздел 3A: Автоматизация

#### 4.1 auto_annotate_file(file_path)

**Назначение:** Автоматическое аннотирование файла (теги, категория, метаданные).

**Параметры:**
```json
{
  "file_path": "03-Resources/Knowledge/00_CORE/csharp_standards.md"
}
```

**Возвращает:**
```json
{
  "tags": ["csharp", "standards", "code-quality", "clean-code"],
  "category": "Стандарты",
  "subcategory": "Код",
  "language": "ru",
  "reading_time_min": 5,
  "complexity": "intermediate",
  "related_files": ["csharp_fast_learning.md", "roslynator_cli.md"],
  "confidence": 0.92
}
```

**Пример вызова:**
```
auto_annotate_file(file_path: "03-Resources/Knowledge/00_CORE/csharp_standards.md")
```

**Процесс:**
```
1. LLM анализирует содержимое файла
2. Извлекает ключевые темы
3. Предлагает теги (4-6 штук)
4. Определяет категорию/подкатегорию
5. Находит связанные файлы
6. Возвращает аннотацию
```

---

#### 4.2 auto_classify_rule(rule_content)

**Назначение:** Автоматическая классификация правила по уровням/типам.

**Параметры:**
```json
{
  "rule_content": "ВСЕГДА тестировать в _TEST_ENV перед коммитом"
}
```

**Возвращает:**
```json
{
  "level": "Красный",
  "type": "Процесс",
  "category": "Тестирование",
  "priority": 1,
  "enforcement": "Обязательно",
  "confidence": 0.95
}
```

**Пример вызова:**
```
auto_classify_rule(rule_content: "ВСЕГДА тестировать в _TEST_ENV...")
```

---

#### 4.3 suggest_related_files(file_path, limit=5)

**Назначение:** Поиск связанных файлов на основе содержания и графа знаний.

**Параметры:**
```json
{
  "file_path": "03-Resources/Knowledge/00_CORE/csharp_standards.md",
  "limit": 5
}
```

**Возвращает:**
```json
{
  "related": [
    {"file": "csharp_fast_learning.md", "relevance": 0.95, "reason": "Обучение на основе стандартов"},
    {"file": "roslynator_cli.md", "relevance": 0.88, "reason": "Инструмент проверки стандартов"},
    {"file": "ai_programming_tips.md", "relevance": 0.82, "reason": "Советы по применению"}
  ]
}
```

**Пример вызова:**
```
suggest_related_files(file_path: "03-Resources/Knowledge/00_CORE/csharp_standards.md", limit=5)
```

---

#### 4.4 detect_knowledge_gaps(queries_log)

**Назначение:** Обнаружение пробелов в базе знаний на основе логов запросов.

**Параметры:**
```json
{
  "queries_log": [
    {"query": "как настроить Docker", "answered": false},
    {"query": "Unity 6 сборка", "answered": true}
  ]
}
```

**Возвращает:**
```json
{
  "gaps": [
    {"topic": "Docker настройка", "frequency": 5, "priority": "Высокая"},
    {"topic": "Unity 6 билд", "frequency": 3, "priority": "Средняя"}
  ],
  "recommendations": [
    "Создать DOCKER_SETUP_GUIDE.md",
    "Дополнить UNITY_BUILD_GUIDE.md"
  ]
}
```

**Пример вызова:**
```
detect_knowledge_gaps(queries_log: [...])
```

---

### Раздел 4: Анализ и метрики

#### 3.1 analyze_rule_quality(rule_name)

**Назначение:** Анализ качества правила.

**Параметры:**
```json
{
  "rule_name": "имя файла.md"
}
```

**Возвращает:**
```json
{
  "score": 95,
  "metrics": {
    "metadata": 100,
    "structure": 90,
    "content": 95,
    "links": 90,
    "tests": 100
  },
  "issues": ["Нет оглавления"],
  "recommendations": ["Добавить оглавление"]
}
```

**Пример вызова:**
```
analyze_rule_quality(rule_name: "csharp_standards.md")
```

---

#### 3.2 get_logic_metrics()

**Назначение:** Получение метрик логической базы.

**Параметры:** Нет

**Возвращает:**
```json
{
  "completeness": 0.95,
  "accuracy": 1.0,
  "avg_chain_length": 4.5,
  "response_time_ms": 150,
  "conflicts": 0
}
```

**Пример вызова:**
```
get_logic_metrics()
```

---

#### 3.3 find_duplicates(content)

**Назначение:** Поиск дубликатов содержания.

**Параметры:**
```json
{
  "content": "текст для проверки"
}
```

**Возвращает:**
```json
{
  "has_duplicates": true,
  "duplicates": [
    {
      "file": "similar_rule.md",
      "similarity": 0.85,
      "excerpt": "Похожий текст..."
    }
  ]
}
```

**Пример вызова:**
```
find_duplicates(content: "Всегда спрашивать выбор при...")
```

---

### Раздел 4: Тестирование

#### 4.1 run_test_suite(suite_name)

**Назначение:** Запуск набора тестов.

**Параметры:**
```json
{
  "suite_name": "all|rules|scripts"
}
```

**Возвращает:**
```json
{
  "total": 25,
  "passed": 25,
  "failed": 0,
  "success_rate": 1.0,
  "details": [
    {"test": "Тест 1", "passed": true},
    {"test": "Тест 2", "passed": true}
  ]
}
```

**Пример вызова:**
```
run_test_suite(suite_name: "all")
```

---

#### 4.2 verify_rule_tests(rule_name)

**Назначение:** Проверка тестов для конкретного правила.

**Параметры:**
```json
{
  "rule_name": "имя файла.md"
}
```

**Возвращает:**
```json
{
  "has_tests": true,
  "tests": [
    {"name": "Тест 1", "status": "passed"},
    {"name": "Тест 2", "status": "passed"}
  ],
  "coverage": 1.0
}
```

**Пример вызова:**
```
verify_rule_tests(rule_name: "csharp_standards.md")
```

---

### Раздел 5: Абдукция и вероятности

#### 5.1 find_best_explanation(observations)

**Назначение:** Поиск наилучшего объяснения (абдукция).

**Параметры:**
```json
{
  "observations": ["наблюдение1", "наблюдение2"]
}
```

**Возвращает:**
```json
{
  "best_explanation": {
    "hypothesis": "скрипты используют неверные пути",
    "confidence": 0.9,
    "supporting_facts": ["тесты провалены", "ошибки путей"]
  },
  "alternatives": [
    {"hypothesis": "тесты некорректны", "confidence": 0.3},
    {"hypothesis": "ошибка среды", "confidence": 0.1}
  ]
}
```

**Пример вызова:**
```
find_best_explanation(
  observations: ["тесты провалены", "88% успеха"]
)
```

---

#### 5.2 rank_hypotheses(hypotheses, evidence)

**Назначение:** Ранжирование гипотез по вероятности.

**Параметры:**
```json
{
  "hypotheses": ["гипотеза1", "гипотеза2"],
  "evidence": ["факт1", "факт2"]
}
```

**Возвращает:**
```json
{
  "ranked": [
    {"hypothesis": "гипотеза1", "probability": 0.7},
    {"hypothesis": "гипотеза2", "probability": 0.3}
  ]
}
```

**Пример вызова:**
```
rank_hypotheses(
  hypotheses: ["пути неверные", "тесты некорректны"],
  evidence: ["ошибки в логах", "88% успеха"]
)
```

---

## 🔧 ИНТЕГРАЦИЯ С LLM

### Пример 1: Function Calling в Qwen

**Запрос пользователя:**
```
Почему тесты провалены?
```

**Вызов функции:**
```json
{
  "function": "get_causal_chain",
  "arguments": {
    "effect": "тесты провалены (88%)"
  }
}
```

**Ответ функции:**
```json
{
  "chain": [
    {"cause": "скрипты используют Base", "effect": "тесты провалены"},
    {"cause": "пути неверные", "effect": "скрипты используют Base"}
  ],
  "root_cause": "пути неверные"
}
```

**Финальный ответ ИИ:**
```
🔍 Анализ: Тесты провалены из-за неправильных путей в скриптах.

Причинно-следственная цепочка:
1. Скрипты используют пути D:\QwenPoekt\Base
2. Тесты запускаются в _TEST_ENV
3. Пути не совпадают → тесты провалены

✅ Решение: Исправить пути на _TEST_ENV
```

---

### Пример 2: Логический вывод

**Запрос пользователя:**
```
Какое правило применить при переименовании?
```

**Вызов функции:**
```json
{
  "function": "run_logical_inference",
  "arguments": {
    "facts": ["файл переименован", "это Красный уровень"],
    "goal": "определить действие"
  }
}
```

**Ответ функции:**
```json
{
  "success": true,
  "chain": [
    {"rule": "Правило 13", "from": ["Красный уровень"], "to": "спросить выбор"}
  ],
  "result": "Спросить пользователя"
}
```

**Финальный ответ ИИ:**
```
🔴 Красный уровень: Всегда спрашивать выбор!

Применено Правило 13:
- ЕСЛИ: Переименование файла
- ТО: Спросить пользователя

Какой вариант предпочитаете?
- 1️⃣ Переименовать с обновлением ссылок
- 2️⃣ Отложить переименование
- 💡 Свой вариант
```

---

### Пример 3: Разрешение конфликта

**Запрос пользователя:**
```
Какое правило важнее: спрашивать или действовать автономно?
```

**Вызов функции:**
```json
{
  "function": "check_rule_conflicts",
  "arguments": {
    "rule1": "Правило 13 (Красный уровень)",
    "rule2": "Правило 15 (Зелёный уровень)"
  }
}
```

**Ответ функции:**
```json
{
  "has_conflict": true,
  "type": "priority_conflict",
  "resolution": "Правило 13 побеждает (Красный > Зелёный)"
}
```

**Финальный ответ ИИ:**
```
⚖️ Разрешение конфликта:

Правило 13 (Красный уровень) > Правило 15 (Зелёный уровень)

**Приоритет:**
🔴 Красный уровень — Всегда спрашивать
🟢 Зелёный уровень — Действовать автономно

**Вывод:** Красный уровень имеет приоритет!
```

---

## 📊 ТАБЛИЦА ФУНКЦИЙ

| Функция | Категория | Параметры | Возвращает |
|---------|-----------|-----------|------------|
| **query_knowledge_base** | Поиск | query, category, limit | Результаты поиска |
| **get_rule_metadata** | Метаданные | rule_name | Метаданные правила |
| **get_rule_relations** | Связи | rule_name | Зависимости, влияния |
| **run_logical_inference** | Вывод | facts, goal | Цепочка правил |
| **get_causal_chain** | Причинность | effect | Цепочка причин |
| **check_rule_conflicts** | Конфликты | rule1, rule2 | Наличие конфликта |
| **analyze_rule_quality** | Анализ | rule_name | Оценка, метрики |
| **get_logic_metrics** | Метрики | - | Метрики базы |
| **find_duplicates** | Дубликаты | content | Список дублей |
| **run_test_suite** | Тесты | suite_name | Результаты тестов |
| **verify_rule_tests** | Тесты | rule_name | Тесты правила |
| **find_best_explanation** | Абдукция | observations | Лучшее объяснение |
| **rank_hypotheses** | Вероятности | hypotheses, evidence | Ранжирование |

---

## 🎯 ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ

### Сценарий 1: Диагностика проблемы

```
1. Пользователь: "Тесты провалены, почему?"
2. ИИ → get_causal_chain(effect: "тесты провалены")
3. Функция → Цепочка причин
4. ИИ → Объяснение пользователю
5. ИИ → run_logical_inference(facts, goal: "исправить")
6. Функция → План действий
7. ИИ → Предложить решение
```

---

### Сценарий 2: Проверка правила

```
1. Пользователь: "Проверь правило csharp_standards.md"
2. ИИ → get_rule_metadata(rule_name: "csharp_standards.md")
3. Функция → Метаданные
4. ИИ → analyze_rule_quality(rule_name: "csharp_standards.md")
5. Функция → Оценка качества
6. ИИ → get_rule_relations(rule_name: "csharp_standards.md")
7. Функция → Связи
8. ИИ → Полный отчёт пользователю
```

---

### Сценарий 3: Поиск дубликатов

```
1. Пользователь: "Есть ли дубли этого правила?"
2. ИИ → find_duplicates(content: "текст правила")
3. Функция → Список дубликатов
4. ИИ → check_rule_conflicts(rule1, rule2)
5. Функция → Конфликты
6. ИИ → Рекомендации пользователю
```

---

### Раздел 6: Продвинутые методы рассуждений

#### 6.1 induce_rule_from_examples(examples)

**Назначение:** Индуктивный вывод общего правила из частных примеров.

**Параметры:**
```json
{
  "examples": [
    {"situation": "...", "action": "...", "result": "..."}
  ],
  "min_confidence": 0.8
}
```

**Возвращает:**
```json
{
  "rule": "сформулированное правило",
  "confidence": 0.75,
  "examples_count": 3,
  "status": "induced",
  "counter_examples": []
}
```

**Пример вызова:**
```
induce_rule_from_examples(
  examples: [
    {"situation": "Создание кнопки", "action": "Добавить Image", "result": "Видна"},
    {"situation": "Создание панели", "action": "Добавить Image", "result": "Видна"},
    {"situation": "Создание текста", "action": "Добавить Image", "result": "Виден"}
  ],
  min_confidence: 0.7
)
```

**Процесс:**
```
1. Проверить количество примеров (≥ 3)
2. Найти общий паттерн
3. Сформулировать правило
4. Рассчитать уверенность: n/(n+1)
5. Проверить на контрпримеры
6. Если валидно → вернуть правило
```

**См.:** [`logic_rules_for_ai.md`](./logic_rules_for_ai.md#22-индукция-induction)

---

#### 6.2 find_analogy(source_domain, target_domain)

**Назначение:** Поиск аналогии между областями для переноса знаний.

**Параметры:**
```json
{
  "source_domain": "область-источник",
  "target_domain": "область-цель"
}
```

**Возвращает:**
```json
{
  "analogy": "A:B :: C:D",
  "mapping": {
    "source_element": "target_element"
  },
  "transferred_knowledge": [...],
  "confidence": 0.85
}
```

**Пример вызова:**
```
find_analogy(
  source_domain: "Git (версионирование)",
  target_domain: "OLD/ (хранение наработок)"
)
```

**Процесс:**
```
1. Извлечь структуру источника
2. Найти похожую структуру в цели
3. Найти отображение (mapping)
4. Перенести знания
5. Рассчитать уверенность
```

**См.:** [`logic_rules_for_ai.md`](./logic_rules_for_ai.md#24-рассуждение-по-аналогии-analogy)

---

#### 6.3 plan_reasoning(goal)

**Назначение:** Построение плана рассуждений перед выполнением задачи.

**Параметры:**
```json
{
  "goal": "цель рассуждения"
}
```

**Возвращает:**
```json
{
  "plan": [
    {"step": 1, "action": "Найти факт А", "required": [...]},
    {"step": 2, "action": "Применить правило Б", "required": [...]},
    {"step": 3, "action": "Проверить условие В", "required": [...]},
    {"step": 4, "action": "Сделать вывод Г", "required": [...]}
  ],
  "estimated_steps": 4,
  "required_facts": [...],
  "required_rules": [...]
}
```

**Пример вызова:**
```
plan_reasoning(goal: "Исправить ошибку компиляции")
```

**Процесс:**
```
1. Декомпозировать цель на подцели
2. Для каждой подцели найти необходимые факты
3. Найти необходимые правила
4. Построить последовательный план
5. Оценить количество шагов
```

**См.:** [`logic_rules_for_ai.md`](./logic_rules_for_ai.md#33-планирование-рассуждений-reasoning-planning)

---

#### 6.4 tree_of_thought(problem, branches=3)

**Назначение:** Исследование дерева рассуждений вместо линейной цепочки.

**Параметры:**
```json
{
  "problem": "проблема для решения",
  "branches": 3,
  "depth": 2
}
```

**Возвращает:**
```json
{
  "tree": {
    "branches": [
      {"id": 1, "steps": [...], "score": 0.85},
      {"id": 2, "steps": [...], "score": 0.60},
      {"id": 3, "steps": [...], "score": 0.70}
    ]
  },
  "best_branch": {"id": 1, "score": 0.85},
  "reasoning": "Выбрана ветвь 1 (наивысшая оценка)"
}
```

**Пример вызова:**
```
tree_of_thought(
  problem: "Кнопка не отображается в Unity",
  branches: 3
)
```

**Процесс:**
```
1. Сгенерировать N ветвей рассуждений
2. Для каждой ветви оценить:
   - Логичность (30%)
   - Полнота (25%)
   - Эффективность (25%)
   - Проверяемость (20%)
3. Выбрать ветвь с максимальной оценкой
4. Продолжить углубление
```

**См.:** [`logic_rules_for_ai.md`](./logic_rules_for_ai.md#4-tree-of-thought-дерево-рассуждений)

---

#### 6.5 retrieve_episodic_memory(new_situation)

**Назначение:** Извлечение похожих эпизодов с цепочками рассуждений.

**Параметры:**
```json
{
  "new_situation": "описание текущей ситуации",
  "threshold": 0.8
}
```

**Возвращает:**
```json
{
  "similar_episodes": [
    {
      "id": "EPISODE-001",
      "context": {...},
      "reasoning_chain": [...],
      "insights": [...],
      "similarity": 0.92
    }
  ],
  "reasoning_chains": [...],
  "insights": [...]
}
```

**Пример вызова:**
```
retrieve_episodic_memory(
  new_situation: "Организация хаотичного хранилища файлов"
)
```

**Процесс:**
```
1. Извлечь контекст ситуации
2. Поиск похожих эпизодов по контексту
3. Сравнить цепочки рассуждений
4. Вернуть эпизоды с порогом相似ности
5. Извлечь инсайты
```

**См.:** [`../reports/EPISODIC_MEMORY.md`](../reports/EPISODIC_MEMORY.md)

---

#### 6.6 case_based_reasoning(new_problem)

**Назначение:** Решение новой задачи через адаптацию прошлых решений.

**Параметры:**
```json
{
  "new_problem": "описание новой проблемы",
  "threshold": 0.7
}
```

**Возвращает:**
```json
{
  "similar_cases": [
    {
      "id": "CASE-001",
      "problem": "...",
      "solution": "...",
      "result": "...",
      "similarity": 0.88
    }
  ],
  "adapted_solution": {...},
  "confidence": 0.88
}
```

**Пример вызова:**
```
case_based_reasoning(
  new_problem: "Кнопка не отображается в Unity UI"
)
```

**Процесс:**
```
1. ИЗВЛЕЧЬ: Поиск похожих кейсов
2. ПЕРЕИСПОЛЬЗУЙ: Выбрать лучший кейс
3. АДАПТИРУЙ: Скорректировать под контекст
4. СОХРАНИ: Новый кейс в базу
```

**См.:** [`../reports/CASE_BASES.md`](../reports/CASE_BASES.md)

---

## 📊 ОБНОВЛЁННАЯ ТАБЛИЦА ФУНКЦИЙ

| Функция | Раздел | Параметры | Возвращает |
|---------|--------|-----------|------------|
| **query_knowledge_base** | Поиск | query, category, limit | Результаты поиска |
| **get_rule_metadata** | Метаданные | rule_name | Метаданные правила |
| **get_rule_relations** | Связи | rule_name | Зависимости, влияния |
| **run_logical_inference** | Вывод | facts, goal | Цепочка правил |
| **get_causal_chain** | Причинность | effect | Цепочка причин |
| **check_rule_conflicts** | Конфликты | rule1, rule2 | Наличие конфликта |
| **analyze_rule_quality** | Анализ | rule_name | Оценка, метрики |
| **get_logic_metrics** | Метрики | - | Метрики базы |
| **find_duplicates** | Дубликаты | content | Список дублей |
| **run_test_suite** | Тесты | suite_name | Результаты тестов |
| **verify_rule_tests** | Тесты | rule_name | Тесты правила |
| **find_best_explanation** | Абдукция | observations | Лучшее объяснение |
| **rank_hypotheses** | Вероятности | hypotheses, evidence | Ранжирование |
| **induce_rule_from_examples** | Индукция | examples, min_confidence | Правило |
| **find_analogy** | Аналогия | source, target | Mapping, knowledge |
| **plan_reasoning** | Планирование | goal | Plan of steps |
| **tree_of_thought** | Дерево | problem, branches | Best branch |
| **retrieve_episodic_memory** | Эпизод | new_situation | Episodes, chains |
| **case_based_reasoning** | CBR | new_problem | Adapted solution |

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`logic_rules_for_ai.md`](./logic_rules_for_ai.md) — Логические правила для ИИ
- [`../reports/CASE_BASES.md`](../reports/CASE_BASES.md) — Case-Based Reasoning
- [`../reports/EPISODIC_MEMORY.md`](../reports/EPISODIC_MEMORY.md) — Эпизодическая память

---

**Версия:** 1.3 (Индукция, Аналогия, Планирование, Tree-of-Thought, CBR, Эпизодическая память)
**Дата:** 2026-03-02
**Статус:** ✅ Дополнено

