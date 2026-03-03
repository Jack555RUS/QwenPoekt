# 📋 PARA ВНЕДРЕНИЕ: НЕДЕЛЯ 2 — РАСПРЕДЕЛЕНИЕ ФАЙЛОВ

**Версия:** 1.0
**Дата:** 3 марта 2026 г.
**Статус:** ⏳ **В процессе**

---

## 📊 **ТЕКУЩЕЕ СОСТОЯНИЕ**

| Папка | Файлов | Статус |
|-------|--------|--------|
| **01-Projects/** | 0 | ✅ Пусто |
| **02-Areas/** | 1 | ✅ para-structure-guide.md |
| **03-Resources/** | 80 | ✅ PowerShell (76), AI, Knowledge, BOOKS, CSharp, Unity |
| **04-Archives/** | 0 | ✅ Пусто |
| **03-Resources/PowerShell/** | 6 | ⏳ Остались .bat, .js |
| **reports/** | 55 | ⏳ Нужно распределить |
| **02-Areas/Documentation/** | 60 | ⏳ Нужно распределить |
| **KNOWLEDGE_BASE/** | 25 | ⏳ Нужно распределить |

---

## ✅ **ВЫПОЛНЕНО (Неделя 2)**

### **Шаг 1: Scripts → Resources/PowerShell**

```
✅ Перемещено: 76 .ps1 файлов
📁 Путь: 03-Resources/PowerShell/
```

**Содержимое:**
- auto-save-chat.ps1
- start-session.ps1
- check-session-rules.ps1
- save-chat-log.ps1
- pre-change-backup.ps1
- ... (остальные 71 скрипт)

---

## ⏳ **ПЛАН (Неделя 2)**

### **Шаг 2: Reports (55 файлов)**

**Критерий:**
- < 30 дней → `03-Resources/Knowledge/`
- > 30 дней → `04-Archives/2026-02/`

**Действие:**
```powershell
# Актуальные отчёты (< 30 дней)
Get-ChildItem reports -File | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-30) } | Move-Item -Destination "03-Resources/Knowledge/"

# Старые отчёты (> 30 дней)
Get-ChildItem reports -File | Where-Object { $_.LastWriteTime -le (Get-Date).AddDays(-30) } | Move-Item -Destination "04-Archives/2026-02/"
```

---

### **Шаг 3: Docs (60 файлов)**

**Критерий:**
- Актуальная документация → `02-Areas/Documentation/`
- Справочные материалы → `03-Resources/Knowledge/`
- Устаревшее → `04-Archives/`

**Действие:**
```powershell
# Актуальная документация
Move-Item "02-Areas/Documentation/*.md" "02-Areas/Documentation/" -Exclude "*old*","*deprecated*"

# Справочные материалы
Move-Item "02-Areas/Documentation/*.md" "03-Resources/Knowledge/" -Include "*guide*","*reference*"

# Устаревшее
Move-Item "02-Areas/Documentation/*.md" "04-Archives/" -Include "*old*","*deprecated*"
```

---

### **Шаг 4: KNOWLEDGE_BASE (25 файлов)**

**Критерий:**
- Ядро базы → `03-Resources/Knowledge/`
- Устаревшее → `04-Archives/`

**Действие:**
```powershell
# Переместить всё в Resources
Move-Item "KNOWLEDGE_BASE/*" "03-Resources/Knowledge/" -Recurse

# Затем архивировать старое
Get-ChildItem "03-Resources/Knowledge" -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddMonths(-6) } | Move-Item -Destination "04-Archives/"
```

---

### **Шаг 5: BOOK и OLD (вне Base)**

**Критерий:**
- BOOK → `D:\QwenPoekt\BOOK\` (библиотека книг)
- OLD → `D:\QwenPoekt\OLD\` (архив проектов)

**Действие:**
```powershell
# Переместить BOOK
Move-Item "Base/BOOK" "D:\QwenPoekt\BOOK" -Force

# Переместить OLD
Move-Item "Base/OLD" "D:\QwenPoekt\OLD" -Force
```

**Почему вне Base:**
- Это не инструменты ИИ
- Огромный размер (41K + 40K файлов)
- Отдельное хранение

---

## 📊 **ОЖИДАЕМАЯ СТРУКТУРА (после Недели 2)**

```
D:\QwenPoekt\Base\
├── 01-Projects/          # 0 файлов (заполняется задачами)
├── 02-Areas/             # ~60 файлов (Documentation)
├── 03-Resources/         # ~200 файлов
│   ├── PowerShell/       # 76 скриптов
│   ├── Knowledge/        # ~100 файлов (отчёты, docs, KB)
│   ├── AI/               # ~10 файлов
│   ├── CSharp/           # ~5 файлов
│   ├── Unity/            # ~5 файлов
│   └── BOOKS/            # 1 файл (библиография)
├── 04-Archives/          # ~50 файлов (старое)
├── sessions/             # Автосохранение (отдельно)
└── 03-Resources/PowerShell/              # 6 файлов (.bat, .js)
```

---

## 📈 **МЕТРИКИ**

| Метрика | До | После | Цель |
|---------|-----|-------|------|
| **Файлов в Base/** | ~82K | ~250 | ✅ |
| **BOOK/OLD вне Base** | Нет | Да | ✅ |
| **Scripts в Resources** | 0 | 76 | ✅ |
| **Архив (>30 дней)** | 0% | 20% | 50% |

---

## ⚠️ **РИСКИ**

| Риск | Вероятность | Влияние | Митигация |
|------|-------------|---------|-----------|
| Потеря файлов | Низкая | Высокое | Бэкап перед перемещением |
| Битые ссылки | Средняя | Среднее | Обновить ссылки после |
| Конфликты имён | Низкая | Низкое | Переименовать при конфликте |

---

## 🔗 **СВЯЗАННЫЕ ФАЙЛЫ**

- [[para-structure-guide]]
- [[building-a-second-brain-summary]]
- [[information-processing-methods]]

---

**Следующий шаг:** Выполнить Шаги 2-5, закоммитить, протестировать поиск.

