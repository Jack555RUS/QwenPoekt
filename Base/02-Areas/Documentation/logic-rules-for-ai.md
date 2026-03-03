# 🧠 ЛОГИЧЕСКИЕ ПРАВИЛА ДЛЯ ИИ

**Версия:** 1.0  
**Дата создания:** 2 марта 2026 г.  
**Статус:** ✅ Активно используется

---

## 1. 🎯 НАЗНАЧЕНИЕ

Этот файл описывает **логические правила для ИИ-ассистента**, включая методы вывода, индукции, дедукции и абдукции.

**Используйте для:**
- Построения логических цепочек рассуждений
- Вывода новых правил из примеров
- Проверки непротиворечивости знаний
- Генерации гипотез

---

## 2. 📋 ТИПЫ ЛОГИЧЕСКОГО ВЫВОДА

### 2.1 Дедукция (Deduction)

**Определение:** Вывод частного из общего.

```
Общее правило: Все коммиты должны быть закоммичены
Частный случай: Этот файл изменён
Вывод: Этот файл должен быть закоммичен
```

**Формула:**
```
∀x (P(x) → Q(x))
P(a)
∴ Q(a)
```

**Функция:**
```python
def deduct(general_rule, specific_case):
    """
    Дедуктивный вывод
    
    Args:
        general_rule: Общее правило (∀x (P(x) → Q(x)))
        specific_case: Частный случай (P(a))
    
    Returns:
        Вывод (Q(a)) или None (если неприменимо)
    """
    if matches_pattern(specific_case, general_rule.antecedent):
        return apply_consequent(general_rule, specific_case)
    return None
```

**Пример использования:**
```
Правило: "ВСЕ .md файлы должны иметь UTF-8 кодировку"
Файл: "AI_START_HERE.md"
Вывод: "AI_START_HERE.md должен иметь UTF-8 кодировку"
```

---

### 2.2 Индукция (Induction) ⭐

**Определение:** Вывод общего правила из частных примеров.

**Процесс:**
```
1. Собрать примеры (успешные действия)
2. Найти общие паттерны
3. Сформулировать правило
4. Проверить на непротиворечивость
```

**Формула:**
```
P(a₁) → Q(a₁)
P(a₂) → Q(a₂)
...
P(aₙ) → Q(aₙ)
∴ ∀x (P(x) → Q(x))  [с уверенностью n/(n+1)]
```

**Функция:**
```python
def induce_rule_from_examples(examples, min_confidence=0.8):
    """
    Индуктивный вывод правила из примеров
    
    Args:
        examples: Список примеров [(P, Q), ...]
        min_confidence: Минимальная уверенность (0.0-1.0)
    
    Returns:
        Правило или None (если недостаточно примеров)
    """
    if len(examples) < 3:
        return None  # Недостаточно примеров
    
    # Найти общие паттерны
    common_pattern = find_common_pattern(examples)
    
    # Сформулировать правило
    rule = formulate_rule(common_pattern)
    
    # Рассчитать уверенность
    confidence = len(examples) / (len(examples) + 1)
    
    if confidence >= min_confidence:
        return {
            "rule": rule,
            "confidence": confidence,
            "examples_count": len(examples),
            "status": "induced"
        }
    
    return None
```

**Пример индукции:**

| Пример | Ситуация | Действие | Результат |
|--------|----------|----------|-----------|
| 1 | Создание кнопки UI | Добавлен Image | Кнопка видна |
| 2 | Создание панели UI | Добавлен Image | Панель видна |
| 3 | Создание текста UI | Добавлен Image | Текст виден |

**Индуктивный вывод:**
> **Правило:** "ВСЕ UI элементы в Unity требуют Image компонент для видимости"
> 
> **Уверенность:** 3/(3+1) = 0.75 (75%)

---

**Критерии качественной индукции:**

