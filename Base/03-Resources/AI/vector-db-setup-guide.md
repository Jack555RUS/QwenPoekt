# 📖 VECTOR DB + RAG — ИНСТРУКЦИЯ ПО НАСТРОЙКЕ

**Версия:** 1.0  
**Дата:** 4 марта 2026 г.  
**Статус:** ⏳ В разработке

---

## 🎯 НАЗНАЧЕНИЕ

Эта инструкция описывает **настройку Vector Database и RAG (Retrieval-Augmented Generation)** для проекта.

---

## 📋 ТРЕБОВАНИЯ

### ПО:

| Компонент | Версия | Проверка |
|-----------|--------|----------|
| **Python** | 3.9+ | `python --version` |
| **pip** | 21.0+ | `pip --version` |
| **Node.js** | 18+ | `node --version` (для MCP) |

### Железо:

| Компонент | Минимум | Рекомендуется |
|-----------|---------|---------------|
| **RAM** | 4 GB | 8 GB |
| **Диск** | 1 GB | 2 GB |
| **CPU** | 2 ядра | 4+ ядра |

---

## 🚀 УСТАНОВКА

### Шаг 1: Виртуальное окружение

```powershell
# Перейти в папку проекта
cd D:\QwenPoekt\Base

# Создать виртуальное окружение
python -m venv .venv

# Активировать
.\.venv\Scripts\Activate.ps1

# Проверка
python --version
# Должно показать: Python 3.x.x
```

---

### Шаг 2: Установка зависимостей

```powershell
# Установить зависимости
pip install -r 03-Resources/AI/requirements-vector-db.txt

# Проверка
pip list | Select-String "chroma|sentence"
```

**Ожидаемый вывод:**
```
chromadb           0.4.22
sentence-transformers 2.3.1
```

---

### Шаг 3: Тестовая векторизация

```python
# test-vector.py
from sentence_transformers import SentenceTransformer

# Загрузка модели
model = SentenceTransformer('all-MiniLM-L6-v2')

# Векторизация текста
text = "Привет! Это тестовая векторизация."
embedding = model.encode(text)

print(f"Размер вектора: {len(embedding)}")
print(f"Первые 5 значений: {embedding[:5]}")
```

**Запуск:**
```powershell
python test-vector.py
```

**Ожидаемый результат:**
```
Размер вектора: 384
Первые 5 значений: [0.123 -0.456 0.789 ...]
```

---

## 🏗️ АРХИТЕКТУРА

### Chroma DB

```
┌─────────────────────────────────────────────────────────┐
│  ДОКУМЕНТЫ (.md файлы)                                  │
│  D:\QwenPoekt\Base\                                     │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  vectorize-kb.py (векторизация)                         │
│  • Чтение файлов                                        │
│  • Разбиение на чанки                                   │
│  • Векторизация (SentenceTransformer)                   │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│  CHROMA DB (chroma/)                                    │
│  • collection: knowledge_base                           │
│  • metadata: путь, дата, теги                           │
│  • embeddings: 384 измерения                            │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 СТРУКТУРА ПАПОК

```
D:\QwenPoekt\Base/
├── .venv/                      # Виртуальное окружение
├── chroma/                     # Chroma DB (создаётся)
│   └── knowledge_base/
├── 03-Resources/AI/
│   ├── requirements-vector-db.txt
│   ├── vectorize-kb.py         # Скрипт векторизации
│   └── rag-search.py           # RAG поиск
├── scripts/
│   └── mcp-rag-search.js       # MCP инструмент
└── reports/
    └── RAG_TEST_REPORT.md      # Отчёт тестов
