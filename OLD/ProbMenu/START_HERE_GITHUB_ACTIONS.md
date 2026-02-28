# 🚀 ЗАПУСК GITHUB ACTIONS — ПОШАГОВАЯ ИНСТРУКЦИЯ

**Автоматическая настройка CI/CD для DragRace Unity**

---

## ⚡ БЫСТРЫЙ СТАРТ (5 минут)

### Шаг 1: Запустите скрипт настройки

```powershell
# Откройте PowerShell в папке проекта
cd D:\QwenPoekt\ProbMenu

# Запустите скрипт
.\setup-github.ps1
```

Скрипт автоматически:
- ✅ Инициализирует Git
- ✅ Создаст .gitignore
- ✅ Добавит файлы
- ✅ Создаст первый коммит
- ✅ Сохранит инструкцию

---

### Шаг 2: Создайте репозиторий на GitHub

1. **Откройте:** https://github.com/new
2. **Войдите** в ваш аккаунт GitHub
3. **Заполните:**
   - **Repository name:** `DragRace`
   - **Description:** Unity DragRace Project
   - **Visibility:** Private ✅
4. **НЕ создавайте** с README, .gitignore, license ❌
5. **Нажмите:** Create repository

---

### Шаг 3: Добавьте секреты

**Откройте:** `Settings → Secrets and variables → Actions`

**Добавьте 4 секрета:**

```
1. New repository secret
   Name: UNITY_EMAIL
   Value: jackal555rus@gmail.com

2. New repository secret
   Name: UNITY_PASSWORD
   Value: Unit0579

3. New repository secret
   Name: UNITY_PERSONAL_TOKEN
   Value: eRctBAYhyLTHFJo-OTzw__dUJIgU2vrQ

4. New repository secret
   Name: UNITY_VERSION
   Value: 6000.3.10f1
```

**Скриншот:**
```
Settings → Secrets and variables → Actions → New repository secret
```

---

### Шаг 4: Отправьте код в GitHub

**Скопируйте команду из шага 3 инструкции:**

```powershell
# Замените YOUR_USERNAME на ваш логин GitHub
git remote add origin https://github.com/YOUR_USERNAME/DragRace.git

# Отправьте файлы
git push -u origin main
```

---

### Шаг 5: Проверьте Actions

1. **Откройте:** https://github.com/YOUR_USERNAME/DragRace/actions
2. **Должно появиться:** Unity Build workflow
3. **Запустится автоматически** или нажмите "Run workflow"

---

## 📊 ЧТО ПРОИСХОДИТ ПОСЛЕ PUSH

### Автоматически запускается:

```
✅ validate (2 мин)    → Проверка проекта
✅ build-windows (30 мин) → Сборка .exe
✅ release (1 мин)     → Публикация (если релиз)
```

### Результат:

```
✅ Артефакт: DragRace-Windows-Build.zip
✅ Файл: DragRace_Windows.exe
✅ Лог: build-unity.log
✅ Отчёт: GITHUB_STEP_SUMMARY
```

---

## 📥 СКАЧИВАНИЕ АРТЕФАКТА

1. **Откройте:** Actions → Выберите запуск
2. **Внизу страницы:** Artifacts
3. **Кликните:** DragRace-Windows-Build
4. **Скачается ZIP** с готовым .exe

---

## 🔧 НАСТРОЙКА GIT (если не установлен)

### Установка Git:

```powershell
# winget (рекомендуется)
winget install Git.Git

# Или скачайте: https://git-scm.com/download/win
```

### Проверка:

```powershell
git --version
# Должно вывести: git version 2.x.x
```

---

## 📁 СТРУКТУРА ПОСЛЕ НАСТРОЙКИ

```
D:\QwenPoekt\ProbMenu\
├── .git/                    ✅ Создано скриптом
├── .github/
│   └── workflows/
│       └── unity-build.yml  ✅ Готово
├── .gitignore               ✅ Создано скриптом
├── DragRaceUnity/           ✅ Unity проект
│   ├── Assets/
│   ├── Packages/
│   └── ProjectSettings/
├── ProbMenu/                ✅ WinForms
├── setup-github.ps1         ✅ Скрипт настройки
└── GITHUB_SETUP_INSTRUCTIONS.txt ✅ Инструкция
```

---

## ⚠️ ЧАСТЫЕ ПРОБЛЕМЫ

### 1. "Git not found"

**Решение:**
```powershell
winget install Git.Git
# Перезапустите PowerShell
.\setup-github.ps1
```

---

### 2. "Permission denied" при push

**Решение:**
```
GitHub → Settings → Developer settings → Personal access tokens
Generate new token (repo полный доступ)
git remote set-url origin https://TOKEN@github.com/USERNAME/REPO.git
git push
```

---

### 3. Workflow не запускается

**Причина:** Actions отключены

**Решение:**
```
GitHub → Actions → I understand my workflows → Enable
```

---

### 4. Ошибка "Unity not found"

**Причина:** Неверная версия в secrets

**Решение:**
```
Settings → Secrets → UNITY_VERSION
Проверьте: 6000.3.10f1
```

---

### 5. Ошибка "No scenes in build settings"

**Причина:** Пустые Build Settings в Unity

**Решение:**
```
1. Откройте проект в Unity
2. File → Build Settings
3. Добавьте сцены (Assets/Scenes/)
4. Commit и push
```

---

## 📞 ПОДДЕРЖКА

### Файлы с инструкциями:

- 📄 `GITHUB_ACTIONS_SETUP_COMPLETE.md` — Полная версия
- 📄 `GITHUB_SETUP_INSTRUCTIONS.txt` — Краткая (создаётся скриптом)
- 📄 `DOCUMENTATION_INDEX.md` — Вся документация

### Контакты:

- **Email:** jackal555rus@gmail.com
- **Telegram:** @jackal555

---

## ✅ ЧЕК-ЛИСТ УСПЕХА

- [ ] Git установлен (`git --version`)
- [ ] Скрипт запущен (`.\setup-github.ps1`)
- [ ] Репозиторий создан на GitHub
- [ ] Secrets добавлены (4 штуки)
- [ ] Push успешен (`git push`)
- [ ] Actions запустились
- [ ] Артефакт скачан
- [ ] .exe файл работает

---

## 🎉 ГОТОВО!

Теперь у вас есть:

- ✅ Автоматическая сборка при каждом push
- ✅ Готовые .exe файлы в артефактах
- ✅ Логи сборок
- ✅ Интеграция с GitHub

**Следующий шаг:** Сделайте изменения в коде и push — сборка запустится автоматически!

---

**Время настройки:** ~5-10 минут  
**Сложность:** ⭐⭐ (из 5)  
**Стоимость:** Бесплатно (GitHub Free)
