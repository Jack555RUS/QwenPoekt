# 🌉 MCP FILESYSTEM — НАСТРОЙКА ДОСТУПА

**Версия:** 1.0  
**Дата:** 2 марта 2026 г.  
**Статус:** ⏳ Требуется установка Node.js и MCP сервера

---

## 🎯 НАЗНАЧЕНИЕ

Этот документ описывает **настройку MCP Filesystem сервера** для предоставления ИИ прямого доступа к папкам `D:\QwenPoekt\`.

---

## 📋 ЧТО ТАКОЕ MCP

**MCP (Model Context Protocol)** — протокол для подключения AI-ассистентов к внешним инструментам.

**Filesystem MCP Server** — официальный сервер от Anthropic, который позволяет ИИ:
- ✅ Читать файлы из указанных папок
- ✅ Записывать новые файлы
- ✅ Исследовать структуру директорий
- ✅ Искать файлы по паттернам
- ✅ Перемещать/переименовывать файлы
- ✅ Создавать/удалять папки

---

## 🔧 ТРЕБОВАНИЯ

| Требование | Статус | Проверка |
|------------|--------|----------|
| **Node.js** | ⏳ Требуется | `node --version` |
| **npm** | ⏳ Требуется | `npm --version` |
| **npx** | ⏳ Требуется | `npx --version` |

---

## 📋 ШАГ 1: УСТАНОВКА NODE.JS

### Если не установлен:

1. Перейти на https://nodejs.org/
2. Скачать LTS версию
3. Установить
4. Проверить:
   ```powershell
   node --version
   npm --version
   ```

---

## 📋 ШАГ 2: НАСТРОЙКА MCP СЕРВЕРА

### Вариант 1: Через settings.json (✅ Рекомендуется)

**Файл:** `.qwen/settings.json`

```json
{
    "mcpServers": {
        "filesystem": {
            "command": "npx",
            "args": [
                "-y",
                "@modelcontextprotocol/server-filesystem",
                "D:\\QwenPoekt",
                "D:\\QwenPoekt\\Base",
                "D:\\QwenPoekt\\Projects",
                "D:\\QwenPoekt\\_BACKUP",
                "D:\\QwenPoekt\\_TEST_ENV"
            ],
            "disabled": false,
            "alwaysAllow": [
                "read_file",
                "list_directory",
                "get_file_info",
                "search_files"
            ],
            "readOnly": false
        }
    }
}
```

---

### Вариант 2: Через команду (альтернатива)

```bash
# Для проекта
qwen mcp add --scope project filesystem -- npx -y @modelcontextprotocol/server-filesystem "D:\QwenPoekt"

