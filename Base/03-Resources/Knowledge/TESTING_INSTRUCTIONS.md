# 🧪 ТЕСТИРОВАНИЕ СИСТЕМЫ АУДИТА

**Версия:** 1.0  
**Дата:** 2 марта 2026 г.  
**Статус:** ⏳ Готово к тестированию

---

## 🎯 НАЗНАЧЕНИЕ

Этот документ описывает **процесс тестирования системы аудита** в изолированной среде `_TEST_ENV`.

---

## 📋 ПРЕДВАРИТЕЛЬНЫЕ ТРЕБОВАНИЯ

### Установлено:
- ✅ PowerShell 7+
- ✅ Git
- ✅ Node.js (для dashboard, опционально)

### Создано:
- ✅ Тестовая среда: `_TEST_ENV/audit_test/`
- ✅ Скрипты в: `Base/03-Resources/PowerShell/`
- ✅ Dashboard в: `Base/reports/KB_DASHBOARD.html`

---

## 🚀 БЫСТРЫЙ СТАРТ

### Шаг 1: Подготовка тестовой среды

```powershell
# Перейти в тестовую директорию
cd D:\QwenPoekt\_TEST_ENV\audit_test

# Проверить структуру
Get-ChildItem
```

**Ожидаемый результат:**
```
KNOWLEDGE_BASE/
03-Resources/PowerShell/
reports/
```

---

### Шаг 2: Копирование тестовых данных

```powershell
# Копирование небольшого подмножества KNOWLEDGE_BASE
$sourceBase = "D:\QwenPoekt\Base\KNOWLEDGE_BASE"
$testBase = "D:\QwenPoekt\_TEST_ENV\audit_test\KNOWLEDGE_BASE"

# Копировать только 00_CORE и 01_RULES (быстро для теста)
Copy-Item "$sourceBase\00_CORE" "$testBase\00_CORE" -Recurse -Force
Copy-Item "$sourceBase\01_RULES" "$testBase\01_RULES" -Recurse -Force

Write-Host "✅ Тестовые данные скопированы"
```

---

### Шаг 3: Копирование скриптов

```powershell
# Копирование скриптов
$sourceScripts = "D:\QwenPoekt\Base\scripts"
$testScripts = "D:\QwenPoekt\_TEST_ENV\audit_test\scripts"

Copy-Item "$sourceScripts\*.ps1" "$testScripts\" -Force

Write-Host "✅ Скрипты скопированы"
```

---

### Шаг 4: Тестовый запуск

#### 4.1 Тест organize-root.ps1 (безопасный режим)

```powershell
cd D:\QwenPoekt\_TEST_ENV\audit_test

# Запуск в режиме WhatIf (без реальных изменений)
.\scripts\organize-root.ps1 -WhatIf
```

**Ожидаемый результат:**
- ✅ Список действий без реального выполнения
- ✅ Нет ошибок

---

#### 4.2 Тест full-file-audit.ps1

```powershell
# Запуск аудита файлов
.\scripts\full-file-audit.ps1 -Path ".\KNOWLEDGE_BASE" -Verbose
```

**Ожидаемый результат:**
- ✅ Отчёт в `reports/FILE_AUDIT_REPORT.md`
- ✅ Таблица с оценками файлов
- ✅ Рекомендации

---

#### 4.3 Тест build-knowledge-graph.ps1

```powershell
# Построение графа
.\scripts\build-knowledge-graph.ps1 -Path ".\KNOWLEDGE_BASE"
```

**Ожидаемый результат:**
- ✅ Отчёт в `reports/KNOWLEDGE_GRAPH.md`
- ✅ JSON в `reports/knowledge_graph.json`
- ✅ Mermaid диаграмма

---

#### 4.4 Тест calculate-kb-metrics.ps1

```powershell
# Расчёт метрик
.\scripts\calculate-kb-metrics.ps1 -Path ".\KNOWLEDGE_BASE"
```

**Ожидаемый результат:**
- ✅ Отчёт в `reports/KB_METRICS.md`
- ✅ JSON в `reports/kb_metrics.json`
- ✅ 5 метрик с оценками

---

#### 4.5 Тест AUDIT_ALL.ps1 (полный цикл)

