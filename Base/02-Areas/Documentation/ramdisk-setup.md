# 📦 RAM ДИСК — РУКОВОДСТВО ПО УСТАНОВКЕ

**Версия:** 1.0  
**Дата:** 2 марта 2026 г.  
**Назначение:** Создание RAM диска 16 GB для временных файлов

---

## 🎯 ПРЕИМУЩЕСТВА

| Метрика | До | После | Прирост |
|---------|----|----|---------|
| **Скорость записи** | ~500 MB/s (SSD) | ~10000 MB/s (RAM) | **20x** |
| **Скорость чтения** | ~3000 MB/s (SSD) | ~20000 MB/s (RAM) | **7x** |
| **Время доступа** | ~0.1 ms | ~0.0001 ms | **1000x** |
| **Износ SSD** | Есть | ❌ Нет | **∞** |

---

## 📥 ВАРИАНТ 1: IMDISK TOOLKIT (РЕКОМЕНДУЕТСЯ)

### Шаг 1: Скачать

**Ссылка:** https://sourceforge.net/projects/imdisk-toolkit/

**Или через winget:**
```powershell
winget install ImDiskToolkit
```

---

### Шаг 2: Установить

1. Запустить установщик
2. Принять лицензию
3. Установить **ImDisk Virtual Disk Driver**
4. ✅ Установить **ImDisk Toolkit**
5. Перезагрузить компьютер

---

### Шаг 3: Создать RAM диск

**Автоматически (скрипт):**
```powershell
cd D:\QwenPoekt\Base\scripts
.\install-ramdisk.ps1 -AutoConfirm
```

**Вручную (GUI):**
1. Пуск → ImDisk → Create Ram Disk
2. Размер: **16384 MB** (16 GB)
3. Буква: **R:**
4. Файловая система: **NTFS**
5. ✅ Format now
6. OK

---

### Шаг 4: Настроить переменные среды

**Автоматически (скрипт):**
```powershell
.\install-ramdisk.ps1 -AutoConfirm
```

**Вручную:**
1. Панель управления → Система → Дополнительные параметры
2. Переменные среды
3. Изменить переменные пользователя:
   - `TEMP` = `R:\Temp`
   - `TMP` = `R:\Temp`

---

## 📦 ВАРИАНТ 2: SOFTPERFECT RAM DISK (АЛЬТЕРНАТИВА)

**Ссылка:** https://www.ramdisk.com/

**Преимущества:**
- ✅ Простой интерфейс
- ✅ Поддержка образов
- ✅ Автосохранение при выключении

**Недостатки:**
- ❌ Платная (есть trial)

---

## 📦 ВАРИАНТ 3: ARSOFT RAM DISK (БЕСПЛАТНО)

**Ссылка:** https://arsoft.eu/

**Преимущества:**
- ✅ Бесплатно
- ✅ Простой интерфейс

**Недостатки:**
- ❌ Меньше функций

---

## 🔧 НАСТРОЙКА ПОСЛЕ УСТАНОВКИ

### 1. Проверка

```powershell
# Проверить диск
Get-Volume | Where-Object DriveLetter -EQ 'R'

# Проверить переменные
echo $env:TEMP
echo $env:TMP
```

---

### 2. NPM кэш

```powershell
npm config set cache "R:\npm-cache"
npm config set prefix "R:\npm-global"
```

---

### 3. VS Code кэш

**Файл:** `.vscode/settings.json`

**Добавить:**
```json
{
    "typescript.tsserver.nodePath": "R:\\VSCode\\node",
    "dotnet.server.extensionPath": "R:\\VSCode\\dotnet"
}
```

---

### 4. Node.js кэш

**Файл:** `%APPDATA%\npm\package.json` (создать)

```json
{
  "cache": "R:\\npm-cache",
  "prefix": "R:\\npm-global"
}
```

---

## 🧹 ОЧИСТКА RAM ДИСКА

### Автоматически (при выключении)

**Скрипт:** `03-Resources/PowerShell/cleanup-ramdisk.ps1`

**Настройка Task Scheduler:**
1. Task Scheduler → Create Task
2. Name: `Cleanup-RAMDisk`
3. Trigger: At log off
4. Action: `powershell.exe -File D:\QwenPoekt\Base\scripts\cleanup-ramdisk.ps1`
5. ✅ Run with highest privileges

---

### Вручную

```powershell
# Очистить TEMP
Remove-Item "R:\Temp\*" -Recurse -Force

# Очистить NPM кэш
npm cache clean --force

# Очистить всё
Get-ChildItem "R:\" -Recurse | Where-Object FullName -ne "R:\Temp" | Remove-Item -Recurse -Force
```

---

## 📊 ОЖИДАЕМЫЙ ПРИРОСТ

| Операция | SSD | RAM диск | Прирост |
|----------|-----|----------|---------|
| **Создание временных файлов** | 100 ms | 1 ms | **100x** |
| **NPM install** | 30 сек | 10 сек | **3x** |
| **VS Code запуск** | 5 сек | 2 сек | **2.5x** |
| **Node.js сборка** | 60 сек | 20 сек | **3x** |
| **Git операции** | 500 ms | 100 ms | **5x** |

---

## ⚠️ ВАЖНЫЕ ПРЕДУПРЕЖДЕНИЯ

### ❌ НЕ сохранять на RAM диске:

- Важные документы
- Исходный код
- Проекты
- Настройки

**Причина:** Все данные удаляются при выключении!

---

### ✅ МОЖНО сохранять на RAM диске:

- Временные файлы
- Кэш NPM
- Кэш Node.js
- Кэш VS Code
- Логи
- Build артефакты

---

## 🔄 ВОССТАНОВЛЕНИЕ ПОСЛЕ ПЕРЕЗАГРУЗКИ

**Скрипт:** `03-Resources/PowerShell/restore-ramdisk.ps1` (будет создан)

**Автоматически:**
1. Task Scheduler → Create Task
2. Name: `Restore-RAMDisk`
3. Trigger: At log on
4. Action: `powershell.exe -File D:\QwenPoekt\Base\scripts\restore-ramdisk.ps1`

---

## 📋 ЧЕК-ЛИСТ УСТАНОВКИ

```markdown
[ ] 1. Установлен ImDisk Toolkit
[ ] 2. Создан RAM диск R: (16 GB)
[ ] 3. Переменные TEMP/TMP настроены
[ ] 4. NPM кэш перемещён
[ ] 5. Скрипт очистки создан
[ ] 6. Task Scheduler настроен
```

---

## 🎯 БЫСТРАЯ УСТАНОВКА (5 МИНУТ)

```powershell
# 1. Установить ImDisk
winget install ImDiskToolkit --silent

# 2. Перезагрузить компьютер
shutdown /r /t 0

# 3. После перезагрузки создать RAM диск
cd D:\QwenPoekt\Base\scripts
.\install-ramdisk.ps1 -AutoConfirm

# 4. Проверить
echo $env:TEMP
Get-Volume | Where-Object DriveLetter -EQ 'R'
```

---

**Файл создан:** 2 марта 2026 г.  
**Следующее действие:** Установить ImDisk и запустить скрипт