| Критерий | Требование | Почему |
|----------|------------|--------|
| **Количество примеров** | ≥ 3 | Минимум для паттерна |
| **Разнообразие** | ≥ 2 типа ситуаций | Не случайное совпадение |
| **Отсутствие контрпримеров** | 0 | Иначе правило ложно |
| **Консистентность** | Все примеры согласованы | Нет противоречий |

---

**Проверка индуктивного правила:**

```python
def validate_induced_rule(rule, knowledge_base):
    """
    Проверка индуктивного правила на непротиворечивость
    
    Args:
        rule: Индуктивное правило
        knowledge_base: База знаний
    
    Returns:
        {
            "is_valid": bool,
            "counter_examples": [...],
            "confidence_adjusted": float
        }
    """
    # Поиск контрпримеров
    counter_examples = find_counter_examples(rule, knowledge_base)
    
    # Корректировка уверенности
    confidence_adjusted = rule.confidence * (1 - len(counter_examples) * 0.1)
    
    return {
        "is_valid": len(counter_examples) == 0,
        "counter_examples": counter_examples,
        "confidence_adjusted": confidence_adjusted,
        "recommendation": "принять" if len(counter_examples) == 0 else "пересмотреть"
    }
```

---

**Пример валидации:**

```
Правило: "ВСЕ UI элементы требуют Image компонент"

Проверка:
✅ Кнопка → Image → Видна
✅ Панель → Image → Видна
✅ Текст → Image → Видна
❌ TextMeshPro → Без Image → Виден  ← КОНТРПРИМЕР!

Вывод:
- is_valid: false
- counter_examples: [TextMeshPro]
- confidence_adjusted: 0.75 * 0.9 = 0.675
- recommendation: "пересмотреть"

Уточнённое правило:
"ВСЕ UI элементы Unity (кроме TextMeshPro) требуют Image компонент"
```

---

### 2.3 Абдукция (Abduction)

**Определение:** Поиск наилучшего объяснения наблюдений.

**Формула:**
```
Наблюдение: Q
Правило: P → Q
Вывод: Возможно P (как объяснение Q)
```

**Функция:**
```python
def find_best_explanation(observations, knowledge_base):
    """
    Поиск наилучшего объяснения (абдукция)
    
    Args:
        observations: Список наблюдений
        knowledge_base: База знаний (правила)
    
    Returns:
        Лучшее объяснение с уверенностью
    """
    hypotheses = []
    
    for observation in observations:
        # Найти все возможные объяснения
        possible_explanations = []
        
        for rule in knowledge_base:
            if rule.consequent == observation:
                possible_explanations.append({
                    "hypothesis": rule.antecedent,
                    "rule": rule,
                    "confidence": rule.confidence
                })
        
        hypotheses.append(possible_explanations)
    
    # Выбрать наилучшее (максимальная уверенность)
    best = max(hypotheses, key=lambda h: h.confidence)
    
    return best
```

**Пример:**
```
Наблюдение: "Тесты провалены (88%)"

Возможные объяснения:
1. Скрипты используют неверные пути (уверенность: 0.9)
2. Тесты некорректны (уверенность: 0.3)
3. Ошибка среды (уверенность: 0.1)

Лучшее объяснение: #1 (скрипты используют неверные пути)
```

---

### 2.4 Рассуждение по аналогии (Analogy) ⭐

**Определение:** Перенос знаний из одной области в другую на основе структурного сходства.

**Процесс:**
```
1. Найти структуру в области A (источник)
2. Найти похожую структуру в области B (цель)
3. Перенести знания (правила, паттерны)
4. Адаптировать под контекст B
```

**Формула:**
```
A имеет свойства: P₁, P₂, P₃, Q
B имеет свойства: P₁, P₂, P₃
∴ B, вероятно, имеет Q
```

