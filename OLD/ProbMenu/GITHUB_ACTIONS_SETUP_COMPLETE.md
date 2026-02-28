# 🚀 ПОЛНАЯ НАСТРОЙКА GITHUB ACTIONS

**Автоматическая настройка CI/CD для DragRace Unity**

---

## 📋 ЧЕК-ЛИСТ НАСТРОЙКИ

### Шаг 1: Установка Git (если нет)

```bash
# winget (рекомендуется)
winget install Git.Git

# Или скачайте: https://git-scm.com/download/win
```

### Шаг 2: Инициализация репозитория

```powershell
# Откройте PowerShell в папке проекта
cd D:\QwenPoekt\ProbMenu

# Инициализация Git
git init

# Добавление всех файлов
git add .

# Первый коммит
git commit -m "Initial commit - DragRace Unity Project"
```

---

## 🐙 Создание репозитория на GitHub

### Вариант А: Через браузер (рекомендуется)

1. **Откройте:** https://github.com/new
2. **Войдите** в ваш аккаунт GitHub
3. **Заполните:**
   - **Repository name:** `DragRace` или `ProbMenu`
   - **Description:** Unity DragRace Project
   - **Visibility:** Private (или Public)
4. **НЕ создавайте** с README, .gitignore, license
5. **Нажмите:** Create repository

### Вариант Б: Через GitHub CLI

```bash
# Установка GitHub CLI
winget install GitHub.cli

# Авторизация
gh auth login

# Создание репозитория
gh repo create DragRace --private --source=. --remote=origin --push
```

---

## 🔐 Добавление секретов (SECRETS)

### 1. Откройте настройки репозитория:

```
GitHub → Ваш репозиторий → Settings → Secrets and variables → Actions
```

### 2. Добавьте секреты:

| Name | Value |
|------|-------|
| `UNITY_EMAIL` | `jackal555rus@gmail.com` |
| `UNITY_PASSWORD` | `Unit0579` |
| `UNITY_PERSONAL_TOKEN` | `eRctBAYhyLTHFJo-OTzw__dUJIgU2vrQ` |
| `UNITY_VERSION` | `6000.3.10f1` |

### 3. Пошагово:

```
1. New repository secret
2. Name: UNITY_EMAIL
3. Value: jackal555rus@gmail.com
4. Add secret

5. New repository secret
6. Name: UNITY_PASSWORD
7. Value: Unit0579
8. Add secret

9. New repository secret
10. Name: UNITY_PERSONAL_TOKEN
11. Value: eRctBAYhyLTHFJo-OTzw__dUJIgU2vrQ
12. Add secret

13. New repository secret
14. Name: UNITY_VERSION
15. Value: 6000.3.10f1
16. Add secret
```

---

## 📤 Загрузка файлов в репозиторий

### Вариант А: Через Git (рекомендуется)

```powershell
# В папке проекта D:\QwenPoekt\ProbMenu

# Добавить remote
git remote add origin https://github.com/ВАШ_USERNAME/DragRace.git

# Добавить все файлы
git add .

# Коммит
git commit -m "Add Unity project with CI/CD"

# Отправить в GitHub
git push -u origin main
```

### Вариант Б: Через веб-интерфейс

1. **Откройте:** https://github.com/new
2. **Создайте репозиторий**
3. **Перетащите файлы** в окно браузера
4. **Или загрузите** через "uploading an existing file"

---

## ✅ Проверка workflow

### 1. Откройте Actions:

```
GitHub → Репозиторий → Actions
```

### 2. Должно появиться:

```
Unity Build workflow
└── Run workflow (автоматически или вручную)
```

### 3. Первый запуск:

```
Actions → Unity Build → Run workflow → Run workflow
```

---

## 📊 Мониторинг сборки

### Статус задач:

```
✅ validate         ~2 мин
🔄 build-windows   ~15-30 мин
⏳ release         ~1 мин
```

### Просмотр логов:

```
1. Кликните на запущенный workflow
2. Выберите задачу (validate / build-windows)
3. Разверните шаги
4. Смотрите вывод
```

### Скачивание артефакта:

```
1. Дождитесь завершения
2. Внизу страницы: Artifacts
3. Кликните: DragRace-Windows-Build
4. Скачается ZIP с .exe файлом
```

