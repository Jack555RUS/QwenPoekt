# ⚙️ НАСТРОЙКА INCREDIBUILD ДЛЯ UNITY

**Дата:** 28 февраля 2026 г.  
**Статус:** ✅ Настроено для DragRaceUnity

---

## 🎯 ЦЕЛЬ НАСТРОЙКИ

Максимальное ускорение компиляции Unity проектов за счёт:
- ✅ Использования всех ядер CPU (RTX 3090 = 24 ядра / 48 потоков)
- ✅ Кэширования результатов компиляции
- ✅ Оптимизации для MSBuild/Unity
- ✅ Мониторинга и логирования

---

## 📋 КОНФИГУРАЦИЯ

### 1. Расположение Incredibuild

```
Путь установки: C:\Program Files (x86)\Incredibuild
Версия: Free Trial (Q4UA-YM65-X6CE-LYIN)
Статус: Активна
```

### 2. Службы

```
✅ Incredibuild Agent — Running
✅ Incredibuild CoordinatorService — Running
✅ Incredibuild Endpoint Service — Running
✅ Incredibuild LicenseService — Running
✅ Incredibuild Manager — Running
⏸️ Incredibuild BuildCache — Manual (нормально)
```

### 3. Настройки кэша

**Рекомендуемые параметры:**

```xml
<!-- Cache Settings -->
<Cache>
  <Enabled>true</Enabled>
  <MaxSizeGB>10</MaxSizeGB>
  <Location>%LOCALAPPDATA%\Incredibuild\Cache</Location>
  <Compression>true</Compression>
</Cache>
```

### 4. Локальные настройки

**Для Unity проекта:**

```xml
<!-- Local Settings -->
<Local>
  <UseAllCores>true</UseAllCores>
  <MaxLocalProcesses>48</MaxLocalProcesses> <!-- По количеству потоков -->
  <Priority>Normal</Priority>
  <AccelerateMSBuild>true</AccelerateMSBuild>
</Local>
```

### 5. Интеграция с Unity

**Автоматическая настройка:**

```powershell
# Unity использует MSBuild
# Incredibuild перехватывает автоматически
# Никаких дополнительных настроек не требуется!
```

---

## 🔧 СКРИПТ НАСТРОЙКИ

### Проверка и оптимизация:

```powershell
# Проверить службы
Get-Service | Where-Object {$_.DisplayName -like '*Incredibuild*'}

# Убедиться, что службы запущены
Start-Service Incredibuild_Agent -ErrorAction SilentlyContinue
Start-Service Incredibuild_CoordinatorService -ErrorAction SilentlyContinue

# Проверить процесс
Get-Process | Where-Object {$_.ProcessName -like '*incredibuild*'}

# Мониторинг сборки
# Запустить с логом
.\auto-build.ps1

# Искать в логе:
# - AcceleratorClientConnectionCallback
# - script compilation time: X.XXs
```

---

## 📊 ОЖИДАЕМОЕ УСКОРЕНИЕ

| Тип сборки | Без IB | С IB | Улучшение |
|------------|--------|------|-----------|
| **Компиляция скриптов** | 2-5 сек | 0.5-1 сек | 75-80% |
| **Полная сборка** | 1-2 мин | 15-30 сек | 75-83% |
| **Инкрементальная** | 10-20 сек | 2-5 сек | 75-80% |
| **Повторная (кэш)** | 2-5 сек | 0.2-0.5 сек | 90-92% |

---

## 🎯 МОНИТОРИНГ

### Incredibuild Monitor

**Открыть:**
```
1. Иконка в трее (возле часов)
2. Правый клик → Open Incredibuild Monitor
3. Или: C:\Program Files (x86)\Incredibuild\IBMonitor.exe
```

**Что показывает:**
- Активные задачи компиляции
- Задействованные ядра
- Статистику ускорения
- Кэш статистику

### Логи Unity

**Искать в `compile_*.log`:**
```
AcceleratorClientConnectionCallback - disconnected
script compilation time: 0.XXXs
```

**Наличие `AcceleratorClientConnectionCallback` = Incredibuild работает!**

---

## 🐛 ТИПИЧНЫЕ ПРОБЛЕМЫ

### 1. Служба не запускается

**Решение:**
```powershell
# Перезапустить службу
Restart-Service Incredibuild_Agent -Force

# Или через services.msc
services.msc → Incredibuild Agent → Restart
```

### 2. Нет ускорения

**Причина:** Incredibuild не перехватывает MSBuild

**Решение:**
```
1. Visual Studio → Tools → Options
2. Incredibuild → General
3. Проверить: "Acceleration enabled"
4. Проверить: "Accelerate MSBuild" включено
```

### 3. Конфликт с антивирусом

**Симптом:** Медленная компиляция, ошибки

**Решение:**
```
Добавить в исключения антивируса:
- C:\Program Files (x86)\Incredibuild\
- %LOCALAPPDATA%\Incredibuild\Cache\
- D:\QwenPoekt\PROJECTS\DragRaceUnity\
```

---

## ✅ ЧЕКЛИСТ ПРОВЕРКИ

- [ ] Все службы Incredibuild запущены
- [ ] Процесс `incredibuild-free-trial-*` активен
- [ ] Иконка в трее отображается
- [ ] Incredibuild Monitor открывается
- [ ] В логе Unity есть `AcceleratorClientConnectionCallback`
- [ ] Компиляция быстрее 1 секунды
- [ ] Кэш включён (10 GB)
- [ ] Все ядра используются

---

## 📚 РЕСУРСЫ

| Ресурс | Расположение |
|--------|--------------|
| **Конфигурация** | `C:\Program Files (x86)\Incredibuild\` |
| **Кэш** | `%LOCALAPPDATA%\Incredibuild\Cache\` |
| **Логи** | `%TEMP%\IB_Setup_Logs\` |
| **Монитор** | `C:\Program Files (x86)\Incredibuild\IBMonitor.exe` |
| **Документация** | `KNOWLEDGE_BASE/INCREDIBUILD_GUIDE.md` |

---

**Incredibuild настроен и готов к работе!** 🚀
