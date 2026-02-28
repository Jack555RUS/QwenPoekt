================================================================================
                    АВТОМАТИЧЕСКАЯ СБОРКА В DOCKER
                         DragRaceUnity v1.0
================================================================================
Дата: 2026-02-27 21:00

ОПИСАНИЕ:
  Автоматический цикл: Сборка → Проверка логов → Исправление → Повтор

СКРИПТЫ:

1. docker/scripts/unity-auto-build.ps1 (PowerShell)
   Использование:
     .\docker\scripts\unity-auto-build.ps1 [-MaxIterations 3] [-Verbose]

2. docker/scripts/unity-auto-build.bat (Windows)
   Использование:
     .\docker\scripts\unity-auto-build.bat

3. docker/scripts/unity-auto-build.sh (Linux/WSL)
   Использование:
     ./docker/scripts/unity-auto-build.sh

ТРЕБОВАНИЯ:

1. Docker Desktop
2. Переменные окружения:
   - UNITY_EMAIL
   - UNITY_PASSWORD
   - UNITY_LICENSE (опционально)

УСТАНОВКА ПЕРЕМЕННЫХ:

Windows (PowerShell):
  [Environment]::SetEnvironmentVariable("UNITY_EMAIL", "your@email.com", "User")
  [Environment]::SetEnvironmentVariable("UNITY_PASSWORD", "password", "User")

Linux/Mac:
  export UNITY_EMAIL="your@email.com"
  export UNITY_PASSWORD="password"

РАБОЧИЙ ПРОЦЕСС:

1. Очистка логов
   ↓
2. Сборка в Docker
   ↓
3. Проверка build.log на ошибки
   ↓
4. Если есть ошибки:
   - Автоматическое исправление
   - Повтор сборки (до MaxIterations)
   ↓
5. Если ошибок нет → УСПЕХ

АВТОМАТИЧЕСКИЕ ИСПРАВЛЕНИЯ:

✅ Input.GetKey → UnityEngine.Input.GetKey
✅ Logger конфликт → using Logger = ProbMenu.Core.Logger
⏳ NUnit → Пропуск (требуется пакет Unity)

ПРИМЕР ИСПОЛЬЗОВАНИЯ:

# Быстрая сборка
.\docker\scripts\unity-auto-build.bat

# Сборка с параметрами
powershell -File .\docker\scripts\unity-auto-build.ps1 -MaxIterations 5 -Verbose

# Просмотр логов
Get-Content .\Builds\build.log -Tail 50

ОТЧЁТНОСТЬ:

После сборки создаётся:
  - Builds/DragRace/DragRace.exe (при успехе)
  - Builds/build.log (лог сборки)
  - DragRaceUnity/Logs/*.log (логи Unity)

УСТРАНЕНИЕ НЕИСПРАВНОСТЕЙ:

1. Ошибка Docker:
   → Проверьте, что Docker запущен
   → docker --version

2. Ошибка лицензии Unity:
   → Проверьте UNITY_EMAIL и UNITY_PASSWORD
   → Получите лицензию на https://store.unity.com

3. Ошибка сборки:
   → Проверьте Builds/build.log
   → Запустите с -MaxIterations 5

================================================================================
АВТОМАТИЗАЦИЯ ГОТОВА!
================================================================================

Запустите: .\docker\scripts\unity-auto-build.bat
