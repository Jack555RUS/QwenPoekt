---
title: Powershell Ampersand Fix
version: 1.0
date: 2026-03-04
status: draft
---
# PowerShell ampersand error fix

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готово

---

## 🔴 ПРОБЛЕМА

Ошибка при использовании `&` (ampersand) в PowerShell:

```
& : The term '...' is not recognized
```

---

## 🎯 ПРИЧИНА

PowerShell интерпретирует `&` как оператор вызова команды.

---

## ✅ РЕШЕНИЯ

### Решение 1: Кавычки

**Неправильно:**
```powershell
python script.py & arg1
```

**Правильно:**
```powershell
python "script.py" "arg1"
```

---

### Решение 2: Оператор вызова

**Используйте `&` правильно:**
```powershell
& "C:\Path\To\Script.ps1" -Argument "value"
```

---

### Решение 3: Escape символ

**Экранирование:**
```powershell
python script.py `& arg1
```

---

## 📋 ПРИМЕРЫ

### Запуск скрипта с путём:

```powershell
# ❌ Ошибка
& C:\Scripts\script.ps1

# ✅ Правильно
& "C:\Scripts\script.ps1"
```

### Передача аргументов:

```powershell
# ❌ Ошибка
python script.py & -arg1 value

# ✅ Правильно
python "script.py" -arg1 "value"
```

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [qwen_cli.md](../02_TOOLS/qwen_cli.md) — Qwen CLI
- [csharp_silent_testing.md](../00_CORE/csharp_silent_testing.md) — Тесты

---

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готово