**Функция:**
```python
def find_analogy(source_domain, target_domain, knowledge_base):
    """
    Поиск аналогии между областями
    
    Args:
        source_domain: Область-источник (известная)
        target_domain: Область-цель (новая)
        knowledge_base: База знаний
    
    Returns:
        {
            "analogy": "A:B :: C:D",
            "mapping": {...},
            "transferred_knowledge": [...],
            "confidence": float
        }
    """
    # Извлечь структуру источника
    source_structure = extract_structure(source_domain, knowledge_base)
    
    # Найти похожую структуру в цели
    target_structure = extract_structure(target_domain, knowledge_base)
    
    # Найти отображение (mapping)
    mapping = find_structural_mapping(source_structure, target_structure)
    
    # Перенести знания
    transferred = transfer_knowledge(source_structure, mapping)
    
    # Рассчитать уверенность
    confidence = calculate_analogy_confidence(mapping)
    
    return {
        "analogy": f"{source_domain}:{target_domain}",
        "mapping": mapping,
        "transferred_knowledge": transferred,
        "confidence": confidence
    }
```

**Пример аналогии:**

```
Источник: Git (система версионирования кода)
Цель: OLD/RELEASE/ARCHIVE (система хранения наработок)

Структура Git:
- Commit → Сохранение версии
- Branch → Ветка разработки
- Merge → Слияние версий
- Tag → Метка версии

Структура OLD/:
- _INBOX → Новые наработки (7 дней)
- _ANALYZED → Проанализированы (60 дней)
- _IDEAS → Идеи (вечно)
- _CODE_SNIPPETS → Код (вечно)

Аналогия:
Git:Commit :: OLD:_ANALYZED (сохранение для будущего)
Git:Branch :: OLD:_INBOX (активная разработка)
Git:Tag :: OLD:_IDEAS (важные метки)

Перенесённое знание:
"Как Git защищает от потери кода → OLD/ защищает от потери наработок"
```

---

**Критерии качественной аналогии:**

| Критерий | Требование | Почему |
|----------|------------|--------|
| **Структурное сходство** | ≥ 3 общих элемента | Не поверхностное |
| **Функциональное сходство** | Одинаковая роль | Та же цель |
| **Отсутствие противоречий** | 0 | Иначе аналогия ложна |
| **Полезность переноса** | Да | Практическая ценность |

---

### 2.5 Рассуждение на основе прецедентов (Case-Based Reasoning)

**Определение:** Решение новой задачи через адаптацию прошлых решений.

**Процесс:**
```
1. ИЗВЛЕЧЬ: Новая проблема → Поиск похожих кейсов
2. ПЕРЕИСПОЛЬЗУЙ: Адаптируй решение из кейса
3. АДАПТИРУЙ: Проверь, скорректируй под контекст
4. СОХРАНИ: Новый кейс → База прецедентов
```

**Функция:**
```python
def case_based_reasoning(new_problem, case_base, threshold=0.7):
    """
    Рассуждение на основе прецедентов
    
    Args:
        new_problem: Описание новой проблемы
        case_base: База прецедентов
        threshold: Порог相似ности (0.0-1.0)
    
    Returns:
        {
            "similar_cases": [...],
            "adapted_solution": {...},
            "confidence": float
        }
    """
    # Поиск похожих кейсов
    similar_cases = find_similar_cases(new_problem, case_base, threshold)
    
    if not similar_cases:
        return {"status": "no_similar_cases"}
    
    # Выбрать лучший кейс
    best_case = similar_cases[0]
    
    # Адаптировать решение
    adapted = adapt_solution(best_case, new_problem)
    
    return {
        "similar_cases": similar_cases,
        "adapted_solution": adapted,
        "confidence": best_case.similarity
    }
```

**См.:** [`../reports/CASE_BASES.md`](../reports/CASE_BASES.md)

---

### 2.6 Эпизодическая память (Episodic Memory)

**Определение:** Хранение целых цепочек рассуждений с контекстом ситуации.

