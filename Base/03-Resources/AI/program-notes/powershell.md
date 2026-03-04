# POWERSHELL — ЗАМЕТКИ

**Версия:** 5.1+ (Windows PowerShell), 7.x (PowerShell Core)
**Дата:** 2026-03-04
**Источник:** docs.microsoft.com/powershell

---

## 🔧 ОСОБЕННОСТИ

### Синтаксис
- Команды: `Get-ChildItem`, `Select-Object`, `Where-Object`
- Параметры: `-Name`, `-Value` (именованные)
- Переменные: `$variable` (префикс $)
- Функции: `function Name { param() ... }`

### Конвенции
- Именование: PascalCase (Get-ChildItem, Write-Host)
- Структура файлов: `.ps1` для скриптов, `.psm1` для модулей
- Стиль кода: [PSRule](https://aka.ms/PSRule)

### Ограничения
- **Out-File -NoBOM** — не работает в PowerShell 5.1
- **UTF8 без BOM** — использовать `[System.IO.File]::WriteAllText()`
- **ExecutionPolicy** — по умолчанию Restricted (скрипты заблокированы)

---

## 📚 ИСТОЧНИКИ

### Официальные
1. [docs.microsoft.com/powershell](https://docs.microsoft.com/powershell) — Документация
2. [GitHub PowerShell](https://github.com/PowerShell/PowerShell) — Исходники
3. [PowerShell Gallery](https://www.powershellgallery.com) — Модули

### Сообщество
1. [Stack Overflow: PowerShell](https://stackoverflow.com/questions/tagged/powershell)
2. [Reddit: r/PowerShell](https://www.reddit.com/r/PowerShell/)
3. [PowerShell Discord](https://discord.gg/powershell)

---

## 💡 ЛУЧШИЕ ПРАКТИКИ

### Практика 1: UTF8 без BOM
**Когда использовать:** Запись файлов для Git, веб-серверов

**Пример:**
```powershell
# ❌ ПЛОХО: Out-File -NoBOM не работает в PS 5.1
$content | Out-File -FilePath "file.txt" -Encoding UTF8 -NoBOM

# ✅ ХОРОШО: WriteAllText работает везде
[System.IO.File]::WriteAllText("file.txt", $content, [System.Text.UTF8Encoding]::new($false))
```

### Практика 2: Проверка External Links
**Когда использовать:** Проверка ссылок в Markdown, JSON, YAML

**Пример:**
```powershell
# Проверка только Markdown
.\scripts\check-external-links.ps1 -Path "." -Recursive

# Проверка Markdown + JSON
.\scripts\check-external-links.ps1 -Path "." -Recursive -IncludeJson

# Проверка всех файлов
.\scripts\check-external-links.ps1 -Path "." -Recursive -IncludeAll
```

### Практика 3: Обработка ошибок
**Когда использовать:** Скрипты с внешними запросами

**Пример:**
```powershell
$ErrorActionPreference = "Continue"  # Не прерывать при ошибке

try {
    $response = $request.GetResponse()
}
catch [System.Net.WebException] {
    # Обработка HTTP ошибок
    $httpCode = [int]$_.Exception.Response.StatusCode
}
```

---

## ⚠️ ПОДВОДНЫЕ КАМНИ

### Проблема 1: Out-File -NoBOM не работает
**Описание:** Параметр `-NoBOM` недоступен в PowerShell 5.1

**Как избежать:** Использовать `[System.IO.File]::WriteAllText()`

**Решение:**
```powershell
[System.IO.File]::WriteAllText($path, $content, [System.Text.UTF8Encoding]::new($false))
```

### Проблема 2: ExecutionPolicy блокирует скрипты
**Описание:** По умолчанию Restricted (скрипты не выполняются)

**Как избежать:** Установить RemoteSigned
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Проблема 3: HEAD запросы блокируются (403)
**Описание:** Некоторые серверы (npmjs.com) блокируют HEAD метод

**Как избежать:** Использовать GET с User-Agent
```powershell
$request.Method = "GET"
$request.UserAgent = "Mozilla/5.0..."
```

---

## 📝 ПРИМЕРЫ КОДА

### Пример 1: Проверка URL
```powershell
$request = [System.Net.WebRequest]::Create("https://example.com")
$request.Timeout = 10000
$request.Method = "HEAD"
$response = $request.GetResponse()
$statusCode = [int]$response.StatusCode
$response.Close()
```

### Пример 2: Запись UTF8 без BOM
```powershell
$content = "Текст с русскими символами"
[System.IO.File]::WriteAllText("file.txt", $content, [System.Text.UTF8Encoding]::new($false))
```

### Пример 3: Множественные шаблоны файлов
```powershell
$Patterns = @("*.md", "*.json", "*.yaml")
$files = @()
foreach ($pattern in $Patterns) {
    $files += Get-ChildItem -Path "." -Include $pattern -Recurse
}
```

---

## 🔄 ИСТОРИЯ ОБНОВЛЕНИЙ

| Дата | Версия | Изменения |
|------|--------|-----------|
| 2026-03-04 | 1.0 | Создание заметки (check-external-links.ps1) |

---

## 🔧 НАСТРОЙКИ (критичные)

| Настройка | Значение | Файл |
|-----------|----------|------|
| **ExecutionPolicy** | `RemoteSigned` | Реестр / `$PROFILE` |
| **Default Encoding** | `UTF8 без BOM` | Скрипты |
| **ErrorAction** | `Continue` (для внешних запросов) | Скрипты |

---

**Создано:** 2026-03-04
**Обновлено:** 2026-03-04
**Следующий пересмотр:** 2026-03-11
