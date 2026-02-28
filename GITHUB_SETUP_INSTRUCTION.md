# 🚀 GITHUB SETUP INSTRUCTION

**Дата:** 28 февраля 2026 г.  
**Статус:** ✅ Готово к подключению

---

## 📊 ТЕКУЩЕЕ СОСТОЯНИЕ

**Git репозиторий:** ✅ Инициализирован  
**Ветка:** `master`  
**Коммитов:** 2  
**Последний коммит:** `0da096849`

**Файлов в репозитории:**
- ✅ KNOWLEDGE_BASE/ (320 файлов)
- ✅ PROJECTS/DragRaceUnity/
- ✅ scripts/ (12 файлов)
- ✅ BOOK/ (PDF книги)
- ✅ _templates/ (5 файлов)

---

## 🔗 ПОДКЛЮЧЕНИЕ К GITHUB

### Вариант 1: Через GitHub CLI (Рекомендуется)

#### Шаг 1: Установить GitHub CLI

```powershell
winget install GitHub.cli
```

---

#### Шаг 2: Авторизация

```powershell
gh auth login
```

**Процесс:**
1. Выбрать **GitHub.com**
2. Выбрать **HTTPS**
3. Выбрать **Login with a web browser**
4. Открыть ссылку в браузере
5. Ввести код с экрана
6. Подтвердить авторизацию

---

#### Шаг 3: Создать репозиторий

```powershell
gh repo create QwenPoekt --public --source=. --remote=origin --push
```

**Опции:**
- `--public` — публичный репозиторий
- `--private` — приватный (если нужно)

---

### Вариант 2: Вручную через сайт

#### Шаг 1: Создать репозиторий на GitHub

1. Открыть https://github.com/new
2. **Repository name:** `QwenPoekt`
3. **Description:** "Knowledge Base & DragRaceUnity Project"
4. **Visibility:** Public или Private
5. **НЕ** нажимать "Initialize with README"
6. Нажать **Create repository**

---

#### Шаг 2: Добавить remote

```powershell
& 'C:\Program Files\Git\bin\git.exe' remote add origin https://github.com/Jackal/QwenPoekt.git
```

**Или через SSH (если настроен):**
```powershell
& 'C:\Program Files\Git\bin\git.exe' remote add origin git@github.com:Jackal/QwenPoekt.git
```

---

#### Шаг 3: Загрузить коммиты

```powershell
& 'C:\Program Files\Git\bin\git.exe' branch -M main
& 'C:\Program Files\Git\bin\git.exe' push -u origin main
```

---

## 🔐 НАСТРОЙКА SSH (Опционально)

### Шаг 1: Создать SSH ключ

```powershell
ssh-keygen -t ed25519 -C "jackal@local.dev"
```

**Нажать Enter** для сохранения по умолчанию.

---

### Шаг 2: Скопировать ключ

```powershell
Get-Content ~/.ssh/id_ed25519.pub | Set-Clipboard
```

---

### Шаг 3: Добавить ключ на GitHub

1. Открыть https://github.com/settings/keys
2. Нажать **New SSH key**
3. **Title:** "My PC"
4. **Key:** Вставить из буфера (Ctrl+V)
5. Нажать **Add SSH key**

---

### Шаг 4: Проверить соединение

```powershell
ssh -T git@github.com
```

**Ожидаемый ответ:**
```
Hi Jackal! You've successfully authenticated, but GitHub does not provide shell access.
```

---

## 📊 ПРОВЕРКА ПОСЛЕ ПОДКЛЮЧЕНИЯ

### Проверка remote

```powershell
& 'C:\Program Files\Git\bin\git.exe' remote -v
```

**Ожидаемый ответ:**
```
origin  https://github.com/Jackal/QwenPoekt.git (fetch)
origin  https://github.com/Jackal/QwenPoekt.git (push)
```

---

### Проверка push

```powershell
& 'C:\Program Files\Git\bin\git.exe' push origin master
```

---

## 🔄 АВТОМАТИЗАЦИЯ

### Скрипт для авто-коммита и push

**Файл:** `scripts/auto-commit-and-push.ps1`

```powershell
param(
    [string]$message = "Auto-commit: Knowledge Base update"
)

# Коммит
.\scripts\auto-commit-knowledge.ps1 -message $message

# Push
& 'C:\Program Files\Git\bin\git.exe' push origin master

Write-Host "✅ Коммит и загрузка завершены!" -ForegroundColor Green
```

---

## 📋 ЧЕК-ЛИСТ

- [x] ✅ Git установлен
- [x] ✅ Репозиторий инициализирован
- [x] ✅ Конфигурация настроена
- [x] ✅ Коммиты сделаны (2 коммита)
- [ ] ⏳ GitHub репозиторий создан
- [ ] ⏳ Remote добавлен
- [ ] ⏳ Коммиты загружены
- [ ] ⏳ SSH настроен (опционально)

---

## 🎯 СЛЕДУЮЩИЕ ШАГИ

1. **Создать репозиторий на GitHub** (2 минуты)
2. **Добавить remote** (1 минута)
3. **Загрузить коммиты** (5 минут)
4. **Настроить авто-push** (опционально)

---

## 🔗 ПОЛЕЗНЫЕ ССЫЛКИ

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Git Documentation](https://git-scm.com/doc)
- [SSH Keys Guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)

---

**Готово к подключению!** 🚀

**Последнее обновление:** 28 февраля 2026 г.