**Структура эпизода:**
```
EPISODE-XXX:
- Контекст: [ситуация, время, проект]
- Цепочка рассуждений: [шаг 1 → шаг 2 → ... → результат]
- Инсайты: [ключевые открытия]
- Результат: [успех/неудача]
```

**Функция:**
```python
def retrieve_episodic_memory(new_situation, episodic_memory, threshold=0.8):
    """
    Извлечение эпизодической памяти
    
    Args:
        new_situation: Текущая ситуация
        episodic_memory: База эпизодов
        threshold: Порог相似ности (0.0-1.0)
    
    Returns:
        {
            "similar_episodes": [...],
            "reasoning_chain": [...],
            "insights": [...]
        }
    """
    # Поиск похожих эпизодов
    similar = find_similar_episodes(new_situation, episodic_memory, threshold)
    
    # Извлечь цепочки рассуждений
    chains = [ep.reasoning_chain for ep in similar]
    
    # Извлечь инсайты
    insights = [ep.insights for ep in similar]
    
    return {
        "similar_episodes": similar,
        "reasoning_chains": chains,
        "insights": insights
    }
```

**См.:** [`../reports/EPISODIC_MEMORY.md`](../reports/EPISODIC_MEMORY.md)

---

## 3. 🔄 МЕТА-ПРАВИЛА ЛОГИКИ

### 3.1 Проверка непротиворечивости

**Правило:**
> "ЕСЛИ новое правило противоречит существующему → ТО отклонить или уточнить"

**Функция:**
```python
def check_consistency(new_rule, knowledge_base):
    """
    Проверка нового правила на непротиворечивость
    
    Args:
        new_rule: Новое правило
        knowledge_base: База знаний
    
    Returns:
        {
            "is_consistent": bool,
            "conflicts": [...],
            "resolution": "принять/отклонить/уточнить"
        }
    """
    conflicts = []
    
    for existing_rule in knowledge_base:
        if rules_conflict(new_rule, existing_rule):
            conflicts.append({
                "rule": existing_rule,
                "type": get_conflict_type(new_rule, existing_rule),
                "severity": get_conflict_severity(new_rule, existing_rule)
            })
    
    return {
        "is_consistent": len(conflicts) == 0,
        "conflicts": conflicts,
        "resolution": "принять" if len(conflicts) == 0 else "уточнить"
    }
```

---

### 3.2 Приоритет правил

**Иерархия:**
```
🔴 Красный уровень (архитектура, безопасность) > 
🟡 Жёлтый уровень (процессы, стандарты) > 
🟢 Зелёный уровень (косметика, рутина)
```

**Функция:**
```python
def resolve_conflict(rule1, rule2):
    """
    Разрешение конфликта правил
    
    Args:
        rule1: Правило 1
        rule2: Правило 2
    
    Returns:
        {
            "winner": rule1 или rule2,
            "reason": "причин приоритета"
        }
    """
    priority_order = {"Красный": 3, "Жёлтый": 2, "Зелёный": 1}
    
    if priority_order[rule1.level] > priority_order[rule2.level]:
        return {"winner": rule1, "reason": f"{rule1.level} > {rule2.level}"}
    elif priority_order[rule1.level] < priority_order[rule2.level]:
        return {"winner": rule2, "reason": f"{rule2.level} > {rule1.level}"}
    else:
        # Одинаковый уровень → более специфичное побеждает
        if rule1.specificity > rule2.specificity:
            return {"winner": rule1, "reason": "более специфичное"}
        else:
            return {"winner": rule2, "reason": "более специфичное"}
```

---

### 3.3 Планирование рассуждений (Reasoning Planning) ⭐

**Определение:** Построение плана рассуждений перед выполнением задачи.

**Формат плана:**
```
План рассуждений:
1. Найти факт А
2. Применить правило Б
3. Проверить условие В
4. Сделать вывод Г
```