```powershell
# Полный аудит
.\scripts\AUDIT_ALL.ps1 -Path "."
```

**Ожидаемый результат:**
- ✅ Все 4 скрипта выполнены
- ✅ Сводный отчёт в `reports/MASTER_AUDIT_REPORT.md`
- ✅ JSON файлы для dashboard

---

#### 4.6 Тест Dashboard

```powershell
# Открытие dashboard
Start-Process "D:\QwenPoekt\_TEST_ENV\audit_test\reports\KB_DASHBOARD.html"
```

**Ожидаемый результат:**
- ✅ HTML открыт в браузере
- ✅ Данные загружены из JSON
- ✅ Графики отображаются
- ✅ Таблицы заполнены

---

## ✅ ЧЕК-ЛИСТ ТЕСТИРОВАНИЯ

### Базовые тесты:

- [ ] organize-root.ps1 -WhatIf выполняется без ошибок
- [ ] full-file-audit.ps1 создаёт отчёт
- [ ] build-knowledge-graph.ps1 строит граф
- [ ] calculate-kb-metrics.ps1 считает метрики
- [ ] AUDIT_ALL.ps1 запускает все скрипты
- [ ] Dashboard открывается в браузере

### Тесты данных:

- [ ] JSON файлы валидны (проверить через jsonlint.com)
- [ ] Mermaid диаграмма рендерится
- [ ] Chart.js графики работают
- [ ] Таблицы заполнены данными

### Тесты производительности:

- [ ] Полный аудит занимает < 5 минут (на тестовых данных)
- [ ] Dashboard загружается < 3 секунд
- [ ] Нет утечек памяти

---

## 🐛 ОТЛАДКА

### Проблема: Скрипт не запускается

**Решение:**
```powershell
# Проверить политику выполнения
Get-ExecutionPolicy

# Если Restricted, разрешить скрипты
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Повторить запуск
.\scripts\AUDIT_ALL.ps1
```

---

### Проблема: Dashboard не загружает данные

**Решение:**
1. Проверить наличие JSON файлов:
   ```powershell
   Get-ChildItem reports\*.json
   ```

2. Проверить консоль браузера (F12 → Console)

3. Убедиться, что файлы не заблокированы:
   ```powershell
   Unblock-File -Path reports\kb_metrics.json
   Unblock-File -Path reports\knowledge_graph.json
   ```

---

### Проблема: Ошибка в скрипте

**Решение:**
```powershell
# Запуск с подробным логом
.\scripts\full-file-audit.ps1 -Path ".\KNOWLEDGE_BASE" -Verbose -Debug

# Проверить переменные
$Error[0] | Format-List * -Force
```

---

## 📊 КРИТЕРИИ УСПЕХА

### ✅ Все тесты пройдены, если:

1. Все 6 скриптов выполняются без ошибок
2. Отчёты генерируются в `reports/`
3. Dashboard отображает данные
4. Нет ошибок в консоли браузера
5. JSON файлы валидны

---

## 📝 СЛЕДУЮЩИЕ ШАГИ

### После успешного тестирования:

1. **Запуск в основной базе:**
   ```powershell
   cd D:\QwenPoekt\Base
   .\scripts\AUDIT_ALL.ps1 -Path "."
   ```

2. **Проверка результатов:**
   - Открыть `reports/MASTER_AUDIT_REPORT.md`
   - Открыть `reports/KB_DASHBOARD.html`

3. **Документирование:**
   - Добавить результаты в `reports/TEST_SUCCESS_MARKER.md`
   - Обновить `README.md`

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [`03-Resources/PowerShell/AUDIT_ALL.ps1`](./03-Resources/PowerShell/AUDIT_ALL.ps1) — Главный скрипт
- [`03-Resources/PowerShell/organize-root.ps1`](./03-Resources/PowerShell/organize-root.ps1) — Организация корня
- [`reports/KB_DASHBOARD.html`](./reports/KB_DASHBOARD.html) — Dashboard
- [`02-Areas/Documentation/VS_CODE_SETUP_FOR_AI.md`](./02-Areas/Documentation/VS_CODE_SETUP_FOR_AI.md) — Настройка VS Code

---

**Файл создан:** 2 марта 2026 г.  
**Готов к тестированию:** ✅

