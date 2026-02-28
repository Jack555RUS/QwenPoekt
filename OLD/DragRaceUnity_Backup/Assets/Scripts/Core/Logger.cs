using UnityEngine;
using System;
using System.Collections.Generic;

namespace ProbMenu.Core
{
    /// <summary>
    /// Единая система логирования с уровнями важности
    /// </summary>
    public static class Logger
    {
        public enum LogLevel
        {
            Debug,      // Отладочная информация
            Info,       // Обычная информация
            Warning,    // Предупреждения
            Error,      // Ошибки
            Critical    // Критические ошибки
        }

        private static readonly string TAG = "[DragRace]";
        private static readonly List<string> logHistory = new List<string>();
        private static readonly int maxHistorySize = 100;

        /// <summary>
        /// Включить/выключить логирование
        /// </summary>
        public static bool EnableDebug { get; set; } = true;
        public static bool EnableInfo { get; set; } = true;
        public static bool EnableWarning { get; set; } = true;
        public static bool EnableError { get; set; } = true;

        /// <summary>
        /// Логирование с уровнем
        /// </summary>
        public static void Log(string message, LogLevel level = LogLevel.Info)
        {
            string log = FormatMessage(message, level);
            AddToHistory(log);

            switch (level)
            {
                case LogLevel.Debug:
                    if (EnableDebug) Debug.Log(log);
                    break;
                case LogLevel.Info:
                    if (EnableInfo) Debug.Log(log);
                    break;
                case LogLevel.Warning:
                    if (EnableWarning) Debug.LogWarning(log);
                    break;
                case LogLevel.Error:
                case LogLevel.Critical:
                    if (EnableError) Debug.LogError(log);
                    break;
            }
        }

        /// <summary>
        /// Debug лог
        /// </summary>
        public static void D(string message) => Log(message, LogLevel.Debug);

        /// <summary>
        /// Info лог
        /// </summary>
        public static void I(string message) => Log(message, LogLevel.Info);

        /// <summary>
        /// Warning лог
        /// </summary>
        public static void W(string message) => Log(message, LogLevel.Warning);

        /// <summary>
        /// Error лог
        /// </summary>
        public static void E(string message) => Log(message, LogLevel.Error);

        /// <summary>
        /// Critical лог
        /// </summary>
        public static void C(string message) => Log(message, LogLevel.Critical);

        /// <summary>
        /// Лог с данными
        /// </summary>
        public static void LogData(string label, object data)
        {
            D($"{label}: {data}");
        }

        /// <summary>
        /// Лог времени выполнения
        /// </summary>
        public static void LogPerformance(string operation, double milliseconds)
        {
            string performance = milliseconds < 16 ? "✅" : milliseconds < 33 ? "⚠️" : "❌";
            D($"{performance} {operation}: {milliseconds:F2}ms");
        }

        /// <summary>
        /// Assert с логированием
        /// </summary>
        public static bool Assert(bool condition, string message = null)
        {
            if (!condition)
            {
                string errorMsg = message ?? "Assertion failed!";
                E($"ASSERT FAILED: {errorMsg}");
                Debug.Assert(false, errorMsg);
            }
            return condition;
        }

        /// <summary>
        /// Assert с сообщением и уровнем Critical
        /// </summary>
        public static bool AssertCritical(bool condition, string message)
        {
            if (!condition)
            {
                C($"CRITICAL ASSERT: {message}");
                Debug.Assert(false, message);
            }
            return condition;
        }

        /// <summary>
        /// Assert не null
        /// </summary>
        public static T AssertNotNull<T>(T obj, string name = null) where T : class
        {
            if (obj == null)
            {
                string errorMsg = name != null ? $"{name} is NULL!" : "Object is NULL!";
                E(errorMsg);
                Debug.Assert(false, errorMsg);
            }
            return obj;
        }

        /// <summary>
        /// Assert диапазона
        /// </summary>
        public static bool AssertRange(float value, float min, float max, string name = null)
        {
            if (value < min || value > max)
            {
                string errorMsg = name != null 
                    ? $"{name} = {value} (out of range [{min}, {max}])"
                    : $"Value {value} out of range [{min}, {max}]";
                E(errorMsg);
                Debug.Assert(false, errorMsg);
            }
            return value >= min && value <= max;
        }

        /// <summary>
        /// Получить историю логов
        /// </summary>
        public static string GetHistory(int count = 50)
        {
            int start = Math.Max(0, logHistory.Count - count);
            return string.Join("\n", logHistory.GetRange(start, logHistory.Count - start));
        }

        /// <summary>
        /// Очистить историю
        /// </summary>
        public static void ClearHistory()
        {
            logHistory.Clear();
        }

        /// <summary>
        /// Экспорт логов в файл
        /// </summary>
        public static void ExportToFile(string path)
        {
            try
            {
                System.IO.File.WriteAllLines(path, logHistory);
                I($"Logs exported to: {path}");
            }
            catch (Exception e)
            {
                E($"Failed to export logs: {e.Message}");
            }
        }

        private static string FormatMessage(string message, LogLevel level)
        {
            string timestamp = DateTime.Now.ToString("HH:mm:ss.fff");
            string levelTag = level switch
            {
                LogLevel.Debug => "DBG",
                LogLevel.Info => "INF",
                LogLevel.Warning => "WRN",
                LogLevel.Error => "ERR",
                LogLevel.Critical => "CRT",
                _ => "???"
            };

            return $"{TAG} [{timestamp}] [{levelTag}] {message}";
        }

        private static void AddToHistory(string log)
        {
            logHistory.Add(log);
            
            while (logHistory.Count > maxHistorySize)
            {
                logHistory.RemoveAt(0);
            }
        }
    }
}
