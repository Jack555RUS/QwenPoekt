#!/bin/bash
# =============================================================================
# Docker Build Script для ProbMenu (Linux/WSL)
# =============================================================================

set -e

VERSION="${1:-latest}"
NO_CACHE=""
if [ "$2" == "--no-cache" ]; then
    NO_CACHE="--no-cache"
fi

echo "=================================================="
echo "  Docker Build - ProbMenu"
echo "  Версия: $VERSION"
echo "=================================================="

# Проверка Docker
echo -e "\n[1/3] Проверка Docker..."
docker --version

# Сборка образа
echo -e "\n[2/3] Сборка образа probmenu:$VERSION..."
docker build -t probmenu:$VERSION -t probmenu:latest -f Dockerfile . $NO_CACHE

# Список образов
echo -e "\n[3/3] Список образов:"
docker images | grep probmenu

echo -e "\n=================================================="
echo "  Сборка завершена успешно!"
echo "=================================================="
echo ""
echo "Использование:"
echo "  docker-compose --profile app up -d"
echo "  docker-compose --profile dev up -d"
