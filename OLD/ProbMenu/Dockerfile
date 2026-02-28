# =============================================================================
# Dockerfile для ProbMenu (WinForms .NET 10)
# =============================================================================
# Многоэтапная сборка для минимизации размера финального образа
# ПРИМЕЧАНИЕ: WinForms требует Windows для выполнения.
# Этот Dockerfile используется для:
# 1. Сборки приложения (build stage)
# 2. Тестирования в CI/CD
# 3. Запуска в Windows-контейнерах (требуется Windows Server или Docker Desktop)
# =============================================================================

# Этап 1: Сборка приложения
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Копируем файл проекта для кэширования зависимостей
COPY ["ProbMenu.csproj", "./"]
RUN dotnet restore "ProbMenu.csproj"

# Копируем исходный код и собираем
COPY . .
RUN dotnet build "ProbMenu.csproj" -c Release -o /app/build

# Этап 2: Публикация
FROM build AS publish
RUN dotnet publish "ProbMenu.csproj" \
    -c Release \
    -o /app/publish \
    /p:UseAppHost=false

# Этап 3: Финальный образ
# Для WinForms требуется Windows. Используйте один из вариантов:
# 
# Вариант A: Windows-контейнер (для запуска WinForms)
# FROM mcr.microsoft.com/dotnet/runtime:10.0-nanoserver-1809
# 
# Вариант B: Linux-контейнер (только для тестов/CI)
FROM mcr.microsoft.com/dotnet/runtime:10.0 AS final

WORKDIR /app
COPY --from=publish /app/publish .

# Метки метаданных
LABEL maintainer="ProbMenu Team"
LABEL version="1.0"
LABEL description="WinForms меню приложение для Drag Racing Game"

# Переменные окружения
ENV DOTNET_ENVIRONMENT=Production

# Порт для возможных будущих веб-функций
EXPOSE 80

# Для WinForms раскомментируйте:
# ENTRYPOINT ["dotnet", "ProbMenu.dll"]
# Для тестов в CI/CD:
CMD ["dotnet", "ProbMenu.dll"]
