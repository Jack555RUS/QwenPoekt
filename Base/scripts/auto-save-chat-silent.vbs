' auto-save-chat-silent.vbs — Полностью невидимый запуск автосохранения
' Запускается каждые 2 минуты через Task Scheduler
' Никаких окон, никакой ряби в глазах

Set objShell = CreateObject("WScript.Shell")

' Запуск PowerShell в полностью скрытом режиме
' 0 = vbHide (полностью скрыто)
' False = не ждать завершения (асинхронно)
objShell.Run "powershell -ExecutionPolicy Bypass -File ""D:\QwenPoekt\Base\scripts\auto-save-chat.ps1""", 0, False
