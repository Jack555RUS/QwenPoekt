# 🚀 НАЧНИТЕ ЗДЕСЬ — Тестирование в _TEST_ENV

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готов к использованию

---

## ⚡ БЫСТРЫЙ СТАРТ (3 команды)

```powershell
# 1. Создать среду
.\scripts\create-test-env.ps1

# 2. Запустить тесты
.\test-pre-operation-backup.ps1 -OperationType "Test"
.\test-safe-delete.ps1 -Path "_drafts" -WhatIf
.\test-old-backup-analysis.ps1

# 3. Очистить после тестов
.\scripts\cleanup-test-env.ps1
```

---

## 🛡️ ГЛАВНОЕ ПРАВИЛО

> **База (D:\QwenPoekt\Base) не должна пострадать!**

**Почему безопасно:**

| Принцип | Защита |
|---------|--------|
| **Изоляция** | Все пути в `_TEST_ENV` (вне не выходит) |
| **Копия** | `Base` → `_TEST_ENV\Base` (оригинал не трогается) |
| **Проверка** | Проверка путей в каждом скрипте |
| **Очистка** | Автоматическая очистка после тестов |

**Если что-то пошло не так:**

```powershell
# Удалить _TEST_ENV и начать заново
.\scripts\cleanup-test-env.ps1 -Force
.\scripts\create-test-env.ps1
```

---

## 📚 ВСЕ ФАЙЛЫ В ОДНОМ МЕСТЕ

### 📘 Инструкции

| Файл | Что читать | Когда |
|------|------------|-------|
| **[TEST_ENV_GUIDE.md](02-Areas/Documentation/test-env-guide.md)** | Полная инструкция по _TEST_ENV | Перед началом |
| **[PRE_OPERATION_BACKUP_GUIDE.md](02-Areas/Documentation/pre-operation-backup-guide.md)** | Как работает бэкап | Перед тестом бэкапа |
| **[SAFE_DELETE_GUIDE.md](02-Areas/Documentation/safe-delete-guide.md)** | Как работает удаление | Перед тестом удаления |
| **[OLD_BACKUP_ANALYSIS_GUIDE.md](02-Areas/Documentation/old-backup-analysis-guide.md)** | Как работает анализ | Перед тестом анализа |

### 📊 Журналы

| Файл | Что содержит |
|------|--------------|
| **OPERATION_LOG.md** | Логи всех операций |
| **reports/CREATE_TEST_ENV_REPORT.md** | Отчёт о создании среды (создаётся при тесте) |
| **reports/BACKUP_ANALYSIS_REPORT.md** | Отчёт анализа бэкапов (создаётся при тесте) |

### 🔧 Скрипты

| Файл | Назначение | Команда |
|------|------------|---------|
| **03-Resources/PowerShell/create-test-env.ps1** | Создание среды | `.\scripts\create-test-env.ps1` |
| **03-Resources/PowerShell/cleanup-test-env.ps1** | Очистка после тестов | `.\scripts\cleanup-test-env.ps1` |
| **03-Resources/PowerShell/test-pre-operation-backup.ps1** | Тест бэкапа | `.\test-pre-operation-backup.ps1 -OperationType "Test"` |
| **03-Resources/PowerShell/test-safe-delete.ps1** | Тест удаления | `.\test-safe-delete.ps1 -Path "_drafts"` |
| **03-Resources/PowerShell/test-old-backup-analysis.ps1** | Тест анализа | `.\test-old-backup-analysis.ps1` |

---

## 🔄 ЖИЗНЕННЫЙ ЦИКЛ ТЕСТА

```
┌─────────────────────────────────────────────────────────┐
│  1. ПРОЧИТАТЬ START_HERE.md (этот файл)                │
│     ↓                                                   │
│  2. Прочитать TEST_ENV_GUIDE.md (если нужно подробно)  │
│     ↓                                                   │
│  3. Создать среду: create-test-env.ps1                 │
│     ↓                                                   │
│  4. Запустить тесты: test-*.ps1                        │
│     ↓                                                   │
│  5. Проверить логи: reports/TEST_LOG.md                │
│     ↓                                                   │
│  6. Очистить: cleanup-test-env.ps1                     │
└─────────────────────────────────────────────────────────┘
```

---

## ❓ ЧАСТЫЕ ВОПРОСЫ

### Q: Где оригинал Base?

**A:** `D:\QwenPoekt\Base` (не трогать!)

---

### Q: Где тестовая копия?

**A:** `D:\QwenPoekt\_TEST_ENV\Base`

---

### Q: Что если сломал тестовую среду?

**A:** 
```powershell
.\scripts\cleanup-test-env.ps1 -Force
.\scripts\create-test-env.ps1
```

---

### Q: Где логи тестов?

**A:** `_TEST_ENV\reports\TEST_LOG.md`

---

### Q: Как сохранить логи?

**A:** 
```powershell
.\scripts\cleanup-test-env.ps1 -SaveLogs
```

---

### Q: Можно ли тестировать на оригинале?

**A:** ❌ **НЕТ!** Сначала создай _TEST_ENV:

```powershell
.\scripts\create-test-env.ps1
```

---

## 🎯 ПРИНЦИПЫ ТЕСТИРОВАНИЯ

| Принцип | Описание |
|---------|----------|
| **Изоляция** | Тесты только в _TEST_ENV (вне не выходит) |
| **Безопасность** | Оригинал Base не трогается |
| **Автоматизация** | Создание и очистка одним скриптом |
| **Логирование** | Все тесты записываются в TEST_LOG.md |
| **Чистота** | После тестов → очистка _TEST_ENV |

---

## 📋 ЧЕК-ЛИСТ ПЕРЕД ТЕСТИРОВАНИЕМ

```
[ ] 1. Прочитать START_HERE.md (этот файл)
[ ] 2. Прочитать TEST_ENV_GUIDE.md (по желанию)
[ ] 3. Создать среду: .\scripts\create-test-env.ps1
[ ] 4. Проверить структуру: ls _TEST_ENV
[ ] 5. Запустить тесты (с -WhatIf сначала)
[ ] 6. Проверить логи: code _TEST_ENV\reports\TEST_LOG.md
[ ] 7. Очистить: .\scripts\cleanup-test-env.ps1
```

---

## 🔗 СВЯЗАННЫЕ РЕСУРСЫ

**Основной проект:**

- 📁 [Base/](../Base/) — Оригинал (не трогать!)
- 📚 [02-Areas/Documentation/](../02-Areas/Documentation/) — Все инструкции
- 📝 [reports/](../reports/) — Отчёты проекта

**Тестовая среда:**

- 🧪 [_TEST_ENV/](./) — Тестовая копия
- 🗑️ [_BACKUP/](./_BACKUP/) — Тестовые бэкапы
- 📊 [reports/](./reports/) — Логи тестов

---

## ⚠️ ПРЕДУПРЕЖДЕНИЯ

| Уровень | Когда | Действие |
|---------|-------|----------|
| **🟢 Низкий** | WhatIf режим, чтение | ✅ Делать без спроса |
| **🟡 Средний** | Создание бэкапа, удаление файлов | ⚠️ Проверить путь |
| **🔴 Высокий** | Выход за _TEST_ENV | ❌ Запрещено! |

---

**Создано:** 2026-03-02  
**Обновлено:** 2026-03-02  
**Скрипт:** create-test-env.ps1

---

**Прочитал? Приступай к тестам!** 🚀

