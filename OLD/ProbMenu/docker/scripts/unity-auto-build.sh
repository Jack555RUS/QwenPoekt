#!/bin/bash
# Автоматическая сборка Unity проекта в Docker (Linux/WSL)

set -e

echo "============================================================================="
echo "Автоматическая сборка Unity в Docker"
echo "============================================================================="
echo ""

# Проверка переменных окружения
if [ -z "$UNITY_EMAIL" ]; then
    echo "ОШИБКА: UNITY_EMAIL не установлен"
    echo "Установите: export UNITY_EMAIL='your@email.com'"
    exit 1
fi

if [ -z "$UNITY_PASSWORD" ]; then
    echo "ОШИБКА: UNITY_PASSWORD не установлен"
    echo "Установите: export UNITY_PASSWORD='your-password'"
    exit 1
fi

# Переход в директорию проекта
cd "$(dirname "$0")/../.."

PROJECT_PATH="$(pwd)/DragRaceUnity"
BUILD_PATH="$(pwd)/Builds"

# Запуск сборки
docker run --rm \
    -v "${PROJECT_PATH}:/unity-project" \
    -v "${BUILD_PATH}:/builds" \
    -e "UNITY_EMAIL=${UNITY_EMAIL}" \
    -e "UNITY_PASSWORD=${UNITY_PASSWORD}" \
    -e "UNITY_LICENSE=${UNITY_LICENSE}" \
    -e "UNITY_PROJECT_PATH=/unity-project" \
    -e "BUILD_PATH=/builds" \
    gameci/unity-builder:2022.3-win \
    bash -c "
        cd /unity-project &&
        unity-builder \
            --projectPath /unity-project \
            --buildPath /builds \
            --buildName DragRace \
            --buildTarget Win64 \
            --versioning None \
            --logFile /builds/build.log || true
    "

echo ""
echo "============================================================================="
echo "Сборка завершена!"
echo "============================================================================="
echo ""
echo "Результат: ${BUILD_PATH}/DragRace/DragRace.exe"
echo ""
