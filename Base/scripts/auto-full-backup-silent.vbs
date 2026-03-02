' auto-full-backup-silent.vbs — Полностью невидимый запуск полного бэкапа
' Запускается каждые 10 минут через Task Scheduler
' Никаких окон, никакой ряби в глазах

Set objShell = CreateObject("WScript.Shell")

' Запуск PowerShell в полностью скрытом режиме
' 0 = vbHide (полностью скрыто)
' False = не ждать завершения (асинхронно)
objShell.Run "powershell -ExecutionPolicy Bypass -File ""D:\QwenPoekt\Base\scripts\auto-full-backup.ps1""", 0, False
