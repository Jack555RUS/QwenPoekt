#!/bin/bash
# =============================================================================
# Unity Build Script для Docker (Linux/WSL)
# =============================================================================

set -e

BUILD_NAME="${1:-DragRace}"
PLATFORM="${2:-Win64}"

echo "=================================================="
echo "  Unity Docker Build"
echo "  Платформа: $PLATFORM"
echo "=================================================="

# Создание директории для сборок
mkdir -p Builds

# Проверка лицензии
if [ -z "$UNITY_LICENSE" ]; then
    echo "WARNING: UNITY_LICENSE не установлена!"
    echo "Для сборки Unity требуется лицензия."
fi

# Запуск Unity Builder
echo -e "\nЗапуск Unity Builder..."
docker compose --profile unity run --rm unity-builder

echo -e "\n=================================================="
echo "  Сборка завершена!"
echo "=================================================="
echo "Путь к сборкам: ./Builds"
