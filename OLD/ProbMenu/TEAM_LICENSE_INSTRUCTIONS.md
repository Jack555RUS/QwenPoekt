# 📖 Инструкция по активации лицензии Unity
**Для команды разработки DragRace**

---

## 🔑 Типы лицензий Unity

| Тип | Для кого | Активация | Docker |
|-----|----------|-----------|--------|
| **Personal** | Физлица, доход < $100K | Онлайн (email+пароль) | ❌ Нет |
| **Pro** | Компании, доход > $100K | Сервер лицензий | ✅ Да |
| **Enterprise** | Крупные компании | Сервер лицензий | ✅ Да |

---

## 📋 Шаг 1: Получение лицензии

### Вариант А: Unity Personal (бесплатно)

1. **Перейдите на:** https://store.unity.com/download
2. **Нажмите:** "Get Started" → "Unity Personal"
3. **Создайте аккаунт Unity** (или войдите)
4. **Скачайте Unity Hub**
5. **Установите Unity Hub**
6. **Активируйте Personal лицензию** в настройках

### Вариант Б: Unity Pro (платно)

1. **Перейдите на:** https://unity.com/products/unity-pro
2. **Выберите тариф:** Pro / Enterprise
3. **Оплатите подписку**
4. **Получите Serial Key** в Unity Dashboard
5. **Активируйте** через Unity Hub

---

## 🔐 Шаг 2: Активация в Unity Editor

### Для Personal лицензии:

1. **Откройте Unity Hub**
2. **Settings** → **License Management**
3. **Add** → **Activate License**
4. **Введите email и пароль** от аккаунта Unity
5. **Пройдите 2FA** (если включена)
6. **Готово!** ✅

### Для Pro лицензии:

1. **Откройте Unity Hub**
2. **Settings** → **License Management**
3. **Add** → **Activate License**
4. **Введите Serial Key** (формат: `XXXX-XXXX-XXXX-XXXX-XXXX`)
5. **Готово!** ✅

---

## 🐳 Шаг 3: Активация для Docker (только Pro/Enterprise)

### Настройка Unity License Server:

1. **Установите Unity License Server** на отдельный сервер:
   ```bash
   # Windows Server
   msiexec /i UnityLicenseServer.msi /quiet
   
   # Linux
   sudo dpkg -i UnityLicenseServer.deb
   ```

2. **Активируйте сервер:**
   ```bash
   UnityLicenseServer.exe --activate --serial=XXXX-XXXX-XXXX-XXXX-XXXX
   ```

3. **Настройте Docker:**
   ```yaml
   # docker-compose.yml
   services:
     unity-builder:
       environment:
         - UNITY_LICENSE_SERVER=license-server.local:27000
   ```

### Для Personal лицензии (ограничено):

**Personal лицензии НЕ работают в Docker!** 

Альтернативы:
1. ✅ Сборка на Windows VM
2. ✅ GitHub Actions / GitLab CI
3. ✅ Выделенный Windows сервер для сборок

---

## 🔧 Шаг 4: Настройка для CI/CD

### GitHub Actions:

1. **Добавьте секреты в репозиторий:**
   ```
   Settings → Secrets and variables → Actions → New repository secret
   
   UNITY_EMAIL = jackal555rus@gmail.com
   UNITY_PASSWORD = ваш-пароль
   ```

2. **Создайте workflow файл:** `.github/workflows/unity-build.yml`

3. **Запустите сборку:**
   ```
   Actions → Unity Build → Run workflow
   ```

### GitLab CI:

1. **Добавьте переменные:**
   ```
   Settings → CI/CD → Variables
   
   UNITY_EMAIL = jackal555rus@gmail.com
   UNITY_PASSWORD = ваш-пароль
   ```

2. **Создайте .gitlab-ci.yml**

---

## 📁 Шаг 5: Проверка активации

### В Unity Editor:

1. **Help** → **About Unity**
2. **Проверьте:**
   - ✅ License Type: Personal / Pro
   - ✅ Serial: XXXX-XXXX-XXXX-XXXX-XXXX
   - ✅ Expiration: Unlimited / Дата

### В командной строке:

```bash
# Windows
powershell -Command "& 'C:\Program Files\Unity\Hub\Editor\6000.3.10f1\Editor\Unity.exe' -batchmode -nographics -quit -logFile license-check.log"

Get-Content license-check.log | Select-String "License|Pro|Personal"
```

### В Docker:

```bash
docker-compose --profile unity run unity-builder cat /unity-license.ulf
```

---

## ⚠️ Частые проблемы

### Ошибка: "No valid Unity Editor license found"

**Причина:** Лицензия не активирована или истекла

**Решение:**
1. Откройте Unity Hub
2. Settings → License Management
3. Deactivate → Activate снова
4. Введите учётные данные

---

### Ошибка: "Failed to login - please check your username or password"

**Причина:** Неверный email/пароль или 2FA

**Решение:**
1. Проверьте email и пароль
2. Если включена 2FA, используйте код из приложения
3. Или создайте Personal Access Token

---

### Ошибка: "Personal licenses cannot be activated manually"

**Причина:** Unity отменила ручную активацию для Personal

**Решение:**
1. Используйте онлайн активацию (email+пароль)
2. Для Docker используйте Windows VM или CI/CD

---

### Ошибка: "Serial number is already in use"

**Причина:** License используется на другом компьютере

**Решение:**
1. Unity Dashboard → License Management
2. Deactivate на старом устройстве
3. Activate на новом

---

## 📞 Поддержка

### Контакты команды:

| Роль | Email | Telegram |
|------|-------|----------|
| **Lead Developer** | jackal555rus@gmail.com | @jackal555 |
| **Unity Admin** | [добавить] | [добавить] |
| **DevOps** | [добавить] | [добавить] |

### Полезные ссылки:

- 📚 [Unity License Documentation](https://docs.unity3d.com/Manual/LicensesAndActivation.html)
- 🛒 [Unity Store](https://store.unity.com/)
- 🔑 [License Portal](https://license.unity3d.com/manual)
- 💬 [Unity Forum](https://forum.unity.com/)
- 🐛 [Unity Bug Reporter](https://unity3d.com/unity/qa/bug-reporting)

---

## 📝 Чек-лист для нового разработчика

- [ ] Создать аккаунт на unity.com
- [ ] Скачать и установить Unity Hub
- [ ] Активировать лицензию (Personal или Pro)
- [ ] Установить Unity Editor 6000.3.10f1
- [ ] Установить необходимые модули
- [ ] Клонировать репозиторий проекта
- [ ] Открыть проект в Unity
- [ ] Проверить сборку (File → Build Settings → Build)

---

## 🎯 Быстрый старт

### 1. Установка Unity:
```bash
# Скачать Unity Hub
winget install Unity.UnityHub

# Или вручную: https://unity.com/download
```

### 2. Активация:
```
Unity Hub → Settings → License Management → Add → Activate License
Email: jackal555rus@gmail.com
Password: [ваш пароль]
```

### 3. Установка редактора:
```
Unity Hub → Installs → Install Editor → 6000.3.10f1
Modules: Android Build Support, IL2CPP
```

### 4. Клонирование проекта:
```bash
git clone https://github.com/your-org/DragRace.git
cd DragRace/DragRaceUnity
```

### 5. Открытие проекта:
```
Unity Hub → Projects → Add → Выбрать папку DragRaceUnity
```

---

**Последнее обновление:** 27 февраля 2026 г.  
**Версия документа:** 1.0  
**Статус:** Актуально для Unity 6000.3.x
