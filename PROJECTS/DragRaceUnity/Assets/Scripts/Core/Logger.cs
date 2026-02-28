using UnityEngine;
using System;
using System.Collections.Generic;

/// <summary>
/// Система логирования для проекта.
/// Предоставляет централизованное логирование с уровнями важности.
/// </summary>
public static class Logger
{
    /// <summary>
    /// Уровни важности логов.
    /// </summary>
    public enum LogLevel
    {
        /// <summary>
        /// Подробная информация (отладка).
        /// </summary>
        Debug,

        /// <summary>
        /// Обычная информация.
        /// </summary>
        Info,

        /// <summary>
        /// Предупреждения.
        /// </summary>
        Warning,

        /// <summary>
        /// Ошибки.
        /// </summary>
        Error
    }

    /// <summary>
    /// Текущий уровень логирования.
    /// Логи ниже этого уровня не выводятся.
    /// </summary>
    public static LogLevel CurrentLogLevel { get; set; } = LogLevel.Debug;

    /// <summary>
    /// Включить ли логи в консоли.
    /// </summary>
    public static bool Enabled { get; set; } = true;

    /// <summary>
    /// Префикс для всех логов.
    /// </summary>
    public static string Prefix { get; set; } = "[Game]";

    /// <summary>
    /// История последних логов (для отладки).
    /// </summary>
    private static readonly List<string> _logHistory = new List<string>();
    private const int MaxHistorySize = 100;

    /// <summary>
    /// Событие при добавлении лога.
    /// </summary>
    public static event Action<LogLevel, string> OnLogAdded;

    #region Public Methods

    /// <summary>
    /// Логирование отладочной информации.
    /// </summary>
    /// <param name="message">Сообщение.</param>
    /// <param name="context">Контекст (объект для ссылки в консоли).</param>
    public static void Debug(string message, UnityEngine.Object context = null)
    {
        Log(LogLevel.Debug, message, context);
    }

    /// <summary>
    /// Логирование информации.
    /// </summary>
    /// <param name="message">Сообщение.</param>
    /// <param name="context">Контекст (объект для ссылки в консоли).</param>
    public static void Info(string message, UnityEngine.Object context = null)
    {
        Log(LogLevel.Info, message, context);
    }

    /// <summary>
    /// Логирование предупреждения.
    /// </summary>
    /// <param name="message">Сообщение.</param>
    /// <param name="context">Контекст (объект для ссылки в консоли).</param>
    public static void Warning(string message, UnityEngine.Object context = null)
    {
        Log(LogLevel.Warning, message, context);
    }

    /// <summary>
    /// Логирование ошибки.
    /// </summary>
    /// <param name="message">Сообщение.</param>
    /// <param name="context">Контекст (объект для ссылки в консоли).</param>
    public static void Error(string message, UnityEngine.Object context = null)
    {
        Log(LogLevel.Error, message, context);
    }

    /// <summary>
    /// Логирование с указанием уровня важности.
    /// </summary>
    /// <param name="level">Уровень важности.</param>
    /// <param name="message">Сообщение.</param>
    /// <param name="context">Контекст (объект для ссылки в консоли).</param>
    public static void Log(LogLevel level, string message, UnityEngine.Object context = null)
    {
        if (!Enabled)
            return;

        if (level < CurrentLogLevel)
            return;

        string logMessage = FormatMessage(level, message);
        WriteLog(level, logMessage, context);
        AddToHistory(logMessage);
        OnLogAdded?.Invoke(level, logMessage);
    }

    /// <summary>
    /// Получить историю логов.
    /// </summary>
    /// <param name="count">Количество последних записей (по умолчанию все).</param>
    /// <returns>Список логов.</returns>
    public static List<string> GetHistory(int count = 0)
    {
        if (count <= 0 || count >= _logHistory.Count)
            return new List<string>(_logHistory);

        return _logHistory.GetRange(_logHistory.Count - count, count);
    }

    /// <summary>
    /// Очистить историю логов.
    /// </summary>
    public static void ClearHistory()
    {
        _logHistory.Clear();
    }

    #endregion

    #region Private Methods

    /// <summary>
    /// Форматирование сообщения.
    /// </summary>
    private static string FormatMessage(LogLevel level, string message)
    {
        string timestamp = DateTime.Now.ToString("HH:mm:ss.fff");
        string levelTag = GetLevelTag(level);
        return $"{timestamp} {Prefix} {levelTag} {message}";
    }

    /// <summary>
    /// Получить тег уровня важности.
    /// </summary>
    private static string GetLevelTag(LogLevel level)
    {
        switch (level)
        {
            case LogLevel.Debug:
                return "[DBG]";
            case LogLevel.Info:
                return "[INF]";
            case LogLevel.Warning:
                return "[WRN]";
            case LogLevel.Error:
                return "[ERR]";
            default:
                return "[???]";
        }
    }

    /// <summary>
    /// Запись лога в консоль.
    /// </summary>
    private static void WriteLog(LogLevel level, string message, UnityEngine.Object context)
    {
        switch (level)
        {
            case LogLevel.Debug:
                UnityEngine.Debug.Log(message, context);
                break;
            case LogLevel.Info:
                UnityEngine.Debug.Log(message, context);
                break;
            case LogLevel.Warning:
                UnityEngine.Debug.LogWarning(message, context);
                break;
            case LogLevel.Error:
                UnityEngine.Debug.LogError(message, context);
                break;
        }
    }

    /// <summary>
    /// Добавление лога в историю.
    /// </summary>
    private static void AddToHistory(string message)
    {
        _logHistory.Add(message);

        if (_logHistory.Count > MaxHistorySize)
        {
            _logHistory.RemoveAt(0);
        }
    }

    #endregion
}
