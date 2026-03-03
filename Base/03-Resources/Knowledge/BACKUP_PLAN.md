---
title: BACKUP PLAN
version: 1.0
date: 2026-03-04
status: draft
---
# 🔄 BACKUP PLAN — КАК ВЕРНУТЬСЯ

**Дата:** 1 марта 2026 г.

---

## ⚠️ ТЕКУЩЕЕ СОСТОЯНИЕ

**До теста:**
```
D:\QwenPoekt\
├── .qwen\
├── KNOWLEDGE_BASE\
├── PROJECTS\
├── scripts\
└── ... (другие файлы)
```

**Тестовая среда:**
```
D:\QwenPoekt\_TEST_ENV\
├── Base\
├── Projects\
└── Документация
```

**Текущая система:** ✅ **НЕ ИЗМЕНЕНА**

---

## 🚨 СЦЕНАРИЙ 1: ТЕСТ ПРОВАЛИЛСЯ

### Быстрый откат

**Шаг 1: Закрыть VS Code**
```
Просто закройте VS Code
```

**Шаг 2: Удалить тестовую среду**
```powershell
cd D:\QwenPoekt
Remove-Item _TEST_ENV -Recurse -Force
```

**Шаг 3: Проверить целостность**
```powershell
git status
```

**Ожидаем:** `nothing to commit, working tree clean`

**Шаг 4: Восстановить (если нужно)**
```powershell
# Если текущая система повреждена:
git checkout .
git clean -fd
```

**Результат:** ✅ Система возвращена к исходному состоянию

---

## 🚨 СЦЕНАРИЙ 2: ЧАСТИЧНЫЙ ПРОВАЛ

### Проблема: Workspace не работает

**Решение:**
```powershell
# Удалить workspace файл
Remove-Item _TEST_ENV\WORKSPACE_TEST.code-workspace

# Проверить остальное
code _TEST_ENV\Base
code _TEST_ENV\Projects\DragRaceUnity
```

---

### Проблема: Qwen не видит папки

**Решение:**
```
1. File → Add Folder to Workspace
2. Добавить _TEST_ENV\Base
3. Добавить _TEST_ENV\Projects
```

---

### Проблема: Git конфликты

**Решение:**
```powershell
# В тестовой папке
cd _TEST_ENV\Base
git status  # Проверить состояние

# Если нужно сбросить
git reset --hard HEAD
git clean -fd
```

---

## 🚨 СЦЕНАРИЙ 3: СЛУЧАЙНО ПОВРЕДИЛИ ТЕКУЩУЮ СИСТЕМУ

### Восстановление из Git

**Шаг 1: Проверить повреждения**
```powershell
git status
git diff HEAD
```

**Шаг 2: Отменить изменения**
```powershell
# Отменить все изменения в рабочей директории
git checkout .

# Удалить новые файлы
git clean -fd
```

**Шаг 3: Проверить**
```powershell
git status  # Должно быть "clean"
```

---

## ✅ СЦЕНАРИЙ 4: ТЕСТ УСПЕШЕН, ВНЕДРЕНИЕ

### План внедрения

**Шаг 1: Создать структуру в корне**
```powershell
cd D:\QwenPoekt

mkdir Base
mkdir Projects
```

**Шаг 2: Переместить файлы**
```powershell
# Переместить в Base
move .qwen Base\
move KNOWLEDGE_BASE Base\
move scripts Base\
move AI_START_HERE.md Base\
move RULES_AND_TASKS.md Base\
move ТЕКУЩАЯ_ЗАДАЧА.md Base\

# Переместить в Projects
move PROJECTS\DragRaceUnity Projects\
move PROJECTS\Template Projects\ (если есть)
```

**Шаг 3: Создать настоящий workspace**
```powershell
# D:\QwenPoekt.code-workspace
```

**Шаг 4: Настроить Git**
```powershell
# Отдельный Git для Base
cd Base
git init

# Отдельный Git для Projects
cd ..\Projects\DragRaceUnity
git init
```

**Шаг 5: Удалить тестовую среду**
```powershell
cd D:\QwenPoekt
Remove-Item _TEST_ENV -Recurse -Force
```

---

## 📊 КОНТРОЛЬНЫЕ ТОЧКИ

| Этап | Что проверять |
|------|---------------|
| **До теста** | `git status` = clean |
| **После создания** | Файлы в `_TEST_ENV\` существуют |
| **После тестов** | Текущая система не изменена |
| **Перед удалением** | Workspace работает |

---

## 📞 ЭКСТРЕННАЯ ПОМОЩЬ

### Команды восстановления:

```powershell
# 1. Проверить Git
cd D:\QwenPoekt
git status

# 2. Отменить изменения
git checkout .

# 3. Удалить новое
git clean -fd

# 4. Удалить тест (если нужно)
Remove-Item _TEST_ENV -Recurse -Force

# 5. Проверить
dir
```

---

## ✅ ПРОВЕРКА БЕЗОПАСНОСТИ

**Перед началом тестов убедитесь:**

- [ ] `git status` показывает "clean"
- [ ] Текущая система работает
- [ ] Файлы не изменены
- [ ] Можно сделать `git checkout .`

---

**Последнее обновление:** 1 марта 2026 г.


