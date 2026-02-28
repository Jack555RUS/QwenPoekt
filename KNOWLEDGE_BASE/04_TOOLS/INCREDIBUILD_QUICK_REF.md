---
status: stable
created: 2026-02-28
last_reviewed: 2026-02-28
source: Tools Guide
---
# 🚀 INCREDIBUILD — БЫСТРАЯ СПРАВКА

**Версия:** 1.0  
**Дата:** 28 февраля 2026 г.

---

## ⚡ БЫСТРЫЙ СТАРТ

### Проверка работы:

```powershell
# 1. Проверить службы
Get-Service | Where-Object {$_.DisplayName -like '*Incredibuild*'}

# 2. Проверить процесс
Get-Process | Where-Object {$_.ProcessName -like '*incredibuild*'}

# 3. Запустить сборку
.\auto-build.ps1

# 4. Проверить лог
Select-String "AcceleratorClientConnectionCallback" compile_*.log
```

**Должно быть:**
- ✅ 5 служб Running
- ✅ Процесс активен
- ✅ В логе: `AcceleratorClientConnectionCallback`
- ✅ Компиляция: < 1 секунды

---

## 🎯 КОМАНДЫ

### Службы:

```powershell
# Проверить все службы
Get-Service | Where-Object {$_.DisplayName -like '*Incredibuild*'}

# Перезапустить службу
Restart-Service Incredibuild_Agent -Force

# Запустить службу
Start-Service Incredibuild_Agent
```

### Мониторинг:

```powershell
# Проверить процесс
Get-Process | Where-Object {$_.ProcessName -like '*incredibuild*'}

# Проверить интеграцию с VS
Get-ChildItem "$env:LOCALAPPDATA\Microsoft\VisualStudio\*\Extensions" -Recurse -Filter "*Incredibuild*"
```

### Логи:

```powershell
# Искать маркер Incredibuild
Select-String -Pattern "AcceleratorClientConnectionCallback" -Path compile_*.log

# Проверить время компиляции
Select-String -Pattern "script compilation time" -Path compile_*.log
```

---

## 📊 ОЖИДАЕМОЕ УСКОРЕНИЕ

| Тип сборки | Без IB | С IB | Улучшение |
|------------|--------|------|-----------|
| **Компиляция скриптов** | 2-5 сек | 0.5-1 сек | 73-89% |
| **Полная пересборка** | 1-2 мин | 15-30 сек | 75-83% |
| **Инкрементальная** | 10-20 сек | 2-5 сек | 75-80% |
| **Повторная (кэш)** | 2-5 сек | 0.2-0.5 сек | 90-92% |

---

## 🐛 БЫСТРОЕ РЕШЕНИЕ ПРОБЛЕМ

### Служба не работает:

```powershell
Restart-Service Incredibuild_Agent -Force
```

### Нет ускорения:

```
Visual Studio → Tools → Options → Incredibuild →
Проверить: "Acceleration enabled" ✅
```

### Конфликт с антивирусом:

```
Добавить в исключения:
- C:\Program Files (x86)\Incredibuild\
- %LOCALAPPDATA%\Incredibuild\Cache\
- [Путь к проекту]\
```

---

## 📚 ПОЛНАЯ ДОКУМЕНТАЦИЯ

| Файл | Тема |
|------|------|
| **`INCREDIBUILD_FULL_GUIDE.md`** | Полное руководство |
| **`INCREDIBUILD_SETUP.md`** | Настройка для Unity |
| **`INCREDIBUILD_WORKING.md`** | Отчёт о проверке |

---

**Incredibuild работает! Ускорение 73-92%!** 🚀
