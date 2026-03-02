@echo off
REM ============================================
REM МОСТ ДЛЯ ДОСТУПА К ПАПКАМ QWENPOEKT
REM ============================================
REM Этот скрипт создаёт символические ссылки
REM Требуется: Запуск от имени администратора!

echo ============================================
echo Создание моста для доступа к папкам
echo ============================================
echo.

REM Проверка прав администратора
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Требуются права администратора!
    echo.
    echo Запустите этот файл от имени администратора:
    echo 1. ПКМ на create-bridge.bat
    echo 2. "Запуск от имени администратора"
    echo.
    pause
    exit /b 1
)

echo [OK] Права администратора подтверждены
echo.

REM Создание символических ссылок
echo Создание ссылок...
echo.

REM Ссылка на корень QwenPoekt
echo [1/4] D:\QwenPoekt -^> D:\QwenPoekt\Base\_EXTERNAL
if exist "D:\QwenPoekt\Base\_EXTERNAL" (
    echo   - Уже существует
) else (
    mklink /D "D:\QwenPoekt\Base\_EXTERNAL" "D:\QwenPoekt" >nul 2>&1
    if %errorLevel% equ 0 (
        echo   - Создано успешно
    ) else (
        echo   - Ошибка создания
    )
)

REM Ссылка на Projects
echo [2/4] D:\QwenPoekt\Projects -^> D:\QwenPoekt\Base\_PROJECTS
if exist "D:\QwenPoekt\Base\_PROJECTS" (
    echo   - Уже существует
) else (
    mklink /D "D:\QwenPoekt\Base\_PROJECTS" "D:\QwenPoekt\Projects" >nul 2>&1
    if %errorLevel% equ 0 (
        echo   - Создано успешно
    ) else (
        echo   - Ошибка создания
    )
)

REM Ссылка на _BACKUP
echo [3/4] D:\QwenPoekt\_BACKUP -^> D:\QwenPoekt\Base\_BACKUP_LINK
if exist "D:\QwenPoekt\Base\_BACKUP_LINK" (
    echo   - Уже существует
) else (
    mklink /D "D:\QwenPoekt\Base\_BACKUP_LINK" "D:\QwenPoekt\_BACKUP" >nul 2>&1
    if %errorLevel% equ 0 (
        echo   - Создано успешно
    ) else (
        echo   - Ошибка создания
    )
)

REM Ссылка на _TEST_ENV
echo [4/4] D:\QwenPoekt\_TEST_ENV -^> D:\QwenPoekt\Base\_TEST_ENV_LINK
if exist "D:\QwenPoekt\Base\_TEST_ENV_LINK" (
    echo   - Уже существует
) else (
    mklink /D "D:\QwenPoekt\Base\_TEST_ENV_LINK" "D:\QwenPoekt\_TEST_ENV" >nul 2>&1
    if %errorLevel% equ 0 (
        echo   - Создано успешно
    ) else (
        echo   - Ошибка создания
    )
)

echo.
echo ============================================
echo Готово!
echo ============================================
echo.
echo Теперь ИИ получит доступ к папкам через:
echo   - D:\QwenPoekt\Base\_EXTERNAL
echo   - D:\QwenPoekt\Base\_PROJECTS
echo   - D:\QwenPoekt\Base\_BACKUP_LINK
echo   - D:\QwenPoekt\Base\_TEST_ENV_LINK
echo.
pause
