# ⚙️ VS CODE НАСТРОЙКА ДЛЯ ИИ-АССИСТЕНТА

**Версия:** 1.0  
**Дата:** 2 марта 2026 г.  
**Статус:** ✅ Готово к применению

---

## 🎯 НАЗНАЧЕНИЕ

Этот документ описывает **оптимальную настройку VS Code** для работы с ИИ-ассистентом (Qwen Code) и Unity/C# разработкой.

---

## 📋 СОДЕРЖАНИЕ

1. [Multi-Root Workspace](#multi-root-workspace)
2. [Расширения для C# / Unity](#расширения-для-c--unity)
3. [Настройки производительности](#настройки-производительности)
4. [AI Интеграция (MCP)](#ai-интеграция-mcp)
5. [Мост для доступа к папкам](#мост-для-доступа-к-папкам)

---

## 1. MULTI-ROOT WORKSPACE

### Проблема:
ИИ-ассистент не имеет доступа к файлам вне текущей workspace папки.

### Решение:
Создать **Multi-Root Workspace** с несколькими корневыми папками.

---

### Шаг 1: Открыть текущую папку

```
File → Open Folder → D:\QwenPoekt\Base
```

---

### Шаг 2: Добавить дополнительные папки

```
File → Add Folder to Workspace → Выбрать папки:
```

**Добавить:**
- `D:\QwenPoekt\Projects\DragRaceUnity` — Unity проект
- `D:\QwenPoekt\Base\KNOWLEDGE_BASE` — База знаний
- `D:\QwenPoekt\Base\scripts` — PowerShell скрипты
- `D:\QwenPoekt\Base\reports` — Отчёты
- `D:\QwenPoekt\Base\_docs` — Документация
- `D:\QwenPoekt\Base\BOOK` — Книги

---

### Шаг 3: Сохранить Workspace

```
File → Save Workspace As... → D:\QwenPoekt\QwenPoekt.code-workspace
```

---

### Шаг 4: Использовать Workspace файл

**Теперь открывайте:**
```
D:\QwenPoekt\QwenPoekt.code-workspace
```

**Результат:**
- ✅ Все папки доступны в одном окне
- ✅ ИИ видит файлы во всех папках
- ✅ Поиск работает по всем папкам
- ✅ Настройки применяются ко всем папкам

---

## 2. РАСШИРЕНИЯ ДЛЯ C# / UNITY

### Обязательные расширения:

| Расширение | ID | Назначение |
|------------|-----|------------|
| **C# Dev Kit** | `ms-dotnettools.csdevkit` | IntelliSense, отладка, тесты |
| **C#** | `ms-dotnettools.csharp` | Базовая поддержка C# |
| **PowerShell** | `ms-vscode.PowerShell` | Скрипты автоматизации |
| **Markdown All in One** | `yzhang.markdown-all-in-one` | Работа с Markdown |
| **Code Spell Checker** | `streetsidesoftware.code-spell-checker` | Проверка орфографии |

---

### Рекомендуемые расширения:

| Расширение | ID | Назначение |
|------------|-----|------------|
| **Unity Code Snippets** | `kainino.unity-snippets` | Сниппеты для Unity |
| **Unity Tools** | `visualstudiotoolsforunity.vstuc` | Интеграция с Unity |
| **GitLens** | `eamodio.gitlens` | Git интеграция |
| **EditorConfig** | `editorconfig.editorconfig` | Единый стиль кода |
| **SonarLint** | `sonarsource.sonarlint-vscode` | Анализ кода |

---

### Установка расширений:

**Способ 1: Через UI**
```
1. Ctrl+Shift+X (Extensions)
2. Ввести название
3. Click "Install"
```

**Способ 2: Через CLI**
```powershell
# C# Dev Kit
code --install-extension ms-dotnettools.csdevkit

# C#
code --install-extension ms-dotnettools.csharp

# PowerShell
code --install-extension ms-vscode.PowerShell

# Markdown All in One
code --install-extension yzhang.markdown-all-in-one

# Code Spell Checker
code --install-extension streetsidesoftware.code-spell-checker
```

---

## 3. НАСТРОЙКИ ПРОИЗВОДИТЕЛЬНОСТИ

### Исключить тяжёлые папки:

**Файл:** `.vscode/settings.json`

```json
{
    "search.exclude": {
        "**/Library/**": true,
        "**/Logs/**": true,
        "**/obj/**": true,
        "**/Build/**": true,
        "**/Temp/**": true,
        "**/*.unity": true,
        "**/*.prefab": true,
        "**/*.meta": true
    },
    
    "files.watcherExclude": {
        "**/Library/**": true,
        "**/Logs/**": true,
        "**/obj/**": true,
        "**/Build/**": true
    },
    
    "cSpell.ignorePaths": [
        "**/*.cs",
        "**/*.csproj",
        "**/*.sln",
        "**/Library/**",
        "**/Logs/**"
    ]
}
```

---

## 4. AI ИНТЕГРАЦИЯ (MCP)

### Model Context Protocol (MCP)

**MCP** — протокол для интеграции AI-моделей в VS Code.

---

### Настройка MCP:

**Файл:** `.qwen/mcp-config.json`

```json
{
    "mcpServers": {
        "qwen-code": {
            "command": "qwen-code",
            "args": ["--workspace", "D:\\QwenPoekt"],
            "env": {
                "QWEN_WORKSPACE_FOLDERS": [
                    "D:\\QwenPoekt\\Base\\KNOWLEDGE_BASE",
                    "D:\\QwenPoekt\\Base\\_docs",
                    "D:\\QwenPoekt\\Base\\reports",
                    "D:\\QwenPoekt\\Base\\scripts"
                ]
            }
        }
    }
}
```

---

### Workspace Context для AI:

**Файл:** `QwenPoekt.code-workspace`

```json
{
    "settings": {
        "qwen.workspaceFolders": [
            "./Base/KNOWLEDGE_BASE",
            "./Base/_docs",
            "./Base/reports",
            "./Base/scripts"
        ]
    }
}
```

---

## 5. МОСТ ДЛЯ ДОСТУПА К ПАПКАМ

### Проблема:
ИИ-ассистент работает только в пределах workspace папки.

### Решение 1: Multi-Root Workspace (✅ Рекомендуется)

**Как работает:**
- Добавляет несколько папок в одну workspace
- ИИ получает доступ ко всем папкам
- Нет ограничений безопасности

**Настройка:** См. [Раздел 1](#1-multi-root-workspace)

---

### Решение 2: Symbolic Links

**Как работает:**
- Создаёт символические ссылки на папки
- ИИ видит ссылки как часть workspace

**Команда:**
```powershell
# Создать ссылку на Projects в Base
cmd /c mklink /D "D:\QwenPoekt\Base\Projects" "D:\QwenPoekt\Projects"

# Создать ссылку на _BACKUP
cmd /c mklink /D "D:\QwenPoekt\Base\_BACKUP" "D:\QwenPoekt\_BACKUP"
```

**⚠️ Предостережение:**
- Символические ссылки могут вызвать проблемы с Git
- Не использовать для больших папок (Library, Logs)

---

### Решение 3: Remote Development (для будущих сценариев)

**Сценарии:**
- **SSH** — подключение к удалённому серверу
- **Dev Containers** — разработка в Docker
- **WSL** — Linux окружение на Windows

**Настройка:**
```
1. Установить расширение "Remote - SSH" / "Dev Containers" / "WSL"
2. F1 → "Remote-SSH: Connect to Host" / "Dev Containers: Reopen in Container"
3. Выбрать хост / контейнер
```

---

### Решение 4: VS Code Server (продвинутый уровень)

**Как работает:**
- Запускает VS Code Server на удалённой машине
- Подключение через браузер или тонкий клиент

**Команда:**
```bash
# На удалённой машине
curl -fsSL https://code.visualstudio.com/remote/install.sh | sh
```

---

## 📊 СРАВНЕНИЕ РЕШЕНИЙ

| Решение | Сложность | Производительность | Безопасность | Рекомендация |
|---------|-----------|-------------------|--------------|--------------|
| **Multi-Root Workspace** | 🟢 Низкая | 🟢 Высокая | 🟢 Полная | ✅ **Основное** |
| **Symbolic Links** | 🟡 Средняя | 🟢 Высокая | 🟡 Средняя | ⚠️ Резервное |
| **Remote Development** | 🔴 Высокая | 🟡 Зависит от сети | 🟢 Полная | 🟡 Для серверов |
| **VS Code Server** | 🔴 Очень высокая | 🟡 Зависит от сети | 🟢 Полная | 🟢 Для команд |

---

## ✅ ЧЕК-ЛИСТ НАСТРОЙКИ

### Базовая настройка:

- [ ] Установить VS Code
- [ ] Установить C# Dev Kit
- [ ] Установить PowerShell расширение
- [ ] Установить Markdown All in One
- [ ] Установить Code Spell Checker

### Workspace настройка:

- [ ] Создать Multi-Root Workspace
- [ ] Добавить папки (Base, Projects, KNOWLEDGE_BASE, scripts, reports, _docs, BOOK)
- [ ] Сохранить `QwenPoekt.code-workspace`
- [ ] Открыть workspace файл

### Настройки:

- [ ] Настроить `search.exclude` для производительности
- [ ] Настроить `cSpell.ignorePaths` для игнорирования кода
- [ ] Включить авто-сохранение
- [ ] Включить форматирование при сохранении

### AI интеграция:

- [ ] Настроить MCP конфигурацию
- [ ] Указать workspace folders для AI
- [ ] Протестировать доступ к файлам

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`QwenPoekt.code-workspace`](./QwenPoekt.code-workspace) — Multi-Root Workspace конфигурация
- [`.vscode/settings.json`](./.vscode/settings.json) — Настройки VS Code
- [`reports/GITHUB_REPOSITORIES_CATALOG.md`](./reports/GITHUB_REPOSITORIES_CATALOG.md) — GitHub репозитории
- [`03-Resources/Knowledge/00_CORE/UNITY_CS_REFERENCE_ANALYSIS.md`](./03-Resources/Knowledge/00_CORE/UNITY_CS_REFERENCE_ANALYSIS.md) — Unity Cs Reference

---

## 📝 СЛЕДУЮЩИЕ ШАГИ

1. **Создать Multi-Root Workspace:**
   ```
   File → Add Folder to Workspace → Сохранить как QwenPoekt.code-workspace
   ```

2. **Установить расширения:**
   ```powershell
   code --install-extension ms-dotnettools.csdevkit
   code --install-extension ms-vscode.PowerShell
   ```

3. **Протестировать доступ:**
   - Открыть файл из Projects
   - Открыть файл из KNOWLEDGE_BASE
   - Запустить поиск по всем папкам

---

**Файл создан:** 2 марта 2026 г.  
**Следующее обновление:** После тестирования настроек

