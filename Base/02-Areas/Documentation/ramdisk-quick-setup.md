# ⚡ БЫСТРАЯ УСТАНОВКА RAM ДИСКА

**Время:** 5 минут  
**Приоритет:** 🟢 Низкий (опционально, но рекомендуется)

---

## 📥 ШАГ 1: СКАЧАТЬ IMDISK

**Ссылка:** https://sourceforge.net/projects/imdisk-toolkit/

1. Откройте ссылку в браузере
2. Нажмите **Download**
3. Сохраните `ImDiskToolkit.exe` в `Downloads`

---

## 🔧 ШАГ 2: УСТАНОВИТЬ

1. Запустите `ImDiskToolkit.exe`
2. ✅ Принять лицензию
3. ✅ Установить **ImDisk Virtual Disk Driver**
4. ✅ Установить **ImDisk Toolkit**
5. **Перезагрузить компьютер**

---

## 🚀 ШАГ 3: СОЗДАТЬ RAM ДИСК

**После перезагрузки:**

```powershell
cd D:\QwenPoekt\Base\scripts
.\install-ramdisk.ps1
```

**Или вручную:**

1. Пуск → ImDisk → **Create Ram Disk**
2. Размер: **16384 MB** (16 GB)
3. Буква: **R:**
4. Файловая система: **NTFS**
5. ✅ **Format now**
6. **OK**

---

## ✅ ШАГ 4: ПРОВЕРИТЬ

```powershell
# Проверить диск
Get-Volume | Where-Object DriveLetter -EQ 'R'

# Проверить TEMP
echo $env:TEMP

# Должно быть: R:\Temp
```

---

## 📊 РЕЗУЛЬТАТ

| Метрика | Значение |
|---------|----------|
| **Диск** | R: |
| **Размер** | 16 GB |
| **Скорость** | ~20000 MB/s |
| **Время доступа** | ~0.0001 ms |

---

## 🔄 АВТОМАТИЧЕСКАЯ ОЧИСТКА

**Скрипт уже создан:** `03-Resources/PowerShell/cleanup-ramdisk.ps1`

**Для автоматической очистки при выключении:**

1. Win+R → `taskschd.msc`
2. Create Task → Name: `Cleanup-RAMDisk`
3. Trigger: **At log off**
4. Action: `powershell.exe -File D:\QwenPoekt\Base\scripts\cleanup-ramdisk.ps1`
5. ✅ Run with highest privileges

---

## ⚠️ ВАЖНО

- **Не сохраняйте** важные файлы на R:
- Все данные **удаляются** при выключении
- Используйте только для **кэша и временных файлов**

---

**Готово!** 🎉

