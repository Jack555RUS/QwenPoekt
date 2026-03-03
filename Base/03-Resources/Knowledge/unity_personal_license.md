---
title: Unity Personal License
version: 1.0
date: 2026-03-04
status: draft
---
# Unity Personal лицензия — активация

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готово

---

## 🎯 НАЗНАЧЕНИЕ

Активация бесплатной лицензии Unity Personal для доходов <$200K/год.

---

## 📋 УСЛОВИЯ (2026)

| Параметр | Значение |
|----------|----------|
| **Доход** | < $200,000 USD/год |
| **Заставка** | Не требуется |
| **Runtime Fee** | Не взимается |

---

## 🔧 АКТИВАЦИЯ ЧЕРЕЗ UNITY HUB

### Пошаговая инструкция:

**1. Запустите Unity Hub**

**2. Войдите в аккаунт**
- Unity ID (или создайте новый)

**3. Перейдите в "Лицензии" (Licenses)**

**4. Нажмите "Добавить лицензию" (Add license)**

**5. Выберите "Получить бесплатную личную лицензию"**

**6. Примите условия и получите лицензию**

**Готово!** Лицензия активирована мгновенно.

---

## ⚠️ ВАЖНЫЕ ПРИМЕЧАНИЯ

### 1. Нет серийного номера

**Лицензия привязана к аккаунту**, не требуется ввод ключа.

### 2. Нет офлайн-активации

**Требуется интернет** для работы Personal лицензии.

**Для офлайн-режима:** Требуется Unity Pro.

### 3. Файл лицензии (.ulf)

**Расположение:**
```
C:\ProgramData\Unity\Unity_v5.x.ulf
```

**Использование:**
```bash
unity-editor -batchmode -licenseFile "C:\ProgramData\Unity\Unity_v2022.ulf"
```

---

## 🐳 ИСПОЛЬЗОВАНИЕ В DOCKER

### Пример для сборки:

```bash
docker run --rm \
  -v /путь/к/проекту:/project \
  -v /путь/к/лицензии.ulf:/license.ulf \
  lachee/unity-runner:6000.0.35f1-windows-mono-runner \
  unity-editor \
    -batchmode \
    -projectPath /project \
    -licenseFile /license.ulf \
    -buildWindows64Player /project/builds/game.exe \
    -quit
```

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [unity_docker_builder.md](unity_docker_builder.md) — Unity в Docker
- [qwen_vscode_setup.md](../02_TOOLS/qwen_vscode_setup.md) — Настройка Qwen

---

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готово


