# 📋 ОТЛОЖЕННЫЕ ЗАДАЧИ — БЭКАП

**Дата создания:** 2 марта 2026 г.
**Статус:** ⏳ Отложено (после реализации автосохранения)

---

## 🔴 ЗАДАЧА: Полная копия Base (автоматически)

**Описание:**
Автосохранение полной копии `Base/` в `_BACKUP/` каждые N минут.

**Проблема:**
- Текущее автосохранение сохраняет только переписку ИИ
- При полном крахе системы переписки недостаточно
- Нужна полная копия всех файлов Base

**Решение (план):**

### Вариант 1: PowerShell (Hidden Window)
```powershell
# auto-full-backup.ps1
$BasePath = "D:\QwenPoekt\Base"
$BackupPath = "D:\QwenPoekt\_BACKUP\Auto_Full\Base_$(Get-Date -Format 'yyyy-MM-dd_HH-mm')"

# Полная копия (исключая временные папки)
robocopy $BasePath $BackupPath /MIR /XF *.tmp /XD _TEMP sessions _LOCAL_ARCHIVE /NFL /NDL /NJH /NJS

# Сжатие старой копии (экономия места)
$oldBackups = Get-ChildItem "D:\QwenPoekt\_BACKUP\Auto_Full\" -Directory | Where-Object { $_.LastWriteTime -lt (Get-Date).AddHours(-1) }
foreach ($backup in $oldBackups) {
    Compress-Archive -Path $backup.FullName -DestinationPath "$($backup.FullName).zip" -Force
    Remove-Item -Path $backup.FullName -Recurse -Force
}
```

**Интервал:**
- ⏳ **Обсуждается** (2 мин? 5 мин? 10 мин?)
- Слишком часто = нагрузка на диск
- Слишком редко = риск потери

**Где запускать:**
- PowerShell Hidden Window
- Или MCP Filesystem напрямую

**Зависимости:**
- ✅ Реализовать автосохранение переписки (текущая задача)
- ⏳ Определить оптимальный интервал
- ⏳ Протестировать нагрузку на диск

---

## 🟡 ЗАДАЧА: Интеграция автосохранения в MCP (напрямую)

**Описание:**
Вместо PowerShell скриптов — прямая запись через MCP Filesystem API.

**Проблема текущего решения:**
- PowerShell скрипты = дополнительный процесс
- VBScript = "костыль" для скрытия окон
- Task Scheduler = внешняя зависимость

**Решение (план):**

### Вариант 2: MCP Filesystem (напрямую)

**Архитектура:**
```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│  ИИ (Qwen)  │ ──→  │  MCP Server  │ ──→  │  Файловая   │
│  (Node.js)  │      │  (Filesystem)│      │  система    │
└─────────────┘      └──────────────┘      └─────────────┘
       │
       │  setInterval (2 мин)
       ▼
┌─────────────┐
│  Запись в   │
│  sessions/  │
└─────────────┘
```

**Преимущества:**
- ✅ **Нет PowerShell** (один процесс вместо двух)
- ✅ **Быстрее** (нет накладных расходов)
- ✅ **Чище код** (Node.js вместо PowerShell)
- ✅ **Полная невидимость** (никаких окон вообще)
- ✅ **Прямой доступ** к файловой системе через MCP

**Недостатки:**
- ⚠️ **Нужно переписать** `auto-save-chat.ps1` на Node.js
- ⚠️ **MCP не имеет таймера** (нужен внешний триггер или setInterval в ИИ)
- ⚠️ **Требует изменений** в MCP сервере (если нет API для периодических задач)

**Реализация (план):**

#### 1. Создать MCP команду для автосохранения:
```javascript
// В MCP сервере (Node.js)
async function autoSaveSession(chatHistory, metadata) {
    const timestamp = new Date().toISOString();
    const sessionId = timestamp.split('T')[0] + '_' + timestamp.split('T')[1].split(':')[0] + '-' + timestamp.split(':')[1];
    
    const sessionPath = `sessions/${sessionId}/`;
    
    // Запись переписки
    await writeFile(`${sessionPath}chat.jsonl`, JSON.stringify(chatHistory));
    await writeFile(`${sessionPath}metadata.json`, JSON.stringify(metadata));
    
    return { success: true, path: sessionPath };
}

// Таймер (каждые 2 минуты)
setInterval(() => {
    autoSaveSession(globalChatHistory, globalMetadata);
}, 120000);
```

#### 2. Интеграция с ИИ:
```javascript
// В коде ИИ (Qwen Code)
// При старте сессии
let autoSaveInterval = setInterval(() => {
    mcp.call('autoSaveSession', {
        chat: currentChat,
        task: currentTask
    });
}, 120000);
```

#### 3. Тестирование:
- ✅ Проверка записи файлов
- ✅ Проверка интервала (2 мин)
- ✅ Проверка после перезапуска

**Зависимости:**
- ✅ Автосохранение переписки (VBScript) — работает
- ⏳ Доступ к MCP серверу (исходный код)
- ⏳ Тестирование производительности

**Сравнение с текущим решением:**

| Критерий | VBScript (сейчас) | MCP (потом) |
|----------|-------------------|-------------|
| **Окна** | ✅ Нет | ✅ Нет |
| **Скорость** | 🟡 Средняя | ✅ Быстрее |
| **Простота** | ✅ Просто | ⚠️ Сложнее |
| **Надёжность** | ✅ Надёжно | ✅ Надёжно |
| **Зависимости** | Task Scheduler | MCP Server |

**Когда внедрять:**
- ⏳ После завершения текущей задачи (автосохранение работает)
- ⏳ При наличии доступа к MCP серверу
- ⏳ Для оптимизации (не критично)

---

## 📊 ПРИОРИТЕТЫ

| Задача | Приоритет | Статус |
|--------|-----------|--------|
| Автосохранение переписки (2 мин) | 🔴 Высокий | ✅ **Готово (VBScript)** |
| Бэкап перед изменением файлов | 🟡 Средний | ✅ Готово |
| Анализ сбоя сессии | 🟡 Средний | ✅ Готово |
| **Полная копия Base (автоматически)** | 🟢 Низкий | ✅ **Готово (robocopy, 10 мин)** |
| **Интеграция в MCP (напрямую)** | 🔵 **Желание** | ⏳ **Отложено (перспектива)** |

---

**Следующий шаг:** Наслаждаться полной защитой (переписка + Base).