```

---

## 🔧 СКРИПТЫ

### 1. vectorize-kb.py — Векторизация БЗ

**Назначение:** Обработка всех .md файлов и сохранение в Chroma

**Использование:**
```powershell
python 03-Resources/AI/vectorize-kb.py
```

**Параметры:**
- `--path` — папка для обработки (по умолчанию: Base/)
- `--chunk-size` — размер чанка (по умолчанию: 500)
- `--overlap` — перекрытие чанков (по умолчанию: 50)

---

### 2. rag-search.py — RAG Поиск

**Назначение:** Поиск по векторной БЗ

**Использование:**
```powershell
python 03-Resources/AI/rag-search.py "Как настроить автосохранение?"
```

**Вывод:**
```json
{
  "query": "Как настроить автосохранение?",
  "results": [
    {
      "text": "Автосохранение настраивается через...",
      "path": "reports/SESSION_SAVE_GUIDE.md",
      "score": 0.92
    }
  ]
}
```

---

### 3. mcp-rag-search.js — MCP Инструмент

**Назначение:** Интеграция RAG с MCP сервером

**Использование:**
```javascript
// В чате Qwen Code
/rag_search "Как настроить автосохранение?"
```

---

## 🧪 ТЕСТИРОВАНИЕ

### Тест 1: Векторизация

```powershell
# Запустить векторизацию
python 03-Resources/AI/vectorize-kb.py

# Проверить Chroma DB
Test-Path chroma/knowledge_base
# Должно вернуть: True
```

**Ожидаемый результат:**
- ✅ Обработано ~155 файлов
- ✅ Создано ~500-1000 чанков
- ✅ Chroma DB инициализирована

---

### Тест 2: Поиск

```powershell
# Поиск по ключевым словам
python 03-Resources/AI/rag-search.py "автосохранение"

# Поиск по смыслу
python 03-Resources/AI/rag-search.py "как сохранить сессию"
```

**Ожидаемый результат:**
- ✅ Найдено 5-10 результатов
- ✅ Score >0.7 для релевантных
- ✅ Время поиска <1 сек

---

### Тест 3: RAG Ответ

```powershell
# RAG с генерацией ответа
python 03-Resources/AI/rag-search.py "автосохранение" --generate
```

**Ожидаемый результат:**
- ✅ Контекст найден
- ✅ Ответ сгенерирован
- ✅ Источники указаны

---

## ⚠️ ПРОБЛЕМЫ И РЕШЕНИЯ

### Проблема 1: Python не найден

**Ошибка:**
```
'python' is not recognized...
```

**Решение:**
```powershell
# Установить Python с https://python.org
# При установке отметить "Add Python to PATH"
```

---

### Проблема 2: Ошибка установки torch

**Ошибка:**
```
Could not find a version that satisfies the requirement torch
```

**Решение:**
```powershell
# Установить CPU версию (быстрее)
pip install torch --index-url https://download.pytorch.org/whl/cpu

# Или GPU версию (медленнее загрузка, но быстрее работа)
pip install torch --index-url https://download.pytorch.org/whl/cu118
```

---

### Проблема 3: Chroma DB не создаётся

**Ошибка:**
```
Connection refused
```

**Решение:**
```powershell
# Удалить старую Chroma DB
Remove-Item chroma/ -Recurse -Force

# Запустить векторизацию заново
python 03-Resources/AI/vectorize-kb.py
```

---

## 📊 МОНИТОРИНГ

### Статус Vector DB:

```powershell
# Размер Chroma DB
Get-ChildItem chroma/ -Recurse | Measure-Object -Property Length -Sum

# Количество документов
python -c "import chromadb; db = chromadb.Client(); print(db.get_collection('knowledge_base').count())"
```

---

## 🔗 ИНТЕГРАЦИЯ С ИИ

### Автоматическое использование:

**В начале сессии:**
```
ИИ автоматически:
1. Проверяет наличие Chroma DB
2. Если нет → запускает векторизацию
3. При вопросах → использует RAG
```

**Команда в чате:**
```
/rag_search [вопрос]
```

---

## 📖 СЛЕДУЮЩИЕ ШАГИ

1. ✅ Настройка (Этап 1)
2. ⏳ Векторизация (Этап 2)
3. ⏳ RAG Pipeline (Этап 3)
4. ⏳ Интеграция с ИИ (Этап 4)
5. ⏳ Тесты (Этап 5)

---

**Создано:** 4 марта 2026 г.  
**Статус:** ⏳ В разработке  
**Следующий шаг:** Запуск vectorize-kb.py

---

**Готово к установке!** 🚀
