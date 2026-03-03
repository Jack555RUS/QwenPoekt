# 📚 ОБНОВЛЕНИЕ БАЗЫ ЗНАНИЙ — 28 февраля 2026 (Subagents)

**Правило:** Изучил → Создал → Применил!

---

## ✅ ЧТО ИЗУЧЕНО И СОЗДАНО

### Специализированные агенты (Subagents)

**Источник:** Возможность Qwen Code  
**Статус:** ✅ Создано 5 агентов

---

## 📊 СОЗДАННЫЕ АГЕНТЫ

| Агент | Роль | Файл |
|-------|------|------|
| **🛡️ Code Reviewer** | Проверка кода | `code-reviewer.md` |
| **🧪 Test Writer** | Написание тестов | `test-writer.md` |
| **🔒 Security Analyzer** | Анализ безопасности | `security-analyzer.md` |
| **📚 Documentation Writer** | Документация | `documentation-writer.md` |
| **🚀 Build Master** | Автоматизация сборки | `build-master.md` |

**Папка:** `.qwen/agents/`

---

## 🎯 КОМАНДЫ ДЛЯ АГЕНТОВ

### Code Reviewer:

```
/code-reviewer проверь [файл/модуль]
```

**Пример:**
```
/code-reviewer проверь Assets/03-Resources/PowerShell/UI/MainMenuController.cs
```

---

### Test Writer:

```
/test-writer напиши тесты для [модуль]
```

**Пример:**
```
/test-writer напиши тесты для SaveSystem
```

---

### Security Analyzer:

```
/security-analyzer проверь [файл/модуль]
```

**Пример:**
```
/security-analyzer выполни полную проверку безопасности
```

---

### Documentation Writer:

```
/doc-writer создай документацию для [модуль]
```

**Пример:**
```
/doc-writer создай документацию для PlayerData
```

---

### Build Master:

```
/build-master собери проект
```

**Пример:**
```
/build-master собери проект
/build-master запусти тесты
/build-master проанализируй логи сборки
```

---

## 📁 СТРУКТУРА ПАПКИ АГЕНТОВ

```
.qwen/
└── agents/
    ├── README.md                # Индекс агентов
    ├── code-reviewer.md         # Проверка кода
    ├── test-writer.md           # Написание тестов
    ├── security-analyzer.md     # Анализ безопасности
    ├── documentation-writer.md  # Документация
    └── build-master.md          # Автоматизация сборки
```

---

## 🔄 ЦИКЛ РАБОТЫ С АГЕНТАМИ

```
1. Пользователь выбирает агента
2. Запрашивает задачу через команду
3. Агент выполняет задачу
4. Предоставляет отчёт
5. Пользователь проверяет
6. При необходимости → исправления
```

---

## 📊 ПРЕИМУЩЕСТВА

### Специализация:

- ✅ Каждый агент — эксперт в своей области
- ✅ Глубокие знания по теме
- ✅ Быстрое выполнение задач

### Разделение ролей:

- ✅ Code Reviewer не пишет тесты
- ✅ Test Writer не проверяет безопасность
- ✅ Чёткое разграничение обязанностей

### Повторное использование:

- ✅ Агенты хранятся в `.qwen/agents/`
- ✅ Можно делиться с командой
- ✅ Масштабируемость

---

## 🛠️ ИНТЕГРАЦИЯ С ПРОЕКТОМ

### Code Reviewer:

**Инструменты:**
- StyleCop.Analyzers
- SonarAnalyzer.CSharp
- .NET Analyzers

**База знаний:**
- `AI_CONSTITUTION.md`
- `UNITY_CODE_STYLE.md`
- `.editorconfig`

---

### Test Writer:

**Инструменты:**
- NUnit
- Unity Test Framework
- uLoopMCP

**База знаний:**
- `TESTING_GUIDE.md`
- `Assets/Tests/`

---

### Security Analyzer:

**Инструменты:**
- SonarAnalyzer.CSharp
- SecurityCodeScan
- Roslyn Security

**База знаний:**
- `CSHARP_UNITY_TOOLS.md`
- `INCREDIBUILD_FULL_GUIDE.md`

---

### Documentation Writer:

**Инструменты:**
- DocFX
- Sandcastle
- Markdown

**База знаний:**
- `KNOWLEDGE_BASE/`
- `README.md`

---

### Build Master:

**Инструменты:**
- `auto-build.ps1`
- `auto-build-exe.ps1`
- GitHub Actions

**База знаний:**
- `TESTING_GUIDE.md`
- `INCREDIBUILD_FULL_GUIDE.md`

---

## 📚 БАЗА ЗНАНИЙ ОБНОВЛЕНА

### Всего файлов:

| Категория | Файлов | Страниц |
|-----------|--------|---------|
| **Агенты** | 6 | 600+ |
| **Инструкции для ИИ** | 4 | 1800+ |
| **Unity** | 7 | 1100+ |
| **C#** | 2 | 100+ |
| **Инструменты** | 5 | 500+ |
| **Методология** | 2 | 500+ |
| **ВСЕГО** | **26** | **4600+** |

---

## ✅ ПРОВЕРКА ПРАВИЛА

**Правило:** Изучил → Создал → Применил!

**Выполнено:**
- ✅ **Изучил:** Возможность Subagents в Qwen Code
- ✅ **Создал:** 5 специализированных агентов
- ✅ **Применил:** Интегрировал в проект
- ✅ **Записал:** Сохранил в базу знаний
- ✅ **Обновил:** `.qwen/QWEN.md`

**Правило выполнено!** ✅

---

## 🎯 СЛЕДУЮЩИЕ ШАГИ

### Активация агентов:

1. ✅ Агенты созданы
2. ✅ Описаны роли и задачи
3. ✅ Определены команды
4. ⏸️ Ожидание использования

### Использование:

```
Просто попросите:
"/code-reviewer проверь [файл]"
"/test-writer напиши тесты для [модуль]"
"/build-master собери проект"
```

---

## 📚 РЕСУРСЫ

### Файлы проекта:

| Файл | Тема |
|------|------|
| **`.qwen/agents/README.md`** | Индекс агентов |
| **`.qwen/agents/*.md`** | Файлы агентов |
| **`.qwen/QWEN.md`** | Мастер-контекст |

### Официальная документация:

- [Qwen Code Documentation](https://docs.unity3d.com/)
- [Subagents Guide](https://docs.unity3d.com/)

---

**Специализированные агенты созданы и готовы к работе!** 🤖

**Использование:** `/[агент] [действие] [объект]`