**Функция:**
```python
def plan_reasoning(goal, knowledge_base):
    """
    Планирование рассуждений
    
    Args:
        goal: Цель рассуждения
        knowledge_base: База знаний
    
    Returns:
        {
            "plan": [шаг 1, шаг 2, ...],
            "estimated_steps": int,
            "required_facts": [...],
            "required_rules": [...]
        }
    """
    # Декомпозиция цели
    subgoals = decompose_goal(goal)
    
    # Построение плана
    plan = []
    required_facts = []
    required_rules = []
    
    for subgoal in subgoals:
        # Найти необходимые факты
        facts = find_required_facts(subgoal, knowledge_base)
        required_facts.extend(facts)
        
        # Найти необходимые правила
        rules = find_required_rules(subgoal, knowledge_base)
        required_rules.extend(rules)
        
        # Добавить шаг
        plan.append({
            "step": f"Достичь подцели: {subgoal}",
            "facts": facts,
            "rules": rules
        })
    
    return {
        "plan": plan,
        "estimated_steps": len(plan),
        "required_facts": required_facts,
        "required_rules": required_rules
    }
```

**Пример:**
```
Цель: "Исправить ошибку компиляции"

План рассуждений:
1. Найти ошибку в логе компиляции
2. Определить тип ошибки (синтаксис, семантика, зависимости)
3. Найти правило решения для этого типа
4. Применить решение
5. Проверить компиляцию

Требуемые факты:
- Текст ошибки
- Файл, строка, столбец

Требуемые правила:
- error_solutions.md (база решений)
- csharp_standards.md (стандарты кода)
```

---

## 4. 🌳 TREE-OF-THOUGHT (ДЕРЕВО РАССУЖДЕНИЙ) ⭐

**Определение:** Исследование дерева рассуждений вместо линейной цепочки.

**Процесс:**
```
1. Сгенерировать несколько ветвей рассуждений (branches=3-5)
2. Оценить каждую ветвь (критерии: логичность, полнота, эффективность)
3. Выбрать лучшую ветвь
4. Продолжить углубление
```

**Функция:**
```python
def tree_of_thought(problem, knowledge_base, branches=3, depth=2):
    """
    Дерево рассуждений
    
    Args:
        problem: Проблема для решения
        knowledge_base: База знаний
        branches: Количество ветвей (по умолчанию 3)
        depth: Глубина дерева (по умолчанию 2)
    
    Returns:
        {
            "tree": {...},
            "best_branch": {...},
            "reasoning": "объяснение выбора"
        }
    """
    # Генерация ветвей
    tree = generate_branches(problem, knowledge_base, branches, depth)
    
    # Оценка ветвей
    for branch in tree.branches:
        branch.score = evaluate_branch(branch, problem, knowledge_base)
    
    # Выбор лучшей
    best = max(tree.branches, key=lambda b: b.score)
    
    return {
        "tree": tree,
        "best_branch": best,
        "reasoning": f"Выбрана ветвь {best.id} (оценка: {best.score})"
    }
```

**Пример:**
```
Проблема: "Кнопка не отображается в Unity"

Ветвь 1 (UI система):
- Проверить Canvas
- Проверить RectTransform
- Проверить Image компонент
Оценка: 0.85 ✅

Ветвь 2 (Слои и камеры):
- Проверить Layer
- Проверить Culling Mask
- Проверить камеру
Оценка: 0.60

Ветвь 3 (Скрипты):
- Проверить активацию объекта
- Проверить видимость в коде
- Проверить порядок инициализации
Оценка: 0.70

Выбор: Ветвь 1 (UI система) — наивысшая оценка
```

---

**Критерии оценки ветви:**

| Критерий | Вес | Описание |
|----------|-----|----------|
| **Логичность** | 30% | Нет логических ошибок |
| **Полнота** | 25% | Все шаги учтены |
| **Эффективность** | 25% | Минимум шагов |
| **Проверяемость** | 20% | Можно верифицировать |

---