---

## 🔧 Настройка .gitignore

Создайте файл `.gitignore` в корне проекта:

```gitignore
# Unity
[Ll]ibrary/
[Tt]emp/
[Oo]bj/
[Bb]uild/
[Bb]uilds/
*.pidb.meta
*.pdb.meta
*.mdb.meta
*.apk
*.aab
*.unitypackage

# OS
.DS_Store
Thumbs.db
desktop.ini

# IDE
.vs/
.vscode/
*.suo
*.user
*.userosscache
*.suo.user

# Logs
*.log
[Ll]ogs/

# Secrets
.env
*.env.local
secrets/
```

---

## 🎯 Проверка успешности

### ✅ Всё работает если:

- [ ] Workflow запускается
- [ ] Задача validate: ✅ Success
- [ ] Задача build-windows: ✅ Success
- [ ] Артефакт скачивается
- [ ] .exe файл запускается

### ❌ Если ошибки:

| Ошибка | Решение |
|--------|---------|
| **Workflow not found** | Проверьте путь `.github/workflows/` |
| **Unity not found** | Проверьте UNITY_VERSION в secrets |
| **License error** | Проверьте UNITY_EMAIL/PASSWORD |
| **No scenes** | Добавьте сцены в Build Settings |

---

## 📁 Структура репозитория

Правильная структура:

```
DragRace/
├── .github/
│   └── workflows/
│       └── unity-build.yml    ✅
├── DragRaceUnity/
│   ├── Assets/                ✅
│   ├── Packages/
│   │   └── manifest.json      ✅
│   └── ProjectSettings/       ✅
├── ProbMenu/
│   ├── Form1.cs               ✅
│   └── ProbMenu.csproj        ✅
├── .gitignore                 ✅
└── README.md                  ✅
```

---

## 🔄 Автоматические триггеры

Workflow запускается автоматически при:

```yaml
✅ Push в main ветку
✅ Push в develop ветку
✅ Создание Pull Request
✅ Публикация Release
✅ Ручной запуск (workflow_dispatch)
```

---

## 💡 Советы по оптимизации

### 1. Кэширование:

```yaml
# Уже настроено в workflow
- uses: actions/cache@v4
  with:
    path: DragRaceUnity/Library
    key: Library-${{ hashFiles(...) }}
```

### 2. Git LFS для больших файлов:

```bash
# Установка
git lfs install

# Отслеживание больших файлов
git lfs track "*.png" "*.fbx" "*.unity" "*.prefab"

# Коммит
git add .gitattributes
git commit -m "Add LFS tracking"
```

### 3. Исключение лишних файлов:

```bash
# Перед коммитом очистите:
Delete: Library/, Temp/, Obj/, Builds/
```

---

## 📞 Если что-то пошло не так

### Проверьте логи:

```
Actions → Выбрать запуск → Кликнуть на задачу → Развернуть шаги
```

### Частые ошибки:

| Ошибка | Причина | Решение |
|--------|---------|---------|
| `Resource not accessible` | Нет прав | Проверьте Permissions |
| `Unity exit code 1` | Ошибка сборки | Смотрите build-unity.log |
| `No such file` | Неправильный путь | Проверьте PROJECT_PATH |
| `Secret not found` | Не добавлен | Пересоздайте secret |

---

## ✅ ФИНАЛЬНАЯ ПРОВЕРКА

### Команды для проверки:

```powershell
# 1. Проверка Git
git status

# 2. Проверка remote
git remote -v

# 3. Тестовый пуш
git push --dry-run

# 4. Проверка файлов
ls .github/workflows/
```

### Чек-лист:

- [ ] Git установлен
- [ ] Репозиторий создан на GitHub
- [ ] Файлы загружены
- [ ] Secrets добавлены
- [ ] Workflow запускается
- [ ] Артефакт скачивается
- [ ] .exe работает

---

## 🎉 ГОТОВО!

Теперь у вас есть:

- ✅ Автоматическая сборка при каждом push
- ✅ Артефакты с готовыми .exe файлами
- ✅ Логи сборок
- ✅ Интеграция с GitHub

**Следующий шаг:** Сделайте push и проверьте первую сборку!

---

**Контакты для поддержки:** jackal555rus@gmail.com
