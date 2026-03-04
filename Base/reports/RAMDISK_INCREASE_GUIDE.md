# 🔧 УВЕЛИЧЕНИЕ RAM ДИСКА — ИНСТРУКЦИЯ

**Дата:** 4 марта 2026 г.  
**Проблема:** R:\Temp переполнен (0 bytes free)

---

## 📊 ТЕКУЩЕЕ СОСТОЯНИЕ

```
R:\Temp: 0 bytes free
%TEMP%: R:\Temp
```

**Проблема:** pip не может установить зависимости (требуется ~2 GB временно)

---

## 🛠️ РЕШЕНИЕ 1: Увеличить RAM диск (рекомендуется)

### Через ImDisk Toolkit:

1. **Открыть ImDisk** (системный трей → ImDisk icon)
2. **Правой кнопкой** → "Change size of existing disk"
3. **Выбрать R:** → Next
4. **Новый размер:** 4096 MB (4 GB) или 8192 MB (8 GB)
5. **Finish** → Перезагрузка не требуется

### Через командную строку (администратор):

```cmd
# Удалить текущий
imdisk -D -m R:

# Создать новый 4GB
imdisk -a -s 4096M -m R: -p "/fs:ntfs"
```

---

## 🛠️ РЕШЕНИЕ 2: Временная смена TEMP

**Временно изменить %TEMP% на системный диск:**

```powershell
# В текущей сессии PowerShell
$env:TEMP = "$env:USERPROFILE\AppData\Local\Temp"
$env:TMP = "$env:USERPROFILE\AppData\Local\Temp"

# Проверка
echo $env:TEMP
# Должно показать: C:\Users\Jackal\AppData\Local\Temp

# Установка зависимостей
pip install chromadb sentence-transformers markdown chardet

# Запуск векторизации
python 03-Resources/AI/vectorize-kb.py
```

---

## 🛠️ РЕШЕНИЕ 3: Очистка + пересоздание

```powershell
# 1. Очистить R:\Temp полностью
Remove-Item R:\Temp\* -Recurse -Force

# 2. Пересоздать RAM диск (если ImDisk)
imdisk -D -m R:
imdisk -a -s 4096M -m R: -p "/fs:ntfs"

# 3. Проверить
dir R:\
```

---

## ✅ ПРОВЕРКА

```powershell
# Проверка места
Get-PSDrive R

# Проверка TEMP
echo $env:TEMP

# Тест установки
pip install chardet --dry-run
```

---

## 📋 СЛЕДУЮЩИЕ ШАГИ

После увеличения RAM диска:

```powershell
# 1. Активировать новый TEMP
$env:TEMP = "R:\Temp"

# 2. Установить зависимости
pip install -r 03-Resources/AI/requirements-vector-db.txt

# 3. Запустить векторизацию
python 03-Resources/AI/vectorize-kb.py
```

---

**Рекомендация:** Увеличить до 4-8 GB для комфортной работы.
