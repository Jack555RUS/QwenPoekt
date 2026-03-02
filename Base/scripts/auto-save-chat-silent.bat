@echo off
REM auto-save-chat-silent.bat — Тихий запуск автосохранения
REM Запускается каждые 2 минуты через Task Scheduler (скрыто)

powershell -WindowStyle Hidden -ExecutionPolicy Bypass -File "%~dp0auto-save-chat.ps1"
