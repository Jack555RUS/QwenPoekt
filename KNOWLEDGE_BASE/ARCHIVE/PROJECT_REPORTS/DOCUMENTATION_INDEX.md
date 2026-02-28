# 📚 Документация проекта ProbMenu / DragRace

**Последнее обновление:** 27 февраля 2026  
**Версия Unity:** 6000.3.10f1  
**Статус:** ✅ Активно разрабатывается

---

## 🎯 Быстрая навигация

### Для новых разработчиков:

1. **[SENIOR_WORKFLOW_OPTIMIZED.md](SENIOR_WORKFLOW_OPTIMIZED.md)** — 🚀 ОПТИМИЗИРОВАННЫЙ WORKFLOW ⭐ **НАЧНИТЕ ЗДЕСЬ**
2. **[START_HERE_GITHUB_ACTIONS.md](START_HERE_GITHUB_ACTIONS.md)** — Настройка GitHub Actions
3. **[UNITY_HUB_SETUP.md](UNITY_HUB_SETUP.md)** — Настройка Unity Hub
4. **[TEAM_LICENSE_INSTRUCTIONS.md](TEAM_LICENSE_INSTRUCTIONS.md)** — Активация лицензий

### Для разработки:

4. **[PROJECT_STATUS_FINAL.md](PROJECT_STATUS_FINAL.md)** — Текущий статус проекта
5. **[README_CI_CD.md](README_CI_CD.md)** — CI/CD навигация

### Для DevOps:

6. **`.github/workflows/unity-build.yml`** — GitHub Actions workflow
7. **`.github/secrets.example.md`** — Шаблон секретов

---

## 📖 Полное оглавление

### 🔧 Настройка рабочего места

| Документ | Описание | Страниц |
|----------|----------|---------|
| **[UNITY_HUB_SETUP.md](UNITY_HUB_SETUP.md)** | Настройка Unity Hub для команды | 6 |
| **[TEAM_LICENSE_INSTRUCTIONS.md](TEAM_LICENSE_INSTRUCTIONS.md)** | Активация лицензий Unity | 5 |
| **[CI_CD_SETUP.md](CI_CD_SETUP.md)** | Настройка GitHub Actions | 4 |

### 📊 Проектная документация

| Документ | Описание | Страниц |
|----------|----------|---------|
| **[PROJECT_STATUS_FINAL.md](PROJECT_STATUS_FINAL.md)** | Полный статус проекта | 3 |
| **[README_CI_CD.md](README_CI_CD.md)** | Навигация по CI/CD | 2 |

### 🔧 Технические файлы

| Файл | Описание |
|------|----------|
| **`.github/workflows/unity-build.yml`** | GitHub Actions workflow для автосборки |
| **`.github/secrets.example.md`** | Шаблон для добавления секретов |
| **`.env`** | Локальные переменные окружения |
| **`docker-compose.yml`** | Docker конфигурация (PostgreSQL, Redis) |
| **`ProbMenu.csproj`** | WinForms проект |

### 🛠️ Скрипты

| Скрипт | Назначение |
|--------|------------|
| **`unity-open.ps1`** | Открыть проект в Unity Editor |
| **`unity-build-fix.ps1`** | Автоматическая установка модулей и сборка |
| **`unity-enable-modules.ps1`** | Включение built-in модулей Unity |

---

## 🚀 Онбординг нового разработчика

### День 1: Настройка

```bash
# 1. Установить Unity Hub
winget install Unity.UnityHub

# 2. Клонировать репозиторий
git clone <repository-url>
cd ProbMenu

# 3. Изучить документацию
start UNITY_HUB_SETUP.md
```

### День 2: Первый запуск

```bash
# 1. Настроить Unity Hub (см. UNITY_HUB_SETUP.md)
# 2. Активировать лицензию (см. TEAM_LICENSE_INSTRUCTIONS.md)
# 3. Открыть проект DragRaceUnity в Unity
# 4. Сделать тестовую сборку
```

### День 3: CI/CD