## 5. 📊 ТАБЛИЦА ЛОГИЧЕСКИХ ФУНКЦИЙ

| Функция | Тип вывода | Параметры | Возвращает |
|---------|------------|-----------|------------|
| **deduct** | Дедукция | general_rule, specific_case | Вывод Q(a) |
| **induce_rule_from_examples** | Индукция | examples, min_confidence | Правило |
| **validate_induced_rule** | Валидация | rule, knowledge_base | is_valid, counter_examples |
| **find_best_explanation** | Абдукция | observations, KB | Лучшее объяснение |
| **find_analogy** | Аналогия | source, target, KB | Mapping, transferred knowledge |
| **case_based_reasoning** | CBR | new_problem, case_base | Adapted solution |
| **retrieve_episodic_memory** | Эпизод | new_situation, memory | Reasoning chains |
| **plan_reasoning** | Планирование | goal, KB | Plan of steps |
| **tree_of_thought** | Дерево | problem, KB, branches | Best branch |
| **check_consistency** | Проверка | new_rule, KB | Conflicts list |
| **resolve_conflict** | Приоритет | rule1, rule2 | Winner rule |

---

## 6. 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`AI_FUNCTIONS.md`](./AI_FUNCTIONS.md) — Функции ИИ
- [`../reports/CASE_BASES.md`](../reports/CASE_BASES.md) — Case-Based Reasoning
- [`../reports/EPISODIC_MEMORY.md`](../reports/EPISODIC_MEMORY.md) — Эпизодическая память
- [`../03-Resources/Knowledge/05_METHODOLOGY/AI_SELF_LEARNING_METHODOLOGY.md`](../03-Resources/Knowledge/05_METHODOLOGY/AI_SELF_LEARNING_METHODOLOGY.md) — Саморазвитие ИИ

---

## 7. 🎯 ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ

### Пример 1: Индуктивное создание правила

```
Шаг 1: Собрать примеры
- Пример 1: Создание меню → WorksFolder = "Base" → Успех
- Пример 2: Создание скрипта → WorksFolder = "Base" → Успех
- Пример 3: Тестирование → WorksFolder = "_TEST_ENV" → Успех

Шаг 2: Применить induce_rule_from_examples()
- Найдено: 3 примера
- Общий паттерн: WorksFolder зависит от типа задачи
- Уверенность: 3/(3+1) = 0.75

Шаг 3: Проверить валидацию
- Контрпримеров: 0
- is_valid: true

Шаг 4: Сформулировать правило
"ПРАВИЛО: WorksFolder = 'Base' для разработки, '_TEST_ENV' для тестирования"
```

---

### Пример 2: Аналогия между системами

```
Шаг 1: Определить области
- Источник: Git (версионирование)
- Цель: OLD/ (хранение наработок)

Шаг 2: Применить find_analogy()
- Mapping:
  Git:Commit → OLD:_ANALYZED
  Git:Branch → OLD:_INBOX
  Git:Tag → OLD:_IDEAS

Шаг 3: Перенести знание
- Git защищает от потери кода → OLD/ защищает от потери наработок
- Git имеет историю → OLD/ имеет сроки хранения

Шаг 4: Адаптировать
- OLD/ добавляет категории ценности (_IDEAS/, _CODE_SNIPPETS/)
- OLD/ добавляет сроки (7/60/∞ дней)
```

---

### Пример 3: Планирование рассуждений

```
Цель: "Почему сборка не работает?"

plan_reasoning(goal, knowledge_base):

План:
1. Найти лог сборки
2. Определить тип ошибки (компиляция, зависимости, пути)
3. Найти правило решения
4. Применить решение
5. Проверить сборку

Требуемые факты:
- Лог сборки
- Версия Unity
- Платформа

Требуемые правила:
- error_solutions.md
- UNITY_BUILD_GUIDE.md
```

---

**Файл создан:** 2 марта 2026 г.  
**Следующее обновление:** По мере добавления новых логических методов