# Глобально
qwen mcp add --scope global filesystem -- npx -y @modelcontextprotocol/server-filesystem "D:\QwenPoekt" "D:\QwenPoekt\Projects"
```

---

## 📋 ШАГ 3: ПЕРЕЗАПУСК QWEN CODE

После настройки:
1. Закрыть VS Code
2. Открыть заново
3. MCP сервер загрузится автоматически

---

## ✅ ПРОВЕРКА РАБОТЫ

### Тест 1: Прочитать файл

**Запрос ИИ:**
```
Прочитай файл D:\QwenPoekt\Projects\DragRaceUnity\README.md
```

**Ожидаемый результат:**
- ✅ ИИ прочитал файл
- ✅ Показал содержимое

---

### Тест 2: Список папки

**Запрос ИИ:**
```
Покажи содержимое папки D:\QwenPoekt\Projects
```

**Ожидаемый результат:**
- ✅ ИИ показал список файлов
- ✅ Видит подпапки

---

### Тест 3: Поиск файлов

**Запрос ИИ:**
```
Найди все .cs файлы в D:\QwenPoekt\Projects\DragRaceUnity\Assets\Scripts
```

**Ожидаемый результат:**
- ✅ ИИ нашёл файлы
- ✅ Показал полный путь

---

## 🔧 КОМАНДЫ MCP FILESYSTEM

| Команда | Описание | Пример |
|---------|----------|--------|
| `read_file(path)` | Чтение файла | `read_file("D:/QwenPoekt/README.md")` |
| `write_file(path, content)` | Запись файла | `write_file("D:/QwenPoekt/test.txt", "Hello")` |
| `list_directory(path)` | Список папки | `list_directory("D:/QwenPoekt")` |
| `create_directory(path)` | Создание папки | `create_directory("D:/QwenPoekt/new")` |
| `move_file(src, dst)` | Перемещение | `move_file("D:/a.txt", "D:/b.txt")` |
| `search_files(pattern, path?)` | Поиск | `search_files("**/*.cs", "D:/QwenPoekt")` |
| `get_file_info(path)` | Метаданные | `get_file_info("D:/QwenPoekt/README.md")` |

---

## 🔒 БЕЗОПАСНОСТЬ

### Разрешённые пути:

```json
[
    "D:\\QwenPoekt",
    "D:\\QwenPoekt\\Base",
    "D:\\QwenPoekt\\Projects",
    "D:\\QwenPoekt\\_BACKUP",
    "D:\\QwenPoekt\\_TEST_ENV"
]
```

### Запрещённые пути (по умолчанию):

```
C:\Windows\
C:\Program Files\
C:\Users\[user]\Documents\
D:\(любые другие папки)
```

---

## ⚙️ НАСТРОЙКИ

### readOnly режим

**Только чтение (без записи):**
```json
{
    "mcpServers": {
        "filesystem": {
            "readOnly": true
        }
    }
}
```

### alwaysAllow (команды без подтверждения):

```json
{
    "alwaysAllow": [
        "read_file",
        "list_directory",
        "get_file_info",
        "search_files"
    ]
}
```

### disabled (отключить сервер):

```json
{
    "mcpServers": {
        "filesystem": {
            "disabled": true
        }
    }
}
```

---

## ❓ ЧАСТЫЕ ВОПРОСЫ

### Q: Как обновить MCP сервер?

**A:** 
```bash
npm update -g @modelcontextprotocol/server-filesystem
```

---

### Q: Как отключить MCP сервер?

**A:** Удалить `.qwen/settings.json` или установить `"disabled": true`

---

### Q: Можно ли добавить больше папок?

**A:** Да, добавить пути в массив `args`:
```json
"args": [
    "-y",
    "@modelcontextprotocol/server-filesystem",
    "D:\\QwenPoekt",
    "D:\\NewFolder"  ← Добавить сюда
]
```

---

### Q: Безопасно ли это?

**A:** Да, ИИ имеет доступ только к указанным папкам. Системные файлы недоступны.

---

## 🚀 БЫСТРЫЙ СТАРТ

### 1. Проверить Node.js:
```powershell
node --version
```

### 2. Создать `.qwen/settings.json`:
```json
{
    "mcpServers": {
        "filesystem": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-filesystem", "D:\\QwenPoekt"]
        }
    }
}
```

### 3. Перезапустить VS Code

### 4. Тестировать:
```
"Прочитай D:\QwenPoekt\README.md"
```

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`.qwen/settings.json`](./.qwen/settings.json) — Конфигурация MCP
- [`_docs/BRIDGE_SETUP.md`](./BRIDGE_SETUP.md) — Мост через Junction
- [`_docs/VS_CODE_SETUP_FOR_AI.md`](./VS_CODE_SETUP_FOR_AI.md) — Настройка VS Code

---

## 📝 СЛЕДУЮЩИЕ ШАГИ

1. **Установить Node.js** (если не установлен)
2. **Создать `.qwen/settings.json`** (готов выше)
3. **Перезапустить VS Code**
4. **Протестировать доступ**

---

**Файл создан:** 2 марта 2026 г.  
**Следующее обновление:** После тестирования MCP
