---
title: Unity Docker Builder
version: 1.0
date: 2026-03-04
status: draft
---
# Unity Builder в Docker для Unity 6000

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готово

---

## 🎯 НАЗНАЧЕНИЕ

Сборка Unity проектов в Docker контейнере для Unity 6000.

---

## ⚠️ ПРОБЛЕМА С GAMECI

**Официальные образы GameCI** (`unityci/editor`) **не поддерживают Unity 6000**.

**Причина:** Образы для 6000.0.3f1+ отсутствуют в репозитории.

---

## ✅ РАБОЧАЯ АЛЬТЕРНАТИВА

**Образы от сообщества:** `lachee/unity-runner`

**Поддержка:** Unity 6000.0.35f1

---

## 📊 ДОСТУПНЫЕ ОБРАЗЫ

| Платформа | Размер | Тег |
|-----------|--------|-----|
| **Все платформы** | ~15.40 GB | `lachee/unity-runner:6000.0.35f1-all-runner` |
| **Android** | ~12.39 GB | `lachee/unity-runner:6000.0.35f1-android-runner` |
| **iOS** | ~10.47 GB | `lachee/unity-runner:6000.0.35f1-ios-runner` |
| **Linux (IL2CPP)** | ~10.58 GB | `lachee/unity-runner:6000.0.35f1-linux-il2cpp-runner` |
| **Mac (Mono)** | ~10.70 GB | `lachee/unity-runner:6000.0.35f1-mac-mono-runner` |
| **WebGL** | ~11.60 GB | `lachee/unity-runner:6000.0.35f1-webgl-runner` |
| **Windows (Mono)** | ~11.07 GB | `lachee/unity-runner:6000.0.35f1-windows-mono-runner` |

---

## 🐳 ПРИМЕР ЗАПУСКА

### Сборка под Windows:

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

**Параметры:**
- `--rm` — удалить контейнер после завершения
- `-v ...` — смонтировать проект и лицензию
- `-batchmode` — пакетный режим
- `-licenseFile` — файл лицензии (.ulf)
- `-buildWindows64Player` — путь к выходному EXE

---

## ⚠️ ВАЖНЫЕ МОМЕНТЫ

### 1. Лицензия

**Unity Personal:**
- ✅ Активация через Unity Hub
- ❌ Нет офлайн-активации
- ⚠️ Требуется файл `.ulf` из `C:\ProgramData\Unity\`

### 2. Размер образов

**10-15 GB** — учитывайте место на диске!

### 3. Unity Accelerator

**Не путать!** Unity Accelerator через Docker — это кэширование ассетов, **не сборка проектов**.

---

## 🔗 СВЯЗАННЫЕ ФАЙЛЫ

- [unity_personal_license.md](unity_personal_license.md) — Лицензия Unity
- [qwen_vscode_setup.md](../02_TOOLS/qwen_vscode_setup.md) — Настройка Qwen
- [csharp_silent_testing.md](../00_CORE/csharp_silent_testing.md) — Тесты C#

---

**Версия:** 1.0  
**Дата:** 2026-03-02  
**Статус:** ✅ Готово


