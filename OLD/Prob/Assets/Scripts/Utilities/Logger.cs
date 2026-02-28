using System;
using System.IO;
using UnityEngine;

namespace RacingGame.Utilities
{
    /// <summary>
    /// Система логирования с записью в файл
    /// </summary>
    public static class GameLogger
    {
        private static string _logFilePath;
        private static bool _initialized;
        private static readonly object _lockObject = new object();

        public enum LogLevel
        {
            Info,
            Warning,
            Error,
            Debug
        }

        public static void Initialize()
        {
            if (_initialized) return;

            string logsDir = Path.Combine(Application.dataPath, "..", "Logs");
            if (!Directory.Exists(logsDir))
            {
                Directory.CreateDirectory(logsDir);
            }

            string fileName = $"GameLog_{DateTime.Now:yyyy-MM-dd_HH-mm-ss}.txt";
            _logFilePath = Path.Combine(logsDir, fileName);
            _initialized = true;

            Log("=== Игра запущена ===", LogLevel.Info);
            Log($"Версия Unity: {Application.unityVersion}", LogLevel.Info);
            Log($"Разрешение: {Screen.width}x{Screen.height}", LogLevel.Info);
        }

        public static void Log(string message, LogLevel level = LogLevel.Info)
        {
            if (!_initialized) Initialize();

            string timestamp = DateTime.Now.ToString("HH:mm:ss.fff");
            string logLevel = level.ToString().ToUpper();
            string logMessage = $"[{timestamp}] [{logLevel}] {message}";

            lock (_lockObject)
            {
                try
                {
                    File.AppendAllText(_logFilePath, logMessage + Environment.NewLine);
                }
                catch (Exception ex)
                {
                    Debug.LogError($"Failed to write to log file: {ex.Message}");
                }
            }

            // Дублируем в консоль Unity
            switch (level)
            {
                case LogLevel.Info:
                    Debug.Log(logMessage);
                    break;
                case LogLevel.Warning:
                    Debug.LogWarning(logMessage);
                    break;
                case LogLevel.Error:
                    Debug.LogError(logMessage);
                    break;
                case LogLevel.Debug:
                    Debug.Log($"[DEBUG] {logMessage}");
                    break;
            }
        }

        public static void LogInfo(string message) => Log(message, LogLevel.Info);
        public static void LogWarning(string message) => Log(message, LogLevel.Warning);
        public static void LogError(string message) => Log(message, LogLevel.Error);
        public static void LogDebug(string message) => Log(message, LogLevel.Debug);
    }
}
