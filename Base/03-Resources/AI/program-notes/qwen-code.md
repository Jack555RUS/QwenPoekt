# QWEN CODE — ЗАМЕТКИ

**Версия:** SDK 1.x (MCP Protocol)
**Дата:** 2026-03-04
**Источник:** docs.qwen.ai, mcp-session-saver.js

---

## 🔧 ОСОБЕННОСТИ

### Синтаксис
- MCP сервер: `mcp-session-saver.js` (280 строк)
- Конфигурация: `.qwen/session-rules.json`, `mcp.json`
- Сессии: `sessions/YYYY-MM-DD_HH-mm/chat.md`

### Конвенции
- Именование: kebab-case для файлов (`mcp-session-saver.js`)
- Структура: `.qwen/` для конфигов, `sessions/` для истории
- Стиль: ES6+ (import/export, async/await)

### Ограничения
- **Контекст:** 128K-200K токенов (лимит)
- **Восстановление:** Ручное (resume-session.ps1)
- **Автосохранение:** Каждые 2 минуты (Task Scheduler)

---

## 📚 ИСТОЧНИКИ

### Официальные
1. [docs.qwen.ai](https://docs.qwen.ai) — Документация Qwen Code
2. [GitHub Qwen Code](https://github.com/qwen-code/qwen-code) — Исходники
3. [MCP Protocol](https://modelcontextprotocol.io) — Model Context Protocol

### Сообщество
1. [Stack Overflow: Qwen Code](https://stackoverflow.com/questions/tagged/qwen-code)
2. [Reddit: r/QwenCode](https://www.reddit.com/r/QwenCode/)
3. [Discord: Qwen Code](https://discord.gg/qwen-code)

---

## 💡 ЛУЧШИЕ ПРАКТИКИ

### Практика 1: Сохранение контекста

**Когда использовать:** Перед завершением сессии, переключением темы

**Пример:**
```javascript
// MCP Server: save_session
await save_session({
  chat: "# Диалог...",
  sessionId: "2026-03-04_18-00",
  task: "Управление контекстом",
  metadata: {
    contextSummary: "Обсуждали Query Refinement...",
    tokenCount: 15000
  }
});
```

---

### Практика 2: Query Refinement

**Когда использовать:** При восстановлении сессии, неясных запросах

**Пример:**
```javascript
// Query Refinement функция
function refineQuery(userQuery, context, history) {
  // Запрос + Контекст + История → Уточнённый запрос
  const lastMessages = history.slice(-3);
  const refinedPrompt = `
    Контекст: ${context}
    История: ${lastMessages.join('\n')}
    Запрос: ${userQuery}
    
    Уточни запрос с учётом контекста и истории.
    Разреши местоимения ("это", "там", "он").
  `;
  return refinedPrompt;
}
```

**Формула:**
```
Уточнённый запрос = Запрос + Контекст + История (последние 3 сообщения)
```

---

### Практика 3: Summarization (суммаризация)

**Когда использовать:** >50% контекста заполнено, >1000 токенов на сообщение

**Пример:**
```javascript
// Summarization функция
async function summarizeContext(chatHistory, threshold = 0.5) {
  const tokenCount = countTokens(chatHistory);
  const maxTokens = 128000; // Лимит
  
  if (tokenCount > maxTokens * threshold) {
    // Суммаризировать историю
    const summary = await llm.summarize(chatHistory, {
      maxLength: 3, // 3 предложения
      preserveFacts: true // Сохранить ключевые факты
    });
    
    return {
      summary: summary,
      originalTokens: tokenCount,
      savedTokens: tokenCount - countTokens(summary)
    };
  }
  
  return null; // Суммаризация не нужна
}
```

**Пороги:**
- >50% контекста → Суммаризировать
- >1000 токенов на сообщение → Удалить/сжать
- >10 сообщений без темы → Перегруппировать

---

### Практика 4: Switch Notification (уведомление о смене темы)

**Когда использовать:** Пользователь резко меняет тему

**Пример:**
```javascript
// Уведомление о смене темы
function notifyTopicSwitch(newTopic, previousTopic, context) {
  return `
💡 Переключаемся на тему: ${newTopic}

Предыдущая тема: ${previousTopic} (сохранено в контексте)
Новая тема: ${context.description}
Связанные файлы: ${context.files.join(', ')}
  `;
}
```

**Формат:**
```markdown
💡 Переключаемся на тему: [Название]

Предыдущая тема: [Сохранено в контексте]
Новая тема: [Описание]
Связанные файлы: [Список]
```

---

## ⚠️ ПОДВОДНЫЕ КАМНИ

### Проблема 1: Переполнение контекста

**Описание:** >75% токенов использовано → качество ответов падает

**Как избежать:**
- Суммаризировать при >50%
- Удалять старые сообщения (>1000 токенов назад)
- Выделять ключевые факты (сохранение)

**Решение:**
```javascript
const summary = await summarizeContext(chatHistory, 0.5);
if (summary) {
  console.log(`Сэкономлено токенов: ${summary.savedTokens}`);
}
```

---

### Проблема 2: Непонимание запросов с местоимениями

**Описание:** "А сколько там?" — непонятно, где "там"

**Как избежать:**
- Query Refinement перед обработкой
- Передача контекста + истории
- Разрешение местоимений

**Решение:**
```javascript
const refinedQuery = refineQuery(userQuery, context, history);
// "А сколько там?" → "А сколько студентов в Томском университете?"
```

---

### Проблема 3: Потеря контекста между сессиями

**Описание:** Qwen Code не поддерживает автоматическое восстановление

**Как избежать:**
- `.resume_marker.json` перед завершением
- `resume-session.ps1` для восстановления
- Копирование в буфер + вставка в чат

**Решение:**
```powershell
# PowerShell: Восстановление контекста
.\resume-session.ps1
# Копирует в буфер → Вставить в чат Qwen Code
```

---

## 📝 ПРИМЕРЫ КОДА

### Пример 1: Сохранение сессии (MCP)

```javascript
// mcp-session-saver.js
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';

const server = new McpServer({
  name: 'session-saver',
  version: '1.0.0'
});

server.tool('save_session', async ({ chat, sessionId, metadata }) => {
  // Сохранение сессии
  const path = `sessions/${sessionId}/chat.md`;
  await fs.writeFile(path, chat);
  return { success: true, path };
});
```

---

### Пример 2: Восстановление контекста (PowerShell)

```powershell
# resume-session.ps1
$marker = Get-Content .resume_marker.json | ConvertFrom-Json

Write-Host "📊 Информация о сессии:"
Write-Host "  Дата: $($marker.Date)"
Write-Host "  Задача: $($marker.CurrentTask)"
Write-Host "  След. шаг: $($marker.NextStep)"

# Копирование в буфер
$marker | ConvertTo-Json | Set-Clipboard
Write-Host "✅ Контекст скопирован в буфер!"
```

---

### Пример 3: Подсчёт токенов

```javascript
// Подсчёт токенов (tiktoken)
import { encoding_for_model } from 'tiktoken';

function countTokens(text, model = 'qwen-3.5-plus') {
  const encoder = encoding_for_model(model);
  const tokens = encoder.encode(text);
  encoder.free();
  return tokens.length;
}

// Использование
const tokenCount = countTokens(chatHistory);
console.log(`Токенов: ${tokenCount} / 128000`);
```

---

## 🔄 ИСТОРИЯ ОБНОВЛЕНИЙ

| Дата | Версия | Изменения |
|------|--------|-----------|
| 2026-03-04 | 1.0 | Создание заметки (Context Management) |

---

## 🔧 НАСТРОЙКИ (критичные)

| Настройка | Значение | Файл |
|-----------|----------|------|
| **maxContextTokens** | `128000` | `.qwen/session-rules.json` |
| **summarizeThreshold** | `0.5` (50%) | `.qwen/session-rules.json` |
| **autoSaveInterval** | `2` минуты | Task Scheduler |
| **encoding** | `UTF-8 без BOM` | Все файлы |

---

## 📊 API МЕТОДЫ (Qwen Code MCP)

| Метод | Параметры | Возвращает | Назначение |
|-------|-----------|------------|------------|
| **save_session** | `chat`, `sessionId`, `metadata` | `{success, path}` | Сохранение сессии |
| **load_session** | `sessionId` | `{chat, metadata}` | Загрузка сессии |
| **list_sessions** | `limit` (опционально) | `[{sessionId, date}]` | Список сессий |
| **update_resume_marker** | `sessionId`, `currentTask`, `nextStep` | `{success}` | Обновление маркера |
| **summarize_context** | `chatHistory`, `threshold` | `{summary, savedTokens}` | Суммаризация |
| **refine_query** | `query`, `context`, `history` | `refinedQuery` | Переформулирование |

---

**Создано:** 2026-03-04
**Обновлено:** 2026-03-04
**Следующий пересмотр:** 2026-03-11
