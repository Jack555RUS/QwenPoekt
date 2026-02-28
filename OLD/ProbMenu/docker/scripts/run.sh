#!/bin/bash
# =============================================================================
# Docker Run Script для ProbMenu (Linux/WSL)
# =============================================================================

set -e

PROFILE="${1:-app}"
DETACH=""
if [ "$2" == "-d" ]; then
    DETACH="-d"
fi

echo "=================================================="
echo "  Docker Run - ProbMenu"
echo "  Профиль: $PROFILE"
echo "=================================================="

# Создание директорий
mkdir -p appdata Builds TestResults

# Запуск
echo -e "\nЗапуск контейнеров..."
docker compose --profile "$PROFILE" up $DETACH

echo -e "\n=================================================="
echo "  Контейнеры запущены!"
echo "=================================================="

echo -e "\nСтатус:"
docker compose ps

if [ "$PROFILE" == "dev" ] || [ "$PROFILE" == "full" ]; then
    echo -e "\nСервисы доступны:"
    echo "  Adminer (БД):  http://localhost:8080"
    echo "  Redis:         localhost:6379"
    echo "  PostgreSQL:    localhost:5432"
fi