```bash
# 1. Изучить CI_CD_SETUP.md
# 2. Получить доступ к GitHub репозиторию
# 3. Сделать первый commit
# 4. Проверить GitHub Actions
```

---

## 📊 Статус компонентов

| Компонент | Статус | Документация |
|-----------|--------|--------------|
| **WinForms ProbMenu** | ✅ Работает | [PROJECT_STATUS_FINAL.md](PROJECT_STATUS_FINAL.md) |
| **Unity Editor** | ✅ 6000.3.10f1 | [UNITY_HUB_SETUP.md](UNITY_HUB_SETUP.md) |
| **Модули Unity** | ✅ Установлены | [UNITY_HUB_SETUP.md](UNITY_HUB_SETUP.md) |
| **Лицензия** | ✅ Personal (Windows) | [TEAM_LICENSE_INSTRUCTIONS.md](TEAM_LICENSE_INSTRUCTIONS.md) |
| **PostgreSQL (Docker)** | ✅ Работает | [PROJECT_STATUS_FINAL.md](PROJECT_STATUS_FINAL.md) |
| **Redis (Docker)** | ✅ Работает | [PROJECT_STATUS_FINAL.md](PROJECT_STATUS_FINAL.md) |
| **GitHub Actions** | ✅ Настроено | [CI_CD_SETUP.md](CI_CD_SETUP.md) |
| **Docker + Unity** | ⚠️ Требуется Pro | [TEAM_LICENSE_INSTRUCTIONS.md](TEAM_LICENSE_INSTRUCTIONS.md) |

---

## 🎯 Ключевые ссылки

### Внутренние:

- 📁 **Репозиторий:** `D:\QwenPoekt\ProbMenu`
- 🎮 **Unity проект:** `D:\QwenPoekt\ProbMenu\DragRaceUnity`
- 📦 **Сборки:** `D:\QwenPoekt\ProbMenu\Builds\`

### Внешние:

- 🌐 **Unity Download:** https://unity.com/download
- 🔑 **License Portal:** https://license.unity3d.com/manual
- 📚 **Unity Docs:** https://docs.unity3d.com/
- 🐙 **GitHub Actions:** https://github.com/features/actions
- 🎮 **GameCI:** https://game.ci/

---

## 📞 Контакты команды

| Роль | Email | Telegram |
|------|-------|----------|
| **Lead Developer** | jackal555rus@gmail.com | @jackal555 |
| **Unity Developer** | [добавить] | [добавить] |
| **DevOps** | [добавить] | [добавить] |

---

## 🔍 Поиск по документации

### По темам:

**Лицензирование:**
- TEAM_LICENSE_INSTRUCTIONS.md
- UNITY_HUB_SETUP.md (раздел "Активация лицензии")

**CI/CD:**
- CI_CD_SETUP.md
- README_CI_CD.md
- .github/workflows/unity-build.yml

**Настройка:**
- UNITY_HUB_SETUP.md
- PROJECT_STATUS_FINAL.md

**Сборка:**
- unity-build-fix.ps1
- CI_CD_SETUP.md (раздел "Сборка проекта")

---

## 📝 История изменений

| Дата | Изменение | Автор |
|------|-----------|-------|
| 27.02.2026 | Создана полная документация | jackal555 |
| 27.02.2026 | Настроен GitHub Actions | jackal555 |
| 27.02.2026 | Обновлён статус проекта | jackal555 |

---

## ✅ Чек-лист для нового разработчика

- [ ] Прочитан README_CI_CD.md
- [ ] Установлен Unity Hub
- [ ] Активирована лицензия
- [ ] Установлен Unity Editor 6000.3.10f1
- [ ] Установлены модули
- [ ] Клонирован репозиторий
- [ ] Открыт проект DragRaceUnity
- [ ] Изучен PROJECT_STATUS_FINAL.md
- [ ] Настроен GitHub Actions (если есть доступ)
- [ ] Сделана первая сборка

---

**Добро пожаловать в команду DragRace!** 🎮

Если у вас возникли вопросы, обратитесь к Lead Developer или создайте issue в репозитории.
